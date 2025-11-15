# 📚 Glossário Técnico de Testes

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Tipos de Testes](#2-tipos-de-testes)
3. [Padrões e Técnicas](#3-padrões-e-técnicas)
4. [Métricas e Qualidade](#4-métricas-e-qualidade)
5. [Arquitetura e Resiliência](#5-arquitetura-e-resiliência)
6. [Ferramentas Open Source](#6-ferramentas-open-source)
7. [Conceitos Avançados](#7-conceitos-avançados)
8. [Termos Ambíguos (Normalização)](#8-termos-ambíguos-normalização)

---

## 1. Visão Geral

### 🎯 Objetivo

Padronizar terminologia usada em testes de software, eliminando ambiguidades e estabelecendo vocabulário comum para o time.

### 📋 Convenções

- **Termo**: Nome padronizado
- **Definição**: Explicação clara e concisa
- **Contexto**: Quando/onde usar
- **Exemplo**: Ilustração prática
- **Sinônimos**: Termos equivalentes (evitar)
- **Relacionado**: Termos conectados
- **Ferramenta Open Source**: Implementação de referência

---

## 2. Tipos de Testes

### Unit Test (Teste Unitário)

**Definição:** Teste que valida uma única unidade de código (método, função, classe) isoladamente, sem dependências externas.

**Contexto:** Primeira linha de defesa; executado frequentemente (a cada commit).

**Exemplo:**

```java
@Test
void deveCalcularDesconto() {
    Calculator calc = new Calculator();
    assertEquals(90.0, calc.applyDiscount(100.0, 10));
}
```

**Características:**

- ✅ Rápido (< 100ms)
- ✅ Isolado (sem I/O, rede, banco)
- ✅ Determinístico (sempre mesmo resultado)
- ✅ Independente (não depende de outros testes)

**Ferramentas:** JUnit 5, pytest, Jest

**Relacionado:** Test Double, Mock, Stub

---

### Integration Test (Teste de Integração)

**Definição:** Teste que valida a interação entre múltiplos componentes ou sistemas, incluindo dependências reais (banco de dados, APIs, filas).

**Contexto:** Validar contratos entre componentes; detectar problemas de comunicação.

**Exemplo:**

```java
@SpringBootTest
@Testcontainers
class OrderServiceIntegrationTest {
    @Container
    static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:15-alpine");

    @Test
    void devePersistirPedidoNoBanco() {
        Order order = new Order("item-123", 2);
        orderService.save(order);

        Order retrieved = orderRepository.findById(order.getId()).orElseThrow();
        assertEquals("item-123", retrieved.getItemId());
    }
}
```

**Características:**

- ⏱️ Mais lento que unitário (1-5s)
- 🔗 Usa dependências reais
- 🐳 Ideal com TestContainers
- 📊 Valida fluxo completo

**Ferramentas:** TestContainers, Spring Boot Test, pytest-docker

**Relacionado:** Contract Test, E2E Test

---

### Contract Test (Teste de Contrato)

**Definição:** Teste que valida o contrato (schema, formato, comportamento) entre consumidor e provedor de uma API, sem necessidade de integração real.

**Contexto:** Microservices; validar quebra de contratos antes do deploy.

**Exemplo (Pact):**

```java
// Consumer test
@Pact(consumer = "OrderService", provider = "PaymentService")
public RequestResponsePact createPact(PactDslWithProvider builder) {
    return builder
        .given("payment service is up")
        .uponReceiving("a request to process payment")
        .path("/payments")
        .method("POST")
        .body(new PactDslJsonBody()
            .stringType("orderId", "order-123")
            .decimalType("amount", 99.99))
        .willRespondWith()
        .status(200)
        .body(new PactDslJsonBody()
            .stringType("paymentId", "pay-456")
            .stringType("status", "APPROVED"))
        .toPact();
}

@Test
@PactVerification
void deveProcessarPagamento() {
    PaymentResponse response = paymentClient.processPayment(
        new PaymentRequest("order-123", 99.99)
    );
    assertEquals("APPROVED", response.getStatus());
}
```

**Características:**

- 🤝 Valida contrato, não implementação
- 🚀 Mais rápido que E2E
- 📝 Gera especificação automática
- 🔄 Bi-direcional (consumer + provider)

**Ferramentas:** Pact, Spring Cloud Contract

**Relacionado:** Consumer-Driven Contract, API Specification

---

### End-to-End Test (Teste Ponta a Ponta)

**Definição:** Teste que valida o fluxo completo da aplicação, do front-end ao back-end, simulando interação real do usuário.

**Contexto:** Validar jornadas críticas de negócio; smoke tests em produção.

**Exemplo (Selenium):**

```java
@Test
void deveCompletarFluxoDeCompra() {
    driver.get("https://myapp.com/products");

    // Selecionar produto
    driver.findElement(By.id("product-123")).click();
    driver.findElement(By.id("add-to-cart")).click();

    // Checkout
    driver.findElement(By.id("checkout-button")).click();
    driver.findElement(By.id("credit-card")).sendKeys("4111111111111111");
    driver.findElement(By.id("submit-order")).click();

    // Validar confirmação
    WebElement confirmation = driver.findElement(By.id("order-confirmation"));
    assertTrue(confirmation.getText().contains("Pedido confirmado"));
}
```

**Características:**

- 🐌 Lento (30s - 5min)
- 💰 Custoso de manter
- 🎭 Simula usuário real
- ⚠️ Propenso a flakiness

**Ferramentas:** Selenium, Playwright, Cypress

**Relacionado:** Smoke Test, UI Test

---

### Smoke Test (Teste de Fumaça)

**Definição:** Conjunto mínimo de testes E2E que valida funcionalidades críticas após deploy, garantindo que "a aplicação não está pegando fogo".

**Contexto:** Pós-deploy em produção; health check avançado.

**Exemplo:**

```bash
#!/bin/bash
# smoke-test.sh

echo "🔍 Running smoke tests..."

# 1. Health check
curl -f http://api.example.com/health || exit 1

# 2. Autenticação
TOKEN=$(curl -X POST http://api.example.com/auth \
  -d '{"user":"test","pass":"test"}' \
  | jq -r '.token')

[ -z "$TOKEN" ] && exit 1

# 3. Endpoint crítico
curl -f -H "Authorization: Bearer $TOKEN" \
  http://api.example.com/orders || exit 1

echo "✅ Smoke tests passed"
```

**Características:**

- ⚡ Rápido (< 5min)
- 🎯 Apenas fluxos críticos
- 🚨 Falha = rollback imediato
- 🔄 Executado em cada deploy

**Ferramentas:** curl + bash, Postman/Newman, k6

**Relacionado:** Health Check, Canary Deployment

---

### Performance Test (Teste de Performance)

**Definição:** Teste que mede características não-funcionais como throughput, latência, uso de recursos sob carga específica.

**Contexto:** Validar SLAs; identificar bottlenecks; capacity planning.

**Exemplo (JMeter):**

```xml
<!-- jmeter-test-plan.jmx -->
<ThreadGroup>
    <stringProp name="ThreadGroup.num_threads">100</stringProp>
    <stringProp name="ThreadGroup.ramp_time">10</stringProp>
    <stringProp name="ThreadGroup.duration">300</stringProp>

    <HTTPSamplerProxy>
        <stringProp name="HTTPSampler.domain">api.example.com</stringProp>
        <stringProp name="HTTPSampler.path">/orders</stringProp>
        <stringProp name="HTTPSampler.method">POST</stringProp>
    </HTTPSamplerProxy>

    <ConstantTimer>
        <stringProp name="ConstantTimer.delay">1000</stringProp>
    </ConstantTimer>
</ThreadGroup>
```

**Tipos:**

- **Load Test**: Comportamento sob carga esperada
- **Stress Test**: Limite de capacidade (quebra)
- **Spike Test**: Picos repentinos de tráfego
- **Soak Test**: Estabilidade em longa duração

**Métricas:**

- Throughput (req/s)
- Latência (P50, P95, P99)
- Error rate (%)
- Resource usage (CPU, memória)

**Ferramentas:** JMeter, Gatling, k6, Locust

**Relacionado:** SLA, SLO, Benchmark

---

### Chaos Test (Teste de Caos)

**Definição:** Teste que injeta falhas deliberadas (latência, indisponibilidade, erros) para validar resiliência e recuperação do sistema.

**Contexto:** Validar tolerância a falhas; testar circuit breakers, retries, fallbacks.

**Exemplo (Chaos Toolkit):**

```yaml
# chaos-experiment.yaml
version: 1.0.0
title: "Simular indisponibilidade do banco de dados"

steady-state-hypothesis:
  title: "Sistema responde com sucesso"
  probes:
    - type: probe
      name: health-check
      provider:
        type: http
        url: http://api.example.com/health
        timeout: 5
      tolerance: 200

method:
  - type: action
    name: stop-database
    provider:
      type: process
      path: kubectl
      arguments: ["scale", "deployment/postgres", "--replicas=0"]
    pauses:
      after: 30 # aguardar 30s com DB down

  - type: probe
    name: verify-fallback
    provider:
      type: http
      url: http://api.example.com/orders
      timeout: 5
    tolerance:
      - 200 # cache hit
      - 503 # circuit breaker open

rollbacks:
  - type: action
    name: restore-database
    provider:
      type: process
      path: kubectl
      arguments: ["scale", "deployment/postgres", "--replicas=1"]
```

**Princípios (Chaos Engineering):**

1. Formular hipótese (estado steady)
2. Injetar falha real
3. Observar comportamento
4. Minimizar blast radius
5. Automatizar experimentos

**Ferramentas:** Chaos Toolkit, Chaos Monkey, LitmusChaos, Pumba

**Relacionado:** Resilience Test, Fault Injection

---

## 3. Padrões e Técnicas

### AAA Pattern (Arrange-Act-Assert)

**Definição:** Padrão estrutural de teste dividido em três fases: preparação, execução e validação.

**Exemplo:**

```java
@Test
void deveCalcularTotalComDesconto() {
    // Arrange (preparação)
    Calculator calc = new Calculator();
    double price = 100.0;
    int quantity = 3;

    // Act (execução)
    double total = calc.calculateTotal(price, quantity, 0.1);

    // Assert (validação)
    assertEquals(270.0, total); // (100 * 3) * 0.9
}
```

**Benefícios:**

- 📖 Legibilidade
- 🎯 Foco claro
- 🔍 Fácil debug

**Relacionado:** Given-When-Then (BDD)

---

### Test Double (Dublê de Teste)

**Definição:** Objeto substituto que simula comportamento de dependência real em testes.

**Tipos:**

#### 1. **Dummy**

Objeto passado mas nunca usado (preencher parâmetros).

```java
User dummy = new User(); // não importa o conteúdo
service.logAction(dummy, "action");
```

#### 2. **Stub**

Retorna resposta pré-programada.

```java
class StubUserRepository implements UserRepository {
    @Override
    public User findById(Long id) {
        return new User(id, "John");
    }
}
```

#### 3. **Spy**

Registra como foi usado (quantas vezes, com quais parâmetros).

```java
@Test
void deveEnviarEmail() {
    EmailService spy = spy(new EmailService());

    service.notifyUser(user);

    verify(spy).send("user@example.com", "Welcome!");
}
```

#### 4. **Mock**

Valida interações específicas (ordem, parâmetros).

```java
@Test
void deveChamarRepositorioComIdCorreto() {
    UserRepository mock = mock(UserRepository.class);
    when(mock.findById(1L)).thenReturn(Optional.of(user));

    service.getUser(1L);

    verify(mock).findById(1L); // validação de interação
}
```

#### 5. **Fake**

Implementação simplificada (em memória).

```java
class FakeUserRepository implements UserRepository {
    private Map<Long, User> users = new HashMap<>();

    @Override
    public void save(User user) {
        users.put(user.getId(), user);
    }

    @Override
    public Optional<User> findById(Long id) {
        return Optional.ofNullable(users.get(id));
    }
}
```

**Ferramentas:** Mockito, unittest.mock (Python), Sinon (JS)

**Relacionado:** Dependency Injection, Test Isolation

---

### Mutation Testing (Teste de Mutação)

**Definição:** Técnica que introduz pequenas mudanças (mutações) no código-fonte para avaliar se os testes detectam essas alterações.

**Exemplo:**

```java
// Código original
if (quantity >= 10) {
    return price * 0.9;
}

// Mutação 1: operador relacional
if (quantity > 10) {  // >= → >
    return price * 0.9;
}

// Mutação 2: constante
if (quantity >= 11) {  // 10 → 11
    return price * 0.9;
}

// Mutação 3: operador aritmético
if (quantity >= 10) {
    return price * 0.8;  // 0.9 → 0.8
}
```

**Mutante Morto:** Mutação detectada por teste (✅ bom)
**Mutante Sobrevivente:** Mutação não detectada (❌ gap de teste)

**Fórmula:**

```
Mutation Score = (Mutantes Mortos / Total de Mutantes) × 100
```

**Ferramentas:** PITest (Java), Stryker (JS/TS), mutmut (Python)

**Relacionado:** Code Coverage, Test Effectiveness

---

### Property-Based Testing (Teste Baseado em Propriedades)

**Definição:** Técnica que gera automaticamente casos de teste baseados em propriedades invariantes que devem sempre ser verdadeiras.

**Exemplo (Hypothesis - Python):**

```python
from hypothesis import given, strategies as st

# Propriedade: lista reversa duas vezes = lista original
@given(st.lists(st.integers()))
def test_reverse_twice_is_identity(lst):
    assert list(reversed(list(reversed(lst)))) == lst

# Propriedade: sort é idempotente
@given(st.lists(st.integers()))
def test_sort_is_idempotent(lst):
    once = sorted(lst)
    twice = sorted(sorted(lst))
    assert once == twice
```

**Benefícios:**

- 🔍 Encontra edge cases inesperados
- 🎲 Testa com milhares de inputs gerados
- 📊 Reduz casos de teste manuais

**Ferramentas:** Hypothesis (Python), QuickCheck (Haskell), fast-check (JS)

**Relacionado:** Fuzz Testing, Generative Testing

---

## 4. Métricas e Qualidade

### Code Coverage (Cobertura de Código)

**Definição:** Percentual do código-fonte executado pelos testes.

**Tipos:**

1. **Line Coverage** (Cobertura de Linhas)

   ```
   Cobertura = (Linhas Executadas / Total de Linhas) × 100
   ```

2. **Branch Coverage** (Cobertura de Branches)

   ```java
   if (x > 0) {  // branch 1
       doA();
   } else {      // branch 2
       doB();
   }
   // 100% branch = testar ambos os caminhos
   ```

3. **Path Coverage** (Cobertura de Caminhos)
   Todos os caminhos possíveis através do código.

**Thresholds:**

- ❌ < 60%: Crítico
- ⚠️ 60-79%: Atenção
- ✅ 80-89%: Bom
- 🏆 ≥ 90%: Excelente

**Ferramentas:** JaCoCo (Java), Coverage.py (Python), Istanbul (JS)

**⚠️ Cuidado:** 100% cobertura ≠ 100% qualidade

**Relacionado:** Mutation Score, Diff Coverage

---

### Diff Coverage (Cobertura Diferencial)

**Definição:** Percentual de cobertura apenas das linhas modificadas em um PR/commit.

**Fórmula:**

```
Diff Coverage = (Linhas Novas Cobertas / Linhas Novas Totais) × 100
```

**Threshold:** ≥ 80% para código novo

**Ferramentas:** Codecov, SonarQube, diff-cover

**Relacionado:** Pull Request Quality Gate

---

### Flaky Test (Teste Instável)

**Definição:** Teste não-determinístico que falha e passa intermitentemente sem mudança no código.

**Causas Comuns:**

- ⏰ Dependência de tempo (`sleep`, timestamps)
- 🔀 Condições de corrida (async)
- 🗃️ Estado compartilhado entre testes
- 🎲 Geração aleatória sem seed
- 📊 Ordem de execução

**Fórmula:**

```
Flaky Rate = (Testes Flaky / Total de Testes) × 100
```

**Meta:** 0% (zero tolerância)

**Mitigação:**

- Usar `Clock` mockado
- `Awaitility` para async
- `@BeforeEach` para limpeza
- `TestContainers` para isolamento

**Ferramentas:** Maven Surefire (rerun), Gradle Test Retry

**Relacionado:** Non-Determinism, Test Isolation

---

### Lead Time (Tempo de Feedback)

**Definição:** Tempo desde o commit até o feedback de qualidade (testes passando/falhando).

**Fórmula:**

```
Lead Time = Tempo Fim CI - Tempo Commit
```

**Metas:**

- Unit tests: < 2 min
- Integration: < 5 min
- E2E: < 15 min

**Otimizações:**

- Paralelização
- Test sharding
- Smart test selection
- Cache de dependências

**Ferramentas:** GitHub Actions, GitLab CI, Jenkins

**Relacionado:** CI/CD, Developer Experience

---

## 5. Arquitetura e Resiliência

### Circuit Breaker (Disjuntor)

**Definição:** Padrão que interrompe chamadas a serviço falhando, evitando cascata de falhas e permitindo recuperação.

**Estados:**

- **CLOSED**: Normal, permite requisições
- **OPEN**: Bloqueando, falha rápido sem chamar serviço
- **HALF_OPEN**: Testando recuperação com requisições limitadas

**Exemplo (Resilience4j):**

```java
CircuitBreaker circuitBreaker = CircuitBreaker.of("paymentService",
    CircuitBreakerConfig.custom()
        .failureRateThreshold(50)           // 50% falhas
        .waitDurationInOpenState(Duration.ofSeconds(30))
        .slidingWindowSize(10)              // últimas 10 chamadas
        .build());

// Uso
Try.ofSupplier(CircuitBreaker.decorateSupplier(
    circuitBreaker,
    () -> paymentClient.processPayment(order)
)).recover(throwable -> fallbackPayment(order));
```

**Métricas:**

- Taxa de abertura
- Tempo em estado OPEN
- Taxa de sucesso em HALF_OPEN

**Ferramentas:** Resilience4j, Hystrix (deprecated), Polly (.NET)

**Relacionado:** Bulkhead, Retry, Fallback

---

### Retry (Retentar)

**Definição:** Padrão que reexecuta operação falhada após intervalo, útil para falhas transientes.

**Estratégias:**

1. **Fixed Delay** (Intervalo Fixo)

   ```
   Tentativa 1 → aguardar 1s → Tentativa 2 → aguardar 1s → Tentativa 3
   ```

2. **Exponential Backoff** (Recuo Exponencial)

   ```
   Tentativa 1 → aguardar 1s → Tentativa 2 → aguardar 2s → Tentativa 3 → aguardar 4s
   ```

3. **Exponential Backoff with Jitter** (com Variação)
   ```
   Delay = BaseDelay × 2^attempt + random(0, Jitter)
   ```

**Exemplo (Resilience4j):**

```java
RetryConfig config = RetryConfig.custom()
    .maxAttempts(3)
    .waitDuration(Duration.ofSeconds(1))
    .retryExceptions(TimeoutException.class, ConnectException.class)
    .ignoreExceptions(BusinessException.class)
    .build();

Retry retry = Retry.of("payment", config);

Try.ofSupplier(Retry.decorateSupplier(retry,
    () -> paymentClient.process(order)
));
```

**Métricas:**

- Taxa de sucesso no 2º retry
- Tentativas médias até sucesso
- Taxa de esgotamento (max attempts)

**⚠️ Cuidado:**

- Não retry em erros 4xx (cliente)
- Timeout total considerando retries
- Idempotência obrigatória

**Ferramentas:** Resilience4j, Spring Retry, Polly

**Relacionado:** Circuit Breaker, Timeout, Idempotency

---

### Bulkhead (Anteparo)

**Definição:** Padrão que isola recursos (threads, conexões) para evitar que falha em um componente esgote recursos de outros.

**Tipos:**

1. **Thread Pool Bulkhead**

   ```java
   ThreadPoolBulkhead bulkhead = ThreadPoolBulkhead.of("orders",
       ThreadPoolBulkheadConfig.custom()
           .maxThreadPoolSize(10)
           .coreThreadPoolSize(5)
           .queueCapacity(20)
           .build());
   ```

2. **Semaphore Bulkhead**
   ```java
   Bulkhead bulkhead = Bulkhead.of("payments",
       BulkheadConfig.custom()
           .maxConcurrentCalls(5)
           .build());
   ```

**Benefícios:**

- 🛡️ Isolamento de falhas
- 📊 Melhor observabilidade
- 🎯 Priorização de recursos

**Ferramentas:** Resilience4j, Hystrix (deprecated)

**Relacionado:** Circuit Breaker, Rate Limiting

---

### Rate Limiting (Limitação de Taxa)

**Definição:** Padrão que limita número de requisições em janela de tempo, protegendo contra sobrecarga.

**Algoritmos:**

1. **Token Bucket**

   - Bucket com N tokens
   - Requisição consome 1 token
   - Tokens repostos a taxa fixa

2. **Leaky Bucket**

   - Fila com vazão constante
   - Requisições entram na fila
   - Processamento em ritmo fixo

3. **Fixed Window**

   - Contador por janela de tempo
   - Reset a cada janela

4. **Sliding Log**
   - Registro de timestamps
   - Conta requisições na janela deslizante

**Exemplo (Bucket4j):**

```java
Bandwidth limit = Bandwidth.classic(100, Refill.greedy(100, Duration.ofMinutes(1)));
Bucket bucket = Bucket.builder()
    .addLimit(limit)
    .build();

if (bucket.tryConsume(1)) {
    // processar requisição
} else {
    // 429 Too Many Requests
}
```

**Métricas:**

- Taxa de throttling (requisições rejeitadas)
- P95 de tokens disponíveis
- Tempo até próximo token

**Ferramentas:** Bucket4j, Guava RateLimiter, Redis (INCR)

**Relacionado:** Throttling, Backpressure

---

## 6. Ferramentas Open Source

### Testing Frameworks

| Linguagem  | Framework    | Descrição                       |
| ---------- | ------------ | ------------------------------- |
| Java       | **JUnit 5**  | Framework padrão, extensível    |
| Java       | **TestNG**   | Alternativa com anotações ricas |
| Python     | **pytest**   | Simples, fixtures poderosos     |
| Python     | **unittest** | Built-in, estilo xUnit          |
| JavaScript | **Jest**     | All-in-one, rápido              |
| JavaScript | **Mocha**    | Flexível, modular               |
| Go         | **testing**  | Built-in, minimalista           |

### Mocking

| Linguagem  | Ferramenta        | Uso                 |
| ---------- | ----------------- | ------------------- |
| Java       | **Mockito**       | Padrão de mercado   |
| Python     | **unittest.mock** | Built-in            |
| JavaScript | **Sinon**         | Spies, stubs, mocks |

### Code Coverage

| Linguagem  | Ferramenta         | Formato Saída |
| ---------- | ------------------ | ------------- |
| Java       | **JaCoCo**         | XML, HTML     |
| Python     | **Coverage.py**    | XML, HTML     |
| JavaScript | **Istanbul/nyc**   | lcov, JSON    |
| Go         | **go test -cover** | Built-in      |

### Mutation Testing

| Linguagem  | Ferramenta  | Mutadores     |
| ---------- | ----------- | ------------- |
| Java       | **PITest**  | 20+ mutadores |
| JavaScript | **Stryker** | Suporta TS    |
| Python     | **mutmut**  | Simples       |

### Contract Testing

| Ferramenta                | Linguagem | Modelo          |
| ------------------------- | --------- | --------------- |
| **Pact**                  | Multi     | Consumer-driven |
| **Spring Cloud Contract** | Java      | Provider-driven |

### Performance Testing

| Ferramenta  | Tipo       | Linguagem  |
| ----------- | ---------- | ---------- |
| **JMeter**  | GUI + CLI  | Java       |
| **Gatling** | Code-based | Scala/Java |
| **k6**      | Scriptable | JavaScript |
| **Locust**  | Pythonic   | Python     |

### Chaos Engineering

| Ferramenta        | Escopo      | Integração   |
| ----------------- | ----------- | ------------ |
| **Chaos Toolkit** | Multi-cloud | Extensível   |
| **LitmusChaos**   | Kubernetes  | Cloud-native |
| **Pumba**         | Docker      | Containers   |
| **Toxiproxy**     | Network     | Proxy        |

### CI/CD

| Ferramenta         | Tipo         | Deployment             |
| ------------------ | ------------ | ---------------------- |
| **Jenkins**        | Self-hosted  | On-premise/cloud       |
| **GitLab CI**      | Integrated   | GitLab.com/self-hosted |
| **GitHub Actions** | Cloud        | GitHub.com             |
| **Drone**          | Cloud-native | Kubernetes             |

### Observability

| Ferramenta     | Tipo          | Uso                    |
| -------------- | ------------- | ---------------------- |
| **Prometheus** | Metrics       | Time-series DB         |
| **Grafana**    | Visualization | Dashboards             |
| **Jaeger**     | Tracing       | Distributed tracing    |
| **ELK Stack**  | Logs          | Elasticsearch + Kibana |

### Databases (Test)

| Ferramenta           | Tipo      | Uso                    |
| -------------------- | --------- | ---------------------- |
| **TestContainers**   | Docker    | Bancos reais em testes |
| **H2**               | In-memory | SQL tests rápidos      |
| **Embedded MongoDB** | In-memory | NoSQL tests            |
| **Redis (embedded)** | In-memory | Cache tests            |

---

## 7. Conceitos Avançados

### Test Pyramid (Pirâmide de Testes)

**Definição:** Modelo que recomenda proporção de testes por nível.

```
        /\
       /  \      E2E (5%)
      /----\
     /      \    Integration (15%)
    /--------\
   /          \  Unit (80%)
  /____________\
```

**Princípios:**

- Muitos unit tests (rápidos, baratos)
- Alguns integration tests (confiança)
- Poucos E2E tests (críticos, caros)

**Relacionado:** Test Trophy, Testing Diamond

---

### Test-Driven Development (TDD)

**Definição:** Prática de escrever teste antes do código de produção.

**Ciclo Red-Green-Refactor:**

1. 🔴 **Red**: Escrever teste que falha
2. 🟢 **Green**: Escrever código mínimo para passar
3. 🔵 **Refactor**: Melhorar código mantendo testes verdes

**Benefícios:**

- 🎯 Design emergente
- 📝 Documentação viva
- 🛡️ Confiança para refatorar

**Relacionado:** BDD, ATDD

---

### Behavior-Driven Development (BDD)

**Definição:** Extensão do TDD focada em comportamento e linguagem ubíqua.

**Estrutura Given-When-Then:**

```gherkin
Feature: Desconto progressivo

  Scenario: Cliente compra 10 itens
    Given um cliente no carrinho com 10 itens
    When o cliente finaliza a compra
    Then o desconto de 5% deve ser aplicado
```

**Ferramentas:** Cucumber, SpecFlow, Behave

**Relacionado:** TDD, Gherkin, Living Documentation

---

### Test Data Builder

**Definição:** Padrão para criar objetos de teste complexos de forma legível.

**Exemplo:**

```java
// Sem builder (verboso, difícil manutenção)
Order order = new Order();
order.setId(1L);
order.setCustomerId(123L);
order.setStatus(OrderStatus.PENDING);
order.setItems(Arrays.asList(
    new OrderItem("item-1", 2, 10.0),
    new OrderItem("item-2", 1, 20.0)
));
order.setTotal(40.0);

// Com builder (fluente, legível)
Order order = OrderBuilder.anOrder()
    .withId(1L)
    .withCustomerId(123L)
    .withStatus(PENDING)
    .withItem("item-1", quantity: 2, price: 10.0)
    .withItem("item-2", quantity: 1, price: 20.0)
    .build();
```

**Benefícios:**

- 📖 Legibilidade
- 🔧 Manutenibilidade
- 🎯 Defaults sensatos

**Relacionado:** Object Mother, Factory

---

### Equivalence Partitioning (Particionamento de Equivalência)

**Definição:** Técnica que divide inputs em classes de equivalência, testando um representante de cada classe.

**Exemplo:**

```java
// Regra: desconto para 10-99 itens
// Classes de equivalência:
// 1. < 10 (sem desconto)
// 2. 10-99 (com desconto)
// 3. >= 100 (desconto maior)

@ParameterizedTest
@ValueSource(ints = {1, 9})    // classe 1
void semDesconto(int quantity) {
    assertEquals(0.0, calculator.getDiscount(quantity));
}

@ParameterizedTest
@ValueSource(ints = {10, 50, 99})  // classe 2
void comDesconto5(int quantity) {
    assertEquals(0.05, calculator.getDiscount(quantity));
}

@ParameterizedTest
@ValueSource(ints = {100, 500})  // classe 3
void comDesconto10(int quantity) {
    assertEquals(0.10, calculator.getDiscount(quantity));
}
```

**Relacionado:** Boundary Value Analysis

---

### Boundary Value Analysis (Análise de Valores Limites)

**Definição:** Técnica que testa valores nas bordas das classes de equivalência.

**Exemplo:**

```java
// Limites: 9-10 (início) e 99-100 (fim)
@ParameterizedTest
@CsvSource({
    "9, 0.0",    // abaixo do limite
    "10, 0.05",  // exatamente no limite
    "11, 0.05",  // acima do limite
    "98, 0.05",  // abaixo do limite superior
    "99, 0.05",  // exatamente no limite superior
    "100, 0.10"  // acima do limite superior
})
void testeBoundaries(int quantity, double expectedDiscount) {
    assertEquals(expectedDiscount, calculator.getDiscount(quantity));
}
```

**Relacionado:** Equivalence Partitioning, Edge Cases

---

## 8. Termos Ambíguos (Normalização)

### Resiliência vs Robustez

**❌ Ambiguidade:** Termos usados intercambiavelmente.

**✅ Padronização:**

**Resiliência**

- **Definição:** Capacidade de se **recuperar rapidamente** de falhas controladas
- **Contexto:** Sistemas distribuídos, microservices
- **Exemplo:** Circuit breaker abrindo e fechando automaticamente
- **Métricas:** MTTR (Mean Time To Recovery), taxa de recuperação

**Robustez**

- **Definição:** Capacidade de **resistir** a falhas não previstas sem degradação severa
- **Contexto:** Software monolítico, algoritmos
- **Exemplo:** Validação de input, tratamento de exceções
- **Métricas:** Taxa de crashes, uptime

**Usar:** "Resiliência" para recuperação; "Robustez" para resistência inicial.

---

### Stub vs Mock

**❌ Ambiguidade:** Chamados genericamente de "mocks".

**✅ Padronização:**

**Stub**

- **Definição:** Retorna resposta pré-programada
- **Foco:** Estado (o que retorna)
- **Verificação:** Não há verificação de interação
- **Exemplo:**
  ```java
  when(repository.findById(1L)).thenReturn(Optional.of(user));
  ```

**Mock**

- **Definição:** Valida interações (chamadas, ordem, parâmetros)
- **Foco:** Comportamento (como foi usado)
- **Verificação:** `verify()` obrigatório
- **Exemplo:**
  ```java
  verify(emailService).send("user@example.com", "Welcome!");
  ```

**Usar:** "Stub" para respostas; "Mock" para validar interações.

---

### Integration Test vs E2E Test

**❌ Ambiguidade:** Termos sobrepostos.

**✅ Padronização:**

**Integration Test**

- **Escopo:** Múltiplos componentes, camada back-end
- **UI:** Não inclui front-end
- **Exemplo:** API + Database + Message Queue
- **Ferramentas:** TestContainers, Spring Boot Test

**E2E Test**

- **Escopo:** Sistema completo, incluindo UI
- **UI:** Obrigatório (Selenium, Playwright)
- **Exemplo:** Clicar em botão → API → Database → Resposta UI
- **Ferramentas:** Selenium, Cypress, Playwright

**Usar:** "Integration" para back-end; "E2E" para fluxo completo com UI.

---

### Fake vs Mock

**❌ Ambiguidade:** Ambos são test doubles.

**✅ Padronização:**

**Fake**

- **Definição:** Implementação simplificada funcional
- **Comportamento:** Lógica real (simplificada)
- **Exemplo:** `FakeUserRepository` com `HashMap`
- **Uso:** Quando mock é muito complexo

**Mock**

- **Definição:** Objeto criado por framework (Mockito)
- **Comportamento:** Pré-programado, sem lógica
- **Exemplo:** `mock(UserRepository.class)`
- **Uso:** Validar interações

**Usar:** "Fake" para implementação; "Mock" para framework.

---

### Flaky vs Intermittent

**❌ Ambiguidade:** Descrevem mesma situação.

**✅ Padronização:**

**Usar apenas:** "Flaky Test" (padrão da indústria)

**Evitar:** "Intermittent test", "unstable test", "nondeterministic test"

---

### SLA vs SLO vs SLI

**❌ Ambiguidade:** Termos de observabilidade confundidos.

**✅ Padronização:**

**SLI (Service Level Indicator)**

- **Definição:** Métrica quantitativa (o que medir)
- **Exemplo:** Latência P95, taxa de erro, throughput

**SLO (Service Level Objective)**

- **Definição:** Meta interna (objetivo)
- **Exemplo:** P95 < 200ms em 99% do tempo

**SLA (Service Level Agreement)**

- **Definição:** Contrato legal com cliente (consequências)
- **Exemplo:** P95 < 500ms ou crédito de 10%

**Relação:** SLI → SLO → SLA (do mais técnico ao mais legal)

---

## 📚 Checklist de Uso

### Para Revisores

- [ ] Verificar termos padronizados no código e documentação
- [ ] Alertar sobre uso de termos ambíguos
- [ ] Referenciar glossário em dúvidas

### Para Desenvolvedores

- [ ] Consultar glossário ao escrever testes
- [ ] Usar nomenclatura consistente
- [ ] Propor novos termos via PR neste glossário

### Para Tech Writers

- [ ] Referenciar glossário em documentações
- [ ] Manter sincronizado com evoluções
- [ ] Traduzir apenas se necessário (manter inglês técnico)

---

## 🔄 Processo de Atualização

1. **Proposta:** Abrir issue com novo termo ou correção
2. **Discussão:** Time técnico revisa e aprova
3. **PR:** Submeter alteração neste arquivo
4. **Comunicação:** Anunciar mudanças em changelog
5. **Treinamento:** Incluir em onboarding

---

## 📖 Referências

- [Martin Fowler - Test Double](https://martinfowler.com/bliki/TestDouble.html)
- [Google Testing Blog](https://testing.googleblog.com/)
- [PITest Documentation](https://pitest.org/)
- [TestContainers](https://www.testcontainers.org/)
- [Resilience4j](https://resilience4j.readme.io/)
- [Chaos Engineering Principles](https://principlesofchaos.org/)
