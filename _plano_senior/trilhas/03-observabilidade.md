# Trilha de Observabilidade - Exercícios Práticos

**Objetivo:** Dominar técnicas de **observabilidade** para entender comportamento de sistemas em produção usando **logs estruturados**, **métricas**, **traces distribuídos** e **dashboards**.

**Nível:** Intermediário → Avançado  
**Tempo Estimado:** 8-10 horas  
**Pré-requisitos:** Spring Boot, Micrometer, OpenTelemetry, conhecimento de sistemas distribuídos

---

## 🧪 Exercício 1: Logs Estruturados com Correlation ID

### 🎯 Objetivo

Implementar **logs estruturados em JSON** com **correlation ID** para rastrear requisições através de múltiplos serviços.

### 📖 Contexto

Logs em texto plano são difíceis de analisar. Quando uma requisição falha, você precisa correlacionar logs de múltiplos serviços. Correlation ID resolve isso.

### 🛠️ Passos

#### 1. Configurar Logback para JSON

```xml
<!-- src/main/resources/logback-spring.xml -->
<configuration>
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder class="net.logstash.logback.encoder.LogstashEncoder">
            <includeContext>true</includeContext>
            <includeMdc>true</includeMdc>
            <customFields>{"application":"order-service","environment":"${ENVIRONMENT:-dev}"}</customFields>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
    </root>
</configuration>
```

**Dependência:**

```xml
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>7.4</version>
</dependency>
```

#### 2. Criar Filtro para Correlation ID

```java
@Component
@Order(1)
public class CorrelationIdFilter extends OncePerRequestFilter {

    private static final String CORRELATION_ID_HEADER = "X-Correlation-ID";
    private static final String CORRELATION_ID_MDC_KEY = "correlationId";

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        // Obter correlation ID do header ou gerar novo
        String correlationId = request.getHeader(CORRELATION_ID_HEADER);

        if (correlationId == null || correlationId.isEmpty()) {
            correlationId = UUID.randomUUID().toString();
        }

        // Adicionar ao MDC (Mapped Diagnostic Context)
        MDC.put(CORRELATION_ID_MDC_KEY, correlationId);

        // Adicionar ao response header
        response.setHeader(CORRELATION_ID_HEADER, correlationId);

        try {
            filterChain.doFilter(request, response);
        } finally {
            // Limpar MDC
            MDC.remove(CORRELATION_ID_MDC_KEY);
        }
    }
}
```

#### 3. Propagar Correlation ID em Chamadas HTTP

```java
@Configuration
public class RestTemplateConfig {

    @Bean
    public RestTemplate restTemplate() {
        RestTemplate restTemplate = new RestTemplate();

        // Interceptor para adicionar correlation ID
        restTemplate.setInterceptors(List.of(
            (request, body, execution) -> {
                String correlationId = MDC.get("correlationId");

                if (correlationId != null) {
                    request.getHeaders().add("X-Correlation-ID", correlationId);
                }

                return execution.execute(request, body);
            }
        ));

        return restTemplate;
    }
}
```

#### 4. Usar Logs Estruturados

```java
@Service
@Slf4j
public class OrderService {

    public Order createOrder(OrderRequest request) {
        // Log estruturado com contexto
        log.info("Creating order",
            kv("userId", request.getUserId()),
            kv("itemCount", request.getItems().size()),
            kv("totalAmount", request.getTotalAmount())
        );

        try {
            Order order = processOrder(request);

            log.info("Order created successfully",
                kv("orderId", order.getId()),
                kv("status", order.getStatus())
            );

            return order;

        } catch (PaymentException e) {
            log.error("Payment failed",
                kv("userId", request.getUserId()),
                kv("errorCode", e.getCode()),
                kv("errorMessage", e.getMessage()),
                e
            );
            throw e;
        }
    }
}
```

**Output JSON:**

