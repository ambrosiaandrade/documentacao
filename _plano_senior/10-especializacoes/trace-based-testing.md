# 🔍 Trace-Based Testing - Especializações Avançadas

## Índice

1. [Introdução](#1-introdução)
2. [OpenTelemetry Fundamentals](#2-opentelemetry-fundamentals)
3. [Validação de Traces](#3-validação-de-traces)
4. [Propagação de Contexto](#4-propagação-de-contexto)
5. [Ferramentas Open Source](#5-ferramentas-open-source)
6. [Testes Práticos](#6-testes-práticos)
7. [Métricas](#7-métricas)
8. [Boas Práticas](#8-boas-práticas)

---

## 1. Introdução

### O que é Trace-Based Testing?

**Definição:** Testes que validam comportamento do sistema através da análise de traces distribuídos (spans, contexto, atributos).

**Diferença de Testes Tradicionais:**
| Aspecto | Testes Tradicionais | Trace-Based Testing |
|---------|---------------------|---------------------|
| **Validação** | Entrada/saída direta | Comportamento observado |
| **Escopo** | Unidade/integração | Sistema distribuído |
| **Fonte** | Asserções explícitas | Traces coletados |
| **Quando** | Durante execução | Durante ou pós-execução |
| **Objetivo** | Provar correção | Provar observabilidade |

### Por que Trace-Based Testing?

**Benefícios:**

- ✅ Validar propagação de contexto entre serviços
- ✅ Detectar problemas de latência e bottlenecks
- ✅ Garantir instrumentação consistente
- ✅ Verificar conformidade com SLOs
- ✅ Debugging facilitado em produção

**Casos de Uso:**

- 🎯 Validar spans criados corretamente
- 🎯 Verificar atributos obrigatórios (user_id, trace_id)
- 🎯 Detectar spans órfãos (sem parent)
- 🎯 Medir latência fim-a-fim
- 🎯 Auditar operações críticas

---

## 2. OpenTelemetry Fundamentals

### 2.1 Conceitos Básicos

**Trace:** Jornada completa de uma requisição através de múltiplos serviços.

**Span:** Unidade de trabalho individual dentro de um trace.

```
Trace ID: 4bf92f3577b34da6a3ce929d0e0e4736

├─ Span: HTTP GET /orders [200ms]
   ├─ Span: OrderService.getOrder() [150ms]
   │  ├─ Span: DB Query SELECT * FROM orders [80ms]
   │  └─ Span: Cache.get(order:123) [5ms]
   └─ Span: PaymentService.validate() [45ms]
      └─ Span: HTTP POST /payment/validate [40ms]
```

**Context Propagation:** Passar trace_id/span_id entre serviços via headers HTTP.

### 2.2 Setup OpenTelemetry (Java)

**Dependências:**

```xml
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-api</artifactId>
    <version>1.32.0</version>
</dependency>
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-sdk</artifactId>
    <version>1.32.0</version>
</dependency>
<dependency>
    <groupId>io.opentelemetry</groupId>
    <artifactId>opentelemetry-exporter-otlp</artifactId>
    <version>1.32.0</version>
</dependency>
```

**Configuração (Java 17+):**

````java
import io.opentelemetry.api.GlobalOpenTelemetry;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.SimpleSpanProcessor;
import io.opentelemetry.exporter.otlp.trace.OtlpGrpcSpanExporter;
import io.opentelemetry.sdk.resources.Resource;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.semconv.ResourceAttributes;

public final class TelemetryConfig {

    private TelemetryConfig() {} // Utility class

    public static OpenTelemetry initTelemetry(String serviceName) {
        var spanExporter = OtlpGrpcSpanExporter.builder()
            .setEndpoint("http://localhost:4317")
            .build();

        var tracerProvider = SdkTracerProvider.builder()
            .addSpanProcessor(SimpleSpanProcessor.create(spanExporter))
            .setResource(Resource.create(Attributes.of(
                ResourceAttributes.SERVICE_NAME, serviceName
            )))
            .build();

        return OpenTelemetrySdk.builder()
            .setTracerProvider(tracerProvider)
            .buildAndRegisterGlobal();
    }
}
```---

## 3. Validação de Traces

### 3.1 Capturar Traces em Testes

**InMemorySpanExporter (Java 17+):**

```java
import io.opentelemetry.sdk.testing.exporter.InMemorySpanExporter;
import io.opentelemetry.sdk.trace.data.SpanData;
import io.opentelemetry.api.trace.SpanKind;
import io.opentelemetry.api.common.AttributeKey;

@SpringBootTest
class OrderServiceTraceTest {

    private static InMemorySpanExporter spanExporter;
    private static OpenTelemetry openTelemetry;

    @BeforeAll
    static void setupTelemetry() {
        spanExporter = InMemorySpanExporter.create();

        var tracerProvider = SdkTracerProvider.builder()
            .addSpanProcessor(SimpleSpanProcessor.create(spanExporter))
            .build();

        openTelemetry = OpenTelemetrySdk.builder()
            .setTracerProvider(tracerProvider)
            .build();
    }

    @BeforeEach
    void resetSpans() {
        spanExporter.reset();
    }

    @Test
    void deveCriarSpanParaCriacaoDePedido() {
        // Arrange
        var request = new OrderRequest("item-123", 2);

        // Act
        orderService.createOrder(request);

        // Assert - Validar spans coletados
        var spans = spanExporter.getFinishedSpanItems();

        assertThat(spans).hasSize(3);

        // Validar span raiz (Java 17+ Stream API)
        var rootSpan = spans.stream()
            .filter(s -> s.getParentSpanId().isEmpty())
            .findFirst()
            .orElseThrow(() -> new AssertionError("Root span not found"));

        assertThat(rootSpan.getName()).isEqualTo("OrderService.createOrder");
        assertThat(rootSpan.getKind()).isEqualTo(SpanKind.SERVER);
        assertThat(rootSpan.getAttributes().get(AttributeKey.stringKey("order.id")))
            .isNotNull();
    }
}
```### 3.2 Validações Comuns

**Hierarquia de Spans (Java 17+):**

```java
@Test
void deveManterHierarquiaCorretaDeSpans() {
    orderService.processOrder("order-456");

    var spans = spanExporter.getFinishedSpanItems();

    // Encontrar span raiz
    var rootSpan = findRootSpan(spans);
    assertThat(rootSpan.getName()).isEqualTo("OrderService.processOrder");

    // Validar filhos (usando toList() do Java 17+)
    var children = findChildrenOf(rootSpan, spans);
    assertThat(children).hasSize(2);
    assertThat(children)
        .extracting(SpanData::getName)
        .containsExactlyInAnyOrder(
            "DB:SELECT orders",
            "PaymentService.validate"
        );
}

private SpanData findRootSpan(List<SpanData> spans) {
    return spans.stream()
        .filter(s -> s.getParentSpanId().isEmpty())
        .findFirst()
        .orElseThrow(() -> new AssertionError("No root span found"));
}

private List<SpanData> findChildrenOf(SpanData parent, List<SpanData> allSpans) {
    return allSpans.stream()
        .filter(s -> s.getParentSpanId().equals(parent.getSpanId()))
        .toList(); // Java 16+: .toList() instead of .collect(Collectors.toList())
}
```**Atributos Obrigatórios:**

```java
@Test
void deveIncluirAtributosObrigatoriosNoSpan() {
    orderService.createOrder(new OrderRequest("item-789", 1));

    SpanData span = spanExporter.getFinishedSpanItems().get(0);

    // Atributos de negócio
    assertThat(span.getAttributes().get(stringKey("order.id"))).isNotNull();
    assertThat(span.getAttributes().get(stringKey("user.id"))).isNotNull();
    assertThat(span.getAttributes().get(longKey("order.amount"))).isGreaterThan(0);

    // Atributos técnicos
    assertThat(span.getAttributes().get(stringKey("http.method"))).isEqualTo("POST");
    assertThat(span.getAttributes().get(longKey("http.status_code"))).isEqualTo(201);
}
````

**Status e Erros (Java 17+):**

````java
@Test
void deveCriarSpanComStatusErroQuandoFalha() {
    // Arrange
    when(paymentService.validate(any()))
        .thenThrow(new PaymentException("Saldo insuficiente"));

    // Act & Assert
    assertThrows(PaymentException.class, () ->
        orderService.createOrder(new OrderRequest("item-999", 1))
    );

    // Validar span
    var span = spanExporter.getFinishedSpanItems().get(0);

    assertThat(span.getStatus().getStatusCode()).isEqualTo(StatusCode.ERROR);
    assertThat(span.getStatus().getDescription()).contains("Saldo insuficiente");

    // Validar evento de exceção (Java 17+ pattern matching preview)
    assertThat(span.getEvents()).hasSize(1);
    var event = span.getEvents().get(0);
    assertThat(event.getName()).isEqualTo("exception");
    assertThat(event.getAttributes().get(stringKey("exception.type")))
        .isEqualTo("PaymentException");
}
```---

## 4. Propagação de Contexto

### 4.1 Validar Propagação HTTP

**Context Headers (W3C Trace Context):**

````

traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01
││ │ ││
│└─ trace-id (128-bit) │ │└─ trace-flags
│ └─ parent-id │
└─ version (span-id 64-bit)└─ sampled

````

**Teste de Propagação (Java 17+):**

```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class ContextPropagationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void devePropagar_TraceContext_EntreServicos() {
        // Arrange - Criar trace inicial
        var tracer = GlobalOpenTelemetry.getTracer("test");
        var span = tracer.spanBuilder("test-request").startSpan();

        try (var scope = span.makeCurrent()) { // Java 17+ try-with-resources
            var headers = new HttpHeaders();

            // OpenTelemetry propaga automaticamente via W3CPropagator
            // Mas podemos validar explicitamente
            var traceParent = """
                00-%s-%s-01
                """.formatted( // Java 15+ Text Blocks + formatted()
                    span.getSpanContext().getTraceId(),
                    span.getSpanContext().getSpanId()
                ).strip();
            headers.set("traceparent", traceParent);

            // Act
            var response = restTemplate.exchange(
                "http://localhost:" + port + "/orders",
                HttpMethod.POST,
                new HttpEntity<>(new OrderRequest("item-123", 1), headers),
                Order.class
            );

            // Assert
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);

            // Validar que spans downstream têm mesmo trace_id
            var spans = spanExporter.getFinishedSpanItems();
            assertThat(spans).isNotEmpty();

            var expectedTraceId = span.getSpanContext().getTraceId();
            spans.forEach(s ->
                assertThat(s.getTraceId()).isEqualTo(expectedTraceId)
            );

        } finally {
            span.end();
        }
    }
}
```### 4.2 Baggage (Contexto Customizado)

**Adicionar Baggage (Java 17+):**

```java
import io.opentelemetry.api.baggage.Baggage;

@Test
void devePropagar_BaggageCustomizado_EntreSpans() {
    var tracer = GlobalOpenTelemetry.getTracer("test");

    // Adicionar baggage ao contexto (Java 17+ var)
    var baggage = Baggage.builder()
        .put("user.id", "user-789")
        .put("tenant.id", "tenant-abc")
        .build();

    try (var baggageScope = baggage.makeCurrent()) {
        var span = tracer.spanBuilder("parent-operation").startSpan();

        try (var spanScope = span.makeCurrent()) {
            // Operação que cria spans internos
            orderService.processOrder("order-123");

            // Validar que baggage foi propagado
            var spans = spanExporter.getFinishedSpanItems();

            // Java 17+ enhanced forEach with var
            spans.forEach(s -> {
                var attributes = s.getAttributes();
                assertThat(attributes.get(stringKey("user.id")))
                    .isEqualTo("user-789");
                assertThat(attributes.get(stringKey("tenant.id")))
                    .isEqualTo("tenant-abc");
            });
        } finally {
            span.end();
        }
    }
}
```---

## 5. Ferramentas Open Source

### 5.1 Jaeger (Backend + UI)

**Docker Compose:**

```yaml
version: "3.8"
services:
  jaeger:
    image: jaegertracing/all-in-one:1.51
    ports:
      - "16686:16686" # UI
      - "4317:4317" # OTLP gRPC
      - "4318:4318" # OTLP HTTP
    environment:
      - COLLECTOR_OTLP_ENABLED=true
````

**Query API para Testes:**

```java
@Test
void deveValidar_TracesNoJaeger_AposCriacaoDePedido() {
    // Act
    orderService.createOrder(new OrderRequest("item-456", 3));

    // Aguardar ingestão
    await().atMost(5, SECONDS).untilAsserted(() -> {
        // Query Jaeger API
        String jaegerUrl = "http://localhost:16686/api/traces?service=order-service&limit=1";

        RestTemplate restTemplate = new RestTemplate();
        JsonNode response = restTemplate.getForObject(jaegerUrl, JsonNode.class);

        assertThat(response.get("data")).isNotEmpty();

        JsonNode trace = response.get("data").get(0);
        JsonNode spans = trace.get("spans");

        assertThat(spans).hasSizeGreaterThan(0);
        assertThat(spans.get(0).get("operationName").asText())
            .isEqualTo("OrderService.createOrder");
    });
}
```

### 5.2 Grafana Tempo

**Docker Compose:**

```yaml
services:
  tempo:
    image: grafana/tempo:2.3.0
    command: ["-config.file=/etc/tempo.yaml"]
    volumes:
      - ./tempo.yaml:/etc/tempo.yaml
    ports:
      - "4317:4317" # OTLP gRPC
      - "3200:3200" # Tempo HTTP

  grafana:
    image: grafana/grafana:10.2.0
    ports:
      - "3000:3000"
    environment:
      - GF_AUTH_ANONYMOUS_ENABLED=true
```

**tempo.yaml:**

```yaml
server:
  http_listen_port: 3200

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317

storage:
  trace:
    backend: local
    local:
      path: /tmp/tempo/traces
```

---

## 6. Testes Práticos

### 6.1 Teste de Latência

```java
@Test
void deveDetectar_SpansLentos_AcimaDe1Segundo() {
    // Act
    orderService.processLargeOrder("order-999");

    // Assert
    List<SpanData> spans = spanExporter.getFinishedSpanItems();

    List<SpanData> slowSpans = spans.stream()
        .filter(s -> {
            long durationMs = Duration.between(
                Instant.ofEpochMilli(s.getStartEpochNanos() / 1_000_000),
                Instant.ofEpochMilli(s.getEndEpochNanos() / 1_000_000)
            ).toMillis();
            return durationMs > 1000;
        })
        .toList();

    assertThat(slowSpans).isEmpty()
        .withFailMessage("Spans lentos detectados: %s",
            slowSpans.stream()
                .map(s -> s.getName() + " (" + getDuration(s) + "ms)")
                .toList()
        );
}

private long getDuration(SpanData span) {
    return (span.getEndEpochNanos() - span.getStartEpochNanos()) / 1_000_000;
}
```

### 6.2 Teste de Conformidade

```java
@Test
void todosSpans_DevemSeguir_NamingConvention() {
    // Act
    orderService.processOrder("order-123");

    // Assert
    List<SpanData> spans = spanExporter.getFinishedSpanItems();

    spans.forEach(span -> {
        String name = span.getName();

        // Convention: <Service>.<method> ou <Type>:<operation>
        assertThat(name).matches("(\\w+\\.\\w+)|(\\w+:\\w+( \\w+)?)")
            .withFailMessage("Span '%s' não segue naming convention", name);

        // Atributos obrigatórios
        assertThat(span.getAttributes().get(stringKey("service.name"))).isNotNull();
        assertThat(span.getKind()).isNotNull();
    });
}
```

---

## 7. Métricas

### 7.1 Métricas-Chave

**Trace Completeness:**

```
Trace Completeness = (Spans com parent válido / Total spans) × 100
Meta: ≥ 95%
```

**Span Coverage:**

```
Span Coverage = (Operações instrumentadas / Total operações críticas) × 100
Meta: 100% para operações de negócio
```

**Context Propagation Rate:**

```
Propagation Rate = (Requisições com trace_id / Total requisições) × 100
Meta: 100%
```

### 7.2 Coleta Automática

**Script Python:**

```python
#!/usr/bin/env python3
import requests
import json
from datetime import datetime, timedelta

def collect_trace_metrics(jaeger_url, service_name, hours=24):
    """Coleta métricas de traces do Jaeger"""

    end_time = datetime.now()
    start_time = end_time - timedelta(hours=hours)

    # Query traces
    params = {
        'service': service_name,
        'start': int(start_time.timestamp() * 1_000_000),
        'end': int(end_time.timestamp() * 1_000_000),
        'limit': 1000
    }

    response = requests.get(f"{jaeger_url}/api/traces", params=params)
    data = response.json()

    traces = data.get('data', [])

    total_spans = 0
    orphan_spans = 0
    slow_spans = 0
    error_spans = 0

    for trace in traces:
        spans = trace.get('spans', [])
        total_spans += len(spans)

        for span in spans:
            # Detectar órfãos
            parent_id = span.get('references', [{}])[0].get('spanID')
            if not parent_id and span.get('spanID') != trace.get('traceID'):
                orphan_spans += 1

            # Detectar lentos (> 1s)
            duration_us = span.get('duration', 0)
            if duration_us > 1_000_000:
                slow_spans += 1

            # Detectar erros
            tags = {t['key']: t['value'] for t in span.get('tags', [])}
            if tags.get('error') == 'true':
                error_spans += 1

    metrics = {
        'timestamp': datetime.now().isoformat(),
        'service': service_name,
        'period_hours': hours,
        'total_traces': len(traces),
        'total_spans': total_spans,
        'orphan_spans': orphan_spans,
        'slow_spans': slow_spans,
        'error_spans': error_spans,
        'completeness_rate': ((total_spans - orphan_spans) / total_spans * 100) if total_spans > 0 else 0,
        'error_rate': (error_spans / total_spans * 100) if total_spans > 0 else 0
    }

    return metrics

if __name__ == '__main__':
    metrics = collect_trace_metrics('http://localhost:16686', 'order-service')
    print(json.dumps(metrics, indent=2))

    # Validar quality gates
    assert metrics['completeness_rate'] >= 95, f"Completeness abaixo de 95%: {metrics['completeness_rate']:.2f}%"
    assert metrics['error_rate'] <= 5, f"Error rate acima de 5%: {metrics['error_rate']:.2f}%"
```

---

## 8. Boas Práticas

### ✅ DO

1. **Nomear spans semanticamente**

   ```java
   // ✅ BOM
   span.updateName("OrderService.createOrder");

   // ❌ RUIM
   span.updateName("doSomething");
   ```

2. **Adicionar atributos de negócio**

   ```java
   span.setAttribute("order.id", orderId);
   span.setAttribute("user.id", userId);
   span.setAttribute("order.total", totalAmount);
   ```

3. **Registrar eventos importantes**

   ```java
   span.addEvent("payment_validated");
   span.addEvent("inventory_reserved", Attributes.of(
       stringKey("item.id"), itemId,
       longKey("quantity"), quantity
   ));
   ```

4. **Marcar erros explicitamente**
   ```java
   try {
       // operação
   } catch (Exception e) {
       span.setStatus(StatusCode.ERROR, e.getMessage());
       span.recordException(e);
       throw e;
   }
   ```

### ❌ DON'T

1. **Não criar spans para tudo** - Foco em operações de negócio
2. **Não adicionar dados sensíveis** - PII, senhas, tokens
3. **Não ignorar context propagation** - Sempre propagar
4. **Não esquecer de fechar spans** - Use try-with-resources

---

## 📊 Resumo de Métricas

| Métrica                 | Meta  | Coleta                    |
| ----------------------- | ----- | ------------------------- |
| **Trace Completeness**  | ≥ 95% | Jaeger API + script       |
| **Span Coverage**       | 100%  | Análise estática + manual |
| **Context Propagation** | 100%  | Logs + testes integração  |
| **Error Rate (spans)**  | ≤ 5%  | Jaeger API                |
| **Slow Spans (> 1s)**   | < 1%  | Jaeger API + alertas      |

---

## 🎯 Checklist

- [ ] OpenTelemetry SDK configurado
- [ ] InMemorySpanExporter em testes
- [ ] Validação de hierarquia de spans
- [ ] Validação de atributos obrigatórios
- [ ] Testes de propagação de contexto
- [ ] Jaeger/Tempo configurado
- [ ] Scripts de coleta de métricas
- [ ] Alertas para orphan spans
- [ ] Naming convention documentada
- [ ] PII protection implementada
