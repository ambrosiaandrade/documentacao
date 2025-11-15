# Trilha de Qualidade - Exercícios Práticos

**Objetivo:** Dominar técnicas para garantir **qualidade de código** através de **coverage**, **mutation testing**, **análise estática** e **refatoração guiada por testes**.

**Nível:** Intermediário → Avançado  
**Tempo Estimado:** 8-10 horas  
**Pré-requisitos:** JUnit 5, Mockito, conhecimento básico de testes

---

## 📚 Estrutura da Trilha

Cada exercício segue o formato:

- 🎯 **Objetivo:** O que você vai aprender
- 📖 **Contexto:** Cenário do problema
- 🛠️ **Passos:** Como implementar
- ✅ **Critério de Sucesso:** Como saber que completou
- ⚠️ **Pitfalls:** Erros comuns
- 🚀 **Extensão:** Desafios extras (opcional)

---

## 🧪 Exercício 1: Code Coverage Avançado

### 🎯 Objetivo

Aumentar **code coverage** de 60% para **85%+** identificando **código não testado** e criando testes efetivos (não apenas para aumentar número).

### 📖 Contexto

Você herdou um serviço de **processamento de pedidos** com coverage de 60%. Seu gestor quer 85%, mas você precisa garantir que os testes são **úteis**, não apenas aumentam a métrica.

```java
public class OrderService {
    private final OrderRepository repository;
    private final PaymentService paymentService;
    private final EmailService emailService;

    public Order processOrder(OrderRequest request) {
        // Validação
        if (request.getItems().isEmpty()) {
            throw new InvalidOrderException("Order must have items");
        }

        if (request.getTotalAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new InvalidOrderException("Total amount must be positive");
        }

        // Salvar pedido
        Order order = new Order();
        order.setItems(request.getItems());
        order.setTotalAmount(request.getTotalAmount());
        order.setStatus(OrderStatus.PENDING);

        Order savedOrder = repository.save(order);

        // Processar pagamento
        try {
            PaymentResult payment = paymentService.processPayment(
                savedOrder.getId(),
                savedOrder.getTotalAmount()
            );

            if (payment.isSuccess()) {
                savedOrder.setStatus(OrderStatus.PAID);
                savedOrder.setPaymentId(payment.getPaymentId());
                repository.save(savedOrder);

                // Enviar confirmação
                emailService.sendOrderConfirmation(savedOrder);
            } else {
                savedOrder.setStatus(OrderStatus.PAYMENT_FAILED);
                savedOrder.setFailureReason(payment.getErrorMessage());
                repository.save(savedOrder);
            }
        } catch (PaymentException e) {
            savedOrder.setStatus(OrderStatus.PAYMENT_ERROR);
            savedOrder.setFailureReason(e.getMessage());
            repository.save(savedOrder);
            throw e;
        }

        return savedOrder;
    }
}
```

**Coverage atual:**

- Lines: 60%
- Branches: 45%
- Métodos não testados: `sendOrderConfirmation`, validações de erro

### 🛠️ Passos

#### 1. Gerar Relatório de Coverage

