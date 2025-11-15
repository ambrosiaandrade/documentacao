# 📊 Dashboard de Métricas - Template

## Índice

1. [Visão Geral](#1-visão-geral)
2. [KPIs Principais](#2-kpis-principais)
3. [Visualizações por Métrica](#3-visualizações-por-métrica)
4. [Dashboard Grafana](#4-dashboard-grafana)
5. [Dashboard SonarQube](#5-dashboard-sonarqube)
6. [README Badges](#6-readme-badges)
7. [Relatórios Customizados](#7-relatórios-customizados)

---

## 1. Visão Geral

### 🎯 Objetivo

Consolidar métricas de qualidade de testes em visualizações acionáveis para tomada de decisão.

### 📈 Princípios de Visualização

1. **At-a-glance**: Status deve ser óbvio em < 3 segundos
2. **Acionável**: Deve apontar para próxima ação
3. **Tendência**: Mostrar evolução temporal
4. **Contexto**: Comparar com baselines e metas

### 🎨 Código de Cores

```
🟢 Verde: Acima da meta (excellent)
🟡 Amarelo: Dentro do threshold (acceptable)
🔴 Vermelho: Abaixo do threshold (action required)
⚪ Cinza: Não aplicável ou sem dados
```

---

## 2. KPIs Principais

### 📊 Quality Score Card

```
┌──────────────────────────────────────────────────┐
│         QUALITY SCORE CARD - Sprint 15           │
├────────────────┬──────────┬──────────┬───────────┤
│ Metric         │ Current  │ Target   │ Status    │
├────────────────┼──────────┼──────────┼───────────┤
│ Mutation Score │ 85%      │ 70%      │ 🟢 +15%   │
│ Line Coverage  │ 92%      │ 80%      │ 🟢 +12%   │
│ Branch Cov.    │ 78%      │ 75%      │ 🟢 +3%    │
│ Diff Coverage  │ 88%      │ 80%      │ 🟢 +8%    │
│ Flaky Rate     │ 0.5%     │ < 1%     │ 🟢 OK     │
│ Lead Time      │ 3.2 min  │ < 5 min  │ 🟢 OK     │
│ Test Success   │ 99.8%    │ 100%     │ 🟡 -0.2%  │
└────────────────┴──────────┴──────────┴───────────┘
```

### 🎯 Health Score (Weighted)

```python
# Cálculo de health score ponderado
def calculate_health_score(metrics):
    weights = {
        'mutation_score': 0.30,    # 30%
        'coverage': 0.25,          # 25%
        'test_success': 0.20,      # 20%
        'diff_coverage': 0.15,     # 15%
        'flaky_rate': 0.10         # 10% (invertido)
    }

    normalized = {
        'mutation_score': min(metrics['mutation_score'] / 70, 1.0),
        'coverage': min(metrics['coverage'] / 80, 1.0),
        'test_success': metrics['test_success'] / 100,
        'diff_coverage': min(metrics['diff_coverage'] / 80, 1.0),
        'flaky_rate': 1.0 - min(metrics['flaky_rate'] / 5, 1.0)
    }

    score = sum(normalized[k] * weights[k] for k in weights.keys())
    return round(score * 100, 1)

# Exemplo
metrics = {
    'mutation_score': 85,
    'coverage': 92,
    'test_success': 99.8,
    'diff_coverage': 88,
    'flaky_rate': 0.5
}

health_score = calculate_health_score(metrics)
# Output: 95.3 (Excellent)
```

**Interpretação:**

- **95-100**: Excellent 🟢
- **80-94**: Good 🟢
- **65-79**: Acceptable 🟡
- **50-64**: Needs Improvement 🟠
- **< 50**: Critical 🔴

---

## 3. Visualizações por Métrica

### 📈 3.1 Mutation Score Trend

**Tipo:** Line Chart
**Período:** Últimos 30 dias
**Meta:** Mostrar evolução e detectar regressões

```
Mutation Score Trend (Last 30 days)
│
100% ┤                                     ╭─╮
 90% ┤                           ╭────╮ ╭─╯ ╰─╮
 80% ┤                     ╭─────╯    ╰─╯      ╰─
 70% ┤ - - - - - - - - - - - - - - - - - - - - -  (Target)
 60% ┤     ╭────╮
 50% ┤ ────╯    ╰────
     └─┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬
      D1  D5  D10 D15 D20 D25 D30
```

**Grafana Query (Prometheus):**

```promql
# Mutation score over time
test_mutation_score{job="ci"}
```

**Alertas:**

```yaml
# Alert se mutation score cair 10% em 24h
- alert: MutationScoreDrop
  expr: |
    (test_mutation_score - test_mutation_score offset 24h) < -10
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Mutation score dropped significantly"
```

---

### 📊 3.2 Coverage Breakdown (Sunburst Chart)

**Tipo:** Hierarchical Sunburst
**Objetivo:** Mostrar distribuição de cobertura por módulo

```
        Total: 85%
           ╱ │ ╲
          ╱  │  ╲
     Domain Services Infrastructure
      95%    82%      78%
      ╱│╲    ╱│╲      ╱│╲
    ...  ... ... ... ... ...
```

**Dados:**

```json
{
  "name": "Project",
  "coverage": 85,
  "children": [
    {
      "name": "Domain",
      "coverage": 95,
      "children": [
        { "name": "Order", "coverage": 98 },
        { "name": "Customer", "coverage": 92 }
      ]
    },
    {
      "name": "Services",
      "coverage": 82,
      "children": [
        { "name": "OrderService", "coverage": 88 },
        { "name": "PaymentService", "coverage": 76 }
      ]
    },
    {
      "name": "Infrastructure",
      "coverage": 78,
      "children": [
        { "name": "Database", "coverage": 85 },
        { "name": "Cache", "coverage": 71 }
      ]
    }
  ]
}
```

---

### 🎲 3.3 Flaky Test Heatmap

**Tipo:** Calendar Heatmap
**Período:** Últimos 90 dias
**Objetivo:** Identificar padrões temporais

```
Flaky Test Occurrences (Last 90 days)

Week │ Mon Tue Wed Thu Fri Sat Sun
─────┼──────────────────────────────
  1  │ ▢   ▢   ▣   ▢   ▢   ▢   ▢
  2  │ ▢   ▣   ▣   ▢   ▢   ▢   ▢
  3  │ ▢   ▢   ▢   ▢   ▣   ▢   ▢
  ...
 13  │ ▢   ▢   ▢   ▢   ▢   ▢   ▢

Legend: ▢ 0  ▣ 1-2  ▣ 3-5  ▣ 6+
```

**Insights:**

- Flaky tests concentrados em Terças/Quartas → Investigar deploy schedule
- Picos após releases → Validar estabilidade pós-deploy

---

### ⏱️ 3.4 Lead Time Distribution (Histogram)

**Tipo:** Histogram + Percentiles
**Objetivo:** Entender distribuição de tempo de execução

```
Test Lead Time Distribution (Last 100 runs)

 40 ┤     ██
 35 ┤     ██
 30 ┤     ██  ██
 25 ┤ ██  ██  ██
 20 ┤ ██  ██  ██  ██
 15 ┤ ██  ██  ██  ██
 10 ┤ ██  ██  ██  ██  ██
  5 ┤ ██  ██  ██  ██  ██  ██
  0 ┴─────────────────────────────
     1   2   3   4   5   6+ (min)

P50: 2.5 min
P90: 3.8 min
P95: 4.2 min
P99: 5.5 min
Max: 6.2 min
```

---

### 🔴 3.5 Failed Test Breakdown (Pie Chart)

**Tipo:** Pie Chart
**Objetivo:** Categorizar falhas

```
Failed Tests by Category (Last 30 days)

     ╱─────────╲
    ╱  45%     ╲
   │  Flaky     │────── Most critical
   │            │
   ╲  30%      ╱
    │ Real     │────── Bugs encontrados
    │ Bugs     │
    ╲  15%   ╱
     │ Env   │────── Infraestrutura
     │ Issues │
     ╲  10% ╱
      │Timeout│────── Performance
      ╰──────╯
```

---

## 4. Dashboard Grafana

### 📊 4.1 Template Completo

```json
{
  "dashboard": {
    "title": "Test Quality Metrics",
    "tags": ["testing", "quality", "ci"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Health Score",
        "type": "stat",
        "gridPos": { "h": 8, "w": 6, "x": 0, "y": 0 },
        "targets": [
          {
            "expr": "test_health_score",
            "legendFormat": "Health Score"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "mode": "absolute",
              "steps": [
                { "value": 0, "color": "red" },
                { "value": 65, "color": "orange" },
                { "value": 80, "color": "yellow" },
                { "value": 95, "color": "green" }
              ]
            },
            "unit": "percent",
            "max": 100,
            "min": 0
          }
        },
        "options": {
          "graphMode": "area",
          "colorMode": "background"
        }
      },
      {
        "id": 2,
        "title": "Mutation Score",
        "type": "gauge",
        "gridPos": { "h": 8, "w": 6, "x": 6, "y": 0 },
        "targets": [
          {
            "expr": "test_mutation_score",
            "legendFormat": "Mutation %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "mode": "absolute",
              "steps": [
                { "value": 0, "color": "red" },
                { "value": 50, "color": "orange" },
                { "value": 70, "color": "yellow" },
                { "value": 85, "color": "green" }
              ]
            },
            "unit": "percent"
          }
        }
      },
      {
        "id": 3,
        "title": "Coverage Trend",
        "type": "graph",
        "gridPos": { "h": 8, "w": 12, "x": 12, "y": 0 },
        "targets": [
          {
            "expr": "test_coverage_line",
            "legendFormat": "Line"
          },
          {
            "expr": "test_coverage_branch",
            "legendFormat": "Branch"
          }
        ],
        "yaxes": [
          {
            "format": "percent",
            "label": "Coverage",
            "max": 100,
            "min": 0
          }
        ]
      },
      {
        "id": 4,
        "title": "Flaky Rate",
        "type": "stat",
        "gridPos": { "h": 4, "w": 6, "x": 0, "y": 8 },
        "targets": [
          {
            "expr": "test_flaky_rate",
            "legendFormat": "Flaky %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "mode": "absolute",
              "steps": [
                { "value": 0, "color": "green" },
                { "value": 1, "color": "yellow" },
                { "value": 3, "color": "orange" },
                { "value": 5, "color": "red" }
              ]
            },
            "unit": "percent"
          }
        }
      },
      {
        "id": 5,
        "title": "Lead Time (P95)",
        "type": "stat",
        "gridPos": { "h": 4, "w": 6, "x": 6, "y": 8 },
        "targets": [
          {
            "expr": "histogram_quantile(0.95, test_lead_time_seconds_bucket)",
            "legendFormat": "P95"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "mode": "absolute",
              "steps": [
                { "value": 0, "color": "green" },
                { "value": 300, "color": "yellow" },
                { "value": 600, "color": "orange" },
                { "value": 900, "color": "red" }
              ]
            },
            "unit": "s"
          }
        }
      },
      {
        "id": 6,
        "title": "Test Results",
        "type": "piechart",
        "gridPos": { "h": 8, "w": 12, "x": 12, "y": 8 },
        "targets": [
          {
            "expr": "test_results_passed",
            "legendFormat": "Passed"
          },
          {
            "expr": "test_results_failed",
            "legendFormat": "Failed"
          },
          {
            "expr": "test_results_skipped",
            "legendFormat": "Skipped"
          }
        ]
      }
    ],
    "refresh": "5m",
    "time": {
      "from": "now-30d",
      "to": "now"
    }
  }
}
```

### 🔧 4.2 Exportar Métricas para Prometheus

```java
// Spring Boot Actuator + Micrometer
@Component
public class TestMetricsExporter {

    private final MeterRegistry registry;

    public TestMetricsExporter(MeterRegistry registry) {
        this.registry = registry;
        initMetrics();
    }

    private void initMetrics() {
        // Mutation Score
        Gauge.builder("test.mutation.score", this, TestMetricsExporter::getMutationScore)
             .description("Mutation testing score percentage")
             .tag("type", "quality")
             .register(registry);

        // Coverage
        Gauge.builder("test.coverage.line", this, TestMetricsExporter::getLineCoverage)
             .description("Line coverage percentage")
             .register(registry);

        Gauge.builder("test.coverage.branch", this, TestMetricsExporter::getBranchCoverage)
             .description("Branch coverage percentage")
             .register(registry);

        // Flaky Rate
        Gauge.builder("test.flaky.rate", this, TestMetricsExporter::getFlakyRate)
             .description("Percentage of flaky tests")
             .register(registry);

        // Lead Time
        DistributionSummary.builder("test.lead.time.seconds")
                          .description("Test execution lead time")
                          .baseUnit("seconds")
                          .register(registry);

        // Test Results
        Counter.builder("test.results.passed")
               .description("Number of passed tests")
               .register(registry);

        Counter.builder("test.results.failed")
               .description("Number of failed tests")
               .register(registry);

        // Health Score
        Gauge.builder("test.health.score", this, TestMetricsExporter::calculateHealthScore)
             .description("Overall test health score (weighted)")
             .register(registry);
    }

    private double getMutationScore() {
        // Parse target/pit-reports/mutations.xml
        return parseMetric("target/pit-reports/mutations.xml", "mutationCoverage");
    }

    private double getLineCoverage() {
        // Parse target/site/jacoco/jacoco.xml
        return parseJaCoCoMetric("LINE");
    }

    private double getBranchCoverage() {
        return parseJaCoCoMetric("BRANCH");
    }

    private double getFlakyRate() {
        // Calculate from history
        return calculateFlakyRateFromHistory();
    }

    private double calculateHealthScore() {
        Map<String, Double> metrics = Map.of(
            "mutation_score", getMutationScore(),
            "coverage", getLineCoverage(),
            "test_success", getTestSuccessRate(),
            "diff_coverage", getDiffCoverage(),
            "flaky_rate", getFlakyRate()
        );

        Map<String, Double> weights = Map.of(
            "mutation_score", 0.30,
            "coverage", 0.25,
            "test_success", 0.20,
            "diff_coverage", 0.15,
            "flaky_rate", 0.10
        );

        double score = 0.0;
        for (String key : weights.keySet()) {
            double normalized = normalizeMetric(key, metrics.get(key));
            score += normalized * weights.get(key);
        }

        return score * 100;
    }

    private double normalizeMetric(String key, double value) {
        // Normalize to 0-1 range based on thresholds
        switch (key) {
            case "mutation_score":
                return Math.min(value / 70.0, 1.0);
            case "coverage":
                return Math.min(value / 80.0, 1.0);
            case "test_success":
                return value / 100.0;
            case "diff_coverage":
                return Math.min(value / 80.0, 1.0);
            case "flaky_rate":
                return 1.0 - Math.min(value / 5.0, 1.0);
            default:
                return 0.0;
        }
    }
}
```

---

## 5. Dashboard SonarQube

### 📊 5.1 Quality Gate Customizado

```json
{
  "name": "Senior Quality Gate",
  "conditions": [
    {
      "metric": "coverage",
      "op": "LT",
      "error": "80"
    },
    {
      "metric": "new_coverage",
      "op": "LT",
      "error": "80"
    },
    {
      "metric": "duplicated_lines_density",
      "op": "GT",
      "error": "3"
    },
    {
      "metric": "new_bugs",
      "op": "GT",
      "error": "0"
    },
    {
      "metric": "new_vulnerabilities",
      "op": "GT",
      "error": "0"
    },
    {
      "metric": "code_smells",
      "op": "GT",
      "error": "10"
    }
  ]
}
```

---

## 6. README Badges

### 🎖️ 6.1 Shields.io Badges

```markdown
# Project Name

![Build](https://img.shields.io/github/workflow/status/owner/repo/CI)
![Coverage](https://img.shields.io/codecov/c/github/owner/repo)
![Mutation](https://img.shields.io/badge/mutation-85%25-brightgreen)
![Quality Gate](https://sonarcloud.io/api/project_badges/measure?project=key&metric=alert_status)
![License](https://img.shields.io/github/license/owner/repo)

## Quality Metrics

| Metric             | Value   | Target  | Status |
| ------------------ | ------- | ------- | ------ |
| 🧬 Mutation Score  | 85%     | 70%     | ✅     |
| 📊 Line Coverage   | 92%     | 80%     | ✅     |
| 📈 Branch Coverage | 78%     | 75%     | ✅     |
| 🎯 Diff Coverage   | 88%     | 80%     | ✅     |
| 🎲 Flaky Rate      | 0.5%    | < 1%    | ✅     |
| ⏱️ Lead Time (P95) | 3.2 min | < 5 min | ✅     |
| 🧪 Test Success    | 99.8%   | 100%    | 🟡     |

**Health Score: 95.3 / 100** 🟢 Excellent
```

### 🔧 6.2 Badge Dinâmico (Endpoint)

```python
# Flask endpoint para badge dinâmico
from flask import Flask, jsonify
import json

app = Flask(__name__)

@app.route('/badge/mutation-score')
def mutation_score_badge():
    # Ler métrica atual
    with open('target/quality-report.json') as f:
        report = json.load(f)

    score = report.get('mutation', {}).get('score', 0)

    # Determinar cor
    if score >= 85:
        color = 'brightgreen'
    elif score >= 70:
        color = 'green'
    elif score >= 50:
        color = 'yellow'
    else:
        color = 'red'

    # Retornar formato Shields.io
    return jsonify({
        'schemaVersion': 1,
        'label': 'mutation',
        'message': f'{score}%',
        'color': color
    })

# Usage in README:
# ![Mutation](https://my-server.com/badge/mutation-score)
```

---

## 7. Relatórios Customizados

### 📄 7.1 HTML Report Template

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Quality Report - {{ date }}</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 40px;
      }
      .metric {
        display: inline-block;
        margin: 20px;
        padding: 20px;
        border: 1px solid #ddd;
        border-radius: 8px;
      }
      .metric.good {
        background: #d4edda;
      }
      .metric.warning {
        background: #fff3cd;
      }
      .metric.bad {
        background: #f8d7da;
      }
      .metric h3 {
        margin: 0 0 10px 0;
      }
      .metric .value {
        font-size: 48px;
        font-weight: bold;
      }
      .metric .label {
        font-size: 14px;
        color: #666;
      }
    </style>
  </head>
  <body>
    <h1>📊 Quality Metrics Report</h1>
    <p>Generated: {{ timestamp }}</p>

    <div class="metric {{ mutation_class }}">
      <h3>🧬 Mutation Score</h3>
      <div class="value">{{ mutation_score }}%</div>
      <div class="label">Target: 70%</div>
    </div>

    <div class="metric {{ coverage_class }}">
      <h3>📊 Line Coverage</h3>
      <div class="value">{{ line_coverage }}%</div>
      <div class="label">Target: 80%</div>
    </div>

    <div class="metric {{ flaky_class }}">
      <h3>🎲 Flaky Rate</h3>
      <div class="value">{{ flaky_rate }}%</div>
      <div class="label">Target: < 1%</div>
    </div>

    <h2>📈 Trends</h2>
    <img src="mutation-trend.png" alt="Mutation Trend" />
    <img src="coverage-trend.png" alt="Coverage Trend" />

    <h2>🎯 Health Score</h2>
    <div class="metric {{ health_class }}">
      <div class="value">{{ health_score }}</div>
      <div class="label">Out of 100</div>
    </div>
  </body>
</html>
```

---

### 📧 7.2 Weekly Email Report

```python
#!/usr/bin/env python3
# scripts/send-weekly-report.py

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.image import MIMEImage
import json
from datetime import datetime, timedelta

def generate_email_report():
    # Carregar métricas da semana
    with open('metrics-history/weekly-summary.json') as f:
        data = json.load(f)

    html = f"""
    <html>
    <body>
        <h1>📊 Weekly Quality Report</h1>
        <p><strong>Period:</strong> {data['start_date']} to {data['end_date']}</p>

        <h2>Summary</h2>
        <table border="1" cellpadding="10" cellspacing="0">
            <tr>
                <th>Metric</th>
                <th>Average</th>
                <th>Change</th>
                <th>Status</th>
            </tr>
            <tr>
                <td>Mutation Score</td>
                <td>{data['avg_mutation']}%</td>
                <td>{data['mutation_change']:+.1f}%</td>
                <td>{data['mutation_status']}</td>
            </tr>
            <tr>
                <td>Line Coverage</td>
                <td>{data['avg_coverage']}%</td>
                <td>{data['coverage_change']:+.1f}%</td>
                <td>{data['coverage_status']}</td>
            </tr>
            <tr>
                <td>Flaky Tests</td>
                <td>{data['flaky_count']}</td>
                <td>{data['flaky_change']:+d}</td>
                <td>{data['flaky_status']}</td>
            </tr>
        </table>

        <h2>Action Items</h2>
        <ul>
            {generate_action_items(data)}
        </ul>

        <p>Full dashboard: <a href="https://grafana.example.com">View in Grafana</a></p>
    </body>
    </html>
    """

    return html

def send_email(to_addresses, subject, html_content):
    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['From'] = 'quality-bot@example.com'
    msg['To'] = ', '.join(to_addresses)

    msg.attach(MIMEText(html_content, 'html'))

    # Anexar gráficos
    with open('mutation-trend.png', 'rb') as f:
        img = MIMEImage(f.read())
        img.add_header('Content-ID', '<mutation-trend>')
        msg.attach(img)

    # Enviar
    with smtplib.SMTP('smtp.example.com', 587) as server:
        server.starttls()
        server.login('username', 'password')
        server.send_message(msg)

    print(f"✅ Email sent to {len(to_addresses)} recipients")

if __name__ == '__main__':
    html = generate_email_report()
    send_email(
        to_addresses=['team@example.com'],
        subject=f"Weekly Quality Report - {datetime.now().strftime('%Y-%m-%d')}",
        html_content=html
    )
```

---

## 📚 Checklist de Implementação

### Fase 1: Setup

- [ ] Definir KPIs e metas
- [ ] Escolher ferramenta de visualização (Grafana, SonarQube, custom)
- [ ] Configurar coleta de métricas
- [ ] Criar pipeline de dados

### Fase 2: Dashboards

- [ ] Criar dashboard principal (overview)
- [ ] Criar dashboards específicos por métrica
- [ ] Configurar refresh automático
- [ ] Testar em diferentes resoluções

### Fase 3: Alertas

- [ ] Configurar alertas de threshold
- [ ] Integrar com Slack/Email
- [ ] Definir on-call rotation
- [ ] Documentar runbooks

### Fase 4: Relatórios

- [ ] Automatizar relatórios semanais
- [ ] Criar badges para README
- [ ] Configurar exportação PDF
- [ ] Arquivar histórico

### Fase 5: Cultura

- [ ] Treinar time em leitura de dashboards
- [ ] Incluir em retrospectivas
- [ ] Celebrar melhorias
- [ ] Ajustar metas baseado em dados

---

## 🎯 Métricas de Sucesso do Dashboard

- **Tempo para detectar problema**: < 5 minutos
- **Tempo para entender problema**: < 2 minutos
- **Ações tomadas baseadas em dashboard**: ≥ 80%
- **Utilização semanal por membro do time**: 100%

---

## 📖 Referências

- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [SonarQube Quality Gates](https://docs.sonarqube.org/latest/user-guide/quality-gates/)
- [Shields.io](https://shields.io/)
