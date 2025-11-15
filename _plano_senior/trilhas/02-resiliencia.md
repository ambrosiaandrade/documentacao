# Trilha de Resiliência - Exercícios Práticos

**Objetivo:** Dominar técnicas para criar **sistemas resilientes** que se recuperam de falhas automaticamente usando **Circuit Breaker**, **Retry**, **Fallback**, **Timeout** e **Chaos Engineering**.

**Nível:** Avançado → Expert  
**Tempo Estimado:** 10-12 horas  
**Pré-requisitos:** Spring Boot, Resilience4j, Testcontainers, conceitos de sistemas distribuídos

---

## 🧪 Exercício 1: Implementar Circuit Breaker com Resilience4j

### 🎯 Objetivo

Proteger seu serviço de falhas em cascata quando dependência externa está fora do ar.

### 📖 Contexto

Seu serviço de pedidos chama API de pagamento externa. Quando essa API fica lenta/fora, seu serviço também trava. Você precisa implementar Circuit Breaker para **isolar a falha**.

### 🛠️ Passos

#### 1. Adicionar Dependências

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
<dependency>
    <groupId>io.github.resilience4j</groupId>
    <artifactId>resilience4j-spring-boot3</artifactId>
    <version>2.2.0</version>
</dependency>
```

#### 2. Configurar Circuit Breaker

```yaml
# application.yml
resilience4j:
  circuitbreaker:
    instances:
      paymentService:
        sliding-window-size: 10 # Janela de 10 requisições
        failure-rate-threshold: 50 # Abre se 50% falharem
        wait-duration-in-open-state: 60000 # Aguarda 60s antes de tentar HALF_OPEN
        permitted-number-of-calls-in-half-open-state: 3
        automatic-transition-from-open-to-half-open-enabled: true
        minimum-number-of-calls: 5 # Mínimo de chamadas antes de calcular taxa
```

#### 3. Implementar Serviço com Circuit Breaker

```java
@Service
public class PaymentService {

    private final RestTemplate restTemplate;
    private final CircuitBreakerRegistry circuitBreakerRegistry;

    @CircuitBreaker(name = "paymentService", fallbackMethod = "paymentFallback")
    public PaymentResult processPayment(String orderId, BigDecimal amount) {
        // Chama API externa
        String url = "https://payment-api.example.com/charge";
        PaymentRequest request = new PaymentRequest(orderId, amount);

        ResponseEntity<PaymentResponse> response = restTemplate.postForEntity(
            url,
            request,
            PaymentResponse.class
        );

        if (response.getStatusCode().is2xxSuccessful()) {
            return PaymentResult.success(response.getBody().getTransactionId());
        } else {
            throw new PaymentException("Payment failed: " + response.getStatusCode());
        }
    }

    // Fallback executado quando circuit está OPEN
    private PaymentResult paymentFallback(String orderId, BigDecimal amount, Exception ex) {
        log.warn("Circuit breaker activated for order {}: {}", orderId, ex.getMessage());

        // Estratégia: Colocar em fila para processamento posterior
        queueService.enqueuePayment(orderId, amount);

        return PaymentResult.queued(orderId, "Payment queued due to service unavailability");
    }
}
```

#### 4. Criar Testes para Circuit Breaker

```java
@SpringBootTest
@ExtendWith(MockitoExtension.class)
class PaymentServiceCircuitBreakerTest {

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private CircuitBreakerRegistry circuitBreakerRegistry;

    @MockBean
    private RestTemplate restTemplate;

    @BeforeEach
    void setUp() {
        // Resetar circuit breaker
        circuitBreakerRegistry.circuitBreaker("paymentService").reset();
    }