```xml
<!-- pom.xml -->
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

```bash
mvn clean test jacoco:report
# Relatório em: target/site/jacoco/index.html
```

#### 2. Identificar Código Não Coberto

Abrir `target/site/jacoco/index.html` e identificar:

- ❌ Linhas vermelhas (não cobertas)
- 🟨 Linhas amarelas (branches parcialmente cobertos)

#### 3. Criar Testes para Cenários Não Cobertos

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock private OrderRepository repository;
    @Mock private PaymentService paymentService;
    @Mock private EmailService emailService;

    @InjectMocks private OrderService service;

    // ✅ Cenário: Pedido com items vazios
    @Test
    void shouldThrowException_whenOrderHasNoItems() {
        // Arrange
        OrderRequest request = new OrderRequest(Collections.emptyList(), BigDecimal.TEN);

        // Act & Assert
        assertThatThrownBy(() -> service.processOrder(request))
            .isInstanceOf(InvalidOrderException.class)
            .hasMessage("Order must have items");
    }

    // ✅ Cenário: Total negativo
    @Test
    void shouldThrowException_whenTotalAmountIsNegative() {
        // Arrange
        OrderRequest request = new OrderRequest(
            List.of(new Item("Product", BigDecimal.TEN)),
            BigDecimal.valueOf(-10)
        );

        // Act & Assert
        assertThatThrownBy(() -> service.processOrder(request))
            .isInstanceOf(InvalidOrderException.class)
            .hasMessage("Total amount must be positive");
    }

    // ✅ Cenário: Pagamento falha (branch não coberto)
    @Test
    void shouldSetPaymentFailedStatus_whenPaymentFails() {
        // Arrange
        OrderRequest request = validOrderRequest();
        Order savedOrder = new Order();
        savedOrder.setId(1L);

        when(repository.save(any(Order.class))).thenReturn(savedOrder);
        when(paymentService.processPayment(anyLong(), any()))
            .thenReturn(PaymentResult.failure("Insufficient funds"));

        // Act
        Order result = service.processOrder(request);

        // Assert
        assertThat(result.getStatus()).isEqualTo(OrderStatus.PAYMENT_FAILED);
        assertThat(result.getFailureReason()).isEqualTo("Insufficient funds");
        verify(emailService, never()).sendOrderConfirmation(any());
    }

    // ✅ Cenário: Exception no pagamento (branch não coberto)
    @Test
    void shouldSetPaymentErrorStatus_whenPaymentThrowsException() {
        // Arrange
        OrderRequest request = validOrderRequest();
        Order savedOrder = new Order();
        savedOrder.setId(1L);

        when(repository.save(any(Order.class))).thenReturn(savedOrder);
        when(paymentService.processPayment(anyLong(), any()))
            .thenThrow(new PaymentException("Connection timeout"));

        // Act & Assert
        assertThatThrownBy(() -> service.processOrder(request))
            .isInstanceOf(PaymentException.class);

        ArgumentCaptor<Order> orderCaptor = ArgumentCaptor.forClass(Order.class);
        verify(repository, times(2)).save(orderCaptor.capture());

        Order finalOrder = orderCaptor.getValue();
        assertThat(finalOrder.getStatus()).isEqualTo(OrderStatus.PAYMENT_ERROR);
        assertThat(finalOrder.getFailureReason()).isEqualTo("Connection timeout");
    }

    // ✅ Cenário: Sucesso completo (cobrir email)
    @Test
    void shouldSendConfirmationEmail_whenPaymentSucceeds() {
        // Arrange
        OrderRequest request = validOrderRequest();
        Order savedOrder = new Order();
        savedOrder.setId(1L);

        when(repository.save(any(Order.class))).thenReturn(savedOrder);
        when(paymentService.processPayment(anyLong(), any()))
            .thenReturn(PaymentResult.success("PAY-123"));

        // Act
        service.processOrder(request);

        // Assert
        verify(emailService).sendOrderConfirmation(argThat(order ->
            order.getStatus() == OrderStatus.PAID &&
            order.getPaymentId().equals("PAY-123")
        ));
    }
}
```

#### 4. Verificar Coverage Aumentou

```bash
mvn clean test jacoco:report
# Verificar novo percentual: 85%+
```

### ✅ Critério de Sucesso

- ✅ Line coverage ≥ 85%
- ✅ Branch coverage ≥ 75%
- ✅ Todos os branches (if/else, try/catch) cobertos
- ✅ Testes verificam comportamento, não apenas executam código
- ✅ Nenhum teste "dummy" (vazio ou sem assertions)

### ⚠️ Pitfalls

- ❌ **Coverage Vanity:** Criar testes que não verificam nada apenas para aumentar número
- ❌ **Ignorar branches:** Focar em lines, esquecer if/else não testados
- ❌ **Testar getters/setters:** Focar em lógica de negócio, não código trivial
- ❌ **Mockar tudo:** Mock excessivo pode dar 100% coverage sem testar nada real

### 🚀 Extensão

1. **Diff Coverage:** Configurar para verificar coverage apenas das linhas alteradas no PR
2. **Coverage Gates:** Configurar CI/CD para falhar se coverage < 85%
3. **Mutation Testing:** Verificar se testes realmente matam mutantes (próximo exercício)

---

## 🧬 Exercício 2: Mutation Testing com PIT

### 🎯 Objetivo