```json
{
  "@timestamp": "2025-11-15T10:30:45.123Z",
  "level": "INFO",
  "message": "Creating order",
  "logger_name": "com.example.OrderService",
  "thread_name": "http-nio-8080-exec-1",
  "correlationId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "application": "order-service",
  "environment": "prod",
  "userId": "USER-123",
  "itemCount": 3,
  "totalAmount": 150.0
}
```

#### 5. Testar Correlation ID

```java
@SpringBootTest
@AutoConfigureMockMvc
class CorrelationIdTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldAddCorrelationIdToResponse_whenNotProvided() throws Exception {
        // Act
        MvcResult result = mockMvc.perform(post("/api/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"items\": [...]}"))
            .andExpect(status().isCreated())
            .andReturn();

        // Assert - Correlation ID foi gerado
        String correlationId = result.getResponse().getHeader("X-Correlation-ID");
        assertThat(correlationId).isNotNull();
        assertThat(UUID.fromString(correlationId)).isNotNull(); // Valida formato UUID
    }

    @Test
    void shouldPreserveCorrelationId_whenProvided() throws Exception {
        // Arrange
        String providedCorrelationId = "TEST-CORRELATION-ID-123";

        // Act
        MvcResult result = mockMvc.perform(post("/api/orders")
                .header("X-Correlation-ID", providedCorrelationId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"items\": [...]}"))
            .andExpect(status().isCreated())
            .andReturn();

        // Assert - Mesmo correlation ID retornado
        String returnedCorrelationId = result.getResponse().getHeader("X-Correlation-ID");
        assertThat(returnedCorrelationId).isEqualTo(providedCorrelationId);
    }

    @Test
    void shouldPropagateCorrelationId_toDownstreamServices() {
        // Arrange
        String correlationId = "PROP-123";
        MDC.put("correlationId", correlationId);

        // Mock downstream service
        stubFor(post(urlEqualTo("/payment/process"))
            .willReturn(aResponse().withStatus(200)));

        // Act
        paymentService.processPayment("ORDER-123", BigDecimal.TEN);

        // Assert - Correlation ID foi propagado
        verify(postRequestedFor(urlEqualTo("/payment/process"))
            .withHeader("X-Correlation-ID", equalTo(correlationId)));

        MDC.clear();
    }
}
```

### ✅ Critério de Sucesso

- ✅ Logs em formato JSON estruturado
- ✅ Correlation ID gerado automaticamente ou recebido do header
- ✅ Correlation ID propagado para serviços downstream
- ✅ Correlation ID retornado no response header
- ✅ Logs podem ser filtrados por correlation ID no Kibana/Grafana Loki

### ⚠️ Pitfalls

- ❌ **Não limpar MDC:** Memory leak em thread pools
- ❌ **Correlation ID não propagado:** Perde rastreabilidade
- ❌ **Logs com informações sensíveis:** Não logar senhas, tokens, PII
- ❌ **Logs excessivos:** Info para tudo cria noise

### 🚀 Extensão

1. **User ID no MDC:** Adicionar user ID após autenticação
2. **Span ID:** Adicionar trace/span ID do OpenTelemetry
3. **Log sampling:** Logar apenas % das requisições em alta carga

---

## 📊 Exercício 2: Métricas de Negócio com Micrometer

### 🎯 Objetivo

Criar **métricas customizadas** para monitorar **KPIs de negócio** (pedidos/min, receita, taxa de conversão) usando **Micrometer**.

### 📖 Contexto

Métricas técnicas (CPU, memória) não bastam. Você precisa monitorar métricas de negócio para entender impacto real.

### 🛠️ Passos

#### 1. Configurar Micrometer

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus,metrics
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: ${spring.application.name}
      environment: ${ENVIRONMENT:dev}
```

#### 2. Criar Métricas Customizadas

```java
@Service
public class OrderMetricsService {

    private final Counter ordersCreatedCounter;
    private final Counter ordersFailedCounter;
    private final Timer orderProcessingTimer;
    private final DistributionSummary orderAmountSummary;
    private final Gauge activeOrdersGauge;

    private final AtomicInteger activeOrders = new AtomicInteger(0);

