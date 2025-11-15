# Estudo de Caso: Saga Pattern

**Objetivo:** Garantir consistência eventual em transações distribuídas através de compensações.

**Contexto:** Sistema de e-commerce onde uma compra envolve múltiplos serviços independentes (Payment, Inventory, Shipping). Cada serviço tem seu próprio banco de dados. Se qualquer passo falhar, os anteriores devem ser compensados.

**Tags:** `#saga` `#distributed-transactions` `#compensation` `#choreography` `#orchestration` `#eventual-consistency`

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Diagrama de Sequência](#diagrama-de-sequência)
4. [Implementação](#implementação)
5. [Estratégia de Testes](#estratégia-de-testes)
6. [Métricas e Observabilidade](#métricas-e-observabilidade)
7. [Anti-patterns e Pitfalls](#anti-patterns-e-pitfalls)
8. [Exercícios Práticos](#exercícios-práticos)

---

## Visão Geral

### O Problema

Em arquiteturas distribuídas, transações ACID tradicionais não funcionam através de múltiplos serviços. Considere:

```
Cenário: Compra de produto
1. Reservar estoque (Inventory Service)
2. Cobrar pagamento (Payment Service)
3. Criar envio (Shipping Service)

Problema: E se step 3 falhar após steps 1 e 2 já executados?
- Estoque reservado ✅
- Pagamento cobrado ✅
- Envio criado ❌ FALHOU

Resultado: Cliente cobrado mas não receberá produto!
```

### A Solução: Saga Pattern

Saga coordena uma sequência de transações locais, onde cada transação tem uma **compensação** correspondente.

**Duas Abordagens:**

1. **Choreography (Coreografia):** Serviços reagem a eventos sem coordenador central
2. **Orchestration (Orquestração):** Componente central (Saga Orchestrator) coordena passos

---

## Arquitetura

### Componentes do Sistema

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│  Order Service  │      │ Payment Service  │      │ Inventory Svc   │
│                 │      │                  │      │                 │
│ Saga            │──────│  ProcessPayment  │──────│  ReserveStock   │
│ Orchestrator    │      │  RefundPayment   │      │  ReleaseStock   │
└─────────────────┘      └──────────────────┘      └─────────────────┘
         │
         │
         └───────────────────────────────┐
                                         │
                                 ┌───────▼────────┐
                                 │ Shipping Svc   │
                                 │                │
                                 │  CreateShipment│
                                 │  CancelShipment│
                                 └────────────────┘
```

### Estados da Saga

```
[STARTED] → [PAYMENT_RESERVED] → [INVENTORY_RESERVED] → [SHIPPING_CREATED] → [COMPLETED]
                    │                      │                     │
                    └──────────────────────┴─────────────────────┴──→ [COMPENSATING] → [FAILED]
```

---

## Diagrama de Sequência

### Happy Path: Compra Bem-Sucedida

```
Order           Payment         Inventory       Shipping        SagaLog
Service         Service         Service         Service
  │                │                │               │               │
  │──StartSaga──────────────────────────────────────────────────────>│
  │                │                │               │               │
  │──ProcessPayment>│                │               │               │
  │                │──Reserve───────>│               │               │
  │                │                │               │               │
  │<──PaymentOK────│<──Reserved─────│               │               │
  │                │                │               │               │
  │────────────────────ReserveStock>│               │               │
  │                │                │               │               │
  │<──────────────────StockReserved─│               │               │
  │                │                │               │               │
  │────────────────────────────────────CreateShipping>│             │
  │                │                │               │               │
  │<──────────────────────────────────ShippingCreated│             │
  │                │                │               │               │
  │──CompleteSaga───────────────────────────────────────────────────>│
  │                │                │               │               │
  │<─OrderCompleted────────────────────────────────────────────SagaOK│
```

### Error Path: Falha no Shipping (Compensação)

```
Order           Payment         Inventory       Shipping        SagaLog
Service         Service         Service         Service
  │                │                │               │               │
  │──StartSaga──────────────────────────────────────────────────────>│
  │                │                │               │               │
  │──ProcessPayment>│                │               │               │
  │<──PaymentOK────│                │               │               │
  │                │                │               │               │
  │────────────────────ReserveStock>│               │               │
  │<──────────────────StockReserved─│               │               │
  │                │                │               │               │
  │────────────────────────────────────CreateShipping>│             │
  │                │                │               │               │
  │<──────────────────────────────────ShippingFailed─│❌            │
  │                │                │               │               │
  │──StartCompensation──────────────────────────────────────────────>│
  │                │                │               │               │
  │────────────────────ReleaseStock>│               │               │
  │<──────────────────StockReleased─│               │               │
  │                │                │               │               │
  │──RefundPayment>│                │               │               │
  │<──Refunded─────│                │               │               │
  │                │                │               │               │
  │──FailSaga───────────────────────────────────────────────────────>│
  │<─OrderFailed────────────────────────────────────────────SagaFailed│
```

---

## Implementação

### 1. Saga Orchestrator (Java)

```java
@Service
@Slf4j
public class OrderSagaOrchestrator {

    private final PaymentServiceClient paymentClient;
    private final InventoryServiceClient inventoryClient;
    private final ShippingServiceClient shippingClient;
    private final SagaLogRepository sagaLogRepository;

    public OrderResult executeOrderSaga(OrderRequest orderRequest) {
        String sagaId = UUID.randomUUID().toString();
        SagaLog sagaLog = createSagaLog(sagaId, orderRequest);

        try {
            // Step 1: Process Payment
            sagaLog.addStep("PAYMENT_PROCESSING");
            PaymentResponse payment = paymentClient.processPayment(
                new PaymentRequest(orderRequest.getCustomerId(), orderRequest.getTotalAmount())
            );
            sagaLog.addStep("PAYMENT_COMPLETED", payment.getPaymentId());

            // Step 2: Reserve Inventory
            sagaLog.addStep("INVENTORY_RESERVING");
            InventoryResponse inventory = inventoryClient.reserveStock(
                new InventoryRequest(orderRequest.getItems())
            );
            sagaLog.addStep("INVENTORY_RESERVED", inventory.getReservationId());

            // Step 3: Create Shipping
            sagaLog.addStep("SHIPPING_CREATING");
            ShippingResponse shipping = shippingClient.createShipment(
                new ShippingRequest(
                    orderRequest.getCustomerId(),
                    orderRequest.getDeliveryAddress(),
                    orderRequest.getItems()
                )
            );
            sagaLog.addStep("SHIPPING_CREATED", shipping.getShipmentId());

            // Saga Completed
            sagaLog.complete();
            sagaLogRepository.save(sagaLog);

            return OrderResult.success(sagaId, payment, inventory, shipping);

        } catch (Exception e) {
            log.error("Saga {} failed at step {}: {}", sagaId, sagaLog.getCurrentStep(), e.getMessage());
            compensate(sagaLog);
            return OrderResult.failure(sagaId, e.getMessage());
        }
    }

    private void compensate(SagaLog sagaLog) {
        sagaLog.startCompensation();

        List<String> completedSteps = sagaLog.getCompletedSteps();

        // Compensate in reverse order
        if (completedSteps.contains("SHIPPING_CREATED")) {
            try {
                String shipmentId = sagaLog.getStepData("SHIPPING_CREATED");
                shippingClient.cancelShipment(shipmentId);
                sagaLog.addCompensation("SHIPPING_CANCELLED");
            } catch (Exception e) {
                log.error("Failed to cancel shipment: {}", e.getMessage());
                // Retry logic or manual intervention needed
                sagaLog.addCompensationFailure("SHIPPING_CANCELLATION_FAILED", e.getMessage());
            }
        }

        if (completedSteps.contains("INVENTORY_RESERVED")) {
            try {
                String reservationId = sagaLog.getStepData("INVENTORY_RESERVED");
                inventoryClient.releaseStock(reservationId);
                sagaLog.addCompensation("INVENTORY_RELEASED");
            } catch (Exception e) {
                log.error("Failed to release inventory: {}", e.getMessage());
                sagaLog.addCompensationFailure("INVENTORY_RELEASE_FAILED", e.getMessage());
            }
        }

        if (completedSteps.contains("PAYMENT_COMPLETED")) {
            try {
                String paymentId = sagaLog.getStepData("PAYMENT_COMPLETED");
                paymentClient.refundPayment(paymentId);
                sagaLog.addCompensation("PAYMENT_REFUNDED");
            } catch (Exception e) {
                log.error("Failed to refund payment: {}", e.getMessage());
                sagaLog.addCompensationFailure("PAYMENT_REFUND_FAILED", e.getMessage());
            }
        }

        sagaLog.fail();
        sagaLogRepository.save(sagaLog);
    }
}
```

### 2. Saga Log (Persistência do Estado)

```java
@Entity
@Table(name = "saga_logs")
@Data
public class SagaLog {

    @Id
    private String sagaId;

    @Enumerated(EnumType.STRING)
    private SagaStatus status; // STARTED, COMPENSATING, COMPLETED, FAILED

    @Column(columnDefinition = "jsonb")
    @Convert(converter = JsonbConverter.class)
    private List<SagaStep> steps = new ArrayList<>();

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public void addStep(String stepName) {
        steps.add(new SagaStep(stepName, LocalDateTime.now()));
        this.updatedAt = LocalDateTime.now();
    }

    public void addStep(String stepName, String data) {
        steps.add(new SagaStep(stepName, LocalDateTime.now(), data));
        this.updatedAt = LocalDateTime.now();
    }

    public void startCompensation() {
        this.status = SagaStatus.COMPENSATING;
        this.updatedAt = LocalDateTime.now();
    }

    public void addCompensation(String compensationName) {
        steps.add(new SagaStep(compensationName, LocalDateTime.now(), true));
        this.updatedAt = LocalDateTime.now();
    }

    public void complete() {
        this.status = SagaStatus.COMPLETED;
        this.updatedAt = LocalDateTime.now();
    }

    public void fail() {
        this.status = SagaStatus.FAILED;
        this.updatedAt = LocalDateTime.now();
    }

    public List<String> getCompletedSteps() {
        return steps.stream()
            .filter(step -> !step.isCompensation())
            .map(SagaStep::getName)
            .toList();
    }

    public String getCurrentStep() {
        return steps.isEmpty() ? "NONE" : steps.get(steps.size() - 1).getName();
    }

    public String getStepData(String stepName) {
        return steps.stream()
            .filter(step -> step.getName().equals(stepName))
            .map(SagaStep::getData)
            .findFirst()
            .orElse(null);
    }
}

@Data
@AllArgsConstructor
class SagaStep {
    private String name;
    private LocalDateTime timestamp;
    private String data;
    private boolean isCompensation;

    public SagaStep(String name, LocalDateTime timestamp) {
        this(name, timestamp, null, false);
    }

    public SagaStep(String name, LocalDateTime timestamp, String data) {
        this(name, timestamp, data, false);
    }

    public SagaStep(String name, LocalDateTime timestamp, boolean isCompensation) {
        this(name, timestamp, null, isCompensation);
    }
}
```

### 3. Service Clients com Idempotência

```java
@Service
@Slf4j
public class PaymentServiceClient {

    private final WebClient webClient;

    public PaymentResponse processPayment(PaymentRequest request) {
        return webClient.post()
            .uri("/payments")
            .header("Idempotency-Key", request.getIdempotencyKey())
            .bodyValue(request)
            .retrieve()
            .bodyToMono(PaymentResponse.class)
            .retryWhen(Retry.backoff(3, Duration.ofSeconds(1))
                .filter(throwable -> throwable instanceof WebClientResponseException.ServiceUnavailable))
            .timeout(Duration.ofSeconds(10))
            .block();
    }

    public void refundPayment(String paymentId) {
        webClient.post()
            .uri("/payments/{paymentId}/refund", paymentId)
            .header("Idempotency-Key", "refund-" + paymentId)
            .retrieve()
            .bodyToMono(Void.class)
            .retryWhen(Retry.backoff(3, Duration.ofSeconds(1)))
            .timeout(Duration.ofSeconds(10))
            .block();
    }
}
```

---

## Estratégia de Testes

### Pirâmide de Testes para Saga

```
                  ╱ ╲
                 ╱ E2E╲          1 teste: Happy path completo
                ╱───────╲
               ╱Contract╲        3 testes: Contratos entre serviços
              ╱───────────╲
             ╱ Integration╲      5 testes: Compensação, timeouts, retries
            ╱───────────────╲
           ╱  Unit Tests     ╲   15 testes: Lógica orchestrator, state machine
          ╱───────────────────╲
```

### 1. Testes Unitários

**Foco:** Lógica do orchestrator, transições de estado, compensações

```java
@ExtendWith(MockitoExtension.class)
class OrderSagaOrchestratorTest {

    @Mock private PaymentServiceClient paymentClient;
    @Mock private InventoryServiceClient inventoryClient;
    @Mock private ShippingServiceClient shippingClient;
    @Mock private SagaLogRepository sagaLogRepository;

    @InjectMocks
    private OrderSagaOrchestrator orchestrator;

    @Test
    @DisplayName("Deve completar saga quando todos os passos são bem-sucedidos")
    void shouldCompleteSagaWhenAllStepsSucceed() {
        // Given
        OrderRequest request = OrderRequestBuilder.anOrder()
            .withCustomerId("customer-123")
            .withTotalAmount(BigDecimal.valueOf(100.00))
            .withItems(List.of(new OrderItem("product-1", 2)))
            .build();

        when(paymentClient.processPayment(any()))
            .thenReturn(new PaymentResponse("payment-id-1", PaymentStatus.APPROVED));
        when(inventoryClient.reserveStock(any()))
            .thenReturn(new InventoryResponse("reservation-id-1", ReservationStatus.RESERVED));
        when(shippingClient.createShipment(any()))
            .thenReturn(new ShippingResponse("shipment-id-1", ShipmentStatus.CREATED));

        // When
        OrderResult result = orchestrator.executeOrderSaga(request);

        // Then
        assertThat(result.isSuccess()).isTrue();
        assertThat(result.getSagaId()).isNotNull();

        verify(paymentClient).processPayment(any());
        verify(inventoryClient).reserveStock(any());
        verify(shippingClient).createShipment(any());

        // Verify saga log saved
        ArgumentCaptor<SagaLog> sagaLogCaptor = ArgumentCaptor.forClass(SagaLog.class);
        verify(sagaLogRepository).save(sagaLogCaptor.capture());

        SagaLog savedLog = sagaLogCaptor.getValue();
        assertThat(savedLog.getStatus()).isEqualTo(SagaStatus.COMPLETED);
        assertThat(savedLog.getCompletedSteps()).containsExactly(
            "PAYMENT_COMPLETED",
            "INVENTORY_RESERVED",
            "SHIPPING_CREATED"
        );
    }

    @Test
    @DisplayName("Deve compensar quando shipping falha")
    void shouldCompensateWhenShippingFails() {
        // Given
        OrderRequest request = OrderRequestBuilder.anOrder().build();

        when(paymentClient.processPayment(any()))
            .thenReturn(new PaymentResponse("payment-id-1", PaymentStatus.APPROVED));
        when(inventoryClient.reserveStock(any()))
            .thenReturn(new InventoryResponse("reservation-id-1", ReservationStatus.RESERVED));
        when(shippingClient.createShipment(any()))
            .thenThrow(new ShippingServiceException("Address not serviceable"));

        // When
        OrderResult result = orchestrator.executeOrderSaga(request);

        // Then
        assertThat(result.isSuccess()).isFalse();
        assertThat(result.getErrorMessage()).contains("Address not serviceable");

        // Verify compensation executed in reverse order
        InOrder inOrder = inOrder(inventoryClient, paymentClient);
        inOrder.verify(inventoryClient).releaseStock("reservation-id-1");
        inOrder.verify(paymentClient).refundPayment("payment-id-1");

        // Verify saga log marked as failed
        ArgumentCaptor<SagaLog> sagaLogCaptor = ArgumentCaptor.forClass(SagaLog.class);
        verify(sagaLogRepository).save(sagaLogCaptor.capture());

        SagaLog savedLog = sagaLogCaptor.getValue();
        assertThat(savedLog.getStatus()).isEqualTo(SagaStatus.FAILED);
    }

    @Test
    @DisplayName("Deve registrar falha de compensação quando refund falhar")
    void shouldLogCompensationFailureWhenRefundFails() {
        // Given
        OrderRequest request = OrderRequestBuilder.anOrder().build();

        when(paymentClient.processPayment(any()))
            .thenReturn(new PaymentResponse("payment-id-1", PaymentStatus.APPROVED));
        when(inventoryClient.reserveStock(any()))
            .thenThrow(new InventoryServiceException("Out of stock"));
        when(paymentClient.refundPayment(any()))
            .thenThrow(new PaymentServiceException("Refund system down"));

        // When
        OrderResult result = orchestrator.executeOrderSaga(request);

        // Then
        assertThat(result.isSuccess()).isFalse();

        verify(paymentClient).refundPayment("payment-id-1");

        ArgumentCaptor<SagaLog> sagaLogCaptor = ArgumentCaptor.forClass(SagaLog.class);
        verify(sagaLogRepository).save(sagaLogCaptor.capture());

        SagaLog savedLog = sagaLogCaptor.getValue();
        assertThat(savedLog.getStatus()).isEqualTo(SagaStatus.FAILED);

        // Verify compensation failure logged for manual intervention
        List<SagaStep> steps = savedLog.getSteps();
        assertThat(steps).anyMatch(step ->
            step.getName().equals("PAYMENT_REFUND_FAILED")
        );
    }
}
```

### 2. Testes de Integração

**Foco:** Comunicação real entre serviços (com Testcontainers ou WireMock)

```java
@SpringBootTest
@Testcontainers
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class OrderSagaIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
        .withDatabaseName("testdb")
        .withUsername("testuser")
        .withPassword("testpass");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private OrderSagaOrchestrator orchestrator;

    @Autowired
    private SagaLogRepository sagaLogRepository;

    private WireMockServer paymentService;
    private WireMockServer inventoryService;
    private WireMockServer shippingService;

    @BeforeEach
    void setup() {
        paymentService = new WireMockServer(8081);
        inventoryService = new WireMockServer(8082);
        shippingService = new WireMockServer(8083);

        paymentService.start();
        inventoryService.start();
        shippingService.start();

        configureFor("localhost", 8081);
    }

    @AfterEach
    void teardown() {
        paymentService.stop();
        inventoryService.stop();
        shippingService.stop();
    }

    @Test
    @Order(1)
    @DisplayName("Integração: Saga completa com sucesso quando todos os serviços respondem OK")
    void sagaCompletesWhenAllServicesRespond() {
        // Given: Mock all services to succeed
        paymentService.stubFor(post("/payments")
            .willReturn(aResponse()
                .withStatus(200)
                .withHeader("Content-Type", "application/json")
                .withBody("{\"paymentId\":\"payment-123\",\"status\":\"APPROVED\"}")));

        inventoryService.stubFor(post("/inventory/reserve")
            .willReturn(aResponse()
                .withStatus(200)
                .withBody("{\"reservationId\":\"reservation-456\",\"status\":\"RESERVED\"}")));

        shippingService.stubFor(post("/shipments")
            .willReturn(aResponse()
                .withStatus(201)
                .withBody("{\"shipmentId\":\"shipment-789\",\"status\":\"CREATED\"}")));

        OrderRequest request = OrderRequestBuilder.anOrder().build();

        // When
        OrderResult result = orchestrator.executeOrderSaga(request);

        // Then
        assertThat(result.isSuccess()).isTrue();

        // Verify saga log persisted
        SagaLog sagaLog = sagaLogRepository.findById(result.getSagaId()).orElseThrow();
        assertThat(sagaLog.getStatus()).isEqualTo(SagaStatus.COMPLETED);
        assertThat(sagaLog.getSteps()).hasSize(6); // 3 steps * 2 (processing + completed)
    }

    @Test
    @Order(2)
    @DisplayName("Integração: Saga compensa quando payment timeout")
    void sagaCompensatesOnPaymentTimeout() {
        // Given: Payment service has high latency (timeout)
        paymentService.stubFor(post("/payments")
            .willReturn(aResponse()
                .withStatus(200)
                .withFixedDelay(15000) // 15s delay (exceeds 10s timeout)
                .withBody("{\"paymentId\":\"payment-123\",\"status\":\"APPROVED\"}")));

        OrderRequest request = OrderRequestBuilder.anOrder().build();

        // When
        OrderResult result = orchestrator.executeOrderSaga(request);

        // Then
        assertThat(result.isSuccess()).isFalse();
        assertThat(result.getErrorMessage()).contains("timeout");

        // Verify no compensations needed (failed at first step)
        SagaLog sagaLog = sagaLogRepository.findById(result.getSagaId()).orElseThrow();
        assertThat(sagaLog.getStatus()).isEqualTo(SagaStatus.FAILED);
        assertThat(sagaLog.getSteps()).noneMatch(SagaStep::isCompensation);
    }

    @Test
    @Order(3)
    @DisplayName("Integração: Saga compensa em ordem reversa quando shipping falha")
    void sagaCompensatesInReverseOrderOnShippingFailure() {
        // Given: Payment and Inventory succeed, Shipping fails
        paymentService.stubFor(post("/payments")
            .willReturn(okJson("{\"paymentId\":\"payment-123\",\"status\":\"APPROVED\"}")));

        paymentService.stubFor(post("/payments/payment-123/refund")
            .willReturn(ok()));

        inventoryService.stubFor(post("/inventory/reserve")
            .willReturn(okJson("{\"reservationId\":\"reservation-456\",\"status\":\"RESERVED\"}")));

        inventoryService.stubFor(post("/inventory/release/reservation-456")
            .willReturn(ok()));

        shippingService.stubFor(post("/shipments")
            .willReturn(aResponse().withStatus(500).withBody("{\"error\":\"Service unavailable\"}")));

        OrderRequest request = OrderRequestBuilder.anOrder().build();

        // When
        OrderResult result = orchestrator.executeOrderSaga(request);

        // Then
        assertThat(result.isSuccess()).isFalse();

        // Verify compensations called
        shippingService.verify(0, postRequestedFor(urlEqualTo("/shipments/cancel")));
        inventoryService.verify(1, postRequestedFor(urlEqualTo("/inventory/release/reservation-456")));
        paymentService.verify(1, postRequestedFor(urlEqualTo("/payments/payment-123/refund")));

        // Verify saga log
        SagaLog sagaLog = sagaLogRepository.findById(result.getSagaId()).orElseThrow();
        assertThat(sagaLog.getStatus()).isEqualTo(SagaStatus.FAILED);
        assertThat(sagaLog.getSteps()).anyMatch(step ->
            step.getName().equals("INVENTORY_RELEASED") && step.isCompensation()
        );
        assertThat(sagaLog.getSteps()).anyMatch(step ->
            step.getName().equals("PAYMENT_REFUNDED") && step.isCompensation()
        );
    }
}
```

### 3. Testes de Contrato (Consumer-Driven)

**Foco:** Garantir que contratos entre serviços sejam respeitados

```java
@SpringBootTest
@AutoConfigureStubRunner(
    ids = "com.example:payment-service:+:stubs:8081",
    stubsMode = StubRunnerProperties.StubsMode.LOCAL
)
class PaymentServiceContractTest {

    @Autowired
    private PaymentServiceClient paymentClient;

    @Test
    @DisplayName("Contrato: processPayment retorna paymentId e status")
    void processPaymentContract() {
        // Given
        PaymentRequest request = new PaymentRequest("customer-123", BigDecimal.valueOf(100.00));

        // When
        PaymentResponse response = paymentClient.processPayment(request);

        // Then
        assertThat(response).isNotNull();
        assertThat(response.getPaymentId()).isNotBlank();
        assertThat(response.getStatus()).isIn(PaymentStatus.APPROVED, PaymentStatus.DECLINED);
    }

    @Test
    @DisplayName("Contrato: refundPayment aceita idempotência")
    void refundPaymentIdempotencyContract() {
        // Given
        String paymentId = "payment-123";

        // When
        paymentClient.refundPayment(paymentId);
        paymentClient.refundPayment(paymentId); // Segunda chamada (idempotente)

        // Then: Não lança exceção
    }
}
```

### 4. Testes de Resiliência (Chaos Engineering)

**Foco:** Validar comportamento sob falhas parciais

```java
@SpringBootTest
@Testcontainers
class OrderSagaChaosTest {

    @Container
    static ToxiproxyContainer toxiproxy = new ToxiproxyContainer(
        "ghcr.io/shopify/toxiproxy:2.5.0"
    );

    @Test
    @DisplayName("Chaos: Saga lida com latência intermitente")
    void sagaHandlesIntermittentLatency() throws IOException {
        // Given: Add latency to payment service
        ToxiproxyClient toxiproxyClient = new ToxiproxyClient(
            toxiproxy.getHost(),
            toxiproxy.getControlPort()
        );

        Proxy paymentProxy = toxiproxyClient.createProxy(
            "payment",
            "0.0.0.0:8666",
            "payment-service:8080"
        );

        paymentProxy.toxics()
            .latency("latency", ToxicDirection.DOWNSTREAM, 5000) // 5s latency
            .setJitter(2000); // ±2s jitter

        OrderRequest request = OrderRequestBuilder.anOrder().build();

        // When
        OrderResult result = orchestrator.executeOrderSaga(request);

        // Then: Saga should handle latency (with retries)
        assertThat(result.isSuccess()).isTrue();
        assertThat(result.getDuration()).isGreaterThan(Duration.ofSeconds(5));
    }

    @Test
    @DisplayName("Chaos: Saga compensa quando network partition")
    void sagaCompensatesOnNetworkPartition() throws IOException {
        // Given: Simulate network partition
        ToxiproxyClient toxiproxyClient = new ToxiproxyClient(
            toxiproxy.getHost(),
            toxiproxy.getControlPort()
        );

        Proxy shippingProxy = toxiproxyClient.createProxy(
            "shipping",
            "0.0.0.0:8667",
            "shipping-service:8080"
        );

        shippingProxy.toxics()
            .timeout("timeout", ToxicDirection.DOWNSTREAM, 0); // Drop all connections

        OrderRequest request = OrderRequestBuilder.anOrder().build();

        // When
        OrderResult result = orchestrator.executeOrderSaga(request);

        // Then: Saga should compensate
        assertThat(result.isSuccess()).isFalse();
        assertThat(result.getErrorMessage()).contains("timeout", "connection");

        // Verify compensations executed
        SagaLog sagaLog = sagaLogRepository.findById(result.getSagaId()).orElseThrow();
        assertThat(sagaLog.getStatus()).isEqualTo(SagaStatus.FAILED);
        assertThat(sagaLog.getSteps()).anyMatch(SagaStep::isCompensation);
    }
}
```

### 5. Teste End-to-End

**Foco:** Fluxo completo com serviços reais

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class OrderSagaE2ETest {

    @Container
    static DockerComposeContainer<?> environment = new DockerComposeContainer<>(
        new File("src/test/resources/docker-compose-e2e.yml")
    )
        .withExposedService("payment-service", 8080)
        .withExposedService("inventory-service", 8080)
        .withExposedService("shipping-service", 8080)
        .withExposedService("postgres", 5432);

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    @DisplayName("E2E: Fluxo completo de compra bem-sucedida")
    void completeOrderFlowEndToEnd() {
        // Given
        String customerId = "customer-e2e-123";
        CreateOrderRequest request = CreateOrderRequest.builder()
            .customerId(customerId)
            .items(List.of(
                new OrderItemRequest("product-1", 2, BigDecimal.valueOf(50.00)),
                new OrderItemRequest("product-2", 1, BigDecimal.valueOf(30.00))
            ))
            .deliveryAddress(new Address("123 Main St", "Springfield", "12345"))
            .build();

        // When
        ResponseEntity<CreateOrderResponse> response = restTemplate.postForEntity(
            "http://localhost:" + port + "/api/orders",
            request,
            CreateOrderResponse.class
        );

        // Then
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getOrderId()).isNotBlank();
        assertThat(response.getBody().getStatus()).isEqualTo("COMPLETED");

        // Verify order created
        String orderId = response.getBody().getOrderId();
        ResponseEntity<OrderDetails> orderDetails = restTemplate.getForEntity(
            "http://localhost:" + port + "/api/orders/" + orderId,
            OrderDetails.class
        );

        assertThat(orderDetails.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(orderDetails.getBody().getPaymentStatus()).isEqualTo("APPROVED");
        assertThat(orderDetails.getBody().getInventoryStatus()).isEqualTo("RESERVED");
        assertThat(orderDetails.getBody().getShippingStatus()).isEqualTo("CREATED");
    }
}
```

---

## Métricas e Observabilidade

### Métricas Essenciais

```java
@Component
public class SagaMetrics {

    private final MeterRegistry meterRegistry;

    public SagaMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }

    public void recordSagaStarted(String sagaType) {
        meterRegistry.counter("saga.started", "type", sagaType).increment();
    }

    public void recordSagaCompleted(String sagaType, Duration duration) {
        meterRegistry.counter("saga.completed", "type", sagaType).increment();
        meterRegistry.timer("saga.duration", "type", sagaType, "status", "completed")
            .record(duration);
    }

    public void recordSagaFailed(String sagaType, String failedStep, Duration duration) {
        meterRegistry.counter("saga.failed",
            "type", sagaType,
            "failed_step", failedStep
        ).increment();
        meterRegistry.timer("saga.duration", "type", sagaType, "status", "failed")
            .record(duration);
    }

    public void recordCompensationExecuted(String sagaType, String compensationStep) {
        meterRegistry.counter("saga.compensation.executed",
            "type", sagaType,
            "step", compensationStep
        ).increment();
    }

    public void recordCompensationFailed(String sagaType, String compensationStep) {
        meterRegistry.counter("saga.compensation.failed",
            "type", sagaType,
            "step", compensationStep
        ).increment();
    }
}
```

### Dashboards (Grafana)

```promql
# Success Rate
sum(rate(saga_completed_total[5m])) / sum(rate(saga_started_total[5m])) * 100

# P95 Duration
histogram_quantile(0.95, sum(rate(saga_duration_bucket[5m])) by (le, status))

# Compensation Rate
sum(rate(saga_compensation_executed_total[5m])) / sum(rate(saga_started_total[5m])) * 100

# Failed Compensations (Critical!)
sum(rate(saga_compensation_failed_total[5m])) by (step)
```

### Alertas

```yaml
# Prometheus Alert Rules
groups:
  - name: saga_alerts
    rules:
      - alert: SagaSuccessRateBelow95
        expr: |
          sum(rate(saga_completed_total[5m])) / sum(rate(saga_started_total[5m])) < 0.95
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Saga success rate below 95%"
          description: "Current success rate: {{ $value | humanizePercentage }}"

      - alert: SagaCompensationFailure
        expr: |
          sum(rate(saga_compensation_failed_total[5m])) > 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Saga compensation failed - MANUAL INTERVENTION NEEDED"
          description: "Compensation step {{ $labels.step }} failed"

      - alert: SagaDurationHigh
        expr: |
          histogram_quantile(0.95, sum(rate(saga_duration_bucket[5m])) by (le)) > 30
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Saga P95 duration above 30s"
          description: "Current P95: {{ $value }}s"
```

### Logs Estruturados

```java
@Slf4j
public class OrderSagaOrchestrator {

    public OrderResult executeOrderSaga(OrderRequest orderRequest) {
        String sagaId = UUID.randomUUID().toString();

        MDC.put("sagaId", sagaId);
        MDC.put("customerId", orderRequest.getCustomerId());
        MDC.put("orderAmount", orderRequest.getTotalAmount().toString());

        try {
            log.info("Saga started: type=order, items={}", orderRequest.getItems().size());

            // ... saga execution

            log.info("Saga completed successfully: duration={}ms", duration.toMillis());
            return OrderResult.success(sagaId, payment, inventory, shipping);

        } catch (Exception e) {
            log.error("Saga failed: step={}, error={}",
                sagaLog.getCurrentStep(),
                e.getMessage(),
                e);
            compensate(sagaLog);
            return OrderResult.failure(sagaId, e.getMessage());
        } finally {
            MDC.clear();
        }
    }

    private void compensate(SagaLog sagaLog) {
        log.warn("Starting compensation: sagaId={}, completedSteps={}",
            sagaLog.getSagaId(),
            sagaLog.getCompletedSteps());

        // ... compensation logic

        if (compensationFailed) {
            log.error("COMPENSATION FAILED: sagaId={}, step={}, error={} - MANUAL INTERVENTION REQUIRED",
                sagaLog.getSagaId(),
                compensationStep,
                error.getMessage());
        }
    }
}
```

### Tracing Distribuído

```java
@Service
public class OrderSagaOrchestrator {

    private final Tracer tracer;

    public OrderResult executeOrderSaga(OrderRequest orderRequest) {
        Span sagaSpan = tracer.nextSpan().name("saga.order.execute")
            .tag("saga.type", "order")
            .tag("customer.id", orderRequest.getCustomerId())
            .start();

        try (Tracer.SpanInScope ws = tracer.withSpan(sagaSpan)) {

            // Step 1: Payment
            Span paymentSpan = tracer.nextSpan().name("saga.step.payment").start();
            try (Tracer.SpanInScope ps = tracer.withSpan(paymentSpan)) {
                PaymentResponse payment = paymentClient.processPayment(request);
                paymentSpan.tag("payment.id", payment.getPaymentId());
                paymentSpan.tag("payment.status", payment.getStatus().toString());
            } finally {
                paymentSpan.end();
            }

            // ... outros steps

            sagaSpan.tag("saga.status", "completed");
            return OrderResult.success(sagaId, payment, inventory, shipping);

        } catch (Exception e) {
            sagaSpan.tag("saga.status", "failed");
            sagaSpan.tag("error", e.getMessage());

            // Compensation trace
            Span compensationSpan = tracer.nextSpan().name("saga.compensation").start();
            try (Tracer.SpanInScope cs = tracer.withSpan(compensationSpan)) {
                compensate(sagaLog);
            } finally {
                compensationSpan.end();
            }

            throw e;
        } finally {
            sagaSpan.end();
        }
    }
}
```

---

## Anti-patterns e Pitfalls

### ❌ Anti-Pattern 1: Compensações Não Idempotentes

**Problema:**

```java
// ❌ MAU: Compensation não idempotente
public void refundPayment(String paymentId) {
    Payment payment = paymentRepository.findById(paymentId);
    payment.setStatus(PaymentStatus.REFUNDED);
    payment.setAmount(payment.getAmount().negate()); // ❌ Segunda chamada duplica refund!
    paymentRepository.save(payment);
}
```

**Solução:**

```java
// ✅ BOM: Compensation idempotente
public void refundPayment(String paymentId) {
    Payment payment = paymentRepository.findById(paymentId);

    if (payment.getStatus() == PaymentStatus.REFUNDED) {
        log.info("Payment already refunded, skipping: {}", paymentId);
        return; // Idempotente
    }

    payment.setStatus(PaymentStatus.REFUNDED);
    payment.setRefundedAt(LocalDateTime.now());
    paymentRepository.save(payment);
}
```

### ❌ Anti-Pattern 2: Saga Sem Timeout

**Problema:**

```java
// ❌ MAU: Sem timeout, saga pode ficar travada indefinidamente
PaymentResponse payment = paymentClient.processPayment(request);
```

**Solução:**

```java
// ✅ BOM: Timeout configurado
PaymentResponse payment = paymentClient.processPayment(request)
    .timeout(Duration.ofSeconds(10))
    .block();

// Ou com retry e circuit breaker
@CircuitBreaker(name = "payment", fallbackMethod = "paymentFallback")
@Retry(name = "payment", fallbackMethod = "paymentFallback")
@TimeLimiter(name = "payment")
public CompletableFuture<PaymentResponse> processPaymentAsync(PaymentRequest request) {
    return CompletableFuture.supplyAsync(() ->
        paymentClient.processPayment(request)
    );
}
```

### ❌ Anti-Pattern 3: Compensação Sem Log

**Problema:**

```java
// ❌ MAU: Falha silenciosa na compensação
try {
    paymentClient.refundPayment(paymentId);
} catch (Exception e) {
    // Ignora erro ❌
}
```

**Solução:**

```java
// ✅ BOM: Log detalhado + alerta
try {
    paymentClient.refundPayment(paymentId);
    sagaLog.addCompensation("PAYMENT_REFUNDED");
} catch (Exception e) {
    log.error("CRITICAL: Failed to refund payment {} for saga {} - MANUAL INTERVENTION REQUIRED",
        paymentId, sagaLog.getSagaId(), e);

    sagaLog.addCompensationFailure("PAYMENT_REFUND_FAILED", e.getMessage());

    // Enviar alerta para PagerDuty/Opsgenie
    alertService.sendCriticalAlert(
        "Saga Compensation Failed",
        Map.of(
            "sagaId", sagaLog.getSagaId(),
            "paymentId", paymentId,
            "error", e.getMessage()
        )
    );
}
```

### ❌ Anti-Pattern 4: Ordem Incorreta de Compensação

**Problema:**

```java
// ❌ MAU: Compensações em ordem aleatória
compensate(paymentId);
compensate(shippingId);
compensate(inventoryId);
```

**Solução:**

```java
// ✅ BOM: Compensações em ordem REVERSA
List<String> completedSteps = sagaLog.getCompletedSteps();

// Reverse order of completion
Collections.reverse(completedSteps);

for (String step : completedSteps) {
    switch (step) {
        case "SHIPPING_CREATED" -> compensateShipping(sagaLog.getStepData(step));
        case "INVENTORY_RESERVED" -> compensateInventory(sagaLog.getStepData(step));
        case "PAYMENT_COMPLETED" -> compensatePayment(sagaLog.getStepData(step));
    }
}
```

### ❌ Anti-Pattern 5: Saga Sem Persistência

**Problema:**

```java
// ❌ MAU: Estado apenas em memória
Map<String, SagaState> sagaStates = new HashMap<>();
```

**Solução:**

```java
// ✅ BOM: Estado persistido em banco
@Entity
@Table(name = "saga_logs")
public class SagaLog {
    @Id
    private String sagaId;

    @Enumerated(EnumType.STRING)
    private SagaStatus status;

    @Column(columnDefinition = "jsonb")
    private List<SagaStep> steps;

    // Permite recuperação após crash
}
```

### ⚠️ Pitfall 1: Ignorar Partial Failures

Compensações podem falhar parcialmente. Exemplo:

- Payment refundado ✅
- Inventory released ✅
- Shipping cancellation failed ❌

**Solução:** Retry com backoff exponencial + dead letter queue para intervenção manual.

### ⚠️ Pitfall 2: Não Testar Timeouts

Saga pode falhar por timeout em qualquer step. **Sempre teste cenários de timeout.**

### ⚠️ Pitfall 3: Esquecer Idempotency-Key

Requests HTTP devem ter `Idempotency-Key` para evitar duplicações em retries.

```java
// ✅ BOM
webClient.post()
    .uri("/payments")
    .header("Idempotency-Key", UUID.randomUUID().toString())
    .bodyValue(request)
    .retrieve()
    .bodyToMono(PaymentResponse.class);
```

---

## Exercícios Práticos

### 🎯 Exercício 1: Implementar Saga com 3 Passos

**Objetivo:** Criar saga simples para `CreateUser` com steps: ValidateEmail, CreateAccount, SendWelcomeEmail.

**Passos:**

1. Criar `UserSagaOrchestrator` com 3 steps
2. Implementar compensações: DeleteAccount, (email não precisa compensar)
3. Criar testes unitários para happy path + 3 failure scenarios
4. Persistir `SagaLog` em banco

**Critério de Sucesso:**

- ✅ Saga completa quando todos os steps OK
- ✅ Compensa em ordem reversa quando qualquer step falhar
- ✅ SagaLog persistido com status correto
- ✅ Testes cobrem 100% dos cenários

### 🎯 Exercício 2: Adicionar Retry com Backoff

**Objetivo:** Melhorar resiliência adicionando retry aos service clients.

**Passos:**

1. Adicionar `@Retry` do Resilience4j aos clients
2. Configurar backoff exponencial: 1s, 2s, 4s
3. Testar com WireMock simulando falhas intermitentes
4. Adicionar métricas de retry

**Critério de Sucesso:**

- ✅ Retry funciona após falhas temporárias
- ✅ Saga não compensa desnecessariamente
- ✅ Métricas registram tentativas de retry

### 🎯 Exercício 3: Implementar Dead Letter Queue

**Objetivo:** Criar DLQ para compensações falhadas.

**Passos:**

1. Quando compensação falhar, publicar evento `CompensationFailed` no Kafka
2. Consumer do DLQ loga detalhes + envia alerta
3. Dashboard no Grafana para monitorar DLQ
4. Testar forçando falha de compensação

**Critério de Sucesso:**

- ✅ Eventos publicados no DLQ
- ✅ Alertas enviados (email/Slack/PagerDuty)
- ✅ Dashboard mostra compensações falhadas

### 🎯 Exercício 4: Testes de Chaos

**Objetivo:** Validar saga sob falhas de rede.

**Passos:**

1. Usar Toxiproxy para simular latência, timeout, partition
2. Testar saga com latência de 5s no payment service
3. Testar saga com network partition no inventory service
4. Validar que compensações executam corretamente

**Critério de Sucesso:**

- ✅ Saga lida com latência (retries)
- ✅ Saga compensa em network partition
- ✅ Métricas registram failures

### 🎯 Exercício 5: Saga Choreography

**Objetivo:** Implementar saga sem orchestrator central (event-driven).

**Passos:**

1. Criar eventos: `OrderCreated`, `PaymentProcessed`, `InventoryReserved`, `ShippingCreated`
2. Cada serviço escuta eventos e publica próximo evento
3. Serviços publicam eventos de compensação: `PaymentRefunded`, `InventoryReleased`
4. Testar fluxo completo + compensação

**Critério de Sucesso:**

- ✅ Saga completa via eventos (sem orchestrator)
- ✅ Compensações propagam via eventos
- ✅ Distributed tracing conecta todos os events

**Comparação:** Orchestration vs Choreography

| Aspecto        | Orchestration                   | Choreography               |
| -------------- | ------------------------------- | -------------------------- |
| Coordenação    | Central (Orchestrator)          | Distribuída (Events)       |
| Acoplamento    | Alto (orchestrator conhece all) | Baixo (serviços isolados)  |
| Debugging      | Mais fácil (single point)       | Mais difícil (distributed) |
| Escalabilidade | Orchestrator = bottleneck       | Melhor escalabilidade      |
| Complexidade   | Menor (lógica centralizada)     | Maior (lógica distribuída) |

---

## Resumo

### Quando Usar Saga Pattern

✅ **Use quando:**

- Transações distribuídas entre múltiplos serviços
- Cada serviço tem seu próprio banco de dados
- Consistência eventual é aceitável
- Compensações são possíveis (reversíveis)

❌ **Não use quando:**

- Transação pode ser local (single DB)
- Operações não são reversíveis (ex: enviar email)
- Consistência forte é mandatória
- Sistema é simples (2-3 tabelas no mesmo DB)

### Checklist de Implementação

- ✅ Saga Log persistido em banco
- ✅ Compensações idempotentes
- ✅ Timeouts configurados em todos os steps
- ✅ Retry com backoff exponencial
- ✅ Idempotency-Key em requests HTTP
- ✅ Ordem reversa de compensação
- ✅ Logs estruturados com sagaId
- ✅ Métricas: success rate, duration, compensations
- ✅ Alertas para compensações falhadas
- ✅ Distributed tracing configurado
- ✅ Testes: unit, integration, contract, chaos, e2e

### Recursos

📚 **Livros:**

- _Microservices Patterns_ - Chris Richardson (Cap. 4: Sagas)
- _Building Microservices_ - Sam Newman (Cap. 5: Distributed Transactions)

🎥 **Vídeos:**

- [Saga Pattern Explained](https://www.youtube.com/watch?v=xDuwrtwYHu8) - CodeOpinion
- [Microservices Data Consistency](https://www.youtube.com/watch?v=CFdPDfXy6Y0) - Chris Richardson

🔗 **Artigos:**

- [Saga Pattern](https://microservices.io/patterns/data/saga.html) - microservices.io
- [Saga Orchestration vs Choreography](https://blog.couchbase.com/saga-pattern-implement-business-transactions-using-microservices-part/) - Couchbase

---

**Criado em:** 2025-11-15  
**Fase:** 7 - Estudos de Caso + Diagramas  
**Tags:** `#saga` `#distributed-transactions` `#compensation` `#orchestration` `#choreography` `#resilience`