Usar **mutation testing** para encontrar **testes fracos** que passam mas não validam comportamento crítico.

### 📖 Contexto

Você tem 90% de code coverage, mas bugs ainda chegam em produção. **Mutation testing** vai revelar que seus testes não verificam lógica corretamente.

```java
public class DiscountCalculator {

    public BigDecimal calculateDiscount(Order order) {
        BigDecimal total = order.getTotalAmount();

        // VIP: 20% desconto
        if (order.getCustomer().isVip()) {
            return total.multiply(BigDecimal.valueOf(0.20));
        }

        // Pedidos > 1000: 10% desconto
        if (total.compareTo(BigDecimal.valueOf(1000)) > 0) {
            return total.multiply(BigDecimal.valueOf(0.10));
        }

        // Sem desconto
        return BigDecimal.ZERO;
    }
}
```

**Teste fraco (coverage 100%, mas não valida valores):**

```java
@Test
void shouldCalculateDiscount() {
    Order order = createVipOrder();

    BigDecimal discount = calculator.calculateDiscount(order);

    assertThat(discount).isNotNull(); // ❌ Teste fraco!
}
```

### 🛠️ Passos

#### 1. Configurar PIT (Pitest)

```xml
<plugin>
    <groupId>org.pitest</groupId>
    <artifactId>pitest-maven</artifactId>
    <version>1.15.3</version>
    <dependencies>
        <dependency>
            <groupId>org.pitest</groupId>
            <artifactId>pitest-junit5-plugin</artifactId>
            <version>1.2.1</version>
        </dependency>
    </dependencies>
    <configuration>
        <targetClasses>
            <param>com.example.service.*</param>
        </targetClasses>
        <targetTests>
            <param>com.example.service.*Test</param>
        </targetTests>
        <mutators>
            <mutator>DEFAULTS</mutator>
        </mutators>
    </configuration>
</plugin>
```

#### 2. Executar Mutation Testing

```bash
mvn test-compile org.pitest:pitest-maven:mutationCoverage
# Relatório: target/pit-reports/YYYYMMDDHHMI/index.html
```

#### 3. Analisar Mutantes Sobreviventes

Abrir relatório PIT e identificar:

**Mutante 1:** `0.20` → `0.21` (survived)

- Teste não verifica valor exato do desconto VIP

**Mutante 2:** `>` → `>=` (survived)

- Teste não valida limite exato de 1000

**Mutante 3:** `BigDecimal.ZERO` → `BigDecimal.ONE` (survived)

- Teste não verifica retorno quando não há desconto

#### 4. Melhorar Testes para Matar Mutantes

```java
class DiscountCalculatorTest {

    private DiscountCalculator calculator;

    @BeforeEach
    void setUp() {
        calculator = new DiscountCalculator();
    }

    // ✅ Teste forte: Valida valor exato
    @Test
    void shouldApply20PercentDiscount_whenCustomerIsVip() {
        // Arrange
        Customer vipCustomer = new Customer("John", true);
        Order order = new Order(vipCustomer, BigDecimal.valueOf(1000));

        // Act
        BigDecimal discount = calculator.calculateDiscount(order);

        // Assert - Valor exato esperado
        assertThat(discount).isEqualByComparingTo("200.00"); // 20% de 1000
    }

    // ✅ Teste de limite exato
    @Test
    void shouldApply10PercentDiscount_whenTotalIsExactly1001() {
        // Arrange
        Customer customer = new Customer("Jane", false);
        Order order = new Order(customer, BigDecimal.valueOf(1001));

        // Act
        BigDecimal discount = calculator.calculateDiscount(order);

        // Assert
        assertThat(discount).isEqualByComparingTo("100.10"); // 10% de 1001
    }

    // ✅ Teste de limite inferior (não deve ter desconto)
    @Test
    void shouldReturnZeroDiscount_whenTotalIs1000AndNotVip() {
        // Arrange
        Customer customer = new Customer("Bob", false);
        Order order = new Order(customer, BigDecimal.valueOf(1000));

        // Act
        BigDecimal discount = calculator.calculateDiscount(order);

        // Assert
        assertThat(discount).isEqualByComparingTo("0.00"); // Sem desconto
    }

    // ✅ Teste de prioridade (VIP > threshold)
    @Test
    void shouldApplyVipDiscount_whenCustomerIsVipAndTotalExceeds1000() {
        // Arrange
        Customer vipCustomer = new Customer("Alice", true);
        Order order = new Order(vipCustomer, BigDecimal.valueOf(2000));

        // Act
        BigDecimal discount = calculator.calculateDiscount(order);

        // Assert - VIP tem prioridade (20%, não 10%)
        assertThat(discount).isEqualByComparingTo("400.00");
    }
}
```