    @Test
    void shouldOpenCircuit_afterMultipleFailures() {
        // Arrange - Simular falhas consecutivas
        when(restTemplate.postForEntity(anyString(), any(), eq(PaymentResponse.class)))
            .thenThrow(new RestClientException("Connection timeout"));

        // Act - Fazer 6 chamadas (mais que sliding-window-size)
        for (int i = 0; i < 6; i++) {
            try {
                paymentService.processPayment("ORD-" + i, BigDecimal.valueOf(100));
            } catch (Exception e) {
                // Esperado
            }
        }

        // Assert - Circuit deve estar OPEN
        CircuitBreaker circuitBreaker = circuitBreakerRegistry.circuitBreaker("paymentService");
        assertThat(circuitBreaker.getState()).isEqualTo(CircuitBreaker.State.OPEN);
    }

    @Test
    void shouldExecuteFallback_whenCircuitIsOpen() {
        // Arrange - Forçar circuit OPEN
        CircuitBreaker circuitBreaker = circuitBreakerRegistry.circuitBreaker("paymentService");
        circuitBreaker.transitionToOpenState();

        // Act
        PaymentResult result = paymentService.processPayment("ORD-123", BigDecimal.valueOf(100));

        // Assert - Fallback executado
        assertThat(result.getStatus()).isEqualTo(PaymentStatus.QUEUED);
        assertThat(result.getMessage()).contains("queued");

        // Verificar que API externa NÃO foi chamada
        verify(restTemplate, never()).postForEntity(anyString(), any(), any());
    }

    @Test
    void shouldTransitionToHalfOpen_afterWaitDuration() throws Exception {
        // Arrange - Circuit OPEN
        CircuitBreaker circuitBreaker = circuitBreakerRegistry.circuitBreaker("paymentService");
        circuitBreaker.transitionToOpenState();

        assertThat(circuitBreaker.getState()).isEqualTo(CircuitBreaker.State.OPEN);

        // Act - Aguardar wait-duration (simulado)
        Thread.sleep(61000); // 61 segundos (mais que wait-duration-in-open-state)

        // Tentar chamada (deve transicionar para HALF_OPEN)
        when(restTemplate.postForEntity(anyString(), any(), eq(PaymentResponse.class)))
            .thenReturn(ResponseEntity.ok(new PaymentResponse("TXN-123")));

        paymentService.processPayment("ORD-456", BigDecimal.valueOf(100));

        // Assert - Deve estar HALF_OPEN ou CLOSED (se sucesso)
        CircuitBreaker.State state = circuitBreaker.getState();
        assertThat(state).isIn(CircuitBreaker.State.HALF_OPEN, CircuitBreaker.State.CLOSED);
    }

    @Test
    void shouldCloseCircuit_afterSuccessfulCallsInHalfOpen() {
        // Arrange - Forçar HALF_OPEN
        CircuitBreaker circuitBreaker = circuitBreakerRegistry.circuitBreaker("paymentService");
        circuitBreaker.transitionToHalfOpenState();

        when(restTemplate.postForEntity(anyString(), any(), eq(PaymentResponse.class)))
            .thenReturn(ResponseEntity.ok(new PaymentResponse("TXN-123")));

        // Act - Fazer 3 chamadas bem-sucedidas (permitted-number-of-calls-in-half-open-state)
        for (int i = 0; i < 3; i++) {
            paymentService.processPayment("ORD-" + i, BigDecimal.valueOf(100));
        }

        // Assert - Circuit deve voltar para CLOSED
        assertThat(circuitBreaker.getState()).isEqualTo(CircuitBreaker.State.CLOSED);
    }
}
```

#### 5. Monitorar Circuit Breaker (Métricas)

```java
@Component
public class CircuitBreakerMetrics {

    private final MeterRegistry meterRegistry;
    private final CircuitBreakerRegistry circuitBreakerRegistry;

