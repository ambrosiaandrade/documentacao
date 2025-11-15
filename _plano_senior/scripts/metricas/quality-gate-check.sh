#!/bin/bash
# Validar quality gates consolidados
#
# Uso:
#   bash quality-gate-check.sh

set -e

echo "🚦 Running Quality Gate Checks"
echo "==============================="
echo ""

FAILED_CHECKS=()

# 1. Verificar se testes rodaram
if [ ! -d "target/surefire-reports" ]; then
    echo "❌ No test reports found. Run 'mvn test' first."
    exit 1
fi

# 2. Coverage
echo "📊 Checking Coverage..."
if [ -f "target/site/jacoco/jacoco.xml" ]; then
    INSTRUCTIONS_MISSED=$(grep -oP '<counter type="INSTRUCTION".*?missed="\K[0-9]+' target/site/jacoco/jacoco.xml | head -1)
    INSTRUCTIONS_COVERED=$(grep -oP '<counter type="INSTRUCTION".*?covered="\K[0-9]+' target/site/jacoco/jacoco.xml | head -1)
    
    if [ -n "$INSTRUCTIONS_MISSED" ] && [ -n "$INSTRUCTIONS_COVERED" ]; then
        INSTRUCTIONS_TOTAL=$((INSTRUCTIONS_MISSED + INSTRUCTIONS_COVERED))
        COVERAGE_PCT=$((INSTRUCTIONS_COVERED * 100 / INSTRUCTIONS_TOTAL))
        
        echo "   Coverage: $COVERAGE_PCT%"
        
        if [ $COVERAGE_PCT -lt 80 ]; then
            echo "   ❌ Coverage ($COVERAGE_PCT%) below threshold (80%)"
            FAILED_CHECKS+=("Coverage")
        else
            echo "   ✅ Coverage passed"
        fi
    else
        echo "   ⚠️  Could not parse coverage (skipping)"
    fi
else
    echo "   ⚠️  JaCoCo report not found (skipping)"
fi
echo ""

# 3. Mutation Score
echo "🧬 Checking Mutation Score..."
if [ -f "target/pit-reports/mutations.xml" ]; then
    MUTATION_SCORE=$(grep -oP 'mutationCoverage>\K[0-9]+' target/pit-reports/mutations.xml | head -1 || echo "0")
    
    if [ -n "$MUTATION_SCORE" ] && [ "$MUTATION_SCORE" != "0" ]; then
        echo "   Mutation Score: $MUTATION_SCORE%"
        
        if [ $MUTATION_SCORE -lt 70 ]; then
            echo "   ❌ Mutation score ($MUTATION_SCORE%) below threshold (70%)"
            FAILED_CHECKS+=("Mutation")
        else
            echo "   ✅ Mutation score passed"
        fi
    else
        echo "   ⚠️  Mutation score not available (skipping)"
    fi
else
    echo "   ⚠️  PITest report not found (skipping)"
fi
echo ""

# 4. Test Results
echo "🧪 Checking Test Results..."
TESTS_TOTAL=0
TESTS_FAILURES=0
TESTS_ERRORS=0

for report in target/surefire-reports/TEST-*.xml; do
    if [ -f "$report" ]; then
        TESTS=$(grep -oP 'tests="\K[0-9]+' "$report" | head -1 || echo "0")
        FAILURES=$(grep -oP 'failures="\K[0-9]+' "$report" | head -1 || echo "0")
        ERRORS=$(grep -oP 'errors="\K[0-9]+' "$report" | head -1 || echo "0")
        
        TESTS_TOTAL=$((TESTS_TOTAL + TESTS))
        TESTS_FAILURES=$((TESTS_FAILURES + FAILURES))
        TESTS_ERRORS=$((TESTS_ERRORS + ERRORS))
    fi
done

TESTS_PASSED=$((TESTS_TOTAL - TESTS_FAILURES - TESTS_ERRORS))
if [ $TESTS_TOTAL -gt 0 ]; then
    SUCCESS_RATE=$((TESTS_PASSED * 100 / TESTS_TOTAL))
else
    SUCCESS_RATE=0
fi

echo "   Total: $TESTS_TOTAL"
echo "   Passed: $TESTS_PASSED"
echo "   Failed: $((TESTS_FAILURES + TESTS_ERRORS))"
echo "   Success Rate: $SUCCESS_RATE%"

if [ $SUCCESS_RATE -lt 100 ]; then
    echo "   ❌ Tests failing"
    FAILED_CHECKS+=("Test Results")
else
    echo "   ✅ All tests passing"
fi
echo ""

# 5. Flaky Tests (verificar reruns)
echo "🎲 Checking for Flaky Tests..."
FLAKY_COUNT=$(grep -c "Flakes:" target/surefire-reports/*.xml 2>/dev/null || echo "0")

if [ "$FLAKY_COUNT" != "0" ]; then
    echo "   Flaky Tests: $FLAKY_COUNT"
    
    if [ $FLAKY_COUNT -gt 0 ]; then
        echo "   ⚠️  Flaky tests detected"
        FAILED_CHECKS+=("Flaky Tests")
    fi
else
    echo "   Flaky Tests: 0"
    echo "   ✅ No flaky tests"
fi
echo ""

# 6. Security (se disponível)
echo "🔒 Checking Security..."
if [ -f "target/dependency-check-report.xml" ]; then
    VULN_COUNT=$(grep -c "<vulnerability>" target/dependency-check-report.xml || echo "0")
    
    echo "   Vulnerabilities: $VULN_COUNT"
    
    if [ "$VULN_COUNT" != "0" ] && [ $VULN_COUNT -gt 0 ]; then
        echo "   ❌ Security vulnerabilities found"
        FAILED_CHECKS+=("Security")
    else
        echo "   ✅ No vulnerabilities"
    fi
else
    echo "   ⚠️  Security report not found (skipping)"
fi
echo ""

# Consolidar resultados
echo "==============================="
echo "📋 Summary"
echo "==============================="
echo ""

if [ ${#FAILED_CHECKS[@]} -eq 0 ]; then
    echo "✅ All quality gates passed!"
    echo ""
    exit 0
else
    echo "❌ ${#FAILED_CHECKS[@]} quality gate(s) failed:"
    for check in "${FAILED_CHECKS[@]}"; do
        echo "   - $check"
    done
    echo ""
    echo "🔍 Review the details above and fix the issues."
    echo ""
    exit 1
fi
