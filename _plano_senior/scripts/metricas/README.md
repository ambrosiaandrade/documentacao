# 📊 Scripts de Métricas de Qualidade

Este diretório contém scripts práticos para coleta, análise e visualização de métricas de qualidade de testes.

## 📂 Estrutura

- `collect-metrics.py` - Coletar métricas de múltiplas fontes (JaCoCo, PITest, Surefire)
- `diff-coverage.sh` - Calcular diff coverage de um PR
- `detect-flaky.sh` - Detectar testes flaky através de múltiplas execuções
- `quality-gate-check.sh` - Validar quality gates consolidados
- `metrics-trend.py` - Gerar gráficos de tendência de métricas
- `weekly-report.sh` - Gerar relatório semanal de qualidade

## 🚀 Uso Rápido

### Coletar Métricas

```bash
# Após rodar testes
python3 scripts/metricas/collect-metrics.py

# Saída: target/quality-report.json
```

### Verificar Diff Coverage

```bash
# Comparar com branch main, threshold 80%
bash scripts/metricas/diff-coverage.sh origin/main 80
```

### Detectar Flaky Tests

```bash
# Rodar teste 10 vezes
bash scripts/metricas/detect-flaky.sh "OrderServiceTest" 10
```

### Quality Gate Check

```bash
# Validar todos os gates
bash scripts/metricas/quality-gate-check.sh
```

### Trending

```bash
# Gerar gráficos dos últimos 30 dias
python3 scripts/metricas/metrics-trend.py
```

## 📋 Pré-requisitos

### Python

```bash
pip install -r requirements.txt
```

### Bash

- `jq` - Parser JSON
- `bc` - Calculadora
- `git` - Controle de versão

### Maven Plugins

- JaCoCo
- PITest
- Surefire

## 🔧 Configuração

### 1. Estrutura de Diretórios

```
project/
├── target/
│   ├── site/jacoco/jacoco.xml
│   ├── pit-reports/mutations.xml
│   └── surefire-reports/*.xml
├── scripts/
│   └── metricas/
│       └── (estes scripts)
└── metrics-history/
    └── YYYY-MM-DD.json
```

### 2. Variáveis de Ambiente

```bash
# .env
GITHUB_TOKEN=ghp_xxx
SLACK_WEBHOOK_URL=https://hooks.slack.com/xxx
SONAR_TOKEN=xxx
```

## 📊 Métricas Coletadas

### 1. Cobertura (JaCoCo)

- Line coverage
- Branch coverage
- Instruction coverage
- Method coverage

### 2. Mutation Testing (PITest)

- Mutation score
- Mutantes mortos
- Mutantes sobreviventes
- Mutantes por classe

### 3. Testes (Surefire)

- Total de testes
- Testes passando
- Testes falhando
- Testes pulados
- Tempo de execução

### 4. Flakiness

- Taxa de flakiness
- Testes flaky identificados
- Padrões de falha

### 5. Performance

- Lead time de testes
- Tempo por suite
- Percentis (P50, P95, P99)

## 🎯 Quality Gates Padrão

| Métrica           | Threshold | Ação           |
| ----------------- | --------- | -------------- |
| Line Coverage     | ≥ 80%     | Bloquear merge |
| Mutation Score    | ≥ 70%     | Bloquear merge |
| Diff Coverage     | ≥ 80%     | Bloquear merge |
| Flaky Rate        | 0%        | Alerta         |
| Test Success Rate | 100%      | Bloquear merge |

## 📈 Exemplos de Uso

### CI/CD Integration (GitHub Actions)

```yaml
- name: Collect Metrics
  run: python3 scripts/metricas/collect-metrics.py

- name: Check Quality Gates
  run: bash scripts/metricas/quality-gate-check.sh

- name: Upload Report
  uses: actions/upload-artifact@v3
  with:
    name: quality-report
    path: target/quality-report.json
```

### Local Development

```bash
# Antes de fazer commit
bash scripts/metricas/quality-gate-check.sh

# Se passar
git commit -m "feat: nova funcionalidade"
```

### Weekly Monitoring

```bash
# Cron job (todo domingo às 9h)
0 9 * * 0 bash /path/to/scripts/metricas/weekly-report.sh
```

## 🔍 Troubleshooting

### "Relatório não encontrado"

- Verifique se os testes foram executados: `mvn test`
- Verifique se os plugins estão configurados no `pom.xml`

### "jq: command not found"

```bash
# Ubuntu/Debian
sudo apt-get install jq

# MacOS
brew install jq

# Windows (Git Bash)
# Baixar de: https://stedolan.github.io/jq/download/
```

### "Python module not found"

```bash
pip install -r scripts/metricas/requirements.txt
```

## 📚 Referências

- [JaCoCo Documentation](https://www.jacoco.org/jacoco/trunk/doc/)
- [PITest Documentation](https://pitest.org/)
- [Maven Surefire Plugin](https://maven.apache.org/surefire/maven-surefire-plugin/)