    @PostConstruct
    public void init() {
        CircuitBreaker circuitBreaker = circuitBreakerRegistry.circuitBreaker("paymentService");

        // Registrar métricas customizadas
        Gauge.builder("circuit.breaker.state", circuitBreaker, cb -> {
            switch (cb.getState()) {
                case CLOSED: return 0;
                case OPEN: return 1;
                case HALF_OPEN: return 0.5;
                default: return -1;
            }
        }).register(meterRegistry);

        // Event listeners para logs
        circuitBreaker.getEventPublisher()
            .onStateTransition(event -> {
                log.info("Circuit Breaker state transition: {} -> {}",
                    event.getStateTransition().getFromState(),
                    event.getStateTransition().getToState());
            })
            .onFailureRateExceeded(event -> {
                log.warn("Failure rate exceeded: {}%", event.getFailureRate());
            });
    }
}
```

### ✅ Critério de Sucesso

- ✅ Circuit abre após threshold de falhas (50% em 10 requisições)
- ✅ Fallback executado quando circuit está OPEN
- ✅ Circuit transiciona OPEN → HALF_OPEN → CLOSED automaticamente
- ✅ Métricas exportadas (Prometheus/Grafana)
- ✅ Logs de state transitions registrados
- ✅ Testes validam todos os estados (CLOSED, OPEN, HALF_OPEN)

### ⚠️ Pitfalls

- ❌ **Threshold muito baixo:** Circuit abre com 1 falha temporária
- ❌ **wait-duration muito curto:** Circuit reabre antes da dependência recuperar
- ❌ **Fallback com dependência:** Fallback chama outra API que pode falhar
- ❌ **Não monitorar:** Circuit abre e ninguém percebe

### 🚀 Extensão

1. **Rate Limiter:** Combinar com rate limiting para não sobrecarregar API após recovery
2. **Bulkhead:** Isolar pools de threads para diferentes circuitos
3. **Dashboard:** Criar dashboard Grafana com estados dos circuits

---

## 🔁 Exercício 2: Retry Exponencial com Idempotência

### 🎯 Objetivo

Implementar **retry exponencial** garantindo que operações sejam **idempotentes** para evitar duplicações.

### 📖 Contexto

API de envio de email ocasionalmente retorna erro 503 (temporário). Você precisa retentar com backoff exponencial sem enviar email duplicado.

### 🛠️ Passos

#### 1. Configurar Retry

```yaml
resilience4j:
  retry:
    instances:
      emailService:
        max-attempts: 3
        wait-duration: 1000 # 1 segundo inicial
        enable-exponential-backoff: true
        exponential-backoff-multiplier: 2 # 1s → 2s → 4s
        retry-exceptions:
          - java.net.SocketTimeoutException
          - org.springframework.web.client.HttpServerErrorException$ServiceUnavailable
```

#### 2. Implementar Serviço com Retry

```java
@Service
public class EmailService {

    private final RestTemplate restTemplate;
    private final EmailRepository emailRepository;

    @Retry(name = "emailService")
    public void sendEmail(String idempotencyKey, EmailRequest request) {
        // Verificar se email já foi enviado (idempotência)
        Optional<EmailLog> existing = emailRepository.findByIdempotencyKey(idempotencyKey);

        if (existing.isPresent()) {
            log.info("Email already sent with key {}", idempotencyKey);
            return; // Idempotente - não reenvia
        }

        try {
            // Chamar API externa
            String url = "https://email-api.example.com/send";
            ResponseEntity<EmailResponse> response = restTemplate.postForEntity(
                url,
                request,
                EmailResponse.class
            );

            if (response.getStatusCode().is2xxSuccessful()) {
                // Registrar sucesso
                EmailLog log = new EmailLog();
                log.setIdempotencyKey(idempotencyKey);
                log.setStatus(EmailStatus.SENT);
                log.setMessageId(response.getBody().getMessageId());
                emailRepository.save(log);
            }

        } catch (HttpServerErrorException.ServiceUnavailable ex) {
            log.warn("Email API unavailable, will retry: {}", ex.getMessage());
            throw ex; // Retry vai retentar
        }
    }
}
```

#### 3. Testar Retry com WireMock

```java
@SpringBootTest
@AutoConfigureWireMock(port = 0)
class EmailServiceRetryTest {

    @Autowired
    private EmailService emailService;