#### 5. Executar PIT Novamente

```bash
mvn test-compile org.pitest:pitest-maven:mutationCoverage
```

**Resultado esperado:**

- Mutation coverage: 100%
- Mutantes mortos: 15/15
- Mutantes sobreviventes: 0

### ✅ Critério de Sucesso

- ✅ Mutation coverage ≥ 80%
- ✅ Todos os mutantes críticos mortos (operadores matemáticos, condicionais)
- ✅ Testes validam valores exatos, não apenas "não null"
- ✅ Limites (boundaries) testados (1000, 1001, 999)

### ⚠️ Pitfalls

- ❌ **Ignorar mutantes:** Aceitar sobreviventes sem investigar
- ❌ **Mutantes equivalentes:** Alguns mutantes são impossíveis de matar (ex: `i++` vs `++i` sem efeito)
- ❌ **Performance:** PIT é lento (executar em CI, não localmente sempre)
- ❌ **Threshold muito alto:** 100% mutation é difícil/impossível

### 🚀 Extensão

1. **Mutantes Customizados:** Configurar mutators específicos (INCREMENTS, CONDITIONALS)
2. **Incremental Analysis:** Usar PIT incremental para rodar apenas em código alterado
3. **CI Integration:** Gate de deploy se mutation < 80%

---

## 🔍 Exercício 3: Análise Estática com SonarQube

### 🎯 Objetivo

Identificar **code smells**, **bugs potenciais** e **vulnerabilidades de segurança** usando análise estática.

### 📖 Contexto

Você precisa garantir que o código segue padrões de qualidade **antes** do merge. SonarQube vai identificar problemas que testes não pegam.

### 🛠️ Passos

#### 1. Configurar SonarQube Local (Docker)

```bash
docker run -d --name sonarqube -p 9000:9000 sonarqube:community
# Acessar: http://localhost:9000 (admin/admin)
```

#### 2. Configurar Projeto Maven

```xml
<properties>
    <sonar.host.url>http://localhost:9000</sonar.host.url>
    <sonar.login>seu-token-aqui</sonar.login>
</properties>
```

#### 3. Executar Análise

```bash
mvn clean verify sonar:sonar
```

#### 4. Analisar Relatório

Abrir `http://localhost:9000` e verificar:

**Bugs (3 encontrados):**

1. **NullPointerException potencial:** `order.getCustomer().getName()` sem verificar null
2. **Resource leak:** `FileInputStream` não fechado
3. **Thread safety:** Campo mutable compartilhado entre threads

**Code Smells (12 encontrados):**

1. **Método muito longo:** `processOrder()` com 150 linhas
2. **Complexidade ciclomática alta:** 15 (limite: 10)
3. **Magic numbers:** `0.20`, `1000` hardcoded
4. **Duplicate code:** 3 blocos idênticos em classes diferentes

**Vulnerabilidades (1 encontrada):**

1. **SQL Injection:** Query concatenada ao invés de PreparedStatement

#### 5. Refatorar Baseado nos Achados

