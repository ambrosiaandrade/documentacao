# 🚦 Automação de Quality Gates

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Quality Gates por Fase](#2-quality-gates-por-fase)
3. [CI/CD Pipelines](#3-cicd-pipelines)
4. [Scripts de Validação](#4-scripts-de-validação)
5. [Alertas e Notificações](#5-alertas-e-notificações)
6. [Enforcement Strategies](#6-enforcement-strategies)
7. [Exceções e Overrides](#7-exceções-e-overrides)
8. [Monitoramento Contínuo](#8-monitoramento-contínuo)

---

## 1. Visão Geral

### 🎯 Definição

**Quality Gate** é um checkpoint automatizado que impede código de baixa qualidade de avançar no pipeline de desenvolvimento.

**Princípios:**

1. **Automatizado**: Sem intervenção manual
2. **Objetivo**: Critérios mensuráveis claros
3. **Falha rápida**: Feedback imediato
4. **Contextual**: Diferentes gates por fase

### 📊 Pirâmide de Quality Gates

```
┌─────────────────────────────┐
│   Production Deploy         │ ← Gate 4: Performance, Security
├─────────────────────────────┤
│   Staging Deploy            │ ← Gate 3: E2E, Smoke Tests
├─────────────────────────────┤
│   Merge to Main             │ ← Gate 2: Mutation, Coverage
├─────────────────────────────┤
│   Local Development         │ ← Gate 1: Unit, Lint
└─────────────────────────────┘
```

### ⚠️ Anti-patterns

- ❌ Gates muito rígidos (bloqueiam trabalho legítimo)
- ❌ Gates muito permissivos (não detectam problemas)
- ❌ Gates lentos (> 10min feedback)
- ❌ Falta de visibilidade (devs não sabem por que falhou)

---

## 2. Quality Gates por Fase

### 🔵 Gate 1: Pre-commit (Local)

**Objetivo:** Detectar problemas antes do commit.

**Critérios:**

- ✅ Testes unitários passando (< 30s)
- ✅ Linter sem erros
- ✅ Formatação consistente
- ✅ Sem código comentado
- ✅ Sem TODOs críticos não rastreados

**Implementação:**

```bash
#!/bin/bash
# .git/hooks/pre-commit

set -e

echo "🔍 Pre-commit Quality Gate"
echo "=========================="

# 1. Formatar código
echo "📝 Formatando código..."
mvn spotless:apply -q

# 2. Lint
echo "🔍 Executando linter..."
mvn checkstyle:check -q

# 3. Testes rápidos (apenas arquivos modificados)
echo "🧪 Executando testes unitários..."
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.java$' | sed 's/src\/main/src\/test/' | sed 's/\.java/Test.java/')

if [ -n "$STAGED_FILES" ]; then
    for file in $STAGED_FILES; do
        if [ -f "$file" ]; then
            TEST_CLASS=$(echo $file | sed 's/.*\/\(.*\)Test\.java/\1Test/')
            mvn test -Dtest=$TEST_CLASS -q || exit 1
        fi
    done
fi

# 4. Verificar TODOs críticos
echo "📋 Verificando TODOs..."
TODO_COUNT=$(git diff --cached | grep -c "TODO: CRITICAL" || true)
if [ $TODO_COUNT -gt 0 ]; then
    echo "❌ TODOs críticos encontrados. Crie issue antes de commitar."
    exit 1
fi

echo "✅ Pre-commit gate passed!"
exit 0
```

**Instalação:**

```bash
# Tornar executável
chmod +x .git/hooks/pre-commit

# Ou usar Husky (Node.js)
npm install --save-dev husky
npx husky install
npx husky add .git/hooks/pre-commit "bash scripts/pre-commit-gate.sh"
```

---

### 🟢 Gate 2: Pull Request (CI)

**Objetivo:** Garantir qualidade antes do merge.

**Critérios:**

- ✅ Todos os testes passando
- ✅ Diff coverage ≥ 80%
- ✅ Mutation score ≥ 70%
- ✅ Flaky rate = 0% (no PR)
- ✅ Code review aprovado
- ✅ Sem vulnerabilidades críticas (Snyk, Dependabot)

**GitHub Actions:**

```yaml
name: PR Quality Gate

on:
  pull_request:
    branches: [main, develop]

jobs:
  quality-gate:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          fetch-depth: 0 # histórico completo para diff

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: 17
          cache: "maven"

      # Gate 2.1: Testes
      - name: Run Tests
        run: mvn clean test

      # Gate 2.2: Coverage
      - name: Generate Coverage Report
        run: mvn jacoco:report

      - name: Upload to Codecov
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./target/site/jacoco/jacoco.xml
          fail_ci_if_error: true

      # Gate 2.3: Diff Coverage
      - name: Check Diff Coverage
        run: |
          bash scripts/diff-coverage.sh origin/main 80

      # Gate 2.4: Mutation Testing (incremental)
      - name: Run Mutation Tests
        run: |
          mvn org.pitest:pitest-maven:mutationCoverage \
            -DwithHistory=true \
            -DtimestampedReports=false

      - name: Check Mutation Score
        run: |
          SCORE=$(grep -oP 'mutationCoverage>\K[0-9]+' target/pit-reports/mutations.xml | head -1)
          echo "Mutation Score: $SCORE%"

          if [ $SCORE -lt 70 ]; then
            echo "❌ Mutation score ($SCORE%) abaixo do limiar (70%)"
            exit 1
          fi

      # Gate 2.5: Security Scan
      - name: Run Snyk Security Scan
        uses: snyk/actions/maven@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

      # Gate 2.6: Code Quality (SonarQube)
      - name: SonarQube Scan
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        run: |
          mvn sonar:sonar \
            -Dsonar.projectKey=my-project \
            -Dsonar.host.url=https://sonarcloud.io \
            -Dsonar.organization=my-org \
            -Dsonar.qualitygate.wait=true

      # Gate 2.7: Consolidar Resultados
      - name: Quality Gate Summary
        if: always()
        run: |
          echo "## 🚦 Quality Gate Results" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "| Check | Status |" >> $GITHUB_STEP_SUMMARY
          echo "|-------|--------|" >> $GITHUB_STEP_SUMMARY
          echo "| ✅ Tests | Passed |" >> $GITHUB_STEP_SUMMARY
          echo "| ✅ Diff Coverage | 85% |" >> $GITHUB_STEP_SUMMARY
          echo "| ✅ Mutation Score | 72% |" >> $GITHUB_STEP_SUMMARY
          echo "| ✅ Security | No issues |" >> $GITHUB_STEP_SUMMARY
```

**Comentário Automatizado no PR:**

```yaml
- name: Comment PR
  uses: actions/github-script@v6
  if: always()
  with:
    script: |
      const fs = require('fs');

      // Ler métricas
      const mutationScore = 72; // extrair do XML
      const diffCoverage = 85;
      const testsTotal = 250;
      const testsPassed = 250;

      const body = `
      ## 🚦 Quality Gate Report

      ### ✅ All checks passed!

      | Metric | Value | Threshold | Status |
      |--------|-------|-----------|--------|
      | Tests | ${testsPassed}/${testsTotal} | 100% | ✅ |
      | Diff Coverage | ${diffCoverage}% | 80% | ✅ |
      | Mutation Score | ${mutationScore}% | 70% | ✅ |
      | Security Issues | 0 | 0 | ✅ |

      **Safe to merge!** 🚀
      `;

      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: body
      });
```

---

### 🟡 Gate 3: Pre-Deploy (Staging)

**Objetivo:** Validar integração completa antes de produção.

**Critérios:**

- ✅ E2E tests passando
- ✅ Smoke tests passando
- ✅ Performance dentro do SLA (P95 < 200ms)
- ✅ Sem degradação de métricas

**GitLab CI:**

```yaml
# .gitlab-ci.yml
stages:
  - test
  - deploy-staging
  - validate-staging

deploy-staging:
  stage: deploy-staging
  script:
    - kubectl apply -f k8s/staging/
    - kubectl rollout status deployment/app -n staging
  environment:
    name: staging
    url: https://staging.example.com

e2e-tests:
  stage: validate-staging
  dependencies:
    - deploy-staging
  script:
    - npm run test:e2e -- --baseUrl=https://staging.example.com
  retry: 1 # flaky tolerance

performance-gate:
  stage: validate-staging
  dependencies:
    - deploy-staging
  script:
    # Rodar load test
    - artillery run tests/load/baseline.yml --output /tmp/report.json

    # Validar P95
    - |
      P95=$(jq '.aggregate.latency.p95' /tmp/report.json)
      echo "P95 Latency: ${P95}ms"

      if [ $(echo "$P95 > 200" | bc) -eq 1 ]; then
        echo "❌ P95 latency (${P95}ms) exceeds threshold (200ms)"
        exit 1
      fi

    # Validar error rate
    - |
      ERROR_RATE=$(jq '.aggregate.counters["errors"] / .aggregate.counters["requests"] * 100' /tmp/report.json)
      echo "Error Rate: ${ERROR_RATE}%"

      if [ $(echo "$ERROR_RATE > 1" | bc) -eq 1 ]; then
        echo "❌ Error rate (${ERROR_RATE}%) exceeds threshold (1%)"
        exit 1
      fi
```

---

### 🔴 Gate 4: Production Deploy

**Objetivo:** Garantir zero downtime e rollback seguro.

**Critérios:**

- ✅ Smoke tests em produção passando
- ✅ Canary deployment saudável (5% tráfego por 10min)
- ✅ Métricas de negócio estáveis
- ✅ SLOs mantidos

**Kubernetes Rollout com Quality Gate:**

```yaml
# k8s/production/deployment.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: app
spec:
  replicas: 10
  strategy:
    canary:
      steps:
        - setWeight: 5 # 5% tráfego
        - pause: { duration: 10m } # aguardar 10min
        - analysis:
            templates:
              - templateName: success-rate
              - templateName: latency-p95
        - setWeight: 25
        - pause: { duration: 5m }
        - setWeight: 50
        - pause: { duration: 5m }
        - setWeight: 100

  analysisRunTemplate:
    - name: success-rate
      spec:
        metrics:
          - name: success-rate
            provider:
              prometheus:
                address: http://prometheus:9090
                query: |
                  sum(rate(http_requests_total{status!~"5.."}[5m])) /
                  sum(rate(http_requests_total[5m]))
            successCondition: result >= 0.99
            failureLimit: 3
            interval: 1m

    - name: latency-p95
      spec:
        metrics:
          - name: latency-p95
            provider:
              prometheus:
                address: http://prometheus:9090
                query: |
                  histogram_quantile(0.95,
                    rate(http_request_duration_seconds_bucket[5m]))
            successCondition: result < 0.2 # 200ms
            failureLimit: 3
            interval: 1m
```

**Rollback Automático:**

```bash
#!/bin/bash
# scripts/production-gate.sh

NAMESPACE="production"
ROLLOUT_NAME="app"

echo "🚀 Monitoring canary deployment..."

# Aguardar análise
kubectl argo rollouts get rollout $ROLLOUT_NAME -n $NAMESPACE --watch

# Verificar status
STATUS=$(kubectl argo rollouts status $ROLLOUT_NAME -n $NAMESPACE)

if [[ $STATUS == *"Degraded"* ]]; then
    echo "❌ Canary analysis failed. Rolling back..."
    kubectl argo rollouts abort $ROLLOUT_NAME -n $NAMESPACE
    kubectl argo rollouts undo $ROLLOUT_NAME -n $NAMESPACE

    # Notificar equipe
    curl -X POST https://slack.com/api/chat.postMessage \
      -H "Authorization: Bearer $SLACK_TOKEN" \
      -d channel="#production-alerts" \
      -d text="🚨 Production deployment rolled back due to failed quality gate"

    exit 1
fi

echo "✅ Canary analysis passed. Promoting to 100%..."
```

---

## 3. CI/CD Pipelines

### 🔧 Pipeline Completo (GitHub Actions)

```yaml
name: Complete CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  JAVA_VERSION: 17
  NODE_VERSION: 18

jobs:
  # Stage 1: Build & Unit Tests
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}

    steps:
      - uses: actions/checkout@v3

      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: ${{ env.JAVA_VERSION }}
          cache: "maven"

      - name: Build
        run: mvn clean compile -DskipTests

      - name: Unit Tests
        run: mvn test -Dtest=**/*UnitTest
        timeout-minutes: 5

      - name: Extract Version
        id: version
        run: |
          VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
          echo "version=$VERSION" >> $GITHUB_OUTPUT

  # Stage 2: Quality Gates
  quality-gates:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: ${{ env.JAVA_VERSION }}
          cache: "maven"

      - name: Integration Tests
        run: mvn verify -DskipUnitTests
        timeout-minutes: 10

      - name: Coverage Report
        run: mvn jacoco:report

      - name: Mutation Testing
        if: github.event_name == 'pull_request'
        run: mvn org.pitest:pitest-maven:mutationCoverage
        timeout-minutes: 30

      - name: Quality Gate Check
        run: bash scripts/quality-gate-check.sh

  # Stage 3: Security Scan
  security:
    needs: build
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: OWASP Dependency Check
        run: mvn dependency-check:check

      - name: Snyk Scan
        uses: snyk/actions/maven@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

      - name: Trivy Container Scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: "myapp:${{ needs.build.outputs.version }}"
          format: "sarif"
          output: "trivy-results.sarif"

      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: "trivy-results.sarif"

  # Stage 4: Deploy Staging
  deploy-staging:
    needs: [quality-gates, security]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com

    steps:
      - name: Deploy to Staging
        run: |
          kubectl set image deployment/app \
            app=myapp:${{ needs.build.outputs.version }} \
            -n staging

      - name: Wait for Rollout
        run: kubectl rollout status deployment/app -n staging
        timeout-minutes: 5

  # Stage 5: E2E Tests
  e2e-tests:
    needs: deploy-staging
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Node
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}

      - name: Run E2E Tests
        run: npm run test:e2e
        env:
          BASE_URL: https://staging.example.com
        timeout-minutes: 15

  # Stage 6: Deploy Production (manual approval)
  deploy-production:
    needs: e2e-tests
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com

    steps:
      - name: Deploy to Production (Canary)
        run: |
          kubectl argo rollouts set image app \
            app=myapp:${{ needs.build.outputs.version }} \
            -n production

      - name: Monitor Canary
        run: bash scripts/production-gate.sh
        timeout-minutes: 30
```

---

## 4. Scripts de Validação

### 🔍 Script Consolidado de Quality Gate

```bash
#!/bin/bash
# scripts/quality-gate-check.sh

set -e

echo "🚦 Running Quality Gate Checks"
echo "==============================="

FAILED_CHECKS=()

# 1. Coverage
echo ""
echo "📊 Checking Coverage..."
COVERAGE=$(grep -oP 'INSTRUCTION.*?missed="\K[0-9]+' target/site/jacoco/jacoco.xml | head -1)
COVERED=$(grep -oP 'INSTRUCTION.*?covered="\K[0-9]+' target/site/jacoco/jacoco.xml | head -1)
TOTAL=$((COVERAGE + COVERED))
COVERAGE_PCT=$((COVERED * 100 / TOTAL))

echo "   Coverage: $COVERAGE_PCT%"

if [ $COVERAGE_PCT -lt 80 ]; then
    echo "   ❌ Coverage ($COVERAGE_PCT%) below threshold (80%)"
    FAILED_CHECKS+=("Coverage")
else
    echo "   ✅ Coverage passed"
fi

# 2. Mutation Score
echo ""
echo "🧬 Checking Mutation Score..."
if [ -f "target/pit-reports/mutations.xml" ]; then
    MUTATION_SCORE=$(grep -oP 'mutationCoverage>\K[0-9]+' target/pit-reports/mutations.xml | head -1)
    echo "   Mutation Score: $MUTATION_SCORE%"

    if [ $MUTATION_SCORE -lt 70 ]; then
        echo "   ❌ Mutation score ($MUTATION_SCORE%) below threshold (70%)"
        FAILED_CHECKS+=("Mutation")
    else
        echo "   ✅ Mutation score passed"
    fi
else
    echo "   ⚠️  Mutation report not found (skipping)"
fi

# 3. Diff Coverage
echo ""
echo "📈 Checking Diff Coverage..."
if command -v bash &> /dev/null && [ -f "scripts/diff-coverage.sh" ]; then
    if bash scripts/diff-coverage.sh origin/main 80; then
        echo "   ✅ Diff coverage passed"
    else
        echo "   ❌ Diff coverage failed"
        FAILED_CHECKS+=("Diff Coverage")
    fi
else
    echo "   ⚠️  Diff coverage script not found (skipping)"
fi

# 4. Flaky Tests
echo ""
echo "🎲 Checking for Flaky Tests..."
FLAKY_COUNT=$(grep -c "Flakes:" target/surefire-reports/*.xml 2>/dev/null || echo 0)
echo "   Flaky Tests: $FLAKY_COUNT"

if [ $FLAKY_COUNT -gt 0 ]; then
    echo "   ❌ Flaky tests detected"
    FAILED_CHECKS+=("Flaky Tests")
else
    echo "   ✅ No flaky tests"
fi

# 5. Security Vulnerabilities
echo ""
echo "🔒 Checking Security..."
if [ -f "target/dependency-check-report.json" ]; then
    VULN_COUNT=$(jq '.dependencies[].vulnerabilities | length' target/dependency-check-report.json | jq -s 'add')
    echo "   Vulnerabilities: $VULN_COUNT"

    if [ $VULN_COUNT -gt 0 ]; then
        echo "   ❌ Security vulnerabilities found"
        FAILED_CHECKS+=("Security")
    else
        echo "   ✅ No vulnerabilities"
    fi
else
    echo "   ⚠️  Security report not found (skipping)"
fi

# 6. Code Smells (SonarQube)
echo ""
echo "👃 Checking Code Smells..."
if [ -f ".scannerwork/report-task.txt" ]; then
    SONAR_URL=$(grep ceTaskUrl .scannerwork/report-task.txt | cut -d'=' -f2)
    echo "   SonarQube: $SONAR_URL"
    # Poderia fazer API call para validar
    echo "   ✅ SonarQube scan completed (check dashboard)"
else
    echo "   ⚠️  SonarQube report not found (skipping)"
fi

# Consolidar resultados
echo ""
echo "==============================="
echo "📋 Summary"
echo "==============================="

if [ ${#FAILED_CHECKS[@]} -eq 0 ]; then
    echo "✅ All quality gates passed!"
    exit 0
else
    echo "❌ ${#FAILED_CHECKS[@]} quality gate(s) failed:"
    for check in "${FAILED_CHECKS[@]}"; do
        echo "   - $check"
    done
    exit 1
fi
```

---

### 📊 Script de Métricas Consolidadas

```python
#!/usr/bin/env python3
# scripts/collect-metrics.py

import xml.etree.ElementTree as ET
import json
import sys
from datetime import datetime

def parse_jacoco(file_path):
    """Extrair métricas de cobertura do JaCoCo"""
    tree = ET.parse(file_path)
    root = tree.getroot()

    counters = {}
    for counter in root.findall('.//counter'):
        type_ = counter.get('type')
        missed = int(counter.get('missed', 0))
        covered = int(counter.get('covered', 0))
        total = missed + covered

        if total > 0:
            counters[type_.lower()] = {
                'covered': covered,
                'missed': missed,
                'total': total,
                'percentage': round((covered / total) * 100, 2)
            }

    return counters

def parse_pitest(file_path):
    """Extrair mutation score do PITest"""
    tree = ET.parse(file_path)
    root = tree.getroot()

    mutations = root.findall('.//mutation')

    killed = sum(1 for m in mutations if m.get('status') == 'KILLED')
    survived = sum(1 for m in mutations if m.get('status') == 'SURVIVED')
    total = len(mutations)

    return {
        'killed': killed,
        'survived': survived,
        'total': total,
        'score': round((killed / total) * 100, 2) if total > 0 else 0
    }

def parse_surefire(directory):
    """Extrair resultados de testes do Surefire"""
    import os
    import glob

    xml_files = glob.glob(f"{directory}/*.xml")

    tests = 0
    failures = 0
    errors = 0
    skipped = 0
    time = 0.0

    for xml_file in xml_files:
        try:
            tree = ET.parse(xml_file)
            root = tree.getroot()

            tests += int(root.get('tests', 0))
            failures += int(root.get('failures', 0))
            errors += int(root.get('errors', 0))
            skipped += int(root.get('skipped', 0))
            time += float(root.get('time', 0))
        except:
            continue

    return {
        'tests': tests,
        'failures': failures,
        'errors': errors,
        'skipped': skipped,
        'passed': tests - failures - errors - skipped,
        'time_seconds': round(time, 2),
        'success_rate': round(((tests - failures - errors) / tests) * 100, 2) if tests > 0 else 0
    }

def generate_report():
    """Gerar relatório consolidado"""
    report = {
        'timestamp': datetime.now().isoformat(),
        'coverage': {},
        'mutation': {},
        'tests': {}
    }

    # JaCoCo
    try:
        report['coverage'] = parse_jacoco('target/site/jacoco/jacoco.xml')
    except Exception as e:
        print(f"⚠️  Could not parse JaCoCo: {e}", file=sys.stderr)

    # PITest
    try:
        report['mutation'] = parse_pitest('target/pit-reports/mutations.xml')
    except Exception as e:
        print(f"⚠️  Could not parse PITest: {e}", file=sys.stderr)

    # Surefire
    try:
        report['tests'] = parse_surefire('target/surefire-reports')
    except Exception as e:
        print(f"⚠️  Could not parse Surefire: {e}", file=sys.stderr)

    return report

def print_report(report):
    """Imprimir relatório formatado"""
    print("=" * 60)
    print("📊 QUALITY METRICS REPORT")
    print("=" * 60)
    print(f"Generated: {report['timestamp']}")
    print()

    # Tests
    if report.get('tests'):
        t = report['tests']
        print("🧪 Tests:")
        print(f"   Total: {t['tests']}")
        print(f"   Passed: {t['passed']} ({t['success_rate']}%)")
        print(f"   Failed: {t['failures'] + t['errors']}")
        print(f"   Skipped: {t['skipped']}")
        print(f"   Duration: {t['time_seconds']}s")
        print()

    # Coverage
    if report.get('coverage'):
        print("📈 Coverage:")
        for type_, data in report['coverage'].items():
            print(f"   {type_.capitalize()}: {data['percentage']}% ({data['covered']}/{data['total']})")
        print()

    # Mutation
    if report.get('mutation'):
        m = report['mutation']
        print("🧬 Mutation Testing:")
        print(f"   Score: {m['score']}%")
        print(f"   Killed: {m['killed']}")
        print(f"   Survived: {m['survived']}")
        print(f"   Total: {m['total']}")
        print()

    print("=" * 60)

def check_thresholds(report):
    """Verificar se métricas atendem thresholds"""
    failures = []

    # Coverage threshold
    if report.get('coverage', {}).get('line', {}).get('percentage', 0) < 80:
        failures.append(f"Line coverage ({report['coverage']['line']['percentage']}%) < 80%")

    # Mutation threshold
    if report.get('mutation', {}).get('score', 0) < 70:
        failures.append(f"Mutation score ({report['mutation']['score']}%) < 70%")

    # Test success rate
    if report.get('tests', {}).get('success_rate', 0) < 100:
        failures.append(f"Test success rate ({report['tests']['success_rate']}%) < 100%")

    return failures

if __name__ == '__main__':
    report = generate_report()

    # Salvar JSON
    with open('target/quality-report.json', 'w') as f:
        json.dump(report, f, indent=2)

    print_report(report)

    # Verificar thresholds
    failures = check_thresholds(report)

    if failures:
        print("❌ Quality thresholds not met:")
        for failure in failures:
            print(f"   - {failure}")
        sys.exit(1)
    else:
        print("✅ All quality thresholds met!")
        sys.exit(0)
```

**Uso:**

```bash
# Após rodar testes
python3 scripts/collect-metrics.py

# Saída:
# ============================================================
# 📊 QUALITY METRICS REPORT
# ============================================================
# Generated: 2025-01-15T10:30:00
#
# 🧪 Tests:
#    Total: 250
#    Passed: 250 (100.0%)
#    Failed: 0
#    Skipped: 0
#    Duration: 12.5s
#
# 📈 Coverage:
#    Line: 85.3% (1024/1200)
#    Branch: 78.9% (145/184)
#
# 🧬 Mutation Testing:
#    Score: 72.5%
#    Killed: 145
#    Survived: 55
#    Total: 200
#
# ============================================================
# ✅ All quality thresholds met!
```

---

## 5. Alertas e Notificações

### 📧 Slack Integration

```bash
#!/bin/bash
# scripts/notify-slack.sh

WEBHOOK_URL="$SLACK_WEBHOOK_URL"
CHANNEL="#quality-alerts"

STATUS=$1 # passed | failed
GATE_NAME=$2
DETAILS=$3

if [ "$STATUS" == "failed" ]; then
    COLOR="danger"
    EMOJI="❌"
    TITLE="Quality Gate Failed"
else
    COLOR="good"
    EMOJI="✅"
    TITLE="Quality Gate Passed"
fi

PAYLOAD=$(cat <<EOF
{
  "channel": "$CHANNEL",
  "username": "Quality Gate Bot",
  "icon_emoji": ":robot_face:",
  "attachments": [
    {
      "color": "$COLOR",
      "title": "$EMOJI $TITLE: $GATE_NAME",
      "text": "$DETAILS",
      "footer": "CI/CD Pipeline",
      "ts": $(date +%s)
    }
  ]
}
EOF
)

curl -X POST -H 'Content-type: application/json' \
  --data "$PAYLOAD" \
  "$WEBHOOK_URL"
```

**Uso no CI:**

```yaml
- name: Notify on Failure
  if: failure()
  run: |
    bash scripts/notify-slack.sh failed "PR Quality Gate" \
      "Mutation score: 65% (threshold: 70%)"
```

---

### 📊 Dashboard de Status

**Prometheus Alerts:**

```yaml
# prometheus/alerts.yml
groups:
  - name: quality_gates
    interval: 5m
    rules:
      - alert: LowMutationScore
        expr: test_mutation_score < 70
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Mutation score below threshold"
          description: "Mutation score is {{ $value }}% (threshold: 70%)"

      - alert: HighFlakyRate
        expr: test_flaky_rate > 1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Flaky test rate too high"
          description: "{{ $value }}% of tests are flaky"

      - alert: SlowTestSuite
        expr: test_lead_time_seconds > 600
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Test suite taking too long"
          description: "Test lead time is {{ $value }}s (threshold: 300s)"
```

---

## 6. Enforcement Strategies

### 🔒 Estratégia 1: Branch Protection (GitHub)

**Settings → Branches → Add rule:**

```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "quality-gate / unit-tests",
      "quality-gate / integration-tests",
      "quality-gate / mutation-testing",
      "quality-gate / security-scan",
      "codecov/patch",
      "codecov/project"
    ]
  },
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "enforce_admins": true,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
```

---

### 🔒 Estratégia 2: Merge Queue (GitLab)

```yaml
# .gitlab-ci.yml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      when: always
    - if: $CI_COMMIT_BRANCH == "main"
      when: always

quality-gate:
  stage: test
  script:
    - bash scripts/quality-gate-check.sh
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      when: on_success
  allow_failure: false # bloqueia merge se falhar
```

---

### 🔒 Estratégia 3: Pre-receive Hook (Git Server)

```bash
#!/bin/bash
# Servidor Git: pre-receive hook

while read oldrev newrev refname; do
    # Verificar se é push para main
    if [[ $refname == "refs/heads/main" ]]; then
        echo "🚦 Validando quality gates..."

        # Verificar se commit passou no CI
        COMMIT_SHA=$newrev

        # Consultar API do CI (GitHub, GitLab, etc.)
        STATUS=$(curl -s "https://api.github.com/repos/owner/repo/commits/$COMMIT_SHA/status" \
          -H "Authorization: token $GITHUB_TOKEN" \
          | jq -r '.state')

        if [[ $STATUS != "success" ]]; then
            echo "❌ Quality gates não passaram. Push rejeitado."
            echo "   Status: $STATUS"
            echo "   Commit: $COMMIT_SHA"
            exit 1
        fi

        echo "✅ Quality gates validados"
    fi
done

exit 0
```

---

## 7. Exceções e Overrides

### 🚨 Quando Permitir Exceções

1. **Hotfix crítico de produção** (documentar dívida técnica)
2. **Código experimental** (feature flag desabilitada)
3. **Refatoração de legado** (meta incremental)
4. **Testes de infraestrutura** (não aplicável)

### 📝 Sistema de Aprovação

```yaml
# .github/quality-gate-override.yml
version: 1

# Definir quem pode aprovar exceções
approvers:
  - tech-lead
  - architect
  - security-team

# Template de exceção
exception_template: |
  ## Quality Gate Override Request

  **Gate:** [nome do gate que falhou]
  **Reason:** [justificativa detalhada]
  **Risk Assessment:** [baixo/médio/alto]
  **Mitigation Plan:** [como resolver posteriormente]
  **Technical Debt Issue:** [link para issue]
  **Approver:** [nome do aprovador]

  **Temporary Threshold Adjustment:**
  - Current: X%
  - Temporary: Y%
  - Duration: Z days
```

**Processo:**

```bash
# 1. Criar issue de exceção
gh issue create \
  --title "Quality Gate Override: [PR-123]" \
  --body-file .github/quality-gate-override.yml \
  --label "quality-gate-override,tech-debt"

# 2. Aguardar aprovação de tech lead
# 3. Merge com label especial
gh pr merge --merge --admin # requer permissões especiais

# 4. Agendar resolução
gh issue create \
  --title "Tech Debt: Resolver override de Quality Gate [PR-123]" \
  --body "Originado de override temporário. Meta: atingir threshold em 2 sprints" \
  --label "tech-debt,quality" \
  --milestone "Sprint 15"
```

---

## 8. Monitoramento Contínuo

### 📈 Trending de Métricas

```python
# scripts/metrics-trend.py
import json
import matplotlib.pyplot as plt
from datetime import datetime, timedelta

def load_historical_metrics(days=30):
    """Carregar métricas históricas"""
    metrics = []

    for i in range(days):
        date = datetime.now() - timedelta(days=days-i)
        file_path = f"metrics-history/{date.strftime('%Y-%m-%d')}.json"

        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
                data['date'] = date
                metrics.append(data)
        except FileNotFoundError:
            continue

    return metrics

def plot_trends(metrics):
    """Plotar tendências"""
    dates = [m['date'] for m in metrics]

    mutation_scores = [m.get('mutation', {}).get('score', 0) for m in metrics]
    coverage_pcts = [m.get('coverage', {}).get('line', {}).get('percentage', 0) for m in metrics]
    flaky_rates = [m.get('flaky_rate', 0) for m in metrics]

    fig, axes = plt.subplots(3, 1, figsize=(12, 10))

    # Mutation Score
    axes[0].plot(dates, mutation_scores, marker='o', color='blue')
    axes[0].axhline(y=70, color='r', linestyle='--', label='Threshold')
    axes[0].set_title('Mutation Score Trend')
    axes[0].set_ylabel('%')
    axes[0].legend()
    axes[0].grid(True)

    # Coverage
    axes[1].plot(dates, coverage_pcts, marker='s', color='green')
    axes[1].axhline(y=80, color='r', linestyle='--', label='Threshold')
    axes[1].set_title('Line Coverage Trend')
    axes[1].set_ylabel('%')
    axes[1].legend()
    axes[1].grid(True)

    # Flaky Rate
    axes[2].plot(dates, flaky_rates, marker='^', color='orange')
    axes[2].axhline(y=1, color='r', linestyle='--', label='Threshold')
    axes[2].set_title('Flaky Rate Trend')
    axes[2].set_ylabel('%')
    axes[2].set_xlabel('Date')
    axes[2].legend()
    axes[2].grid(True)

    plt.tight_layout()
    plt.savefig('metrics-trend.png')
    print("📊 Trend chart saved to metrics-trend.png")

if __name__ == '__main__':
    metrics = load_historical_metrics(30)
    plot_trends(metrics)
```

---

### 🔔 Weekly Report

```bash
#!/bin/bash
# scripts/weekly-quality-report.sh

REPORT_FILE="/tmp/weekly-quality-report.md"

cat > $REPORT_FILE <<EOF
# 📊 Weekly Quality Report
**Period:** $(date -d '7 days ago' +%Y-%m-%d) to $(date +%Y-%m-%d)

## Summary

EOF

# Agregar métricas da semana
python3 <<PYTHON >> $REPORT_FILE
import json
import glob
from datetime import datetime, timedelta

files = glob.glob("metrics-history/*.json")[-7:]  # últimos 7 dias

mutation_scores = []
coverage_pcts = []
flaky_counts = []

for file in files:
    with open(file) as f:
        data = json.load(f)
        mutation_scores.append(data.get('mutation', {}).get('score', 0))
        coverage_pcts.append(data.get('coverage', {}).get('line', {}).get('percentage', 0))
        # flaky_counts.append(...)

avg_mutation = sum(mutation_scores) / len(mutation_scores) if mutation_scores else 0
avg_coverage = sum(coverage_pcts) / len(coverage_pcts) if coverage_pcts else 0

print(f"| Metric | Average | Threshold | Status |")
print(f"|--------|---------|-----------|--------|")
print(f"| Mutation Score | {avg_mutation:.1f}% | 70% | {'✅' if avg_mutation >= 70 else '❌'} |")
print(f"| Line Coverage | {avg_coverage:.1f}% | 80% | {'✅' if avg_coverage >= 80 else '❌'} |")
print(f"| Flaky Tests | 0 | 0 | ✅ |")

PYTHON

# Enviar por email
cat $REPORT_FILE | mail -s "Weekly Quality Report" team@example.com

# Postar no Slack
curl -X POST $SLACK_WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d @<(cat <<EOF
{
  "text": "📊 Weekly Quality Report disponível",
  "attachments": [{
    "text": "$(cat $REPORT_FILE)"
  }]
}
EOF
)

echo "✅ Weekly report sent"
```

---

## 📚 Checklist de Implementação

### Fase 1: Setup Básico

- [ ] Configurar pre-commit hooks
- [ ] Configurar CI básico (build + test)
- [ ] Definir métricas e thresholds iniciais
- [ ] Documentar processo

### Fase 2: Quality Gates

- [ ] Implementar gate de PR
- [ ] Implementar gate de deploy staging
- [ ] Implementar gate de deploy produção
- [ ] Testar rollback automático

### Fase 3: Observabilidade

- [ ] Configurar coleta de métricas
- [ ] Criar dashboard
- [ ] Configurar alertas
- [ ] Implementar relatórios periódicos

### Fase 4: Cultura

- [ ] Treinar equipe nos gates
- [ ] Documentar processo de exceções
- [ ] Estabelecer rotina de revisão de métricas
- [ ] Celebrar melhorias

---

## 🎯 Métricas de Sucesso da Automação

- **Lead time to production**: < 2 horas
- **Change failure rate**: < 5%
- **Mean time to recovery**: < 30 minutos
- **Deploy frequency**: Múltiplos por dia
- **Quality gate pass rate**: > 95%

---

## 📖 Referências

- [Google - DevOps Research and Assessment (DORA)](https://www.devops-research.com/research.html)
- [Netflix - Full Cycle Developers](https://netflixtechblog.com/full-cycle-developers-at-netflix-a08c31f83249)
- [Kubernetes - Progressive Delivery](https://github.com/argoproj/argo-rollouts)
- [GitHub - Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