    @Test
    void shouldRetryOnServiceUnavailable() {
        // Arrange - Simular 2 falhas + 1 sucesso
        stubFor(post(urlEqualTo("/send"))
            .inScenario("Retry")
            .whenScenarioStateIs(STARTED)
            .willReturn(aResponse().withStatus(503))
            .willSetStateTo("First Retry"));

        stubFor(post(urlEqualTo("/send"))
            .inScenario("Retry")
            .whenScenarioStateIs("First Retry")
            .willReturn(aResponse().withStatus(503))
            .willSetStateTo("Second Retry"));

        stubFor(post(urlEqualTo("/send"))
            .inScenario("Retry")
            .whenScenarioStateIs("Second Retry")
            .willReturn(aResponse()
                .withStatus(200)
                .withBody("{\"messageId\": \"MSG-123\"}")));

        // Act
        EmailRequest request = new EmailRequest("user@example.com", "Subject", "Body");
        emailService.sendEmail("IDEMPOTENCY-KEY-123", request);

        // Assert - 3 tentativas (2 falhas + 1 sucesso)
        verify(3, postRequestedFor(urlEqualTo("/send")));
    }

    @Test
    void shouldNotSendDuplicateEmail_whenRetryingWithSameIdempotencyKey() {
        // Arrange - Email já foi enviado
        EmailLog existingLog = new EmailLog();
        existingLog.setIdempotencyKey("IDEMPOTENCY-KEY-456");
        existingLog.setStatus(EmailStatus.SENT);
        emailRepository.save(existingLog);

        stubFor(post(urlEqualTo("/send"))
            .willReturn(aResponse().withStatus(200)));

        // Act
        EmailRequest request = new EmailRequest("user@example.com", "Subject", "Body");
        emailService.sendEmail("IDEMPOTENCY-KEY-456", request);

        // Assert - API NÃO foi chamada (idempotência)
        verify(0, postRequestedFor(urlEqualTo("/send")));
    }

    @Test
    void shouldRespectExponentialBackoff() {
        // Arrange
        stubFor(post(urlEqualTo("/send"))
            .willReturn(aResponse().withStatus(503)));

        long startTime = System.currentTimeMillis();

        // Act - Tentar enviar (vai falhar e retentar)
        try {
            emailService.sendEmail("KEY-789", new EmailRequest("user@example.com", "S", "B"));
        } catch (Exception e) {
            // Esperado após 3 tentativas
        }

        long duration = System.currentTimeMillis() - startTime;

        // Assert - Tempo total deve ser ~7s (1s + 2s + 4s)
        assertThat(duration).isBetween(6000L, 8000L);
    }
}
```

### ✅ Critério de Sucesso

- ✅ Retry automático em erros 5xx
- ✅ Backoff exponencial (1s → 2s → 4s)
- ✅ Idempotência garante não duplicar operação
- ✅ Após max attempts, falha definitivamente
- ✅ Métricas: tentativas por requisição, taxa de sucesso no 2º retry

### ⚠️ Pitfalls

- ❌ **Retry em 4xx:** Erro do cliente não deve retentar
- ❌ **Backoff fixo:** Thundering herd (todos retentam ao mesmo tempo)
- ❌ **Sem idempotência:** Duplica operações (cobranças, emails)
- ❌ **Retry infinito:** Nunca desistir esgota recursos

### 🚀 Extensão

1. **Jitter:** Adicionar aleatoriedade ao backoff para evitar sincronização
2. **Retry budgets:** Limitar retries globais (ex: máximo 10% do tráfego)
3. **Dead Letter Queue:** Enviar falhas definitivas para fila de análise

---

## 🎭 Exercício 3: Chaos Engineering - Simulação de Falhas

### 🎯 Objetivo

Validar resiliência do sistema **injetando falhas propositalmente** (latência, partition, crash).

### 📖 Contexto

Você quer garantir que seu sistema se recupera de falhas de rede, lentidão e indisponibilidade de dependências.

### 🛠️ Passos

#### 1. Instalar Toxiproxy (Simulador de Falhas)

```bash
docker run -d --name toxiproxy \
  -p 8474:8474 \
  -p 8666:8666 \
  ghcr.io/shopify/toxiproxy:latest
