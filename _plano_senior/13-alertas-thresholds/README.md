# 🚨 Fase 13: Alertas e Thresholds - Guia Completo

> **Objetivo:** Dominar alertas eficazes, thresholds dinâmicos e observabilidade operacional.

---

## 📚 Visão Geral

Esta fase cobre a **ciência de alertas**: desde fundamentos (SLI/SLO/SLA) até implementação avançada (anomaly detection, chaos testing). O objetivo é criar alertas **acionáveis, precisos e não fatigantes**.

---

## 📑 Módulos

### [13.1 - Fundamentos de Alertas](13.1-fundamentos-alertas.md)

**Conceitos:** SLI/SLO/SLA, Error Budget, Golden Signals  
**Ferramentas:** Prometheus, Micrometer  
**Duração:** 3-4 horas

**Aprenda:**

- Diferença entre SLI (medição), SLO (meta), SLA (contrato)
- Calcular Error Budget e Burn Rate
- Golden Signals (Latency, Traffic, Errors, Saturation)
- Alert design principles (actionable, symptomatic, timely)
- Alert taxonomy (critical/warning/info)

**Hands-on:**

```java
// Calcular Error Budget
var errorBudget = errorBudgetService.calculateErrorBudget(99.9, 30);
System.out.println("Budget consumed: " + errorBudget.budgetConsumed() + "%");
System.out.println("Policy: " + errorBudget.policy());
```

---

### [13.2 - Prometheus Alerting](13.2-prometheus-alerting.md)

**Conceitos:** AlertManager, PromQL, Routing, Inhibition  
**Ferramentas:** Prometheus, AlertManager, PagerDuty, Slack  
**Duração:** 4-5 horas

**Aprenda:**

- Configurar AlertManager (routing, grouping, silencing)
- Escrever alert rules com PromQL
- Multi-window alerts (burn rate)
- Inhibition rules (evitar ruído)
- Integrations (PagerDuty, Slack, Email)

**Hands-on:**

```yaml
# Burn rate alert (multi-window)
- alert: FastBurnRate
  expr: |
    sli:error_rate:5m > (10 * slo:error_budget)
    and
    sli:error_rate:1h > (10 * slo:error_budget)
  for: 2m
  labels:
    severity: critical
```

---

### [13.3 - Thresholds Dinâmicos](13.3-thresholds-dinamicos.md)

**Conceitos:** Baselines adaptativos, Anomaly detection, Seasonality  
**Ferramentas:** Prometheus, Prophet, ARIMA, Isolation Forest  
**Duração:** 5-6 horas

**Aprenda:**

- Calcular baseline adaptativo (média + N \* stddev)
- Z-Score para anomaly detection
- Rate of Change (ROC) para detectar mudanças súbitas
- Percentiles e outliers (IQR method)
- Sazonalidade (dia da semana, hora do dia)
- Machine Learning (Prophet, ARIMA, Isolation Forest)

**Hands-on:**

```yaml
# Threshold dinâmico: baseline + 3σ
- record: threshold:latency_p99:dynamic
  expr: |
    baseline:latency_p99:7d + (3 * baseline:latency_p99:stddev)

- alert: HighLatencyDynamic
  expr: |
    histogram_quantile(0.99, rate(http_requests_seconds_bucket[5m])) 
    > threshold:latency_p99:dynamic
```

---

### [13.4 - Alert Fatigue](13.4-alert-fatigue.md)

**Conceitos:** Alert hygiene, Runbooks, On-call, Post-mortem  
**Ferramentas:** PagerDuty, Opsgenie, Kubernetes  
**Duração:** 4-5 horas

**Aprenda:**

- Identificar e reduzir alert fatigue
- Métricas: False positive rate, MTTA, MTTR
- Alert tuning (calibração de thresholds)
- Runbook automation
- Auto-remediation (rollback, scaling, circuit breaker)
- On-call rotation e escalation
- Post-mortem process (5 Whys, action items)

