# 🔍 Mini-Casos - Entrevistas Técnicas de Testes

## Índice

1. [Como Usar Este Documento](#1-como-usar-este-documento)
2. [Caso 1: E-commerce com Alta Taxa de Cancelamento](#2-caso-1-e-commerce-com-alta-taxa-de-cancelamento)
3. [Caso 2: API Gateway com Latência Intermitente](#3-caso-2-api-gateway-com-latência-intermitente)
4. [Caso 3: Microserviço de Pagamento com Idempotência](#4-caso-3-microserviço-de-pagamento-com-idempotência)
5. [Caso 4: Sistema Legado Sem Testes](#5-caso-4-sistema-legado-sem-testes)
6. [Caso 5: Pipeline CI/CD Lento](#6-caso-5-pipeline-cicd-lento)
7. [Caso 6: Distributed Tracing Quebrado](#7-caso-6-distributed-tracing-quebrado)
8. [Caso 7: Chaos Engineering Incident](#8-caso-7-chaos-engineering-incident)
9. [Caso 8: Flaky Tests em 15%](#9-caso-8-flaky-tests-em-15)
10. [Caso 9: Database Migration Failure](#10-caso-9-database-migration-failure)
11. [Caso 10: Contract Testing entre Times](#11-caso-10-contract-testing-entre-times)

---

## 1. Como Usar Este Documento

### Para Entrevistadores

**Estrutura da Sessão (30-45 min por caso):**

1. **Apresentação (5 min)**: Ler o cenário, dar contexto
2. **Clarificação (5 min)**: Candidato faz perguntas
3. **Análise (10 min)**: Candidato identifica problemas
4. **Proposta (10 min)**: Candidato propõe solução
5. **Discussão (10 min)**: Aprofundar, desafiar suposições

**Perguntas de Follow-up:**

- "Que outras informações você precisaria?"
- "Como você priorizaria essas ações?"
- "Que métricas usaria para validar sucesso?"
- "E se [constraint X] existisse?"

### Para Candidatos

**Framework de Resposta:**

1. ✅ **Clarificar**: Fazer perguntas antes de responder
2. 🔍 **Analisar**: Identificar causas raiz, não sintomas
3. 🎯 **Priorizar**: Propor ações ordenadas por impacto
4. 📊 **Medir**: Definir métricas de sucesso
5. 🔧 **Implementar**: Detalhar ferramentas e técnicas
6. 🔄 **Prevenir**: Propor melhorias de longo prazo

**Red Flags a Evitar:**

- ❌ Pular direto para solução sem entender problema
- ❌ Propor refatoração total sem justificativa
- ❌ Ignorar contexto (time, prazo, recursos)
- ❌ Focar apenas em ferramentas sem estratégia
- ❌ Não considerar trade-offs

---

## 2. Caso 1: E-commerce com Alta Taxa de Cancelamento

### 📋 Cenário

Você é Tech Lead em um e-commerce que processa 10k pedidos/dia. Nas últimas 2 semanas:

- **Taxa de cancelamento** subiu de 2% para 18%
- **Reclamações** de clientes: "pedido cancelado sem motivo"
- **Logs** mostram: `PaymentException: Timeout after 5000ms`
- **Time de Pagamento** diz que o gateway está normal (SLA 99.9%)

**Arquitetura:**

```
[Frontend] → [Order Service] → [Payment Service] → [Payment Gateway]
                    ↓
              [Notification Service]
```

**Código do Payment Service (simplificado):**

```java
@Service
public class PaymentService {

    @Autowired
    private PaymentGatewayClient gatewayClient;

    public PaymentResult processPayment(Order order) {
        try {
            // Timeout fixo de 5 segundos
            PaymentResponse response = gatewayClient.charge(
                order.getCustomerId(),
                order.getTotal(),
                Duration.ofSeconds(5)
            );

            if (response.isApproved()) {
                return PaymentResult.success(response.getTransactionId());
            } else {
                return PaymentResult.failed(response.getReason());
            }
        } catch (TimeoutException e) {
            // Cancela pedido imediatamente
            orderService.cancel(order.getId(), "Payment timeout");
            return PaymentResult.failed("Timeout");
        }
    }
}
```

### 🎯 Desafio

**Como Tech Lead, você precisa:**

1. Identificar a causa raiz
2. Propor solução de curto prazo (hotfix)
3. Propor solução de longo prazo (prevenção)
4. Definir testes que teriam detectado o problema
5. Estabelecer métricas para monitorar

### 💡 Perguntas para o Candidato Fazer

<details>
<summary>Clique para ver perguntas esperadas</summary>

- Qual é a latência p95/p99 do Payment Gateway nas últimas semanas?
- Os timeouts acontecem em horários específicos?
- O gateway retorna erro ou simplesmente demora?
- Há retry implementado?
- Qual é o SLA do gateway (latência, não só disponibilidade)?
- Quantas chamadas simultâneas fazemos ao gateway?
- O gateway tem rate limiting?
- Já validamos se o problema é no nosso lado (rede, DNS)?
</details>

### ✅ Solução Esperada

<details>
<summary>Clique para ver solução modelo (Nível Sênior)</summary>

#### Análise da Causa Raiz

**Problemas identificados:**

1. ✅ **Timeout muito agressivo**: 5s pode ser insuficiente em picos
2. ✅ **Sem retry**: Falha transiente cancela pedido imediatamente
3. ✅ **Sem Circuit Breaker**: Não há proteção contra degradação
4. ✅ **Sem observabilidade**: Não sabemos latência real do gateway
5. ✅ **Sem fallback**: Cancela em vez de tentar alternativa

#### Solução de Curto Prazo (Hotfix - 2h)

```java
@Service
public class PaymentService {

    private static final Duration TIMEOUT = Duration.ofSeconds(15); // 5s → 15s

    @Retryable(
        value = TimeoutException.class,
        maxAttempts = 3,
        backoff = @Backoff(delay = 2000, multiplier = 2)
    )
    public PaymentResult processPayment(Order order) {
        try {
            PaymentResponse response = gatewayClient.charge(
                order.getCustomerId(),
                order.getTotal(),
                TIMEOUT
            );

            if (response.isApproved()) {
                return PaymentResult.success(response.getTransactionId());
            } else {
                return PaymentResult.failed(response.getReason());
            }
        } catch (TimeoutException e) {
            // Não cancela! Marca como pendente para retry posterior
            orderService.markPending(order.getId(), "Payment retry needed");
            throw e; // Retry automático
        }
    }
}
```

**Deploy:**

- Feature flag: `payment.timeout.seconds=15` (configurável sem redeploy)
- Rollout gradual: 10% → 50% → 100%

#### Solução de Longo Prazo (1 sprint)

```java
@Service
public class ResilientPaymentService {

    @Autowired
    private PaymentGatewayClient gatewayClient;

    @Autowired
    private PaymentQueueService queueService;

    // Circuit Breaker com Resilience4j
    @CircuitBreaker(name = "payment-gateway", fallbackMethod = "fallbackPayment")
    @Retry(name = "payment-gateway")
    @TimeLimiter(name = "payment-gateway")
    public PaymentResult processPayment(Order order) {
        Timer.Sample sample = Timer.start(meterRegistry);

        try {
            PaymentResponse response = gatewayClient.charge(
                order.getCustomerId(),
                order.getTotal()
            );

            sample.stop(Timer.builder("payment.gateway.duration")
                .tag("result", "success")
                .register(meterRegistry));

            if (response.isApproved()) {
                return PaymentResult.success(response.getTransactionId());
            } else {
                return PaymentResult.failed(response.getReason());
            }
        } catch (Exception e) {
            sample.stop(Timer.builder("payment.gateway.duration")
                .tag("result", "error")
                .register(meterRegistry));
            throw e;
        }
    }

    private PaymentResult fallbackPayment(Order order, Exception e) {
        log.warn("Payment gateway unavailable, queueing order {}", order.getId(), e);

        // Enfileira para processamento assíncrono
        queueService.enqueuePayment(order);

        return PaymentResult.pending("Payment queued for retry");
    }
}
```

**Configuração (application.yml):**

```yaml
resilience4j:
  circuitbreaker:
    instances:
      payment-gateway:
        slidingWindowSize: 10
        failureRateThreshold: 50
        waitDurationInOpenState: 30s
        permittedNumberOfCallsInHalfOpenState: 3

  retry:
    instances:
      payment-gateway:
        maxAttempts: 3
        waitDuration: 2s
        exponentialBackoffMultiplier: 2
        retryExceptions:
          - java.util.concurrent.TimeoutException
          - org.springframework.web.client.ResourceAccessException

  timelimiter:
    instances:
      payment-gateway:
        timeoutDuration: 10s
```

#### Testes que Teriam Detectado

**1. Integration Test com WireMock (latência simulada):**

```java
@SpringBootTest
@AutoConfigureWireMock(port = 0)
class PaymentServiceIntegrationTest {

    @Test
    @DisplayName("Deve fazer retry quando gateway responde lentamente")
    void shouldRetryOnSlowGateway() {
        // Arrange
        stubFor(post("/charge")
            .inScenario("retry")
            .whenScenarioStateIs(STARTED)
            .willReturn(aResponse()
                .withFixedDelay(6000) // > 5s timeout
                .withStatus(500))
            .willSetStateTo("second-attempt"));

        stubFor(post("/charge")
            .inScenario("retry")
            .whenScenarioStateIs("second-attempt")
            .willReturn(aResponse()
                .withStatus(200)
                .withBody("{\"approved\": true, \"transactionId\": \"tx-123\"}")));

        // Act
        PaymentResult result = paymentService.processPayment(order);

        // Assert
        assertThat(result.isSuccess()).isTrue();
        verify(exactly(2), postRequestedFor(urlEqualTo("/charge")));
    }

    @Test
    @DisplayName("Deve usar fallback quando Circuit Breaker abre")
    void shouldUseFallbackWhenCircuitOpens() {
        // Simular 6 falhas consecutivas (> 50% threshold)
        for (int i = 0; i < 6; i++) {
            stubFor(post("/charge").willReturn(aResponse().withStatus(500)));
            assertThatThrownBy(() -> paymentService.processPayment(order))
                .isInstanceOf(Exception.class);
        }

        // Próxima chamada deve ir direto para fallback (circuit open)
        PaymentResult result = paymentService.processPayment(order);

        assertThat(result.isPending()).isTrue();
        verify(exactly(6), postRequestedFor(urlEqualTo("/charge"))); // Não chama na 7ª
    }
}
```

**2. Performance Test com k6 (carga):**

```javascript
import http from "k6/http";
import { check, sleep } from "k6";

export let options = {
  stages: [
    { duration: "1m", target: 50 }, // Ramp up
    { duration: "3m", target: 50 }, // Sustain
    { duration: "1m", target: 100 }, // Spike
    { duration: "2m", target: 100 },
    { duration: "1m", target: 0 }, // Ramp down
  ],
  thresholds: {
    http_req_duration: ["p(95)<15000"], // p95 < 15s
    payment_cancellation_rate: ["rate<0.05"], // < 5%
  },
};

export default function () {
  let payload = JSON.stringify({
    customerId: "123",
    total: 100.0,
  });

  let response = http.post("http://localhost:8080/api/payments", payload, {
    headers: { "Content-Type": "application/json" },
  });

  check(response, {
    "status is 200": (r) => r.status === 200,
    "not cancelled": (r) => !r.json().cancelled,
  });

  sleep(1);
}
```

**3. Chaos Test (Toxiproxy - latência variável):**

```bash
#!/bin/bash
# chaos-payment-latency.sh

# Criar proxy para Payment Gateway
toxiproxy-cli create payment-gateway -l 0.0.0.0:8474 -u payment-gateway:8080

# Adicionar latência variável (500ms ± 400ms)
toxiproxy-cli toxic add payment-gateway -t latency -a latency=500 -a jitter=400

# Executar testes
mvn test -Dtest=PaymentServiceChaosTest

# Aumentar latência gradualmente
for latency in 1000 2000 5000 10000; do
    echo "Testing with ${latency}ms latency..."
    toxiproxy-cli toxic update payment-gateway -n latency -a latency=$latency

    # Validar que sistema não cancela pedidos
    curl -X POST http://localhost:8080/api/payments \
        -H "Content-Type: application/json" \
        -d '{"customerId": "123", "total": 100}' \
        | jq '.status' | grep -q "pending\|success" || echo "FAILED at ${latency}ms"
done

# Cleanup
toxiproxy-cli delete payment-gateway
```

#### Métricas para Monitorar

**Dashboard Grafana:**

```yaml
panels:
  - title: Payment Gateway Latency
    targets:
      - expr: histogram_quantile(0.95, payment_gateway_duration_bucket)
        legend: p95
      - expr: histogram_quantile(0.99, payment_gateway_duration_bucket)
        legend: p99
    alert:
      condition: p95 > 10s for 5m

  - title: Circuit Breaker State
    targets:
      - expr: resilience4j_circuitbreaker_state{name="payment-gateway"}
        legend: "0=closed, 1=open, 2=half-open"
    alert:
      condition: state == 1 for 5m # Open por muito tempo

  - title: Payment Cancellation Rate
    targets:
      - expr: rate(payment_cancelled_total[5m]) / rate(payment_attempted_total[5m])
    alert:
      condition: rate > 0.05 for 10m # > 5%

  - title: Retry Success Rate
    targets:
      - expr: payment_retry_success_total / payment_retry_total
    threshold: 0.80 # 80% dos retries devem funcionar
```

**Alertas Prometheus:**

```yaml
groups:
  - name: payment_alerts
    rules:
      - alert: HighPaymentCancellationRate
        expr: rate(payment_cancelled_total[10m]) > 0.05
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: "High payment cancellation rate: {{ $value }}"

      - alert: PaymentGatewayHighLatency
        expr: histogram_quantile(0.95, payment_gateway_duration_bucket) > 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Payment gateway p95 latency: {{ $value }}s"
```

#### Prevenção Futura

**1. SLO e Error Budget:**

```yaml
# payment-service-slo.yaml
apiVersion: v1
kind: ServiceLevelObjective
metadata:
  name: payment-availability
spec:
  slo: 99.5%
  errorBudgetPeriod: 30d
  sli:
    query: |
      sum(rate(payment_success_total[5m])) / 
      sum(rate(payment_total[5m]))
```

**2. Quality Gate (CI/CD):**

```yaml
# .gitlab-ci.yml
performance-test:
  stage: test
  script:
    - docker-compose up -d toxiproxy payment-gateway-stub
    - k6 run --out json=results.json performance/payment-load-test.js
    - k6 run --out json=chaos-results.json performance/payment-chaos-test.js
  artifacts:
    reports:
      metrics: results.json
  rules:
    - if: '$CI_MERGE_REQUEST_TARGET_BRANCH_NAME == "main"'
  allow_failure: false
```

**3. Runbook:**

```markdown
# Payment Service - Runbook

## Alert: HighPaymentCancellationRate

### Triage (5 min)

1. Check Payment Gateway status: https://status.gateway.com
2. Check p95/p99 latency: Grafana dashboard
3. Check Circuit Breaker state: `curl /actuator/circuitbreakerevents`

### Mitigation (10 min)

1. If gateway is slow (not down):
   - Increase timeout: `kubectl set env deployment/payment-service PAYMENT_TIMEOUT=20s`
2. If gateway is down:
   - Enable queue mode: `kubectl set env deployment/payment-service PAYMENT_QUEUE_ENABLED=true`

### Root Cause Analysis (30 min)

1. Export traces: Jaeger query for failed payments
2. Analyze retry patterns
3. Check for correlated events (deploy, traffic spike)
```

</details>

### 📊 Critérios de Avaliação

| Aspecto       | Júnior             | Pleno                     | Sênior                                                  |
| ------------- | ------------------ | ------------------------- | ------------------------------------------------------- |
| **Análise**   | Identifica timeout | Identifica falta de retry | Identifica falta de resiliência sistêmica               |
| **Solução**   | Aumenta timeout    | Adiciona retry            | Implementa Circuit Breaker + fallback + observabilidade |
| **Testes**    | Unit test básico   | Integration test com mock | Chaos test + performance test                           |
| **Métricas**  | Menciona logs      | Propõe latência p95       | Define SLO com error budget                             |
| **Prevenção** | "Testar melhor"    | Quality gate no CI/CD     | Cultura de resiliência + runbooks                       |

---

## 3. Caso 2: API Gateway com Latência Intermitente

### 📋 Cenário

Você é Engenheiro de Confiabilidade em uma fintech. O API Gateway está apresentando:

- **Latência intermitente**: p50=100ms, p95=200ms, p99=15s (!!)
- **Horário**: Ocorre entre 18h-20h (horário de pico)
- **Sintoma**: Alguns requests demoram muito, outros são rápidos
- **Logs**: Nada de anormal aparente

**Arquitetura:**

```
[Mobile App] → [API Gateway (Kong)] → [Auth Service]
                                    ↘ [Account Service]
                                    ↘ [Transaction Service]
```

**Métricas observadas:**

- Kong: 1000 req/s no pico
- CPU: 40% (normal)
- Memória: 60% (normal)
- Database: 30% CPU (normal)

### 🎯 Desafio

1. Como você investigaria a causa raiz?
2. Que ferramentas/técnicas usaria para isolar o problema?
3. Como reproduziria o problema em ambiente de teste?
4. Que solução proporia?
5. Como preveniria regressões?

### 💡 Dica Investigativa

<details>
<summary>Clique para ver pista</summary>

**Pergunta-chave:** O que acontece com **conexões TCP** em alta carga?

**Ferramenta útil:**

```bash
# Verificar connection pool
kubectl exec -it kong-pod -- netstat -an | grep ESTABLISHED | wc -l

# Verificar TIME_WAIT
kubectl exec -it kong-pod -- netstat -an | grep TIME_WAIT | wc -l
```

**Possível causa:** Connection pool esgotado ou mal configurado.

</details>

### ✅ Solução Esperada

<details>
<summary>Clique para ver solução modelo</summary>

#### Causa Raiz

**Connection pool exhaustion:**

- Kong tem pool padrão de **100 conexões** por upstream
- Durante pico (1000 req/s), requisições ficam em fila aguardando conexão livre
- Alguns requests pegam conexão imediatamente (p50/p95), outros esperam muito (p99)

#### Investigação

**1. Distributed Tracing (Jaeger):**

```bash
# Buscar traces com latência > 10s
curl 'http://jaeger:16686/api/traces?service=api-gateway&minDuration=10s'

# Analisar spans:
# - Kong processing: 50ms (rápido)
# - Waiting for connection: 14s (!!)
# - Upstream call: 100ms (rápido)
```

**2. Métricas de Connection Pool:**

```promql
# Prometheus queries
kong_upstream_target_health{state="healthy"}  # Quantas conexões saudáveis
kong_nginx_connections_active  # Conexões ativas
kong_nginx_connections_waiting  # Requests aguardando conexão
```

#### Solução

**1. Ajustar Connection Pool:**

```yaml
# kong-config.yaml
_format_version: "2.1"
services:
  - name: account-service
    url: http://account-service:8080
    connect_timeout: 60000
    read_timeout: 60000
    write_timeout: 60000
    retries: 3

upstreams:
  - name: account-upstream
    slots: 1000 # 100 → 1000 conexões
    healthchecks:
      active:
        healthy:
          interval: 5
          successes: 2
        unhealthy:
          interval: 5
          http_failures: 3
      passive:
        unhealthy:
          http_failures: 3
          timeouts: 2
```

**2. Testes de Validação:**

**Performance Test (k6):**

```javascript
import http from "k6/http";
import { check } from "k6";

export let options = {
  stages: [
    { duration: "5m", target: 1000 }, // Simular pico
  ],
  thresholds: {
    "http_req_duration{type:p99}": ["p(99)<1000"], // p99 < 1s
    http_req_failed: ["rate<0.01"], // < 1% errors
  },
};

export default function () {
  let response = http.get("http://api-gateway/account/balance");

  check(response, {
    "status is 200": (r) => r.status === 200,
    "latency < 1s": (r) => r.timings.duration < 1000,
  });
}
```

**Chaos Test (Toxiproxy - limit bandwidth):**

```bash
# Limitar largura de banda para simular conexões lentas
toxiproxy-cli toxic add account-service -t bandwidth -a rate=100

# Executar carga
k6 run --vus 1000 --duration 5m load-test.js

# Validar que p99 < 1s mesmo com bandwidth limitado
```

#### Prevenção

**Monitoring:**

```yaml
# prometheus-alerts.yaml
- alert: HighP99Latency
  expr: histogram_quantile(0.99, rate(http_request_duration_seconds_bucket[5m])) > 1
  for: 5m
  annotations:
    summary: "p99 latency above 1s: {{ $value }}s"

- alert: ConnectionPoolExhaustion
  expr: kong_nginx_connections_waiting > 100
  for: 2m
  annotations:
    summary: "{{ $value }} requests waiting for connection"
```

</details>

---

## 4. Caso 3: Microserviço de Pagamento com Idempotência

### 📋 Cenário

Você está implementando um microserviço de pagamento. Requisito crítico: **idempotência**.

**Problema:** Clientes relatam cobranças duplicadas.

**Código atual:**

```java
@PostMapping("/payments")
public PaymentResponse processPayment(@RequestBody PaymentRequest request) {
    // Valida cartão
    if (!isValidCard(request.getCardNumber())) {
        throw new InvalidCardException();
    }

    // Processa pagamento
    String transactionId = paymentGateway.charge(
        request.getCardNumber(),
        request.getAmount()
    );

    // Salva no banco
    Payment payment = new Payment(
        UUID.randomUUID(),
        request.getCustomerId(),
        request.getAmount(),
        transactionId,
        PaymentStatus.COMPLETED
    );
    paymentRepository.save(payment);

    return new PaymentResponse(payment.getId(), transactionId);
}
```

### 🎯 Desafio

1. Por que o código não é idempotente?
2. Como você implementaria idempotência?
3. Que testes escreveria para validar?
4. Como trataria edge cases (timeout, retry, concorrência)?

### ✅ Solução Esperada

<details>
<summary>Clique para ver solução modelo</summary>

#### Implementação Idempotente

```java
@PostMapping("/payments")
public PaymentResponse processPayment(
    @RequestHeader("Idempotency-Key") String idempotencyKey,
    @RequestBody PaymentRequest request
) {
    // Validar idempotency key
    if (idempotencyKey == null || idempotencyKey.isBlank()) {
        throw new MissingIdempotencyKeyException();
    }

    // Buscar pagamento existente
    Optional<Payment> existing = paymentRepository.findByIdempotencyKey(idempotencyKey);
    if (existing.isPresent()) {
        return toResponse(existing.get());
    }

    // Lock distribuído para prevenir race condition
    String lockKey = "payment:lock:" + idempotencyKey;
    try (RedisLock lock = redisLockService.acquire(lockKey, Duration.ofSeconds(30))) {

        // Double-check após adquirir lock
        existing = paymentRepository.findByIdempotencyKey(idempotencyKey);
        if (existing.isPresent()) {
            return toResponse(existing.get());
        }

        // Processar pagamento
        String transactionId = paymentGateway.charge(
            request.getCardNumber(),
            request.getAmount(),
            idempotencyKey  // Gateway também deve suportar idempotência
        );

        // Salvar atomicamente
        Payment payment = new Payment(
            UUID.randomUUID(),
            idempotencyKey,
            request.getCustomerId(),
            request.getAmount(),
            transactionId,
            PaymentStatus.COMPLETED
        );
        paymentRepository.save(payment);

        return toResponse(payment);

    } catch (LockAcquisitionException e) {
        // Outro processo está processando este pagamento
        throw new ConcurrentPaymentException("Payment is being processed");
    }
}
```

#### Testes

**1. Test de Idempotência Básica:**

```java
@Test
void shouldReturnSameResultForSameIdempotencyKey() {
    String idempotencyKey = UUID.randomUUID().toString();
    PaymentRequest request = new PaymentRequest("card-123", 100.0);

    // Primeira chamada
    PaymentResponse response1 = paymentService.processPayment(idempotencyKey, request);

    // Segunda chamada com mesma key
    PaymentResponse response2 = paymentService.processPayment(idempotencyKey, request);

    // Deve retornar mesmo payment ID
    assertThat(response1.getPaymentId()).isEqualTo(response2.getPaymentId());

    // Gateway deve ser chamado apenas uma vez
    verify(paymentGateway, times(1)).charge(anyString(), anyDouble(), anyString());
}
```

**2. Test de Concorrência:**

```java
@Test
void shouldHandleConcurrentRequestsWithSameIdempotencyKey() throws Exception {
    String idempotencyKey = UUID.randomUUID().toString();
    PaymentRequest request = new PaymentRequest("card-123", 100.0);

    int threadCount = 10;
    ExecutorService executor = Executors.newFixedThreadPool(threadCount);
    CountDownLatch latch = new CountDownLatch(threadCount);

    List<Future<PaymentResponse>> futures = new ArrayList<>();

    // Disparar 10 requests simultâneos com mesma idempotency key
    for (int i = 0; i < threadCount; i++) {
        futures.add(executor.submit(() -> {
            latch.countDown();
            latch.await(); // Sincronizar para executar simultaneamente
            return paymentService.processPayment(idempotencyKey, request);
        }));
    }

    // Coletar resultados
    Set<String> paymentIds = futures.stream()
        .map(f -> f.get().getPaymentId())
        .collect(Collectors.toSet());

    // Deve ter apenas 1 payment ID único
    assertThat(paymentIds).hasSize(1);

    // Gateway chamado apenas uma vez
    verify(paymentGateway, times(1)).charge(anyString(), anyDouble(), anyString());
}
```

**3. Test de Retry após Timeout:**

```java
@Test
void shouldHandleRetryAfterTimeout() {
    String idempotencyKey = UUID.randomUUID().toString();
    PaymentRequest request = new PaymentRequest("card-123", 100.0);

    // Primeira tentativa: timeout no gateway
    when(paymentGateway.charge(anyString(), anyDouble(), anyString()))
        .thenThrow(new TimeoutException());

    assertThatThrownBy(() -> paymentService.processPayment(idempotencyKey, request))
        .isInstanceOf(TimeoutException.class);

    // Segunda tentativa: sucesso
    when(paymentGateway.charge(anyString(), anyDouble(), anyString()))
        .thenReturn("tx-123");

    PaymentResponse response = paymentService.processPayment(idempotencyKey, request);

    assertThat(response.getTransactionId()).isEqualTo("tx-123");

    // Gateway chamado duas vezes (primeira falhou)
    verify(paymentGateway, times(2)).charge(anyString(), anyDouble(), anyString());
}
```

</details>

---

## 5. Caso 4: Sistema Legado Sem Testes

### 📋 Cenário

Você herdou um sistema de 80k linhas de código Java, **0% de cobertura de testes**. O sistema:

- Está em produção há 5 anos
- Processa transações bancárias críticas
- Tem 3 bugs reportados por semana
- Time tem medo de mexer no código

**Seu objetivo:** Adicionar funcionalidade nova (integração com Pix) sem quebrar o existente.

### 🎯 Desafio

1. Por onde começar a adicionar testes?
2. Como priorizar o que testar?
3. Que estratégia usar para não quebrar o existente?
4. Como medir progresso?

### ✅ Solução Esperada

<details>
<summary>Clique para ver solução modelo</summary>

#### Estratégia (baseada em "Working Effectively with Legacy Code")

**1. Não Tentar Testar Tudo:**

- Impossível e improdutivo
- Focar em áreas de maior risco

**2. Characterization Tests:**

- Capturar comportamento atual (mesmo que bugado)
- Prevenir regressões

**3. Seam Points:**

- Identificar pontos de injeção de dependências
- Refatoração mínima para testabilidade

#### Implementação

**1. Análise de Risco (Matriz):**

```markdown
| Módulo             | Complexidade | Mudança Freq. | Bugs/Ano | Prioridade |
| ------------------ | ------------ | ------------- | -------- | ---------- |
| TransactionService | Alta         | Alta          | 12       | CRÍTICA    |
| AccountService     | Média        | Média         | 5        | ALTA       |
| ReportService      | Baixa        | Baixa         | 1        | BAIXA      |
```

**2. Characterization Test Exemplo:**

```java
@Test
void captureCurrentBehavior_TransactionService_transfer() {
    // Setup
    Account from = new Account("123", 1000.0);
    Account to = new Account("456", 500.0);

    // Execute
    TransactionResult result = legacyTransactionService.transfer(from, to, 200.0);

    // Capture current behavior (pode estar bugado, mas é o atual)
    assertThat(result.isSuccess()).isTrue();
    assertThat(from.getBalance()).isEqualTo(800.0);
    assertThat(to.getBalance()).isEqualTo(700.0);
    assertThat(result.getFee()).isEqualTo(5.0); // descoberto executando

    // Documentar comportamento inesperado
    // TODO: Bug? Fee deveria ser 2.0 conforme doc, mas código retorna 5.0
}
```

**3. Golden Master Testing:**

```java
@Test
void goldenMasterTest_monthlyReport() throws Exception {
    // Input conhecido
    List<Transaction> transactions = loadTransactionsFromFile("golden-input.json");

    // Executar
    Report report = reportService.generateMonthly(transactions);

    // Comparar com golden output
    String actual = objectMapper.writeValueAsString(report);
    String expected = new String(Files.readAllBytes(
        Paths.get("src/test/resources/golden-output.json")
    ));

    // Se falhar, avaliar se mudança é intencional ou bug
    assertThat(actual).isEqualToIgnoringWhitespace(expected);
}
```

**4. Refatoração Incremental:**

```java
// Antes (não testável - depende de new)
public class TransactionService {
    public void process(Transaction tx) {
        Database db = new Database(); // dependência hard-coded
        db.save(tx);
    }
}

// Depois (testável - dependency injection)
public class TransactionService {
    private final Database database;

    // Constructor injection
    public TransactionService(Database database) {
        this.database = database;
    }

    public void process(Transaction tx) {
        database.save(tx);
    }
}

// Test
@Test
void shouldSaveTransaction() {
    Database mockDb = mock(Database.class);
    TransactionService service = new TransactionService(mockDb);

    service.process(new Transaction("tx-123", 100.0));

    verify(mockDb).save(argThat(tx -> tx.getId().equals("tx-123")));
}
```

**5. Métricas de Progresso:**

```bash
# Script para medir cobertura incremental
#!/bin/bash

# Cobertura por módulo
mvn jacoco:report
cat target/site/jacoco/index.html | grep -A 5 "TransactionService"

# Diff coverage (apenas código novo)
./scripts/diff-coverage.sh origin/main HEAD

# Mutation score (qualidade dos testes)
mvn org.pitest:pitest-maven:mutationCoverage
```

</details>

---

_(Casos 6-10 seguem estrutura similar com diferentes cenários: Distributed Tracing, Chaos Engineering, Flaky Tests, Database Migration, Contract Testing)_

---

## 📊 Resumo dos Casos

| Caso | Tema Principal          | Nível  | Duração | Skills Avaliadas                                 |
| ---- | ----------------------- | ------ | ------- | ------------------------------------------------ |
| 1    | E-commerce Cancelamento | Sênior | 45 min  | Resiliência, Circuit Breaker, Observabilidade    |
| 2    | API Gateway Latência    | Sênior | 30 min  | Performance, Troubleshooting, Connection Pool    |
| 3    | Pagamento Idempotência  | Sênior | 30 min  | Distributed Systems, Concurrency, Testing        |
| 4    | Legacy Code             | Sênior | 45 min  | Refatoração, Priorização, Characterization Tests |
| 5    | CI/CD Lento             | Pleno  | 30 min  | Pipeline, Paralelização, Trade-offs              |
| 6    | Tracing Quebrado        | Sênior | 30 min  | Observabilidade, Debugging Distribuído           |
| 7    | Chaos Incident          | Sênior | 45 min  | Chaos Engineering, Blameless Postmortem          |
| 8    | Flaky Tests 15%         | Pleno  | 30 min  | Test Reliability, Root Cause Analysis            |
| 9    | Migration Failure       | Sênior | 30 min  | Database, Rollback, Blue-Green                   |
| 10   | Contract Testing        | Sênior | 45 min  | Microservices, Consumer-Driven Contracts         |

---

## 📚 Próximos Passos

- Ver [rubrica de avaliação](rubrica-avaliacao.md) para critérios detalhados
- Praticar com [perguntas técnicas](perguntas-tecnicas.md)
- Consultar [glossário](../12-taxonomia/glossario.md) para termos técnicos