    public OrderMetricsService(MeterRegistry registry) {
        // Counter: Total de pedidos criados
        this.ordersCreatedCounter = Counter.builder("orders.created")
            .description("Total number of orders created")
            .tag("service", "order-service")
            .register(registry);

        // Counter: Total de pedidos falhados
        this.ordersFailedCounter = Counter.builder("orders.failed")
            .description("Total number of failed orders")
            .tag("service", "order-service")
            .register(registry);

        // Timer: Tempo de processamento
        this.orderProcessingTimer = Timer.builder("orders.processing.time")
            .description("Time to process an order")
            .tag("service", "order-service")
            .publishPercentiles(0.5, 0.95, 0.99) // P50, P95, P99
            .register(registry);

        // DistributionSummary: Valor dos pedidos
        this.orderAmountSummary = DistributionSummary.builder("orders.amount")
            .description("Order amount distribution")
            .baseUnit("currency")
            .publishPercentiles(0.5, 0.95, 0.99)
            .register(registry);

        // Gauge: Pedidos ativos no momento
        this.activeOrdersGauge = Gauge.builder("orders.active", activeOrders, AtomicInteger::get)
            .description("Number of orders being processed")
            .register(registry);
    }

    public void recordOrderCreated(Order order) {
        ordersCreatedCounter.increment();
        orderAmountSummary.record(order.getTotalAmount().doubleValue());
    }

    public void recordOrderFailed(String reason) {
        ordersFailedCounter.increment();
    }

    public <T> T recordProcessingTime(Supplier<T> operation) {
        return orderProcessingTimer.record(operation);
    }

    public void incrementActiveOrders() {
        activeOrders.incrementAndGet();
    }

    public void decrementActiveOrders() {
        activeOrders.decrementAndGet();
    }
}
```

#### 3. Usar Métricas no Serviço

```java
@Service
@Slf4j
public class OrderService {

    private final OrderMetricsService metricsService;
    private final OrderRepository repository;

    public Order createOrder(OrderRequest request) {
        metricsService.incrementActiveOrders();

        try {
            // Medir tempo de processamento
            Order order = metricsService.recordProcessingTime(() -> {
                Order newOrder = new Order();
                newOrder.setItems(request.getItems());
                newOrder.setTotalAmount(calculateTotal(request));
                newOrder.setStatus(OrderStatus.CREATED);

                return repository.save(newOrder);
            });

            // Registrar sucesso
            metricsService.recordOrderCreated(order);

            log.info("Order created", kv("orderId", order.getId()));
            return order;

        } catch (Exception e) {
            // Registrar falha
            metricsService.recordOrderFailed(e.getClass().getSimpleName());
            log.error("Failed to create order", e);
            throw e;

        } finally {
            metricsService.decrementActiveOrders();
        }
    }
}
```

#### 4. Criar Métricas de Taxa de Conversão

```java
@Service
public class ConversionMetricsService {

    private final Counter cartCreatedCounter;
    private final Counter checkoutStartedCounter;
    private final Counter orderCompletedCounter;

    public ConversionMetricsService(MeterRegistry registry) {
        this.cartCreatedCounter = Counter.builder("funnel.cart.created")
            .register(registry);

        this.checkoutStartedCounter = Counter.builder("funnel.checkout.started")
            .register(registry);

        this.orderCompletedCounter = Counter.builder("funnel.order.completed")
            .register(registry);
    }

    public void recordCartCreated() {
        cartCreatedCounter.increment();
    }

    public void recordCheckoutStarted() {
        checkoutStartedCounter.increment();
    }

    public void recordOrderCompleted() {
        orderCompletedCounter.increment();
    }

    // Taxa de conversão calculada via PromQL:
    // (funnel_order_completed / funnel_cart_created) * 100
}
```

#### 5. Testar Métricas

```java
@SpringBootTest
class OrderMetricsTest {

    @Autowired
    private OrderService orderService;

    @Autowired
    private MeterRegistry meterRegistry;