**Hands-on:**

```java
// Auto-remediation: Rollback em error rate alto
if (alert.getName().equals("HighErrorRate")) {
    var deployment = alert.getLabels().get("deployment");
    var lastDeployTime = k8s.getLastDeployTime(deployment);

    if (Duration.between(lastDeployTime, Instant.now()).toMinutes() < 120) {
        k8s.rollback(deployment);
    }
}
```

---

### [13.5 - Testing Alerts](13.5-testing-alerts.md)

**Conceitos:** Alert testing, Chaos engineering, Observability tests  
**Ferramentas:** Testcontainers, Chaos Toolkit, Chaos Mesh  
**Duração:** 5-6 horas

**Aprenda:**

- Pirâmide de testes de alertas (Unit/Integration/E2E)
- Testcontainers com Prometheus + AlertManager
- Alert simulation (mock metrics)
- Chaos engineering (kill pods, saturar CPU)
- Contract testing (validar métricas existem)
- SLO testing (validar compliance)

**Hands-on:**

```java
@Test
void testHighLatencyAlertFires() {
    metricsExporter.simulateHighLatency(Duration.ofMillis(600));

    await().atMost(Duration.ofMinutes(6))
           .until(() -> alertManager.hasAlert("HighLatency", Severity.WARNING));
}
```

---

## 🎯 Objetivos de Aprendizado

Ao completar esta fase, você será capaz de:

- ✅ Definir SLI/SLO/SLA para serviços críticos
- ✅ Calcular Error Budget e tomar decisões baseadas nele
- ✅ Implementar Golden Signals (latency, traffic, errors, saturation)
- ✅ Escrever alert rules eficazes com PromQL
- ✅ Configurar routing, grouping e inhibition no AlertManager
- ✅ Criar thresholds dinâmicos (baseline + N \* stddev)
- ✅ Implementar anomaly detection (Z-Score, ROC, IQR)
- ✅ Integrar ML (Prophet, ARIMA) para forecasting
- ✅ Reduzir alert fatigue (false positive rate < 5%)
- ✅ Automatizar runbooks e remediation
- ✅ Configurar on-call rotation com escalation
- ✅ Escrever post-mortems eficazes (5 Whys)
- ✅ Testar alertas com Testcontainers e Chaos Engineering

---

## 📊 Métricas de Sucesso

### Indicadores de Qualidade

| Métrica                             | Target   | Como Medir                                           |
| ----------------------------------- | -------- | ---------------------------------------------------- |
| **False Positive Rate**             | < 5%     | (Alertas resolvidos sem ação / Total alertas) \* 100 |
| **Alert Noise Ratio**               | < 200%   | (Alertas warning+info / Alertas critical) \* 100     |
| **MTTA (Mean Time to Acknowledge)** | < 5 min  | Tempo médio entre alert fire e ACK                   |
| **MTTR (Mean Time to Resolve)**     | < 30 min | Tempo médio entre alert fire e resolve               |
| **SLO Compliance**                  | > 99%    | % de tempo dentro do SLO (últimos 30 dias)           |
| **Error Budget Remaining**          | > 20%    | Budget não consumido (evitar freeze)                 |
| **Runbook Coverage**                | 100%     | % de alertas critical com runbook                    |
| **Auto-Remediation Rate**           | > 50%    | % de alertas resolvidos automaticamente              |

### Checklist de Pronto

- [ ] Todos serviços críticos têm SLI/SLO definidos
- [ ] Error Budget calculado e dashboard visível
- [ ] Golden Signals monitorados (latency, traffic, errors, saturation)
- [ ] Alertas classificados (critical/warning/info)
- [ ] Thresholds calibrados (false positive rate < 5%)
- [ ] AlertManager com routing por severidade
- [ ] Inhibition rules para evitar ruído
- [ ] Burn rate alerts (multi-window)
- [ ] Thresholds dinâmicos (baseline + N \* stddev)
- [ ] Anomaly detection implementada (Z-Score ou ML)
- [ ] Runbooks documentados para alertas critical
- [ ] Auto-remediation para alertas comuns
- [ ] On-call rotation configurada (PagerDuty/Opsgenie)
- [ ] Post-mortem process definido
- [ ] Alertas testados (Testcontainers + Chaos)