```

#### 2. Configurar Proxy para Dependência

```java
@Testcontainers
@SpringBootTest
class ChaosEngineeringTest {

    @Container
    static ToxiproxyContainer toxiproxy = new ToxiproxyContainer(
        "ghcr.io/shopify/toxiproxy:2.5.0"
    );

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");

    private ToxiproxyClient toxiproxyClient;
    private Proxy databaseProxy;

    @BeforeEach
    void setUp() throws Exception {
        toxiproxyClient = new ToxiproxyClient(
            toxiproxy.getHost(),
            toxiproxy.getControlPort()
        );

        // Criar proxy para banco de dados
        databaseProxy = toxiproxyClient.createProxy(
            "database",
            "0.0.0.0:8666",
            postgres.getHost() + ":" + postgres.getFirstMappedPort()
        );
    }

    @Test
    void shouldHandleNetworkLatency() throws Exception {
        // Arrange - Adicionar latência de 5 segundos
        databaseProxy.toxics()
            .latency("latency", ToxicDirection.DOWNSTREAM, 5000);

        // Act - Tentar executar query (deve ter timeout configurado)
        long startTime = System.currentTimeMillis();

        assertThatThrownBy(() -> {
            userRepository.findAll(); // Timeout deve ocorrer
        }).isInstanceOf(QueryTimeoutException.class);

        long duration = System.currentTimeMillis() - startTime;

        // Assert - Deve falhar antes de 10s (timeout configurado)
        assertThat(duration).isLessThan(10000);
    }

    @Test
    void shouldHandleNetworkPartition() throws Exception {
        // Arrange - Simular partition (timeout infinito)
        databaseProxy.toxics()
            .timeout("timeout", ToxicDirection.DOWNSTREAM, 0); // 0 = infinito

        // Act & Assert - Deve falhar rapidamente (não travar)
        assertThatThrownBy(() -> {
            userRepository.findById(1L);
        }).hasCauseInstanceOf(SocketTimeoutException.class);

        // Verificar que circuit breaker abriu
        CircuitBreaker circuitBreaker = circuitBreakerRegistry.circuitBreaker("database");
        assertThat(circuitBreaker.getState()).isEqualTo(CircuitBreaker.State.OPEN);
    }

    @Test
    void shouldRecoverAfterPartitionHeals() throws Exception {
        // Arrange - Criar partition
        Toxic toxic = databaseProxy.toxics()
            .timeout("timeout", ToxicDirection.DOWNSTREAM, 0);

        // Act - Falhar requisições (circuit abre)
        for (int i = 0; i < 10; i++) {
            try {
                userRepository.findAll();
            } catch (Exception e) {
                // Esperado
            }
        }

        CircuitBreaker circuitBreaker = circuitBreakerRegistry.circuitBreaker("database");
        assertThat(circuitBreaker.getState()).isEqualTo(CircuitBreaker.State.OPEN);

        // Remover partition (rede volta)
        toxic.remove();

        // Aguardar wait-duration e tentar novamente
        Thread.sleep(61000);

        // Assert - Circuit deve fechar após sucessos
        List<User> users = userRepository.findAll();
        assertThat(users).isNotEmpty();
        assertThat(circuitBreaker.getState()).isEqualTo(CircuitBreaker.State.CLOSED);
    }

