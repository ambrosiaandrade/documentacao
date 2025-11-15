# 🌪️ Chaos Engineering - Especializações Avançadas

## Índice

1. [Introdução](#1-introdução)
2. [Princípios de Chaos Engineering](#2-princípios-de-chaos-engineering)
3. [Ferramentas Open Source](#3-ferramentas-open-source)
4. [Experimentos Práticos](#4-experimentos-práticos)
5. [Métricas e Observabilidade](#5-métricas-e-observabilidade)
6. [Implementação Gradual](#6-implementação-gradual)
7. [Casos de Uso Reais](#7-casos-de-uso-reais)
8. [Blameless Postmortems](#8-blameless-postmortems)

---

## 1. Introdução

### O que é Chaos Engineering?

> "Chaos Engineering is the discipline of experimenting on a system in order to build confidence in the system's capability to withstand turbulent conditions in production." — _Principles of Chaos Engineering_

**Objetivo:** Identificar fraquezas antes que se tornem incidentes em produção.

**Diferença de Testes Tradicionais:**
| Aspecto | Testes Tradicionais | Chaos Engineering |
|---------|---------------------|-------------------|
| **Foco** | Verificar comportamento esperado | Descobrir comportamento inesperado |
| **Ambiente** | Pré-produção (staging) | Produção (preferencialmente) |
| **Abordagem** | Determinística | Exploratória |
| **Quando** | Antes do deploy | Continuamente após deploy |
| **Objetivo** | Provar que funciona | Provar que é resiliente |

### Por que Chaos Engineering?

**Motivações:**

1. 🔥 **Falhas são inevitáveis** - Hardware falha, rede é instável, dependências caem
2. 📊 **Sistemas distribuídos são complexos** - Comportamento emergente imprevisível
3. ⏱️ **MTTR > MTBF** - Melhor recuperar rápido que prevenir toda falha
4. 🧪 **Aprendizado contínuo** - Entender limites reais do sistema

**Benefícios:**

- ✅ Identificar Single Points of Failure (SPOF)
- ✅ Validar Circuit Breakers, Retries, Timeouts
- ✅ Melhorar observabilidade (encontrar gaps)
- ✅ Aumentar confiança do time
- ✅ Reduzir MTTR (Mean Time To Recovery)

---

## 2. Princípios de Chaos Engineering

### 2.1 Princípios Fundamentais

**1. Build a Hypothesis around Steady State Behavior**

```
Hipótese: "O sistema mantém p99 < 500ms mesmo com 20% de falhas no serviço de pagamento"
```

**2. Vary Real-world Events**

- Falhas de hardware
- Network delays/partitions
- Resource exhaustion (CPU, memória, disco)
- Dependências indisponíveis

**3. Run Experiments in Production**

- Ambiente real revela problemas que staging não mostra
- Mas começar em staging/pré-prod

**4. Automate Experiments to Run Continuously**

- Não é um evento único
- CI/CD de resiliência

**5. Minimize Blast Radius**

- Começar pequeno (1% do tráfego)
- Rollback automático se hipótese falhar

### 2.2 Método Científico

```
1. Observar o sistema (baseline)
   └─> Coletar métricas: latência, throughput, error rate

2. Formular hipótese
   └─> "Sistema tolera perda de 1 instância sem degradação"

3. Executar experimento
   └─> Desligar 1 instância aleatória

4. Medir resultado
   └─> Comparar métricas com baseline

5. Analisar
   └─> Hipótese confirmada? Problemas encontrados?

6. Aprender e iterar
   └─> Documentar, corrigir, expandir experimentos
```

---

## 3. Ferramentas Open Source

### 3.1 Chaos Toolkit

**O que é:** Framework Python para definir e executar experimentos de chaos.

**Instalação:**

```bash
pip install chaostoolkit chaostoolkit-kubernetes chaostoolkit-spring
```

**Exemplo - Experimento de Latência:**

```json
{
  "version": "1.0.0",
  "title": "Sistema tolera latência de 2s no serviço de pagamento",
  "description": "Validar que Circuit Breaker abre corretamente",
  "tags": ["payment", "circuit-breaker"],

  "steady-state-hypothesis": {
    "title": "Sistema está saudável",
    "probes": [
      {
        "type": "probe",
        "name": "order-service-availability",
        "tolerance": {
          "type": "probe",
          "name": "order-success-rate",
          "provider": {
            "type": "python",
            "module": "chaosspring.probes",
            "func": "health_check",
            "arguments": {
              "url": "http://order-service:8080/actuator/health"
            }
          }
        }
      },
      {
        "type": "probe",
        "name": "p95-latency-acceptable",
        "provider": {
          "type": "python",
          "module": "chaosprometheus.probes",
          "func": "query_prometheus",
          "arguments": {
            "query": "histogram_quantile(0.95, http_request_duration_seconds_bucket{service='order-service'})",
            "when": "after"
          }
        },
        "tolerance": [0, 1.0]
      }
    ]
  },

  "method": [
    {
      "type": "action",
      "name": "inject-latency-payment-service",
      "provider": {
        "type": "python",
        "module": "chaosspring.actions",
        "func": "inject_latency",
        "arguments": {
          "service": "payment-service",
          "latency_ms": 2000,
          "duration": 60
        }
      },
      "pauses": {
        "after": 30
      }
    }
  ],

  "rollbacks": [
    {
      "type": "action",
      "name": "remove-latency",
      "provider": {
        "type": "python",
        "module": "chaosspring.actions",
        "func": "remove_latency",
        "arguments": {
          "service": "payment-service"
        }
      }
    }
  ]
}
```

**Executar:**

```bash
chaos run experiment.json --journal-path results.json
```

---

### 3.2 LitmusChaos (Kubernetes)

**O que é:** Plataforma de Chaos Engineering nativa do Kubernetes.

**Instalação:**

```bash
kubectl apply -f https://litmuschaos.github.io/litmus/litmus-operator-v3.0.0.yaml

# Instalar ChaosEngine CRD
kubectl apply -f https://hub.litmuschaos.io/api/chaos/master?file=charts/generic/pod-delete/engine.yaml
```

**Exemplo - Pod Delete:**

```yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: order-service-chaos
  namespace: production
spec:
  appinfo:
    appns: production
    applabel: app=order-service
    appkind: deployment

  # Agendar experimento
  engineState: active
  chaosServiceAccount: litmus-admin

  experiments:
    - name: pod-delete
      spec:
        components:
          env:
            # Quantos pods deletar
            - name: TOTAL_CHAOS_DURATION
              value: "60"

            # Intervalo entre deleções
            - name: CHAOS_INTERVAL
              value: "10"

            # Porcentagem de pods
            - name: PODS_AFFECTED_PERC
              value: "50"

            # Força deleção
            - name: FORCE
              value: "false"

        probe:
          - name: check-order-availability
            type: httpProbe
            mode: Continuous
            runProperties:
              probeTimeout: 5
              interval: 2
              retry: 1
            httpProbe/inputs:
              url: http://order-service.production.svc.cluster.local:8080/health
              method:
                get:
                  criteria: ==
                  responseCode: "200"
```

**Monitorar:**

```bash
kubectl get chaosresult -n production
kubectl describe chaosresult order-service-chaos-pod-delete -n production
```

---

### 3.3 Toxiproxy

**O que é:** Proxy TCP para simular falhas de rede (latência, bandwidth, timeouts).

**Instalação:**

```bash
# Docker
docker run -d -p 8474:8474 -p 28080:28080 --name toxiproxy ghcr.io/shopify/toxiproxy

# CLI
wget -O toxiproxy-cli https://github.com/Shopify/toxiproxy/releases/download/v2.5.0/toxiproxy-cli-linux-amd64
chmod +x toxiproxy-cli
```

**Configuração:**

```bash
# Criar proxy para PostgreSQL
toxiproxy-cli create postgres -l 0.0.0.0:5433 -u postgres:5432

# Adicionar latência (500ms ± 100ms jitter)
toxiproxy-cli toxic add postgres -t latency -a latency=500 -a jitter=100

# Limitar bandwidth (100 KB/s)
toxiproxy-cli toxic add postgres -t bandwidth -a rate=100

# Simular timeout (fechar conexão após 5s)
toxiproxy-cli toxic add postgres -t timeout -a timeout=5000

# Simular packet loss (10%)
toxiproxy-cli toxic add postgres -t slicer -a average_size=100 -a size_variation=50 -a delay=10

# Listar toxics ativos
toxiproxy-cli toxic list postgres

# Remover toxic específico
toxiproxy-cli toxic remove postgres -n latency

# Deletar proxy
toxiproxy-cli delete postgres
```

**Exemplo - Teste de Resiliência:**

```java
@SpringBootTest
@Testcontainers
class OrderServiceResilienceTest {

    @Container
    static ToxiproxyContainer toxiproxy = new ToxiproxyContainer(
        "ghcr.io/shopify/toxiproxy:2.5.0"
    );

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
        .withNetwork(toxiproxy.getNetwork());

    private ToxiproxyClient toxiproxyClient;
    private Proxy postgresProxy;

    @BeforeEach
    void setupProxy() throws IOException {
        toxiproxyClient = new ToxiproxyClient(
            toxiproxy.getHost(),
            toxiproxy.getControlPort()
        );

        postgresProxy = toxiproxyClient.createProxy(
            "postgres",
            "0.0.0.0:8666",
            postgres.getHost() + ":" + postgres.getFirstMappedPort()
        );
    }

    @Test
    @DisplayName("Sistema deve tolerar latência de 2s no banco")
    void shouldTolerateDatabase2sLatency() throws IOException {
        // Arrange
        postgresProxy.toxics()
            .latency("high-latency", ToxicDirection.DOWNSTREAM, 2000)
            .setJitter(200);

        Order order = OrderBuilder.anOrder()
            .withCustomerId(123L)
            .withItems(List.of(new OrderItem("item-1", 1, 100.0)))
            .build();

        // Act
        Instant start = Instant.now();
        OrderResult result = orderService.createOrder(order);
        Duration duration = Duration.between(start, Instant.now());

        // Assert
        assertThat(result.isSuccess()).isTrue();
        assertThat(duration).isLessThan(Duration.ofSeconds(5)); // Timeout configurado

        // Validar que retry funcionou
        verify(orderRepository, atLeast(1)).save(any());
    }

    @Test
    @DisplayName("Circuit Breaker deve abrir após 50% de falhas")
    void shouldOpenCircuitBreakerOnDatabaseTimeout() throws IOException {
        // Simular timeout total
        postgresProxy.toxics()
            .timeout("connection-timeout", ToxicDirection.DOWNSTREAM, 100);

        // Executar 10 chamadas para abrir circuit breaker
        List<OrderResult> results = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            try {
                results.add(orderService.createOrder(OrderBuilder.anOrder().build()));
            } catch (Exception e) {
                // Esperado
            }
        }

        // Remover toxic
        postgresProxy.toxics().get("connection-timeout").remove();

        // Próxima chamada deve ir para fallback (circuit aberto)
        OrderResult result = orderService.createOrder(OrderBuilder.anOrder().build());

        assertThat(result.isFallback()).isTrue();
        assertThat(result.getMessage()).contains("Circuit breaker is OPEN");
    }

    @AfterEach
    void cleanup() throws IOException {
        if (postgresProxy != null) {
            postgresProxy.delete();
        }
    }
}
```

---

### 3.4 Pumba (Docker Chaos)

**O que é:** Chaos testing para containers Docker.

**Instalação:**

```bash
docker pull gaiaadm/pumba
```

**Exemplo - Kill Random Container:**

```bash
# Matar container aleatório a cada 60s
pumba kill --interval 60s --random re2:order-service-.*

# Adicionar latência de rede (300ms)
pumba netem --duration 5m --interface eth0 delay --time 300 order-service-1

# Limitar bandwidth (1 Mbps)
pumba netem --duration 5m rate --rate 1mbit order-service-1

# Simular packet loss (20%)
pumba netem --duration 5m loss --percent 20 order-service-1

# Pausar container (simular freeze)
pumba pause --duration 30s order-service-1
```

**Exemplo - Docker Compose:**

```yaml
version: "3.8"

services:
  order-service:
    image: order-service:latest
    labels:
      com.gaiaadm.pumba: "true"

  payment-service:
    image: payment-service:latest
    labels:
      com.gaiaadm.pumba: "true"

  pumba:
    image: gaiaadm/pumba
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: >
      pumba kill
      --interval 2m
      --random
      --label com.gaiaadm.pumba=true
```

---

## 4. Experimentos Práticos

### 4.1 Experimento 1: Network Partition (Split Brain)

**Objetivo:** Validar que sistema detecta e se recupera de partição de rede.

**Hipótese:** "Sistema mantém consistência de dados mesmo com partição de rede entre microserviços por até 30s"

**Setup:**

```yaml
# chaos-network-partition.yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: network-partition-test
spec:
  experiments:
    - name: pod-network-partition
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: "30"
            - name: DESTINATION_IPS
              value: "payment-service-svc.default.svc.cluster.local"
            - name: DESTINATION_PORTS
              value: "8080"
```

**Validação:**

```bash
# Executar experimento
kubectl apply -f chaos-network-partition.yaml

# Monitorar logs
kubectl logs -f order-service-pod --tail=100

# Verificar métricas
curl http://prometheus:9090/api/v1/query?query='http_request_duration_seconds{quantile="0.99",service="order-service"}'

# Validar Circuit Breaker abriu
curl http://order-service:8080/actuator/circuitbreakerevents | jq '.circuitBreakerEvents[] | select(.stateTransition=="CLOSED_TO_OPEN")'
```

**Métricas de Sucesso:**

- ✅ Circuit Breaker abre em <5s
- ✅ Fallback é acionado (nenhum erro 500)
- ✅ Após recuperação, Circuit Breaker fecha em <30s
- ✅ Sem perda de dados (idempotência)

---

### 4.2 Experimento 2: Resource Exhaustion (Memory Leak)

**Objetivo:** Validar que OOM (Out of Memory) não derruba cluster inteiro.

**Hipótese:** "Sistema escala horizontalmente quando memória atinge 80% e mata pod problemático"

**Setup:**

```yaml
# stress-memory.yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-stress
  labels:
    app: order-service
spec:
  containers:
    - name: stress
      image: polinux/stress
      resources:
        limits:
          memory: "2Gi"
        requests:
          memory: "1Gi"
      command: ["stress"]
      args: ["--vm", "1", "--vm-bytes", "1500M", "--vm-hang", "0"]
```

**Validação:**

```bash
# Aplicar stress
kubectl apply -f stress-memory.yaml

# Monitorar uso de memória
kubectl top pod -l app=order-service --watch

# Verificar HPA (Horizontal Pod Autoscaler)
kubectl get hpa order-service -w

# Validar que pod foi killed
kubectl get events --field-selector involvedObject.name=memory-stress

# Verificar que novos pods foram criados
kubectl get pods -l app=order-service
```

**Métricas de Sucesso:**

- ✅ HPA cria novos pods em <2min quando memória >80%
- ✅ Pod com OOM é killed automaticamente
- ✅ Outros pods continuam funcionando (isolamento)
- ✅ Tráfego é redistribuído sem downtime

---

### 4.3 Experimento 3: Cascading Failure

**Objetivo:** Validar que falha em dependência não causa efeito cascata.

**Hipótese:** "Falha no Payment Service não afeta Search Service (serviços independentes)"

**Setup com Chaos Toolkit:**

```json
{
  "title": "Validar isolamento de falhas",
  "method": [
    {
      "type": "action",
      "name": "stop-payment-service",
      "provider": {
        "type": "process",
        "path": "kubectl",
        "arguments": ["scale", "deployment", "payment-service", "--replicas=0"]
      }
    },
    {
      "type": "probe",
      "name": "search-service-still-works",
      "provider": {
        "type": "http",
        "url": "http://search-service:8080/api/products?q=laptop",
        "timeout": 5,
        "expected_status": 200
      }
    }
  ],
  "rollbacks": [
    {
      "type": "action",
      "name": "restore-payment-service",
      "provider": {
        "type": "process",
        "path": "kubectl",
        "arguments": ["scale", "deployment", "payment-service", "--replicas=3"]
      }
    }
  ]
}
```

---

## 5. Métricas e Observabilidade

### 5.1 Métricas Essenciais

**SLIs (Service Level Indicators):**

```yaml
# prometheus-rules.yaml
groups:
  - name: chaos_sli
    rules:
      # Availability
      - record: sli:availability:ratio
        expr: |
          sum(rate(http_requests_total{status!~"5.."}[5m]))
          /
          sum(rate(http_requests_total[5m]))

      # Latency (p99)
      - record: sli:latency:p99
        expr: |
          histogram_quantile(0.99,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service)
          )

      # Error Rate
      - record: sli:error_rate:ratio
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m]))
          /
          sum(rate(http_requests_total[5m]))
```

**Alertas Chaos:**

```yaml
groups:
  - name: chaos_alerts
    rules:
      - alert: ChaosExperimentFailed
        expr: chaos_experiment_status{result="failed"} == 1
        for: 1m
        annotations:
          summary: "Chaos experiment {{ $labels.experiment }} failed"
          description: "Hypothesis was not validated. System is not resilient to {{ $labels.failure_type }}"

      - alert: SteadyStateViolated
        expr: |
          (sli:availability:ratio < 0.99) or
          (sli:latency:p99 > 1.0) or
          (sli:error_rate:ratio > 0.01)
        during: chaos_experiment_active == 1
        for: 5m
        annotations:
          summary: "SLI violated during chaos experiment"
```

### 5.2 Dashboard Grafana

**Painéis Essenciais:**

```json
{
  "dashboard": {
    "title": "Chaos Engineering - Experiment Results",
    "panels": [
      {
        "title": "Experiment Timeline",
        "type": "graph",
        "targets": [
          {
            "expr": "chaos_experiment_active",
            "legendFormat": "Experiment: {{ experiment_name }}"
          }
        ]
      },
      {
        "title": "Availability During Chaos",
        "type": "graph",
        "targets": [
          {
            "expr": "sli:availability:ratio",
            "legendFormat": "Availability"
          }
        ],
        "alert": {
          "conditions": [
            {
              "evaluator": { "params": [0.99], "type": "lt" },
              "query": { "params": ["A", "5m", "now"] }
            }
          ]
        }
      },
      {
        "title": "p99 Latency",
        "type": "graph",
        "targets": [
          {
            "expr": "sli:latency:p99",
            "legendFormat": "{{ service }}"
          }
        ]
      },
      {
        "title": "Circuit Breaker State",
        "type": "stat",
        "targets": [
          {
            "expr": "resilience4j_circuitbreaker_state",
            "legendFormat": "{{ name }}"
          }
        ],
        "mappings": [
          { "value": 0, "text": "CLOSED", "color": "green" },
          { "value": 1, "text": "OPEN", "color": "red" },
          { "value": 2, "text": "HALF_OPEN", "color": "yellow" }
        ]
      }
    ]
  }
}
```

---

## 6. Implementação Gradual

### 6.1 Roadmap de Adoção

**Fase 1: Game Days (Manual - 1 mês)**

```
Semana 1: Sessão de treinamento + primeiro game day
Semana 2-3: Game days agendados (1x/semana)
Semana 4: Retrospectiva e documentação
```

**Atividades:**

- ✅ Equipe se reúne presencialmente
- ✅ Simular falha específica manualmente (ex: desligar serviço)
- ✅ Observar comportamento
- ✅ Documentar problemas encontrados
- ✅ Blameless postmortem

**Fase 2: Experimentos Automatizados (2-3 meses)**

```
Mês 1: Setup ferramentas (Chaos Toolkit, Toxiproxy)
Mês 2: Criar 10 experimentos básicos
Mês 3: Executar experimentos semanalmente em staging
```

**Fase 3: Chaos Contínuo (ongoing)**

```
- Experimentos rodando diariamente em staging
- Experimentos semanais em produção (canary)
- Métricas de resiliência no dashboard principal
```

### 6.2 Começando Pequeno

**Experimentos Seguros para Iniciantes:**

1. ✅ **Latência Artificial (Staging)**

   - Baixo risco
   - Fácil rollback
   - Aprende sobre timeouts

2. ✅ **Pod Delete em Staging**

   - Valida alta disponibilidade
   - Kubernetes recria automaticamente

3. ✅ **Limitar CPU/Memória**
   - Valida autoscaling
   - Impacto limitado

**Experimentos Avançados (somente após maturidade):**

4. 🔶 **Network Partition em Produção**

   - Risco médio
   - Blast radius controlado (1% tráfego)

5. 🔶 **Region Failover**
   - Risco alto
   - Requer DR testado

---

## 7. Casos de Uso Reais

### 7.1 Netflix - Chaos Monkey

**Contexto:** Netflix criou Chaos Engineering

**Experimento:** Desligar instâncias EC2 aleatoriamente em produção

**Resultado:**

- Forçou engenheiros a construir sistemas resilientes
- MTTR reduziu de horas para minutos
- Confiança em deployments aumentou

**Lição:** Falhas constantes normalizam resiliência

---

### 7.2 Gremlin - Black Friday Test

**Contexto:** E-commerce preparando para Black Friday

**Experimento:**

1. Simular 10x tráfego normal
2. Desligar 30% dos servidores
3. Injetar latência em banco de dados

**Resultado:**

- Descobriu que cache Redis não escalava
- Identificou N+1 queries sob carga
- Ajustou connection pools

**ROI:** Evitou $2M em revenue loss

---

### 7.3 Case: Microservices com Idempotência

**Problema:** Pagamentos duplicados em retry

**Experimento:**

```bash
# Simular timeout no gateway
toxiproxy-cli toxic add payment-gateway -t timeout -a timeout=3000

# Executar 100 pagamentos com retry
for i in {1..100}; do
  curl -X POST http://api/payments \
    -H "Idempotency-Key: $(uuidgen)" \
    -d '{"amount": 100, "card": "4111111111111111"}'
done

# Validar banco
psql -c "SELECT idempotency_key, COUNT(*) FROM payments GROUP BY idempotency_key HAVING COUNT(*) > 1"
```

**Resultado:** Encontrou race condition em lock distribuído

**Fix:**

```java
// Antes (race condition)
if (!paymentRepository.existsByIdempotencyKey(key)) {
    processPayment(key);
}

// Depois (lock + double-check)
try (Lock lock = redisLock.acquire(key, 30)) {
    if (!paymentRepository.existsByIdempotencyKey(key)) {
        processPayment(key);
    }
}
```

---

## 8. Blameless Postmortems

### 8.1 Template de Postmortem

```markdown
# Postmortem: [Nome do Experimento]

**Data:** 2025-01-15
**Duração:** 14:00 - 14:45 (45 minutos)
**Severidade:** Medium (sistema degradou mas não caiu)

## Resumo Executivo

[1-2 parágrafos sobre o que aconteceu]

## Hipótese Original

"Sistema tolera perda de 2 instâncias do Order Service sem degradação"

## O que Aconteceu (Timeline)

| Tempo | Evento                                              |
| ----- | --------------------------------------------------- |
| 14:00 | Experimento iniciado: Killed 2/5 pods order-service |
| 14:02 | p99 latency aumentou de 200ms → 2s                  |
| 14:05 | Circuit Breaker abriu para Payment Service          |
| 14:10 | Novos pods iniciados pelo HPA                       |
| 14:15 | Latência voltou ao normal                           |
| 14:20 | Circuit Breaker fechou                              |

## Hipótese: ✅ Confirmada | ❌ Refutada

**❌ Refutada** - Sistema degradou significativamente (p99 10x maior)

## Causa Raiz

1. HPA configurado para escalar apenas em CPU >80%
2. Alta latência não trigger autoscaling
3. Connection pool esgotado (100 conexões para 3 pods)

## Impacto

- **Usuários:** 2% dos requests com latência >2s
- **Duração:** 10 minutos até recovery
- **Revenue:** Nenhum (staging)

## O que Funcionou Bem ✅

- Circuit Breaker abriu corretamente
- Monitoring detectou problema em <2min
- Rollback automático funcionou

## O que Melhorar 🔧

1. **Curto prazo (1 sprint):**
   - Ajustar HPA: escalar também em p95 latency >500ms
   - Aumentar connection pool de 100 → 300
2. **Médio prazo (1 mês):**
   - Implementar load shedding quando load >80%
   - Adicionar rate limiting por cliente
3. **Longo prazo (3 meses):**
   - Migrar para gRPC (multiplexing)
   - Implementar backpressure

## Action Items

| #   | Ação                          | Responsável | Prazo      | Status |
| --- | ----------------------------- | ----------- | ---------- | ------ |
| 1   | Ajustar HPA trigger           | @joao       | 2025-01-20 | ⏳     |
| 2   | Aumentar connection pool      | @maria      | 2025-01-18 | ✅     |
| 3   | Documento sobre load shedding | @pedro      | 2025-02-15 | ⏳     |

## Lessons Learned

- ⭐ CPU não é único indicador de carga
- ⭐ Connection pool é SPOF em alta carga
- ⭐ Chaos tests encontraram problema que load tests não acharam

## Attachments

- Grafana dashboard: [link]
- Logs: [link]
- Experimento JSON: [chaos-experiment.json]
```

---

## 📊 Checklist de Experimento

### Antes de Executar

- [ ] Hipótese clara e mensurável
- [ ] Baseline de métricas coletado
- [ ] Rollback automático configurado
- [ ] Blast radius definido (<5% usuários)
- [ ] Time alertado (não surpresa)
- [ ] Observabilidade funcionando (Grafana, logs)
- [ ] Runbook de rollback manual pronto

### Durante Execução

- [ ] Monitorar métricas em tempo real
- [ ] Comunicar no Slack #chaos-experiments
- [ ] Anotar timeline de eventos
- [ ] Rollback se SLO violado por >5min

### Após Execução

- [ ] Restaurar sistema ao estado normal
- [ ] Validar métricas voltaram ao baseline
- [ ] Documentar resultados
- [ ] Agendar postmortem (24-48h depois)
- [ ] Criar issues para action items

---

## 📚 Recursos

### Livros

- **Chaos Engineering** (Netflix, O'Reilly)
- **Site Reliability Engineering** (Google)
- **Release It!** (Michael Nygard)

### Ferramentas

- [Chaos Toolkit](https://chaostoolkit.org/)
- [LitmusChaos](https://litmuschaos.io/)
- [Toxiproxy](https://github.com/Shopify/toxiproxy)
- [Pumba](https://github.com/alexei-led/pumba)
- [Chaos Mesh](https://chaos-mesh.org/)

### Comunidade

- [Chaos Engineering Slack](https://chaos-engineering.slack.com)
- [Principles of Chaos Engineering](https://principlesofchaos.org/)
- [Awesome Chaos Engineering](https://github.com/dastergon/awesome-chaos-engineering)

---

**Próximos passos:**

- Ler [Property-Based Testing](property-based-testing.md)
- Ver [Supply Chain Security](supply-chain-security.md)
- Consultar [Glossário](../09-taxonomia/glossario.md)