---

## 🛠️ Ferramentas e Dependências

### Essenciais

```xml
<!-- Micrometer (métricas) -->
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>

<!-- Spring Boot Actuator -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

<!-- Testcontainers -->
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>testcontainers</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>
```

### Infraestrutura

```yaml
# docker-compose.yml
version: "3.8"
services:
  prometheus:
    image: prom/prometheus:v2.48.0
    ports:
      - "9090:9090"

  alertmanager:
    image: prom/alertmanager:v0.26.0
    ports:
      - "9093:9093"

  grafana:
    image: grafana/grafana:10.2.0
    ports:
      - "3000:3000"
```

### Machine Learning (Opcional)

```bash
pip install fbprophet statsmodels scikit-learn pandas
```

---

## 📚 Referências

### Livros

- **Site Reliability Engineering** (Google) - Capítulos sobre monitoring e alerting
- **The Site Reliability Workbook** (Google) - Alerting on SLOs
- **Observability Engineering** (Charity Majors) - Modern observability practices

### Documentação

- [Prometheus Alerting](https://prometheus.io/docs/alerting/latest/overview/)
- [Google SRE Book - Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/)
- [AlertManager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)

### Ferramentas

- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [PagerDuty](https://www.pagerduty.com/)
- [Chaos Toolkit](https://chaostoolkit.org/)
- [Chaos Mesh](https://chaos-mesh.org/)

---

## 🎓 Exercícios Práticos

### Básico (2-3 horas)

1. Configurar Prometheus + AlertManager localmente
2. Criar alert rule para latência p99 > 500ms
3. Integrar com Slack para notificações

### Intermediário (4-5 horas)

4. Calcular Error Budget e Burn Rate
5. Implementar threshold dinâmico (baseline + 3σ)
6. Configurar inhibition rules (InstanceDown silencia outros)

### Avançado (6-8 horas)

7. Setup Testcontainers com Prometheus + AlertManager
8. Criar chaos experiment (kill pod + validar alertas)
9. Implementar auto-remediation (rollback em error rate alto)
10. Integrar Prophet para anomaly detection

---

## 🚀 Próximos Passos

Após completar esta fase:

- **Fase 14:** Big O Notation (Análise de Complexidade)
- **Fase 15:** Code Review (Boas Práticas)
- **Revisão:** Integração de todas as fases

---

## 📝 Notas Importantes

### Trade-offs

**Alertas demais vs poucos:**

- ❌ Muitos alertas → Alert fatigue, ignorar críticos
- ❌ Poucos alertas → Problemas não detectados
- ✅ Balanceado: Critical < 10 alertas/dia, Warning < 50 alertas/dia

**Thresholds fixos vs dinâmicos:**

- ✅ Fixos: Simples, fácil debug, bom para métricas estáveis
- ✅ Dinâmicos: Menos falsos positivos, adapta a sazonalidade
- ⚠️ Dinâmicos: Complexidade maior, pode mascarar problemas reais

**Auto-remediation vs manual:**

- ✅ Auto: Resolve rápido, reduz MTTR, escala melhor
- ⚠️ Auto: Risco de mascarar root cause, pode piorar situação
- 💡 Recomendação: Auto para ações seguras (scaling), manual para ações destrutivas (rollback)

---

**Duração Total:** 20-25 horas  
**Dificuldade:** 🔥🔥🔥🔥 (Avançado)  
**Pré-requisitos:** Fase 3 (Avançado), Fase 8 (Métricas), conhecimento de Prometheus

---

**Anterior:** Fase 12 - Banco de Dados  
**Próximo:** Fase 14 - Big O Notation