    @Test
    void shouldIncrementOrdersCreatedCounter_whenOrderSucceeds() {
        // Arrange
        OrderRequest request = validOrderRequest();

        double before = meterRegistry.counter("orders.created").count();

        // Act
        orderService.createOrder(request);

        // Assert
        double after = meterRegistry.counter("orders.created").count();
        assertThat(after).isEqualTo(before + 1);
    }

    @Test
    void shouldRecordOrderAmount_inDistributionSummary() {
        // Arrange
        OrderRequest request = orderRequestWithAmount(BigDecimal.valueOf(250.00));

        // Act
        orderService.createOrder(request);

        // Assert
        DistributionSummary summary = meterRegistry.find("orders.amount")
            .summary();

        assertThat(summary.count()).isGreaterThan(0);
        assertThat(summary.totalAmount()).isGreaterThanOrEqualTo(250.00);
    }

    @Test
    void shouldRecordProcessingTime_inTimer() {
        // Arrange
        OrderRequest request = validOrderRequest();

        // Act
        orderService.createOrder(request);

        // Assert
        Timer timer = meterRegistry.find("orders.processing.time")
            .timer();

        assertThat(timer.count()).isGreaterThan(0);
        assertThat(timer.mean(TimeUnit.MILLISECONDS)).isLessThan(1000); // < 1s
    }

    @Test
    void shouldIncrementFailedCounter_whenOrderFails() {
        // Arrange
        when(paymentService.process(any())).thenThrow(new PaymentException("Failed"));

        double before = meterRegistry.counter("orders.failed").count();

        // Act
        assertThatThrownBy(() -> orderService.createOrder(validOrderRequest()));

        // Assert
        double after = meterRegistry.counter("orders.failed").count();
        assertThat(after).isEqualTo(before + 1);
    }
}
```

#### 6. Consultar Métricas via Prometheus

```promql
# Taxa de criação de pedidos por minuto
rate(orders_created_total[5m]) * 60

# P95 do tempo de processamento
orders_processing_time_seconds{quantile="0.95"}

# Taxa de erro
rate(orders_failed_total[5m]) / rate(orders_created_total[5m]) * 100

# Receita por minuto
rate(orders_amount_sum[5m]) * 60

# Taxa de conversão
(funnel_order_completed_total / funnel_cart_created_total) * 100
```

### ✅ Critério de Sucesso

- ✅ Counter para pedidos criados/falhados
- ✅ Timer para tempo de processamento (P50, P95, P99)
- ✅ DistributionSummary para valores de pedidos
- ✅ Gauge para pedidos ativos
- ✅ Métricas exportadas para Prometheus
- ✅ Dashboard Grafana com KPIs de negócio

### ⚠️ Pitfalls

- ❌ **Métricas sem tags:** Dificulta filtrar por dimensão
- ❌ **Muitas métricas:** Sobrecarrega sistema
- ❌ **Counter resetado:** Usar rate() no Prometheus
- ❌ **Gauge para totais:** Usar Counter

### 🚀 Extensão

1. **SLI/SLO:** Definir Service Level Indicators e Objectives
2. **Alertas:** Configurar alertas no AlertManager (taxa erro > 5%)
3. **Exemplars:** Linkar métricas a traces (Tempo/Grafana)

---

## 🔍 Exercício 3: Distributed Tracing com OpenTelemetry

### 🎯 Objetivo

Implementar **traces distribuídos** para visualizar **latência** e **fluxo de requisições** através de múltiplos serviços.

### 📖 Contexto

Cliente → API Gateway → Order Service → Payment Service → Database

Você precisa entender onde está a latência e qual serviço está causando lentidão.

### 🛠️ Passos

#### 1. Configurar OpenTelemetry

```xml
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-api</artifactId>
</dependency>
<dependency>
    <groupId>io.opentelemetry.instrumentation</groupId>
    <artifactId>opentelemetry-spring-boot-starter</artifactId>
    <version>2.0.0</version>
</dependency>
```

```yaml
# application.yml
otel:
  service:
    name: order-service
  exporter:
    otlp:
      endpoint: http://localhost:4317
  traces:
    sampler:
      probability: 1.0 # 100% em dev, 10% em prod
