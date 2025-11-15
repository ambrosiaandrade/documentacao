#!/bin/bash
# Detectar testes flaky executando múltiplas vezes
#
# Uso:
#   bash detect-flaky.sh <test-pattern> <runs>
#
# Exemplo:
#   bash detect-flaky.sh "OrderServiceTest" 10
#   bash detect-flaky.sh "**/*Test" 5

set -e

TEST_PATTERN=${1:-"**/*Test"}
RUNS=${2:-10}

echo "🔍 Flaky Test Detection"
echo "======================="
echo "Test pattern: $TEST_PATTERN"
echo "Number of runs: $RUNS"
echo ""

TMP_DIR=$(mktemp -d)
FAILED_RUNS=()
PASSED_RUNS=()

for i in $(seq 1 $RUNS); do
    echo "▶️  Run $i/$RUNS..."
    
    LOG_FILE="$TMP_DIR/run-$i.log"
    
    # Executar testes
    if mvn test -Dtest="$TEST_PATTERN" > "$LOG_FILE" 2>&1; then
        echo "   ✅ Passed"
        PASSED_RUNS+=($i)
    else
        echo "   ❌ Failed"
        FAILED_RUNS+=($i)
        
        # Salvar testes que falharam
        grep -E "Tests run:|FAILURE" "$LOG_FILE" | head -5 >> "$TMP_DIR/failures.txt"
    fi
    
    # Pequeno delay entre runs
    sleep 0.5
done

echo ""
echo "📊 Results:"
echo "==========="
PASSED_COUNT=${#PASSED_RUNS[@]}
FAILED_COUNT=${#FAILED_RUNS[@]}

echo "   Passed: $PASSED_COUNT/$RUNS"
echo "   Failed: $FAILED_COUNT/$RUNS"
echo ""

# Análise
if [ $FAILED_COUNT -eq 0 ]; then
    echo "✅ No flakiness detected - test is stable!"
    rm -rf $TMP_DIR
    exit 0
    
elif [ $PASSED_COUNT -eq 0 ]; then
    echo "❌ Test consistently fails (not flaky - real bug)"
    echo ""
    echo "Sample failure output:"
    head -20 "$TMP_DIR/run-1.log"
    rm -rf $TMP_DIR
    exit 2
    
else
    echo "⚠️  FLAKY TEST DETECTED!"
    echo ""
    echo "   Test passes sometimes but fails other times."
    echo "   This indicates non-deterministic behavior."
    echo ""
    echo "Common causes:"
    echo "   - Timing dependencies (sleep, timeouts)"
    echo "   - Async operations without proper synchronization"
    echo "   - Shared state between tests"
    echo "   - Order-dependent tests"
    echo "   - Random data without seeding"
    echo ""
    
    if [ -f "$TMP_DIR/failures.txt" ]; then
        echo "Sample failures:"
        cat "$TMP_DIR/failures.txt" | head -10
    fi
    
    echo ""
    echo "📝 Action items:"
    echo "   1. Create issue to track flaky test"
    echo "   2. Investigate root cause (see common causes above)"
    echo "   3. Add @Tag(\"flaky\") and @Disabled until fixed"
    echo "   4. Consider quarantine strategy"
    echo ""
    
    rm -rf $TMP_DIR
    exit 1
fi