    @Test
    void shouldHandleSlowResponses() throws Exception {
        // Arrange - Adicionar 3s de latência
        databaseProxy.toxics()
            .latency("slow", ToxicDirection.DOWNSTREAM, 3000);

        // Act - Requisições devem completar (mas lentas)
        long startTime = System.currentTimeMillis();
        List<User> users = userRepository.findAll();
        long duration = System.currentTimeMillis() - startTime;

        // Assert
        assertThat(users).isNotNull();
        assertThat(duration).isBetween(3000L, 4000L);

        // Verificar métricas de latência
        Timer timer = meterRegistry.timer("database.query.time");
        assertThat(timer.mean(TimeUnit.MILLISECONDS)).isGreaterThan(3000);
    }
}
```

#### 3. Testar Cascata de Falhas

```java
@Test
void shouldNotCascadeFail_whenPaymentServiceIsDown() throws Exception {
    // Arrange - Payment service totalmente indisponível
    paymentProxy.disable();

    // Act - Criar pedido (payment deve usar fallback)
    OrderRequest request = new OrderRequest(
        List.of(new Item("Product", BigDecimal.TEN)),
        BigDecimal.TEN
    );

    Order order = orderService.createOrder(request);

    // Assert - Pedido criado com status PENDING (não FAILED)
    assertThat(order.getStatus()).isEqualTo(OrderStatus.PENDING_PAYMENT);
    assertThat(order.getId()).isNotNull();

    // Order service deve continuar funcionando
    List<Order> allOrders = orderService.findAll();
    assertThat(allOrders).contains(order);
}
```

### ✅ Critério de Sucesso

- ✅ Sistema sobrevive a latência de 5s em dependência
- ✅ System sobrevive a network partition
- ✅ Circuit breaker abre durante falhas
- ✅ Sistema se recupera automaticamente quando dependência volta
- ✅ Falhas não cascateiam (isolation)
- ✅ Timeouts configurados impedem travamento

### ⚠️ Pitfalls

- ❌ **Sem timeouts:** Sistema trava esperando resposta infinitamente
- ❌ **Sem circuit breaker:** Continua chamando dependência falha
- ❌ **Sem fallback:** Erro total ao invés de degradação graceful
- ❌ **Testar apenas em ambiente perfeito:** Produção tem falhas reais

### 🚀 Extensão

1. **Gameday:** Simular falhas em produção (com monitoramento)
2. **Chaos Monkey:** Desligar instâncias aleatoriamente
3. **Stress testing:** Injetar latência + alto volume de requisições

---

## ⏱️ Exercício 4: Timeout Hierárquico

### 🎯 Objetivo

Configurar **timeouts em múltiplas camadas** garantindo que falhas não travem sistema.

### 📖 Contexto

Seu serviço faz chamada: **Client → API Gateway → Backend Service → Database**

Cada camada precisa de timeout apropriado para não bloquear a anterior.

### 🛠️ Passos

#### 1. Configurar Timeouts em Camadas

```yaml
# Client (5s total)
http:
  client:
    connect-timeout: 1000 # 1s para conectar
    read-timeout: 4000 # 4s para resposta