```

#### 2. Criar Spans Customizados

```java
@Service
public class OrderService {

    private final Tracer tracer;

    public OrderService(OpenTelemetry openTelemetry) {
        this.tracer = openTelemetry.getTracer("order-service", "1.0.0");
    }

    public Order createOrder(OrderRequest request) {
        // Span principal (já criado automaticamente pelo Spring)
        Span currentSpan = Span.current();
        currentSpan.setAttribute("user.id", request.getUserId());
        currentSpan.setAttribute("order.items.count", request.getItems().size());

        // Span customizado para validação
        Span validationSpan = tracer.spanBuilder("validate-order")
            .setParent(Context.current().with(currentSpan))
            .startSpan();

        try (Scope scope = validationSpan.makeCurrent()) {
            validateOrder(request);
            validationSpan.setStatus(StatusCode.OK);
        } catch (ValidationException e) {
            validationSpan.recordException(e);
            validationSpan.setStatus(StatusCode.ERROR, "Validation failed");
            throw e;
        } finally {
            validationSpan.end();
        }

        // Span para processamento de pagamento
        Span paymentSpan = tracer.spanBuilder("process-payment")
            .setParent(Context.current().with(currentSpan))
            .startSpan();

        try (Scope scope = paymentSpan.makeCurrent()) {
            PaymentResult result = paymentService.processPayment(
                request.getTotalAmount()
            );

            paymentSpan.setAttribute("payment.id", result.getPaymentId());
            paymentSpan.setAttribute("payment.status", result.getStatus().name());
            paymentSpan.setStatus(StatusCode.OK);

            return createOrderFromPayment(result);

        } catch (PaymentException e) {
            paymentSpan.recordException(e);
            paymentSpan.setStatus(StatusCode.ERROR, "Payment failed");
            throw e;
        } finally {
            paymentSpan.end();
        }
    }
}
```

#### 3. Propagar Context em Chamadas Assíncronas

```java
@Service
public class AsyncOrderProcessor {

    @Async
    public CompletableFuture<Void> sendConfirmationEmail(Order order) {
        // Context é propagado automaticamente pelo OpenTelemetry
        Span span = Span.current();
        span.setAttribute("order.id", order.getId());
        span.setAttribute("email.recipient", order.getCustomer().getEmail());

        try {
            emailService.send(order.getCustomer().getEmail(), "Order Confirmation");
            span.setStatus(StatusCode.OK);

        } catch (Exception e) {
            span.recordException(e);
            span.setStatus(StatusCode.ERROR);
            throw e;
        }

        return CompletableFuture.completedFuture(null);
    }
}
```

#### 4. Visualizar Traces no Jaeger

```yaml
# docker-compose.yml
version: "3.8"
services:
  jaeger:
    image: jaegertracing/all-in-one:1.52
    ports:
      - "16686:16686" # UI
      - "4317:4317" # OTLP gRPC
    environment:
      - COLLECTOR_OTLP_ENABLED=true
```

**Acessar:** `http://localhost:16686`

#### 5. Testar Tracing

