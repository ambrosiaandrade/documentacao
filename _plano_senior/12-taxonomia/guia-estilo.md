# 📝 Guia de Estilo - Testes de Software

## Índice

1. [Princípios Gerais](#1-princípios-gerais)
2. [Nomenclatura de Testes](#2-nomenclatura-de-testes)
3. [Estrutura de Testes](#3-estrutura-de-testes)
4. [Formatação e Estilo](#4-formatação-e-estilo)
5. [Comentários e Documentação](#5-comentários-e-documentação)
6. [Asserções](#6-asserções)
7. [Test Data](#7-test-data)
8. [Organização de Arquivos](#8-organização-de-arquivos)
9. [Mensagens de Erro](#9-mensagens-de-erro)
10. [Anti-patterns a Evitar](#10-anti-patterns-a-evitar)

---

## 1. Princípios Gerais

### 🎯 F.I.R.S.T Principles

Todo teste deve ser:

- **F**ast (Rápido): < 100ms para unit tests
- **I**solated (Isolado): Sem dependências entre testes
- **R**epeatable (Repetível): Mesmo resultado sempre
- **S**elf-validating (Auto-validante): Pass/Fail claro
- **T**imely (Oportuno): Escrito junto com código

### 🔓 Open Source First

- ✅ Priorizar ferramentas open source
- ✅ Mencionar alternativas proprietárias se relevante
- ✅ Documentar configuração de ferramentas open source

### 📖 Legibilidade

> "Código é escrito uma vez e lido mil vezes. Testes ainda mais."

- Priorizar clareza sobre brevidade
- Nomes descritivos > nomes curtos
- Um conceito por teste

---

## 2. Nomenclatura de Testes

### 2.1 Convenção de Nomes de Métodos

**Padrão Recomendado: `deve_<ação>_quando_<condição>`**

```java
// ✅ BOM - Claro e descritivo
@Test
void deveCalcularDescontoQuandoQuantidadeMaiorQue10() {
    // ...
}

@Test
void deveLancarExcecaoQuandoPrecoNegativo() {
    // ...
}

@Test
void deveRetornarVazioQuandoUsuarioNaoExistir() {
    // ...
}

// ❌ RUIM - Vago ou técnico demais
@Test
void test1() { }

@Test
void testCalculation() { }

@Test
void verifyDiscount() { }
```

**Alternativa em Inglês: `should_<action>_when_<condition>`**

```java
@Test
void shouldCalculateDiscountWhenQuantityGreaterThan10() {
    // ...
}

@Test
void shouldThrowExceptionWhenPriceIsNegative() {
    // ...
}
```

### 2.2 DisplayName (JUnit 5)

Para cenários complexos, usar `@DisplayName`:

```java
@Test
@DisplayName("Deve aplicar desconto progressivo: 5% para 10-49 itens, 10% para 50-99, 15% para 100+")
void deveAplicarDescontoProgressivo() {
    // ...
}

@Test
@DisplayName("REQ-123: Cliente VIP recebe frete grátis em pedidos acima de R$ 100")
void clienteVipFreteGratis() {
    // ...
}
```

### 2.3 Classe de Teste

**Convenção: `<ClasseTestada>Test`**

```java
// ✅ BOM
public class OrderServiceTest { }
public class DiscountCalculatorTest { }
public class UserRepositoryIntegrationTest { }

// ❌ RUIM
public class TestOrderService { }
public class Orders { }
public class ServiceTest { }
```

**Sufixos por Tipo:**

- `*Test` - Unit tests
- `*IntegrationTest` - Integration tests
- `*E2ETest` ou `*AcceptanceTest` - E2E tests
- `*PerformanceTest` - Performance tests

### 2.4 Nested Tests

Para agrupar cenários relacionados:

```java
@Nested
@DisplayName("Quando carrinho está vazio")
class QuandoCarrinhoVazio {

    @Test
    void deveRetornarTotalZero() { }

    @Test
    void naoDevePermitirFinalizarCompra() { }
}

@Nested
@DisplayName("Quando carrinho tem itens")
class QuandoCarrinhoTemItens {

    @Test
    void deveCalcularTotalCorretamente() { }

    @Test
    void devePermitirFinalizarCompra() { }
}
```

---

## 3. Estrutura de Testes

### 3.1 AAA Pattern (Arrange-Act-Assert)

**Estrutura obrigatória para clareza:**

```java
@Test
void deveCalcularTotalComDesconto() {
    // Arrange (preparação)
    var calculator = new DiscountCalculator();
    double price = 100.0;
    int quantity = 3;

    // Act (execução)
    double total = calculator.calculateTotal(price, quantity, 0.1);

    // Assert (validação)
    assertEquals(270.0, total);
}
```

**Com comentários visuais:**

```java
@Test
void deveProcessarPedidoComSucesso() {
    // ========== Arrange ==========
    Order order = OrderBuilder.anOrder()
        .withCustomerId(123L)
        .withItems(List.of(
            new OrderItem("item-1", 2, 10.0),
            new OrderItem("item-2", 1, 20.0)
        ))
        .build();

    when(paymentService.process(any())).thenReturn(
        new PaymentResponse("pay-456", PaymentStatus.APPROVED)
    );

    // ========== Act ==========
    OrderResult result = orderService.processOrder(order);

    // ========== Assert ==========
    assertThat(result.isSuccess()).isTrue();
    assertThat(result.getOrderId()).isNotNull();
    verify(paymentService).process(argThat(payment ->
        payment.getAmount().equals(40.0)
    ));
}
```

### 3.2 Given-When-Then (BDD)

Alternativa descritiva:

```java
@Test
void deveAplicarDescontoProgressivo() {
    // Given (dado que)
    var calculator = new DiscountCalculator();
    int quantity = 50;

    // When (quando)
    double discount = calculator.getDiscount(quantity);

    // Then (então)
    assertEquals(0.10, discount); // 10%
}
```

### 3.3 Setup e Teardown

**Usar anotações JUnit:**

```java
class OrderServiceTest {

    private OrderService orderService;
    private OrderRepository repository;

    @BeforeAll
    static void setupOnce() {
        // Executado uma vez antes de todos os testes
        System.setProperty("test.mode", "true");
    }

    @BeforeEach
    void setup() {
        // Executado antes de cada teste
        repository = mock(OrderRepository.class);
        orderService = new OrderService(repository);
    }

    @AfterEach
    void teardown() {
        // Executado após cada teste
        reset(repository);
    }

    @AfterAll
    static void teardownOnce() {
        // Executado uma vez após todos os testes
        System.clearProperty("test.mode");
    }

    @Test
    void deveFazerAlgo() {
        // teste usa orderService já inicializado
    }
}
```

**⚠️ Cuidado:**

- `@BeforeAll`/`@AfterAll` requerem métodos `static`
- Evitar lógica complexa em setup (preferir builders)
- Limpar estado em `@AfterEach` se necessário

---

## 4. Formatação e Estilo

### 4.1 Indentação e Espaçamento

```java
// ✅ BOM - Espaçamento claro entre seções
@Test
void deveProcessarPagamento() {
    // Arrange
    Payment payment = new Payment(100.0);
    when(gateway.process(payment)).thenReturn(true);

    // Act
    boolean result = paymentService.process(payment);

    // Assert
    assertTrue(result);
    verify(gateway).process(payment);
}

// ❌ RUIM - Tudo junto
@Test
void deveProcessarPagamento() {
    Payment payment = new Payment(100.0);
    when(gateway.process(payment)).thenReturn(true);
    boolean result = paymentService.process(payment);
    assertTrue(result);
    verify(gateway).process(payment);
}
```

### 4.2 Quebra de Linhas

**Regra: Máximo 120 caracteres por linha**

```java
// ✅ BOM - Quebrado adequadamente
@Test
void deveValidarPedidoComplexo() {
    Order order = OrderBuilder.anOrder()
        .withCustomerId(123L)
        .withItems(List.of(
            new OrderItem("item-1", 2, 10.0),
            new OrderItem("item-2", 1, 20.0)
        ))
        .withDeliveryAddress(
            new Address("Rua Teste", "123", "São Paulo", "SP")
        )
        .build();

    // ...
}

// ❌ RUIM - Linha muito longa
@Test
void deveValidarPedidoComplexo() {
    Order order = OrderBuilder.anOrder().withCustomerId(123L).withItems(List.of(new OrderItem("item-1", 2, 10.0), new OrderItem("item-2", 1, 20.0))).withDeliveryAddress(new Address("Rua Teste", "123", "São Paulo", "SP")).build();
}
```

### 4.3 Formatação de Dados de Teste

**Usar constantes ou builders:**

```java
// ✅ BOM - Constantes claras
class OrderServiceTest {

    private static final Long CUSTOMER_ID = 123L;
    private static final String ITEM_ID = "item-001";
    private static final double PRICE = 99.99;

    @Test
    void deveCalcularTotal() {
        Order order = OrderBuilder.anOrder()
            .withCustomerId(CUSTOMER_ID)
            .withItem(ITEM_ID, 2, PRICE)
            .build();

        // ...
    }
}

// ❌ RUIM - Magic numbers
@Test
void deveCalcularTotal() {
    Order order = new Order(123, "item-001", 2, 99.99);
}
```

---

## 5. Comentários e Documentação

### 5.1 Quando Comentar

**✅ BOM - Comentar o "porquê", não o "quê":**

```java
@Test
void deveUsarCacheDespoisDePrimeiraConsulta() {
    // Primeira chamada deve ir ao banco
    User user1 = userService.getUser(1L);
    verify(repository).findById(1L);

    // Segunda chamada deve usar cache (não chama repository novamente)
    // Bug #1234: Verificar que cache está funcionando
    User user2 = userService.getUser(1L);
    verifyNoMoreInteractions(repository);

    assertSame(user1, user2);
}
```

**❌ RUIM - Comentar o óbvio:**

```java
@Test
void teste() {
    // Criar usuário
    User user = new User();

    // Setar nome
    user.setName("John");

    // Verificar nome
    assertEquals("John", user.getName());
}
```

### 5.2 TODO e FIXME

**Usar tags para rastreamento:**

```java
@Test
@Disabled("TODO: Implementar após refatoração do PaymentService")
void deveProcessarPagamentoInternacional() {
    // Teste futuro
}

@Test
void deveCalcularFrete() {
    // FIXME: Teste flaky devido a dependência de timestamp
    // Issue #567 aberta para resolver

    // Workaround temporário: usar Clock mockado
    Clock fixedClock = Clock.fixed(Instant.parse("2025-01-01T00:00:00Z"), ZoneId.of("UTC"));
    // ...
}
```

### 5.3 Javadoc em Testes

**Opcional, mas útil para testes complexos:**

```java
/**
 * Valida que o sistema aplica desconto progressivo baseado na quantidade:
 * - 10-49 itens: 5% de desconto
 * - 50-99 itens: 10% de desconto
 * - 100+ itens: 15% de desconto
 *
 * Requisito: REQ-123
 * @see DiscountCalculator#getDiscount(int)
 */
@Test
void deveAplicarDescontoProgressivo() {
    // ...
}
```

---

## 6. Asserções

### 6.1 Biblioteca de Asserções

**Recomendado: AssertJ (mais expressivo que JUnit)**

```java
// ✅ BOM - AssertJ (fluente, legível)
assertThat(result.isSuccess()).isTrue();
assertThat(result.getErrors()).isEmpty();
assertThat(result.getOrder().getId()).isNotNull();
assertThat(result.getOrder().getTotal()).isEqualByComparingTo(BigDecimal.valueOf(100.0));

// 🔶 OK - JUnit padrão (funcional)
assertTrue(result.isSuccess());
assertTrue(result.getErrors().isEmpty());
assertNotNull(result.getOrder().getId());
assertEquals(BigDecimal.valueOf(100.0), result.getOrder().getTotal());
```

### 6.2 Mensagens de Asserção

**Incluir contexto em asserções:**

```java
// ✅ BOM - Mensagem descritiva
assertThat(order.getStatus())
    .as("Status do pedido após processamento")
    .isEqualTo(OrderStatus.CONFIRMED);

// ✅ BOM - Com múltiplas validações
assertThat(order)
    .satisfies(o -> {
        assertThat(o.getStatus()).as("status").isEqualTo(OrderStatus.CONFIRMED);
        assertThat(o.getTotal()).as("total").isGreaterThan(BigDecimal.ZERO);
        assertThat(o.getItems()).as("items").isNotEmpty();
    });

// ❌ RUIM - Sem contexto
assertThat(order.getStatus()).isEqualTo(OrderStatus.CONFIRMED);
```

### 6.3 Asserções de Exceções

**Usar assertThrows (JUnit 5):**

```java
// ✅ BOM - Captura e valida exceção
@Test
void deveLancarExcecaoQuandoPrecoNegativo() {
    IllegalArgumentException exception = assertThrows(
        IllegalArgumentException.class,
        () -> calculator.calculateTotal(-100.0, 1)
    );

    assertThat(exception.getMessage())
        .contains("Preço não pode ser negativo");
}

// ✅ BOM - AssertJ (mais expressivo)
@Test
void deveLancarExcecaoQuandoPrecoNegativo() {
    assertThatThrownBy(() -> calculator.calculateTotal(-100.0, 1))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("Preço não pode ser negativo");
}

// ❌ RUIM - Try-catch manual
@Test
void deveLancarExcecaoQuandoPrecoNegativo() {
    try {
        calculator.calculateTotal(-100.0, 1);
        fail("Deveria ter lançado exceção");
    } catch (IllegalArgumentException e) {
        assertTrue(e.getMessage().contains("negativo"));
    }
}
```

### 6.4 Asserções de Coleções

```java
// ✅ BOM - AssertJ para coleções
@Test
void deveRetornarPedidosAtivos() {
    List<Order> orders = orderService.getActiveOrders();

    assertThat(orders)
        .hasSize(3)
        .extracting(Order::getStatus)
        .containsOnly(OrderStatus.ACTIVE, OrderStatus.PENDING);

    assertThat(orders)
        .extracting("id", "customerId")
        .containsExactly(
            tuple(1L, 101L),
            tuple(2L, 102L),
            tuple(3L, 101L)
        );
}

// ✅ BOM - Validar elementos específicos
@Test
void deveFiltrarPedidosPorCliente() {
    List<Order> orders = orderService.getOrdersByCustomer(101L);

    assertThat(orders)
        .filteredOn(order -> order.getTotal().compareTo(BigDecimal.valueOf(100)) > 0)
        .hasSize(2)
        .allMatch(order -> order.getCustomerId().equals(101L));
}
```

### 6.5 Asserções Soft (Múltiplas Validações)

```java
// ✅ BOM - SoftAssertions (todas executam, mesmo se uma falhar)
@Test
void deveValidarPedidoCompleto() {
    Order order = orderService.createOrder(request);

    SoftAssertions softly = new SoftAssertions();
    softly.assertThat(order.getId()).isNotNull();
    softly.assertThat(order.getStatus()).isEqualTo(OrderStatus.PENDING);
    softly.assertThat(order.getTotal()).isGreaterThan(BigDecimal.ZERO);
    softly.assertThat(order.getItems()).isNotEmpty();
    softly.assertAll(); // Falha se alguma asserção falhou
}

// ❌ RUIM - Asserções independentes (para no primeiro erro)
@Test
void deveValidarPedidoCompleto() {
    Order order = orderService.createOrder(request);

    assertThat(order.getId()).isNotNull();
    assertThat(order.getStatus()).isEqualTo(OrderStatus.PENDING); // se falhar aqui, não testa o resto
    assertThat(order.getTotal()).isGreaterThan(BigDecimal.ZERO);
    assertThat(order.getItems()).isNotEmpty();
}
```

---

## 7. Test Data

### 7.1 Test Data Builders

**Padrão obrigatório para objetos complexos:**

```java
// ✅ BOM - Builder pattern
public class OrderBuilder {

    private Long id;
    private Long customerId = 1L; // default sensato
    private OrderStatus status = OrderStatus.PENDING;
    private List<OrderItem> items = new ArrayList<>();
    private BigDecimal total = BigDecimal.ZERO;

    public static OrderBuilder anOrder() {
        return new OrderBuilder();
    }

    public OrderBuilder withId(Long id) {
        this.id = id;
        return this;
    }

    public OrderBuilder withCustomerId(Long customerId) {
        this.customerId = customerId;
        return this;
    }

    public OrderBuilder withStatus(OrderStatus status) {
        this.status = status;
        return this;
    }

    public OrderBuilder withItem(String itemId, int quantity, double price) {
        this.items.add(new OrderItem(itemId, quantity, price));
        return this;
    }

    public Order build() {
        if (total.equals(BigDecimal.ZERO)) {
            total = items.stream()
                .map(item -> BigDecimal.valueOf(item.getPrice() * item.getQuantity()))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        }
        return new Order(id, customerId, status, items, total);
    }
}

// Uso nos testes
@Test
void deveProcessarPedido() {
    Order order = OrderBuilder.anOrder()
        .withCustomerId(123L)
        .withItem("item-1", 2, 10.0)
        .withItem("item-2", 1, 20.0)
        .build();

    // ...
}
```

### 7.2 Object Mother

**Para cenários pré-definidos comuns:**

```java
public class OrderMother {

    public static Order emptyOrder() {
        return OrderBuilder.anOrder().build();
    }

    public static Order standardOrder() {
        return OrderBuilder.anOrder()
            .withCustomerId(1L)
            .withItem("item-standard", 1, 100.0)
            .build();
    }

    public static Order largeOrder() {
        return OrderBuilder.anOrder()
            .withCustomerId(1L)
            .withItem("item-1", 50, 10.0)
            .withItem("item-2", 30, 20.0)
            .build();
    }

    public static Order vipCustomerOrder() {
        return OrderBuilder.anOrder()
            .withCustomerId(999L) // VIP customer
            .withItem("premium-item", 1, 500.0)
            .build();
    }
}

// Uso
@Test
void deveAplicarDescontoParaPedidoGrande() {
    Order order = OrderMother.largeOrder();
    // ...
}
```

### 7.3 Constantes de Teste

**Centralizar valores comuns:**

```java
public class TestConstants {

    // Customer IDs
    public static final Long REGULAR_CUSTOMER_ID = 1L;
    public static final Long VIP_CUSTOMER_ID = 999L;

    // Timestamps fixos
    public static final Instant FIXED_NOW = Instant.parse("2025-01-01T00:00:00Z");
    public static final Clock FIXED_CLOCK = Clock.fixed(FIXED_NOW, ZoneId.of("UTC"));

    // Valores monetários
    public static final BigDecimal STANDARD_PRICE = BigDecimal.valueOf(100.0);
    public static final BigDecimal DISCOUNT_5_PERCENT = BigDecimal.valueOf(0.05);

    // Configurações
    public static final int DEFAULT_TIMEOUT_SECONDS = 5;
}
```

### 7.4 Randomização Controlada

**Usar seeds para reprodutibilidade:**

```java
// ✅ BOM - Random com seed fixa
@Test
void deveProcessarPedidoComIdAleatorio() {
    Random random = new Random(42); // seed fixa
    Long orderId = random.nextLong();

    // teste reproduzível
}

// ✅ BOM - UUID mockado
@Test
void deveGerarIdUnico() {
    UUID fixedUuid = UUID.fromString("123e4567-e89b-12d3-a456-426614174000");
    when(uuidGenerator.generate()).thenReturn(fixedUuid);

    String id = orderService.generateOrderId();

    assertThat(id).isEqualTo("ORDER-123e4567");
}

// ❌ RUIM - Random sem seed (não-determinístico)
@Test
void teste() {
    Random random = new Random(); // seed diferente a cada execução
    // teste flaky!
}
```

---

## 8. Organização de Arquivos

### 8.1 Estrutura de Diretórios

```
src/
├── main/
│   └── java/
│       └── com/example/
│           ├── domain/
│           │   ├── Order.java
│           │   └── OrderService.java
│           ├── repository/
│           │   └── OrderRepository.java
│           └── api/
│               └── OrderController.java
└── test/
    ├── java/
    │   └── com/example/
    │       ├── domain/
    │       │   ├── OrderTest.java
    │       │   └── OrderServiceTest.java
    │       ├── repository/
    │       │   └── OrderRepositoryIntegrationTest.java
    │       ├── api/
    │       │   └── OrderControllerIntegrationTest.java
    │       └── helpers/
    │           ├── OrderBuilder.java
    │           ├── OrderMother.java
    │           └── TestConstants.java
    └── resources/
        ├── application-test.properties
        ├── test-data/
        │   └── orders.json
        └── fixtures/
            └── sample-order.json
```

**Regras:**

- Espelhar estrutura de pacotes de `src/main`
- Sufixo `Test` para unit tests
- Sufixo `IntegrationTest` para integration tests
- Pasta `helpers/` para builders e utilities

### 8.2 Recursos de Teste

```
test/resources/
├── application-test.properties          # Configuração de testes
├── logback-test.xml                     # Log config
├── test-data/                           # Dados estruturados
│   ├── customers.csv
│   └── orders.json
├── fixtures/                            # Payloads de exemplo
│   ├── valid-order-request.json
│   └── invalid-order-request.json
└── contracts/                           # Contract tests (Pact)
    └── order-payment-contract.json
```

---

## 9. Mensagens de Erro

### 9.1 Mensagens Descritivas

```java
// ✅ BOM - Contexto claro
@Test
void deveCalcularDescontoCorretamente() {
    double discount = calculator.getDiscount(50);

    assertThat(discount)
        .as("Desconto para 50 itens deve ser 10%%")
        .isEqualByComparingTo(0.10);
}

// Quando falha:
// [Desconto para 50 itens deve ser 10%] expected:<0.10> but was:<0.05>

// ❌ RUIM - Sem contexto
@Test
void teste() {
    double discount = calculator.getDiscount(50);
    assertEquals(0.10, discount);
}

// Quando falha:
// expected:<0.10> but was:<0.05>  (hã? qual teste? qual cenário?)
```

### 9.2 Falhas em Loops

**Incluir índice do elemento:**

```java
// ✅ BOM - Índice claro
@Test
void deveFiltrarPedidosAtivos() {
    List<Order> orders = orderService.getActiveOrders();

    for (int i = 0; i < orders.size(); i++) {
        assertThat(orders.get(i).getStatus())
            .as("Pedido na posição %d deve estar ativo", i)
            .isEqualTo(OrderStatus.ACTIVE);
    }
}

// Quando falha:
// [Pedido na posição 2 deve estar ativo] expected:<ACTIVE> but was:<CANCELLED>
```

---

## 10. Anti-patterns a Evitar

### ❌ 10.1 Logic in Tests

```java
// ❌ RUIM - Lógica condicional no teste
@Test
void teste() {
    if (order.getTotal() > 100) {
        assertEquals(0.10, calculator.getDiscount(order));
    } else {
        assertEquals(0.05, calculator.getDiscount(order));
    }
}

// ✅ BOM - Testes separados ou parametrizados
@ParameterizedTest
@CsvSource({
    "50.0, 0.05",
    "150.0, 0.10"
})
void deveCalcularDescontoBaseadoNoTotal(double total, double expectedDiscount) {
    Order order = OrderBuilder.anOrder().withTotal(total).build();
    assertEquals(expectedDiscount, calculator.getDiscount(order));
}
```

### ❌ 10.2 Testes Interdependentes

```java
// ❌ RUIM - Testes dependem de ordem
class PedidoTest {
    private static Order order;

    @Test
    void teste1_criarPedido() {
        order = orderService.create(request);
        assertNotNull(order.getId());
    }

    @Test
    void teste2_atualizarPedido() {
        order.setStatus(OrderStatus.CONFIRMED); // depende de teste1!
        orderService.update(order);
    }
}

// ✅ BOM - Testes independentes
class PedidoTest {

    @Test
    void deveCriarPedido() {
        Order order = orderService.create(request);
        assertNotNull(order.getId());
    }

    @Test
    void deveAtualizarPedido() {
        // Criar order localmente
        Order order = OrderBuilder.anOrder().build();
        orderService.save(order);

        order.setStatus(OrderStatus.CONFIRMED);
        orderService.update(order);
    }
}
```

### ❌ 10.3 Múltiplas Asserções Não Relacionadas

```java
// ❌ RUIM - Teste valida múltiplos comportamentos
@Test
void testePedido() {
    // Testa criação
    Order order = orderService.create(request);
    assertNotNull(order.getId());

    // Testa atualização
    order.setStatus(OrderStatus.CONFIRMED);
    orderService.update(order);
    assertEquals(OrderStatus.CONFIRMED, order.getStatus());

    // Testa remoção
    orderService.delete(order.getId());
    assertFalse(orderService.exists(order.getId()));
}

// ✅ BOM - Um conceito por teste
@Test
void deveCriarPedido() {
    Order order = orderService.create(request);
    assertNotNull(order.getId());
}

@Test
void deveAtualizarPedido() {
    Order order = givenExistingOrder();

    order.setStatus(OrderStatus.CONFIRMED);
    orderService.update(order);

    assertEquals(OrderStatus.CONFIRMED, order.getStatus());
}

@Test
void deveRemoverPedido() {
    Order order = givenExistingOrder();

    orderService.delete(order.getId());

    assertFalse(orderService.exists(order.getId()));
}
```

### ❌ 10.4 Testes que Sempre Passam

```java
// ❌ RUIM - Sem asserções
@Test
void testeSemAssercao() {
    orderService.processOrder(order); // só executa, não valida
}

// ❌ RUIM - Asserção inútil
@Test
void testeInutil() {
    assertTrue(true);
}

// ✅ BOM - Valida comportamento real
@Test
void deveProcessarPedido() {
    OrderResult result = orderService.processOrder(order);

    assertThat(result.isSuccess()).isTrue();
    assertThat(result.getOrder().getStatus()).isEqualTo(OrderStatus.CONFIRMED);
}
```

### ❌ 10.5 Sleeps e Timeouts Hardcoded

```java
// ❌ RUIM - Sleep fixo (flaky)
@Test
void deveProcessarAsync() throws InterruptedException {
    orderService.processAsync(order);
    Thread.sleep(1000); // pode falhar se processar mais devagar
    assertTrue(order.isProcessed());
}

// ✅ BOM - Awaitility (espera condicional)
@Test
void deveProcessarAsync() {
    orderService.processAsync(order);

    await().atMost(Duration.ofSeconds(5))
           .pollInterval(Duration.ofMillis(100))
           .until(() -> order.isProcessed());
}
```

### ❌ 10.6 Over-Mocking

```java
// ❌ RUIM - Mocka tudo, incluindo lógica simples
@Test
void testeOverMock() {
    Calculator calculator = mock(Calculator.class);
    when(calculator.add(1, 2)).thenReturn(3); // mockando soma!

    assertEquals(3, calculator.add(1, 2));
}

// ✅ BOM - Mock apenas dependências externas
@Test
void deveCalcularTotalComDesconto() {
    Calculator calculator = new Calculator(); // lógica real
    OrderRepository repository = mock(OrderRepository.class); // I/O mockado

    double total = calculator.calculateWithDiscount(100.0, 0.1);
    assertEquals(90.0, total);
}
```

---

## 📚 Checklist de Revisão

### Para Autor do Teste

- [ ] Nome do teste é descritivo e segue convenção
- [ ] Estrutura AAA/Given-When-Then clara
- [ ] Uma asserção lógica por teste
- [ ] Sem lógica condicional ou loops complexos
- [ ] Usa builders para objetos complexos
- [ ] Mensagens de erro são descritivas
- [ ] Teste é independente (pode rodar em qualquer ordem)
- [ ] Teste é rápido (< 100ms para unit)
- [ ] Usa ferramentas open source

### Para Revisor

- [ ] Teste valida comportamento, não implementação
- [ ] Nomenclatura consistente com projeto
- [ ] Não há duplicação de lógica de teste
- [ ] Test data é clara e não obscurece o teste
- [ ] Mocks são usados apropriadamente
- [ ] Cobertura de edge cases e boundaries
- [ ] Documentação adequada (se complexo)

---

## 🔧 Ferramentas de Estilo

### Checkstyle (Java)

```xml
<!-- checkstyle.xml -->
<module name="Checker">
    <module name="TreeWalker">
        <!-- Nomenclatura -->
        <module name="MethodName">
            <property name="format" value="^(deve|should)[A-Z][a-zA-Z0-9]*$"/>
        </module>

        <!-- Tamanho -->
        <module name="MethodLength">
            <property name="max" value="50"/>
            <property name="tokens" value="METHOD_DEF"/>
        </module>

        <!-- Complexidade -->
        <module name="CyclomaticComplexity">
            <property name="max" value="5"/>
        </module>
    </module>
</module>
```

### Spotless (Formatação Automática)

```xml
<plugin>
    <groupId>com.diffplug.spotless</groupId>
    <artifactId>spotless-maven-plugin</artifactId>
    <version>2.40.0</version>
    <configuration>
        <java>
            <googleJavaFormat>
                <version>1.17.0</version>
            </googleJavaFormat>
            <removeUnusedImports/>
            <trimTrailingWhitespace/>
            <endWithNewline/>
        </java>
    </configuration>
</plugin>
```

### ArchUnit (Regras Arquiteturais)

```java
// Validar nomenclatura de testes
@ArchTest
static final ArchRule test_classes_should_be_suffixed =
    classes()
        .that().resideInAPackage("..test..")
        .should().haveSimpleNameEndingWith("Test")
        .orShould().haveSimpleNameEndingWith("IntegrationTest");

// Validar estrutura de pacotes
@ArchTest
static final ArchRule test_should_mirror_main_structure =
    classes()
        .that().resideInAPackage("..test..")
        .should().resideInAPackage("..main..")
        .as("Testes devem espelhar estrutura de pacotes de main");
```

---

## 📖 Referências

- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [AssertJ Documentation](https://assertj.github.io/doc/)
- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- [Clean Code (Robert C. Martin)](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [Growing Object-Oriented Software, Guided by Tests](https://www.amazon.com/Growing-Object-Oriented-Software-Guided-Tests/dp/0321503627)