# API Gateway (4s)
gateway:
  routes:
    - id: backend
      uri: lb://backend-service
      predicates:
        - Path=/api/**
      filters:
        - name: CircuitBreaker
          args:
            name: backend
            fallbackUri: forward:/fallback
        - name: Timeout
          args:
            timeout: 4s # Gateway timeout < Client timeout

# Backend Service (3s)
spring:
  datasource:
    hikari:
      connection-timeout: 1000
      validation-timeout: 1000
  jpa:
    properties:
      javax.persistence.query.timeout: 2000 # Query timeout 2s
```

#### 2. Implementar Timeouts Explícitos

```java
@Service
public class OrderService {

    private final RestTemplate restTemplate;

    @TimeLimiter(name = "orderService")  // Timeout via Resilience4j
    public CompletableFuture<Order> createOrderAsync(OrderRequest request) {
        return CompletableFuture.supplyAsync(() -> {
            // Chamar payment service (com timeout próprio)
            PaymentResult payment = paymentService.processPayment(
                request.getTotalAmount()
            );

            // Salvar ordem (com query timeout)
            Order order = new Order();
            order.setPaymentId(payment.getPaymentId());
            return orderRepository.save(order);
        });
    }
}
```

**Configuração:**

```yaml
resilience4j:
  timelimiter:
    instances:
      orderService:
        timeout-duration: 3s
        cancel-running-future: true # Cancelar future se timeout
```

#### 3. Testar Timeouts

```java
@Test
void shouldTimeout_whenServiceIsSlow() {
    // Arrange - Simular lentidão (5s)
    when(paymentService.processPayment(any()))
        .thenAnswer(invocation -> {
            Thread.sleep(5000);
            return PaymentResult.success("TXN-123");
        });

    // Act & Assert - Deve falhar por timeout (3s configurado)
    assertThatThrownBy(() -> {
        orderService.createOrderAsync(request).get();
    })
        .hasCauseInstanceOf(TimeoutException.class);
}

@Test
void shouldCascadeTimeouts_correctly() {
    // Client timeout: 5s
    // Gateway timeout: 4s
    // Backend timeout: 3s
    // Query timeout: 2s

    // Simular query lenta (2.5s) - deve falhar no query timeout
    when(orderRepository.save(any()))
        .thenAnswer(inv -> {
            Thread.sleep(2500);
            return inv.getArgument(0);
        });

    // Backend vai falhar em 2s (query timeout)
    // Gateway vai receber erro antes de 4s
    // Client vai receber erro antes de 5s

    long start = System.currentTimeMillis();

    assertThatThrownBy(() -> {
        orderService.createOrderAsync(request).get();
    });

    long duration = System.currentTimeMillis() - start;

    // Deve falhar em ~2s (query timeout), não esperar 5s (client timeout)
    assertThat(duration).isLessThan(3000);
}
```

### ✅ Critério de Sucesso

- ✅ Timeout configurado em todas as camadas
- ✅ Timeouts hierárquicos (cada camada < anterior)
- ✅ Operação cancela ao atingir timeout (não fica zumbi)
- ✅ Métricas de timeout por serviço
- ✅ Cliente não espera mais que timeout máximo

### ⚠️ Pitfalls

- ❌ **Timeout muito curto:** Falsos positivos em operações legítimas
- ❌ **Timeout muito longo:** Cliente trava esperando
- ❌ **Timeout igual em camadas:** Layer superior espera mais que inferior
- ❌ **Sem cancelamento:** Thread fica executando após timeout

### 🚀 Extensão

1. **Timeout adaptativo:** Ajustar baseado em P99 de latência
2. **Budget propagation:** Propagar tempo restante via header
3. **Deadline propagation:** gRPC deadline context

---

## 🔥 Exercício 5: Bulkhead Pattern - Isolamento de Recursos

### 🎯 Objetivo

Isolar pools de recursos para que falha em feature secundária não derrube feature crítica.

### 📖 Contexto

Seu serviço tem 2 features:

- **Crítica:** Processar pedidos (prioridade alta)
- **Secundária:** Gerar relatórios (pode falhar sem impacto)

Sem bulkhead, relatórios lentos podem esgotar thread pool e travar processamento de pedidos.

### 🛠️ Passos

#### 1. Configurar Bulkhead

```yaml
resilience4j:
  bulkhead:
    instances:
      orderProcessing:
        max-concurrent-calls: 10
        max-wait-duration: 0 # Rejeitar imediatamente se pool cheio
      reportGeneration:
        max-concurrent-calls: 3
        max-wait-duration: 0
```

#### 2. Implementar Serviços com Bulkhead

```java
@Service
public class OrderService {

    @Bulkhead(name = "orderProcessing")
    public Order processOrder(OrderRequest request) {
        // Feature crítica - pool isolado de 10 threads
        // ...
    }
}

@Service
public class ReportService {

    @Bulkhead(name = "reportGeneration")
    public Report generateReport(ReportRequest request) {
        // Feature secundária - pool isolado de 3 threads
        // ...
    }
}
```

#### 3. Testar Isolamento

```java
@Test
void shouldIsolatePools_reportFailureDoesNotAffectOrders() throws Exception {
    // Arrange - Saturar pool de relatórios (3 threads + 1)
    CountDownLatch latch = new CountDownLatch(3);

    // Iniciar 3 relatórios lentos (saturar pool)
    for (int i = 0; i < 3; i++) {
        executor.submit(() -> {
            try {
                reportService.generateReport(new ReportRequest());
                latch.countDown();
            } catch (Exception e) {
                // ...
            }
        });
    }

    // Act - Tentar 4º relatório (deve ser rejeitado - pool cheio)
    assertThatThrownBy(() -> {
        reportService.generateReport(new ReportRequest());
    }).hasCauseInstanceOf(BulkheadFullException.class);

    // Mas processamento de pedidos deve continuar funcionando
    Order order = orderService.processOrder(new OrderRequest(...));
    assertThat(order.getId()).isNotNull();
    assertThat(order.getStatus()).isEqualTo(OrderStatus.PROCESSING);
}

@Test
void shouldMonitorBulkheadSaturation() {
    // Act - Saturar pool de pedidos
    List<CompletableFuture<Order>> futures = new ArrayList<>();

    for (int i = 0; i < 15; i++) {  // Mais que max-concurrent-calls (10)
        CompletableFuture<Order> future = CompletableFuture.supplyAsync(() ->
            orderService.processOrder(new OrderRequest(...))
        );
        futures.add(future);
    }

    // Assert - 5 requisições devem ser rejeitadas
    long rejected = futures.stream()
        .filter(f -> {
            try {
                f.get();
                return false;
            } catch (Exception e) {
                return e.getCause() instanceof BulkheadFullException;
            }
        })
        .count();

    assertThat(rejected).isEqualTo(5);

    // Verificar métrica de saturação
    Gauge gauge = meterRegistry.find("resilience4j.bulkhead.available.concurrent.calls")
        .tag("name", "orderProcessing")
        .gauge();

    assertThat(gauge.value()).isLessThanOrEqualTo(10);
}
```

### ✅ Critério de Sucesso

- ✅ Pools isolados por feature (crítica vs secundária)
- ✅ Feature secundária não impacta crítica quando saturada
- ✅ Rejeição rápida quando pool cheio (fail-fast)
- ✅ Métricas de saturação por pool
- ✅ Alertas quando pool > 80% utilização

### ⚠️ Pitfalls

- ❌ **Pools muito pequenos:** Rejeição desnecessária
- ❌ **Compartilhar pools:** Perde benefício de isolamento
- ❌ **Não monitorar:** Pool satura e ninguém percebe
- ❌ **Sem priorização:** Requisições críticas competem com não-críticas

### 🚀 Extensão

1. **Adaptive Bulkhead:** Ajustar tamanho baseado em latência
2. **Priority queue:** Fila de prioridade para requisições críticas
3. **Shed load:** Rejeitar requisições menos prioritárias sob carga

---

## 📊 Checkpoint: Autoavaliação da Trilha Resiliência

### Nível Intermediário (41-70%)

- ⬜ Implementa Circuit Breaker básico
- ⬜ Configura retry com backoff
- ⬜ Usa fallback para degradação graceful
- ⬜ Configura timeouts em serviços

### Nível Avançado (71-90%)

- ⬜ Circuit Breaker com estados (CLOSED/OPEN/HALF_OPEN)
- ⬜ Retry exponencial com idempotência
- ⬜ Timeouts hierárquicos (camadas)
- ⬜ Bulkhead para isolamento de recursos
- ⬜ Monitora métricas de resiliência

### Nível Senior (91-100%)

- ⬜ Chaos Engineering em testes
- ⬜ Simula network partition, latência, crash
- ⬜ Sistema se recupera automaticamente
- ⬜ Falhas não cascateiam
- ⬜ Dashboards de resiliência em produção
- ⬜ Gameday/disaster recovery testing

---

**Criado em:** 2025-11-15  
**Tempo Estimado:** 10-12 horas  
**Próxima Trilha:** [Observabilidade](trilhas/03-observabilidade.md)