```java
@SpringBootTest
class TracingTest {

    @Autowired
    private OrderService orderService;

    @Autowired
    private OpenTelemetry openTelemetry;

    private final List<SpanData> exportedSpans = new ArrayList<>();

    @BeforeEach
    void setUp() {
        // Configurar exporter in-memory para testes
        InMemorySpanExporter spanExporter = InMemorySpanExporter.create();
        exportedSpans.clear();
    }

    @Test
    void shouldCreateSpans_forOrderCreation() {
        // Act
        orderService.createOrder(validOrderRequest());

        // Assert - Verificar spans criados
        await().atMost(Duration.ofSeconds(5))
            .untilAsserted(() -> {
                assertThat(exportedSpans).hasSizeGreaterThanOrEqualTo(3);
            });

        // Span principal (controller)
        SpanData rootSpan = exportedSpans.stream()
            .filter(span -> span.getName().equals("POST /api/orders"))
            .findFirst()
            .orElseThrow();

        assertThat(rootSpan.getAttributes().get(AttributeKey.stringKey("http.method")))
            .isEqualTo("POST");

        // Span de validação
        SpanData validationSpan = exportedSpans.stream()
            .filter(span -> span.getName().equals("validate-order"))
            .findFirst()
            .orElseThrow();

        assertThat(validationSpan.getParentSpanId()).isEqualTo(rootSpan.getSpanId());

        // Span de pagamento
        SpanData paymentSpan = exportedSpans.stream()
            .filter(span -> span.getName().equals("process-payment"))
            .findFirst()
            .orElseThrow();

        assertThat(paymentSpan.getParentSpanId()).isEqualTo(rootSpan.getSpanId());
    }

    @Test
    void shouldRecordException_inSpan() {
        // Arrange
        when(paymentService.processPayment(any()))
            .thenThrow(new PaymentException("Card declined"));

        // Act
        assertThatThrownBy(() -> orderService.createOrder(validOrderRequest()));

        // Assert - Span deve ter exception registrada
        await().atMost(Duration.ofSeconds(5))
            .untilAsserted(() -> {
                SpanData paymentSpan = exportedSpans.stream()
                    .filter(span -> span.getName().equals("process-payment"))
                    .findFirst()
                    .orElseThrow();

                assertThat(paymentSpan.getStatus().getStatusCode())
                    .isEqualTo(StatusCode.ERROR);

                assertThat(paymentSpan.getEvents())
                    .anyMatch(event -> event.getName().equals("exception"));
            });
    }
}
```

### ✅ Critério de Sucesso

- ✅ Traces propagados através de múltiplos serviços
- ✅ Spans customizados para operações importantes
- ✅ Atributos relevantes adicionados aos spans
- ✅ Exceções registradas nos spans
- ✅ Traces visualizados no Jaeger/Zipkin
- ✅ Latência por serviço visível
- ✅ Context propagado em chamadas assíncronas

### ⚠️ Pitfalls

- ❌ **100% sampling em prod:** Overhead alto
- ❌ **Spans sem atributos:** Dificulta debugging
- ❌ **Não registrar exceções:** Perde contexto de erros
- ❌ **Context não propagado:** Perde correlação entre spans

### 🚀 Extensão

1. **Exemplars:** Linkar traces a métricas (clicar em spike no gráfico abre trace)
2. **Service Map:** Visualizar topologia de serviços
3. **Tail-based sampling:** Samplear apenas traces com erros

---

## 🎯 Exercício 4: Dashboard Grafana com Métricas de Negócio

### 🎯 Objetivo

Criar **dashboard Grafana** com **KPIs de negócio** e **alertas** para monitoramento proativo.

### 📖 Contexto

Métricas técnicas (CPU, memória) não mostram impacto no negócio. Você precisa de dashboard com pedidos/min, receita, taxa de erro, SLA.

### 🛠️ Passos

#### 1. Configurar Prometheus como Data Source

```yaml
# docker-compose.yml
version: "3.8"
services:
  prometheus:
    image: prom/prometheus:v2.48.0
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana:10.2.2
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-storage:/var/lib/grafana
```

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "order-service"
    metrics_path: "/actuator/prometheus"
    static_configs:
      - targets: ["host.docker.internal:8080"]
