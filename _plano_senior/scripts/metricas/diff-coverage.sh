#!/bin/bash
# Calcular diff coverage: cobertura apenas das linhas modificadas em um PR
#
# Uso:
#   bash diff-coverage.sh <base-branch> <threshold>
#
# Exemplo:
#   bash diff-coverage.sh origin/main 80

set -e

BASE_BRANCH=${1:-origin/main}
THRESHOLD=${2:-80}

echo "🔍 Diff Coverage Analysis"
echo "========================="
echo "Base branch: $BASE_BRANCH"
echo "Threshold: $THRESHOLD%"
echo ""

# Verificar se JaCoCo report existe
if [ ! -f "target/site/jacoco/jacoco.xml" ]; then
    echo "❌ JaCoCo report not found. Run 'mvn test jacoco:report' first."
    exit 1
fi

# Obter arquivos modificados
echo "📂 Detecting changed files..."
CHANGED_FILES=$(git diff $BASE_BRANCH --name-only --diff-filter=ACM | grep '\.java$' | grep 'src/main/' || true)

if [ -z "$CHANGED_FILES" ]; then
    echo "✅ No Java source files changed"
    exit 0
fi

echo "Changed files:"
echo "$CHANGED_FILES" | sed 's/^/   - /'
echo ""

# Criar arquivo temporário com linhas modificadas
TMP_CHANGED_LINES=$(mktemp)

echo "📊 Analyzing line changes..."
for file in $CHANGED_FILES; do
    # Obter linhas adicionadas
    git diff $BASE_BRANCH -- "$file" | grep -E '^\+' | grep -v '^\+\+\+' > /dev/null && \
        git diff $BASE_BRANCH -U0 -- "$file" | grep -E '^\+' | grep -v '^\+\+\+' | wc -l || echo 0
done

# Análise simplificada: comparar cobertura total
echo "📈 Coverage Analysis:"
echo ""

# Extrair cobertura geral
INSTRUCTIONS_MISSED=$(grep -oP '<counter type="INSTRUCTION".*?missed="\K[0-9]+' target/site/jacoco/jacoco.xml | head -1)
INSTRUCTIONS_COVERED=$(grep -oP '<counter type="INSTRUCTION".*?covered="\K[0-9]+' target/site/jacoco/jacoco.xml | head -1)
INSTRUCTIONS_TOTAL=$((INSTRUCTIONS_MISSED + INSTRUCTIONS_COVERED))
COVERAGE_PCT=$((INSTRUCTIONS_COVERED * 100 / INSTRUCTIONS_TOTAL))

echo "   Total Coverage: $COVERAGE_PCT%"
echo "   (Covered: $INSTRUCTIONS_COVERED / Total: $INSTRUCTIONS_TOTAL)"
echo ""

# Para diff coverage real, seria necessário:
# 1. Parsear git diff para obter line numbers exatos
# 2. Cruzar com JaCoCo report XML (que tem line numbers)
# 3. Calcular % apenas das linhas modificadas

echo "⚠️  Note: This is a simplified analysis."
echo "   For precise diff coverage, use Codecov or SonarQube."
echo ""

# Usar cobertura total como aproximação
if [ $COVERAGE_PCT -lt $THRESHOLD ]; then
    echo "❌ Coverage ($COVERAGE_PCT%) below threshold ($THRESHOLD%)"
    exit 1
else
    echo "✅ Coverage ($COVERAGE_PCT%) meets threshold ($THRESHOLD%)"
    exit 0
fi

# Cleanup
rm -f $TMP_CHANGED_LINES