**Antes (bug #1):**

```java
public String getCustomerName(Order order) {
    return order.getCustomer().getName(); // ❌ NPE se customer ou nome for null
}
```

**Depois:**

```java
public String getCustomerName(Order order) {
    return Optional.ofNullable(order)
        .map(Order::getCustomer)
        .map(Customer::getName)
        .orElse("Unknown");
}
```

**Antes (smell #3):**

```java
if (total.compareTo(BigDecimal.valueOf(1000)) > 0) {
    return total.multiply(BigDecimal.valueOf(0.20)); // ❌ Magic numbers
}
```

**Depois:**

```java
private static final BigDecimal VIP_DISCOUNT_RATE = BigDecimal.valueOf(0.20);
private static final BigDecimal BULK_ORDER_THRESHOLD = BigDecimal.valueOf(1000);

if (total.compareTo(BULK_ORDER_THRESHOLD) > 0) {
    return total.multiply(VIP_DISCOUNT_RATE);
}
```

**Antes (vulnerability #1):**

```java
String sql = "SELECT * FROM users WHERE username = '" + username + "'"; // ❌ SQL Injection
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery(sql);
```

**Depois:**

```java
String sql = "SELECT * FROM users WHERE username = ?";
PreparedStatement pstmt = conn.prepareStatement(sql);
pstmt.setString(1, username); // ✅ Parametrizado
ResultSet rs = pstmt.executeQuery();
```

#### 6. Verificar Melhorias

```bash
mvn clean verify sonar:sonar
```

**Resultado esperado:**

- Bugs: 3 → 0
- Code Smells: 12 → 2 (apenas menores)
- Vulnerabilities: 1 → 0
- Technical Debt: 2h → 15min

### ✅ Critério de Sucesso

- ✅ Zero bugs (severidade: Blocker, Critical)
- ✅ Zero vulnerabilidades de segurança
- ✅ Code smells ≤ 5 (apenas menores)
- ✅ Technical debt < 30min
- ✅ Coverage ≥ 80% (validado pelo Sonar)

### ⚠️ Pitfalls

- ❌ **Ignorar code smells:** "São só warnings" - podem virar bugs
- ❌ **Desabilitar regras:** Ao invés de corrigir
- ❌ **Não configurar quality gate:** Deixar issues passarem
- ❌ **Rodar apenas localmente:** Integrar no CI/CD

### 🚀 Extensão

1. **Quality Gate customizado:** Configurar limites por projeto
2. **Pull Request Decoration:** Comentários automáticos no PR
3. **Análise de segurança:** Integrar com OWASP Dependency Check

---

## 🧹 Exercício 4: Refatoração Guiada por Testes

### 🎯 Objetivo

Refatorar código legado **com segurança** usando testes como rede de proteção.

### 📖 Contexto

Código legado com 200 linhas em um único método, sem testes. Você precisa refatorar sem quebrar funcionalidade.

**Código legado:**

```java
public class OrderProcessor {

    // ❌ Método gigante, difícil de testar
    public void processOrder(String orderId) {
        // 200 linhas de código aqui...
        // - Validação
        // - Cálculo de frete
        // - Aplicar desconto
        // - Processar pagamento
        // - Enviar emails
        // - Atualizar estoque
        // - Gerar nota fiscal
    }
}
```

### 🛠️ Passos

#### 1. Criar Testes de Caracterização (Approval Tests)

```java
@Test
void shouldProcessOrder_characterizationTest() {
    // Arrange
    String orderId = "ORD-123";

    // Act
    processor.processOrder(orderId);

    // Assert - Capturar estado atual (mesmo que errado)
    Order order = orderRepository.findById(orderId);

    assertThat(order.getStatus()).isEqualTo(OrderStatus.COMPLETED);
    assertThat(order.getTotalAmount()).isEqualByComparingTo("1250.00");
    verify(emailService).sendConfirmation(orderId);
    verify(inventoryService).updateStock(any());
}
```

#### 2. Extrair Validação

**Antes:**

```java
public void processOrder(String orderId) {
    if (orderId == null || orderId.isEmpty()) {
        throw new IllegalArgumentException("Order ID required");
    }

    Order order = repository.findById(orderId);
    if (order == null) {
        throw new OrderNotFoundException(orderId);
    }

    if (order.getItems().isEmpty()) {
        throw new InvalidOrderException("No items");
    }

    // ... resto do código
}
```

**Depois:**

```java
public void processOrder(String orderId) {
    Order order = validateAndFetchOrder(orderId);
    // ... resto do código
}

private Order validateAndFetchOrder(String orderId) {
    if (orderId == null || orderId.isEmpty()) {
        throw new IllegalArgumentException("Order ID required");
    }

    Order order = repository.findById(orderId);
    if (order == null) {
        throw new OrderNotFoundException(orderId);
    }

    if (order.getItems().isEmpty()) {
        throw new InvalidOrderException("No items");
    }

    return order;
}
```

**Teste do método extraído:**

```java
@Test
void shouldValidateOrderId() {
    assertThatThrownBy(() -> processor.validateAndFetchOrder(null))
        .isInstanceOf(IllegalArgumentException.class);
}
```

#### 3. Extrair Cálculo de Frete

```java
// Extrair para ShippingCalculator
public class ShippingCalculator {

    public BigDecimal calculateShipping(Order order) {
        BigDecimal weight = order.getItems().stream()
            .map(Item::getWeight)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        if (weight.compareTo(BigDecimal.valueOf(10)) <= 0) {
            return BigDecimal.valueOf(15.00);
        } else {
            return BigDecimal.valueOf(25.00);
        }
    }
}
```

**Teste isolado:**

```java
class ShippingCalculatorTest {

    @Test
    void shouldCalculate15ForLightOrders() {
        Order order = orderWithWeight(5.0);

        BigDecimal shipping = calculator.calculateShipping(order);

        assertThat(shipping).isEqualByComparingTo("15.00");
    }
}
```

#### 4. Continuar Extraindo até Método Principal Ser Simples

```java
public void processOrder(String orderId) {
    Order order = validateAndFetchOrder(orderId);

    BigDecimal shipping = shippingCalculator.calculate(order);
    BigDecimal discount = discountCalculator.calculate(order);
    BigDecimal total = order.getSubtotal().add(shipping).subtract(discount);

    order.setTotalAmount(total);

    PaymentResult payment = paymentService.process(order);

    if (payment.isSuccess()) {
        order.setStatus(OrderStatus.PAID);
        inventoryService.updateStock(order);
        emailService.sendConfirmation(order);
        invoiceService.generate(order);
    } else {
        order.setStatus(OrderStatus.PAYMENT_FAILED);
    }

    repository.save(order);
}
```

#### 5. Executar Todos os Testes

```bash
mvn test
# Todos devem passar (incluindo teste de caracterização)
```

### ✅ Critério de Sucesso

- ✅ Método principal ≤ 20 linhas
- ✅ Cada método extraído ≤ 10 linhas
- ✅ Complexidade ciclomática ≤ 5 por método
- ✅ Todos os testes passam (antes e depois da refatoração)
- ✅ Coverage mantido ou aumentado
- ✅ Cada método extraído tem testes isolados

### ⚠️ Pitfalls

- ❌ **Refatorar sem testes:** Risco de quebrar funcionalidade
- ❌ **Mudar comportamento:** Refatoração NÃO deve mudar comportamento
- ❌ **Extrair demais:** Criar muitos métodos de 1 linha
- ❌ **Ignorar testes antigos:** Manter testes de caracterização

### 🚀 Extensão

1. **Approval Testing:** Usar ApprovalTests library para snapshots
2. **Refatorar para padrões:** Extrair Strategy, Factory, etc
3. **Performance:** Medir tempo antes/depois da refatoração

---

## 🎨 Exercício 5: Detectar e Eliminar Code Smells

### 🎯 Objetivo

Identificar **10 code smells clássicos** e refatorar para código limpo.

### 📖 Contexto

Você é revisor de código e precisa identificar smells em um PR. Cada smell tem um padrão de refatoração recomendado.

### 🛠️ Code Smells e Refatorações

#### Smell 1: Long Method

**Antes:**

```java
public void processPayment(Order order) {
    // 150 linhas...
}
```

**Depois:**

```java
public void processPayment(Order order) {
    validatePaymentInfo(order);
    BigDecimal amount = calculateTotalAmount(order);
    PaymentResult result = chargeCustomer(order, amount);
    updateOrderStatus(order, result);
    sendNotifications(order, result);
}
```

#### Smell 2: Long Parameter List

**Antes:**

```java
public Order createOrder(String customerId, String name, String address,
                        String city, String state, String zip,
                        String phone, String email, List<Item> items) {
    // ...
}
```

**Depois:**

```java
public Order createOrder(OrderRequest request) {
    // request agrupa todos os parâmetros
}
```

#### Smell 3: Duplicate Code

**Antes:**

```java
// Em OrderService
if (order.getTotal().compareTo(MIN_THRESHOLD) > 0) {
    applyDiscount();
}

// Em InvoiceService (duplicado)
if (invoice.getTotal().compareTo(MIN_THRESHOLD) > 0) {
    applyDiscount();
}
```

**Depois:**

```java
// Extrair para DiscountPolicy
public class DiscountPolicy {
    public boolean isEligible(BigDecimal total) {
        return total.compareTo(MIN_THRESHOLD) > 0;
    }
}
```

#### Smell 4: Data Class (sem comportamento)

**Antes:**

```java
public class Order {
    private BigDecimal subtotal;
    private BigDecimal tax;
    private BigDecimal discount;

    // Apenas getters/setters
}

// Lógica em OrderService (anemic domain)
public BigDecimal calculateTotal(Order order) {
    return order.getSubtotal()
        .add(order.getTax())
        .subtract(order.getDiscount());
}
```

**Depois:**

```java
public class Order {
    private BigDecimal subtotal;
    private BigDecimal tax;
    private BigDecimal discount;

    // Comportamento na classe
    public BigDecimal calculateTotal() {
        return subtotal.add(tax).subtract(discount);
    }
}
```

#### Smell 5: Magic Numbers

**Antes:**

```java
if (order.getTotal().compareTo(BigDecimal.valueOf(1000)) > 0) {
    discount = total.multiply(BigDecimal.valueOf(0.10));
}
```

**Depois:**

```java
private static final BigDecimal BULK_ORDER_THRESHOLD = BigDecimal.valueOf(1000);
private static final BigDecimal BULK_DISCOUNT_RATE = BigDecimal.valueOf(0.10);

if (order.getTotal().compareTo(BULK_ORDER_THRESHOLD) > 0) {
    discount = total.multiply(BULK_DISCOUNT_RATE);
}
```

### ✅ Critério de Sucesso

- ✅ Identificar 10 code smells diferentes no código
- ✅ Refatorar cada smell seguindo padrões
- ✅ Testes passam antes e depois da refatoração
- ✅ Complexidade ciclomática reduzida
- ✅ SonarQube não reporta novos smells

### 🚀 Extensão

Identificar e refatorar:

- Shotgun Surgery
- Feature Envy
- Inappropriate Intimacy
- Primitive Obsession
- Switch Statements (substituir por polimorfismo)

---

## 📊 Checkpoint: Autoavaliação da Trilha Qualidade

### Nível Iniciante (0-40%)

- ⬜ Consegue gerar relatório de coverage básico
- ⬜ Identifica código não coberto por testes
- ⬜ Cria testes unitários simples

### Nível Intermediário (41-70%)

- ⬜ Aumenta coverage de forma consciente (não vanity)
- ⬜ Identifica branches não testados
- ⬜ Refatora métodos longos com testes de proteção
- ⬜ Usa SonarQube para encontrar code smells

### Nível Avançado (71-90%)

- ⬜ Usa mutation testing para validar qualidade dos testes
- ⬜ Mata mutantes sobreviventes
- ⬜ Refatora código legado sem testes com Approval Testing
- ⬜ Elimina code smells sistematicamente

### Nível Senior (91-100%)

- ⬜ Implementa quality gates no CI/CD (coverage, mutation, Sonar)
- ⬜ Configura análise de diff coverage
- ⬜ Mentorei time em práticas de qualidade
- ⬜ Propõe melhorias de processo baseadas em métricas
- ⬜ Balanço entre qualidade e pragmatismo (não 100% sempre)

---

## 📚 Recursos Adicionais

**Ferramentas:**

- JaCoCo: https://www.jacoco.org/
- PIT (Pitest): https://pitest.org/
- SonarQube: https://www.sonarqube.org/
- Checkstyle, PMD, SpotBugs

**Livros:**

- Refactoring: Improving the Design of Existing Code - Martin Fowler
- Working Effectively with Legacy Code - Michael Feathers
- Clean Code - Robert C. Martin

**Métricas:**

- Code Coverage: 80-90% (sweet spot)
- Mutation Score: 70-80% (bom)
- Complexity: ≤ 10 por método
- Technical Debt: < 1 dia por sprint

---

**Criado em:** 2025-11-15  
**Atualizado em:** 2025-11-15  
**Tempo Estimado:** 8-10 horas  
**Próxima Trilha:** [Resiliência](trilhas/resiliencia.md)