```

#### 2. Criar Dashboard JSON

```json
{
  "dashboard": {
    "title": "Order Service - Business Metrics",
    "panels": [
      {
        "title": "Orders per Minute",
        "targets": [
          {
            "expr": "rate(orders_created_total[5m]) * 60",
            "legendFormat": "Orders/min"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Revenue per Minute",
        "targets": [
          {
            "expr": "rate(orders_amount_sum[5m]) * 60",
            "legendFormat": "Revenue/min ({{currency}})"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "(rate(orders_failed_total[5m]) / rate(orders_created_total[5m])) * 100",
            "legendFormat": "Error Rate %"
          }
        ],
        "type": "graph",
        "alert": {
          "conditions": [
            {
              "evaluator": {
                "params": [5],
                "type": "gt"
              },
              "query": {
                "params": ["A", "5m", "now"]
              }
            }
          ],
          "executionErrorState": "alerting",
          "frequency": "1m",
          "name": "High Error Rate Alert"
        }
      },
      {
        "title": "P95 Processing Time",
        "targets": [
          {
            "expr": "orders_processing_time_seconds{quantile=\"0.95\"}",
            "legendFormat": "P95"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Conversion Funnel",
        "targets": [
          {
            "expr": "funnel_cart_created_total",
            "legendFormat": "Cart Created"
          },
          {
            "expr": "funnel_checkout_started_total",
            "legendFormat": "Checkout Started"
          },
          {
            "expr": "funnel_order_completed_total",
            "legendFormat": "Order Completed"
          }
        ],
        "type": "graph"
      }
    ]
  }
}
```

#### 3. Configurar Alertas

```yaml
# alertmanager.yml
route:
  receiver: "slack"

receivers:
  - name: "slack"
    slack_configs:
      - api_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
        channel: "#alerts"
        title: "{{ .GroupLabels.alertname }}"
        text: "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}"
```

**Alertas PromQL:**

```yaml
# prometheus-alerts.yml
groups:
  - name: business_metrics
    rules:
      - alert: HighErrorRate
        expr: (rate(orders_failed_total[5m]) / rate(orders_created_total[5m])) * 100 > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}% (threshold: 5%)"

      - alert: SlowProcessing
        expr: orders_processing_time_seconds{quantile="0.95"} > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow order processing"
          description: "P95 processing time is {{ $value }}s (threshold: 2s)"

      - alert: LowConversionRate
        expr: (funnel_order_completed_total / funnel_cart_created_total) * 100 < 10
        for: 15m
        labels:
          severity: info
        annotations:
          summary: "Low conversion rate"
          description: "Conversion rate is {{ $value }}% (threshold: 10%)"
```

### ✅ Critério de Sucesso

- ✅ Dashboard com 5+ painéis de negócio
- ✅ Métricas de taxa (orders/min, revenue/min)
- ✅ Taxa de erro visualizada
- ✅ Latência (P50, P95, P99)
- ✅ Funil de conversão
- ✅ Alertas configurados (erro > 5%, latência > 2s)
- ✅ Notificações via Slack/email

### ⚠️ Pitfalls

- ❌ **Queries pesadas:** Usar recording rules
- ❌ **Muitos alertas:** Fadiga de alertas
- ❌ **Thresholds estáticos:** Usar anomaly detection
- ❌ **Dashboard sem contexto:** Adicionar annotations

### 🚀 Extensão

1. **SLO Dashboard:** Visualizar SLI vs SLO (99.9% uptime)
2. **Anomaly Detection:** Usar Grafana ML para detectar padrões
3. **Drill-down:** Link do dashboard para traces no Jaeger

---

## 🔗 Exercício 5: Integração Completa (Logs + Métricas + Traces)

### 🎯 Objetivo

Integrar **logs**, **métricas** e **traces** para investigação rápida de incidentes.

### 📖 Contexto

Alerta dispara: "Taxa de erro > 5%". Você precisa:

1. Ver no dashboard qual serviço está falhando
2. Clicar no trace com erro
3. Ver logs relacionados ao trace

### 🛠️ Passos

#### 1. Linkar Logs a Traces

```java
@Component
public class TracingLogAppender {

    @PostConstruct
    public void init() {
        // Adicionar trace/span ID aos logs automaticamente
        MDC.putCloseable("traceId", () -> {
            Span span = Span.current();
            return span.getSpanContext().getTraceId();
        });

        MDC.putCloseable("spanId", () -> {
            Span span = Span.current();
            return span.getSpanContext().getSpanId();
        });
    }
}
```

**Log JSON com trace ID:**

```json
{
  "@timestamp": "2025-11-15T10:30:45.123Z",
  "level": "ERROR",
  "message": "Payment failed",
  "correlationId": "a1b2c3d4",
  "traceId": "4bf92f3577b34da6a3ce929d0e0e4736",
  "spanId": "00f067aa0ba902b7",
  "errorCode": "PAYMENT_DECLINED"
}
```

#### 2. Configurar Exemplars (Métricas → Traces)

```java
@Configuration
public class ExemplarsConfig {

    @Bean
    public MeterRegistryCustomizer<PrometheusMeterRegistry> exemplarsConfig() {
        return registry -> registry.config()
            .meterFilter(new MeterFilter() {
                @Override
                public DistributionStatisticConfig configure(Meter.Id id, DistributionStatisticConfig config) {
                    return DistributionStatisticConfig.builder()
                        .percentilesHistogram(true)
                        .serviceLevelObjectives(
                            Duration.ofMillis(100).toNanos(),
                            Duration.ofMillis(500).toNanos(),
                            Duration.ofSeconds(1).toNanos()
                        )
                        .build()
                        .merge(config);
                }
            });
    }
}
```

#### 3. Workflow de Investigação

**Cenário:** Alerta de erro alto dispara

1. **Dashboard Grafana:** Ver painel "Error Rate" subiu para 8%
2. **Click no spike:** Ver exemplar (trace ID)
3. **Abrir Jaeger:** Ver trace completo com latência por span
4. **Identificar span lento:** `process-payment` demorou 5s
5. **Ver logs do span:** Filtrar logs por `spanId` no Loki
6. **Root cause:** Log mostra "Payment API timeout after 5s"

#### 4. Criar Query Unificada no Grafana

```promql
# Painel 1: Métrica com exemplar
histogram_quantile(0.95,
  rate(orders_processing_time_seconds_bucket[5m])
)

# Painel 2: Logs relacionados (Loki)
{service="order-service", traceId=~"$traceId"}

# Painel 3: Trace (Tempo)
<trace visualization from exemplar>
```

### ✅ Critério de Sucesso

- ✅ Logs contêm trace/span ID
- ✅ Métricas têm exemplars linkando a traces
- ✅ Dashboard permite drill-down: Métrica → Trace → Logs
- ✅ Investigação de incidente < 5 minutos
- ✅ Grafana Tempo integrado (traces visualization)

### ⚠️ Pitfalls

- ❌ **Logs sem trace ID:** Não consegue correlacionar
- ❌ **Exemplars desabilitados:** Não consegue linkar métrica → trace
- ❌ **Sampling muito baixo:** Exemplar pode não existir
- ❌ **Ferramentas isoladas:** Usar stack integrado (Grafana LGTM)

### 🚀 Extensão

1. **Grafana OnCall:** Rotação de plantão automática
2. **Runbooks:** Documentar procedimentos de investigação
3. **SRE Golden Signals:** Latency, Traffic, Errors, Saturation

---

## 📊 Checkpoint: Autoavaliação da Trilha Observabilidade

### Nível Intermediário (41-70%)

- ⬜ Logs estruturados em JSON
- ⬜ Correlation ID em logs
- ⬜ Métricas básicas (Counter, Timer)
- ⬜ Dashboard Grafana com métricas técnicas

### Nível Avançado (71-90%)

- ⬜ Correlation ID propagado entre serviços
- ⬜ Métricas de negócio (KPIs)
- ⬜ Distributed tracing com spans customizados
- ⬜ Dashboard com alertas configurados
- ⬜ Logs + Métricas + Traces integrados

### Nível Senior (91-100%)

- ⬜ Exemplars linkando métricas → traces
- ⬜ Drill-down completo (métrica → trace → logs)
- ⬜ SLI/SLO definidos e monitorados
- ⬜ Anomaly detection configurado
- ⬜ Runbooks documentados
- ⬜ MTTR (Mean Time to Recovery) < 15min

---

**Criado em:** 2025-11-15  
**Tempo Estimado:** 8-10 horas  
**Próxima Trilha:** [Performance](trilhas/04-performance.md)
