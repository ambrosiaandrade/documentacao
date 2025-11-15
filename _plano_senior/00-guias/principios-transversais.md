# Princípios Transversais de Testes

**Objetivo:** Consolidar boas práticas de testes que **se aplicam a todos os níveis** (básico, intermediário, avançado) evitando repetições e criando referência única.

**Última Atualização:** 2025-11-15  
**Nível:** TRANSVERSAL  
**Tempo Estimado:** 60 minutos

---

## 📚 O que são Princípios Transversais?

São **práticas fundamentais** que devem ser seguidas independentemente de:

- 🎯 Tipo de teste (unit, integration, E2E)
- 🛠️ Framework usado (JUnit, Mockito, Testcontainers)
- 📦 Arquitetura (monolito, microserviços)
- 🌐 Linguagem (Java, Python, etc)

**Objetivo:** Criar testes **legíveis**, **confiáveis**, **rápidos** e **manuteníveis**.

---

## 1️⃣ AAA: Arrange-Act-Assert

### 📖 Definição

**AAA** é um padrão de estrutura de teste que divide em **3 fases claras**:

1. **Arrange (Preparar):** Configurar dados, mocks, estado inicial
2. **Act (Agir):** Executar a ação sendo testada
3. **Assert (Afirmar):** Verificar o resultado esperado

### ✅ Exemplo Correto

```java
@Test
void shouldCalculateTotalPriceWithDiscount() {
    // Arrange
    Product product = new Product("Laptop", new BigDecimal("1000.00"));
    Discount discount = new Discount(10); // 10%
    PriceCalculator calculator = new PriceCalculator();

    // Act
    BigDecimal totalPrice = calculator.calculatePrice(product, discount);

    // Assert
    assertThat(totalPrice).isEqualByComparingTo("900.00");
}
```

### 🎯 Benefícios

- ✅ **Legibilidade:** Qualquer desenvolvedor entende o fluxo
- ✅ **Manutenção:** Fácil identificar qual fase precisa ajuste
- ✅ **Documentação:** Teste auto-explicativo
- ✅ **Debugging:** Fácil identificar onde falhou

### ❌ Anti-Patterns

#### ❌ Misturar fases

```java
@Test
void badTest() {
    Product product = new Product("Laptop", new BigDecimal("1000.00")); // Arrange
    BigDecimal price = calculator.calculatePrice(product, null); // Act
    Discount discount = new Discount(10); // ❌ Arrange depois do Act
    assertThat(price).isNotNull(); // Assert
}
```

#### ❌ Múltiplos Acts

```java
@Test
void badTestMultipleActs() {
    // Arrange
    Order order = new Order();

    // Act 1
    order.addItem(item1); // ❌ Primeiro Act

    // Assert parcial
    assertThat(order.getItems()).hasSize(1);

    // Act 2
    order.addItem(item2); // ❌ Segundo Act

    // Assert final
    assertThat(order.getItems()).hasSize(2);
}
```

**✅ Solução:** Criar 2 testes separados ou usar testes parametrizados.

### 💡 Variações do AAA

#### Given-When-Then (BDD Style)

```java
@Test
@DisplayName("Given valid product and discount, When calculating price, Then should apply discount")
void givenValidProductAndDiscount_whenCalculatingPrice_thenShouldApplyDiscount() {
    // Given (Arrange)
    Product product = ProductBuilder.aLaptop().withPrice("1000.00").build();
    Discount discount = new Discount(10);

    // When (Act)
    BigDecimal result = calculator.calculatePrice(product, discount);

    // Then (Assert)
    assertThat(result).isEqualByComparingTo("900.00");
}
```

---

## 2️⃣ Determinismo: Testes Previsíveis

### 📖 Definição

**Teste determinístico** sempre produz o **mesmo resultado** com as **mesmas entradas**, independente de:

- ⏰ Hora/data de execução
- 🎲 Geração de números aleatórios
- 🌐 Ordem de execução
- 💾 Estado do banco de dados

### ⚠️ Problema: Testes Não Determinísticos (Flaky Tests)

```java
// ❌ NÃO DETERMINÍSTICO
@Test
void badTestWithCurrentTime() {
    Order order = new Order();
    order.setCreatedAt(LocalDateTime.now()); // ❌ Depende do horário

    // Vai falhar em horários diferentes
    assertThat(order.getCreatedAt().getHour()).isEqualTo(10);
}

// ❌ NÃO DETERMINÍSTICO
@Test
void badTestWithRandom() {
    int randomValue = new Random().nextInt(100); // ❌ Aleatório

    // Pode falhar aleatoriamente
    assertThat(randomValue).isLessThan(50);
}
```

### ✅ Solução 1: Clock Fixo (Datas/Horas)

```java
public class OrderService {
    private final Clock clock;

    public OrderService(Clock clock) {
        this.clock = clock;
    }

    public Order createOrder() {
        Order order = new Order();
        order.setCreatedAt(LocalDateTime.now(clock)); // Usa clock injetado
        return order;
    }
}

// Teste determinístico
@Test
void shouldCreateOrderWithFixedTime() {
    // Arrange
    Clock fixedClock = Clock.fixed(
        Instant.parse("2025-11-15T10:00:00Z"),
        ZoneId.of("UTC")
    );
    OrderService service = new OrderService(fixedClock);

    // Act
    Order order = service.createOrder();

    // Assert
    assertThat(order.getCreatedAt())
        .isEqualTo(LocalDateTime.of(2025, 11, 15, 10, 0, 0));
}
```

### ✅ Solução 2: Seed para Random

```java
@Test
void shouldGenerateConsistentRandomValues() {
    // Arrange - seed fixo garante mesma sequência
    Random random = new Random(12345L);
    RandomService service = new RandomService(random);

    // Act
    int value1 = service.generateNumber();
    int value2 = service.generateNumber();

    // Assert - valores sempre iguais com mesmo seed
    assertThat(value1).isEqualTo(3542);
    assertThat(value2).isEqualTo(9876);
}
```

### ✅ Solução 3: UUID Mockado

```java
public class OrderService {
    private final UuidGenerator uuidGenerator;

    public Order createOrder() {
        Order order = new Order();
        order.setId(uuidGenerator.generate()); // Usa gerador injetado
        return order;
    }
}

@Test
void shouldCreateOrderWithPredictableUuid() {
    // Arrange
    UuidGenerator fixedUuidGenerator = () -> UUID.fromString(
        "550e8400-e29b-41d4-a716-446655440000"
    );
    OrderService service = new OrderService(fixedUuidGenerator);

    // Act
    Order order = service.createOrder();

    // Assert
    assertThat(order.getId()).hasToString("550e8400-e29b-41d4-a716-446655440000");
}
```

### 📊 Checklist de Determinismo

- ✅ Usar `Clock.fixed()` para datas/horas
- ✅ Seed fixo para `Random`
- ✅ Mockar UUID/GUID quando necessário
- ✅ Não depender de ordem de execução dos testes
- ✅ Não depender de dados externos (APIs, arquivos)
- ✅ Limpar estado compartilhado entre testes

---

## 3️⃣ Isolamento: Testes Independentes

### 📖 Definição

Cada teste deve ser **completamente independente**:

- ✅ Não compartilhar estado com outros testes
- ✅ Executar em qualquer ordem
- ✅ Poder ser executado isoladamente
- ✅ Não depender de side-effects de outros testes

### ⚠️ Problema: Testes Acoplados

```java
// ❌ MAU: Estado compartilhado entre testes
public class BadUserServiceTest {
    private static User sharedUser = new User("John"); // ❌ Compartilhado

    @Test
    void test1() {
        sharedUser.setAge(25); // Modifica estado compartilhado
        assertThat(sharedUser.getAge()).isEqualTo(25);
    }

    @Test
    void test2() {
        // ❌ Falha se test1 executou antes e modificou sharedUser
        assertThat(sharedUser.getAge()).isEqualTo(0);
    }
}
```

### ✅ Solução 1: @BeforeEach para Setup Isolado

```java
public class GoodUserServiceTest {
    private User user; // Instância por teste
    private UserService service;

    @BeforeEach
    void setUp() {
        user = new User("John"); // Nova instância a cada teste
        service = new UserService();
    }

    @Test
    void shouldSetAge() {
        service.setAge(user, 25);
        assertThat(user.getAge()).isEqualTo(25);
    }

    @Test
    void shouldInitializeWithZeroAge() {
        assertThat(user.getAge()).isEqualTo(0); // ✅ Sempre funciona
    }
}
```

### ✅ Solução 2: Transações com Rollback (DB)

```java
@SpringBootTest
@Transactional // ✅ Rollback automático após cada teste
class UserRepositoryTest {

    @Autowired
    private UserRepository repository;

    @Test
    void shouldSaveUser() {
        User user = new User("John");
        repository.save(user);

        assertThat(repository.findByName("John")).isPresent();
    } // ✅ Rollback automático - não afeta outros testes

    @Test
    void shouldFindNoUsers() {
        assertThat(repository.findAll()).isEmpty();
    } // ✅ Sempre funciona, não vê dados do teste anterior
}
```

### ✅ Solução 3: Testcontainers Isolados

```java
@Testcontainers
class UserRepositoryContainerTest {

    @Container // ✅ Container único por teste (ou por classe)
    private static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
        .withDatabaseName("testdb");

    @Test
    void shouldSaveUser() {
        // Container isolado garante estado limpo
    }
}
```

### 📊 Checklist de Isolamento

- ✅ Usar `@BeforeEach` para setup, não variáveis estáticas
- ✅ Usar `@Transactional` para testes de banco
- ✅ Limpar caches entre testes (`@CacheEvict`)
- ✅ Usar containers isolados (Testcontainers)
- ✅ Não depender de ordem de execução (`@TestMethodOrder`)
- ✅ Mockar dependências externas (APIs, filas)

---

## 4️⃣ Naming: Nomenclatura Clara

### 📖 Definição

Nome do teste deve **descrever claramente**:

- 🎯 O que está sendo testado
- 📥 Quais as entradas/condições
- 📤 Qual o resultado esperado

### ✅ Padrões Recomendados

#### 1. should_When_Expected Pattern

```java
@Test
void shouldReturnDiscount_whenUserIsVip() { }

@Test
void shouldThrowException_whenProductIsOutOfStock() { }

@Test
void shouldCalculateTotalPrice_whenMultipleItemsAdded() { }
```

#### 2. Given_When_Then Pattern (BDD)

```java
@Test
void givenVipUser_whenCalculatingDiscount_thenShouldApply20Percent() { }

@Test
void givenOutOfStockProduct_whenAddingToCart_thenShouldThrowException() { }
```

#### 3. @DisplayName (JUnit 5)

```java
@Test
@DisplayName("Should calculate shipping cost for international orders")
void test1() { }

@Test
@DisplayName("Should reject order when payment fails")
void test2() { }

@Test
@DisplayName("Given expired coupon, When applying to order, Then should throw InvalidCouponException")
void test3() { }
```

### ❌ Anti-Patterns de Naming

```java
// ❌ Nome genérico
@Test
void test1() { }

// ❌ Nome não descritivo
@Test
void testUser() { }

// ❌ Nome ambíguo
@Test
void testCalculate() { } // Calcular o quê?

// ❌ Nome muito longo
@Test
void shouldCalculateTheTotalPriceOfAllItemsInTheShoppingCartIncludingTaxesAndDiscountsWhenTheUserIsLoggedInAndHasValidCoupon() { }
```

### 💡 Boas Práticas

```java
// ✅ Nome claro e específico
@Test
void shouldCalculateTotalWithTax_whenCartHasMultipleItems() {
    // Teste
}

// ✅ Nome indica exceção esperada
@Test
void shouldThrowInvalidCouponException_whenCouponIsExpired() {
    // Teste
}

// ✅ Nome indica caso de borda
@Test
void shouldReturnEmptyList_whenNoOrdersExist() {
    // Teste
}

// ✅ Nome indica múltiplas condições
@Test
void shouldApplyVipDiscount_whenUserIsVipAndOrderExceeds100() {
    // Teste
}
```

---

## 5️⃣ Performance: Testes Rápidos

### 📖 Definição

Testes devem ser **rápidos** para feedback ágil:

- 🎯 Unit tests: < 100ms
- 🔗 Integration tests: < 1s
- 🌐 E2E tests: < 10s

### ⚠️ Problema: Sleeps Explícitos

```java
// ❌ NÃO FAÇA: Sleep explícito
@Test
void badTestWithSleep() throws Exception {
    service.processAsync();
    Thread.sleep(5000); // ❌ Espera fixa de 5 segundos
    assertThat(service.isComplete()).isTrue();
}
```

### ✅ Solução: Awaitility

```java
@Test
void goodTestWithAwaitility() {
    // Arrange
    service.processAsync();

    // Act & Assert
    await()
        .atMost(Duration.ofSeconds(5))
        .pollInterval(Duration.ofMillis(100))
        .untilAsserted(() ->
            assertThat(service.isComplete()).isTrue()
        );
}
```

### ✅ Boas Práticas de Performance

#### 1. Paralelização

```java
// junit-platform.properties
junit.jupiter.execution.parallel.enabled = true
junit.jupiter.execution.parallel.mode.default = concurrent
```

```java
@Execution(ExecutionMode.CONCURRENT) // Testes paralelos
class FastTestSuite {
    @Test
    void test1() { }

    @Test
    void test2() { }
}
```

#### 2. Timeouts para Evitar Testes Travados

```java
@Test
@Timeout(value = 5, unit = TimeUnit.SECONDS) // ✅ Timeout de 5s
void shouldCompleteWithinTimeout() {
    // Teste que não pode demorar mais que 5s
}
```

#### 3. Mockar I/O Pesado

```java
// ❌ Teste lento (chama API real)
@Test
void slowTestWithRealApi() {
    String result = externalApi.fetchData(); // ❌ Chama API real (lento)
    assertThat(result).isNotNull();
}

// ✅ Teste rápido (mock)
@Test
void fastTestWithMock() {
    when(externalApiMock.fetchData()).thenReturn("mocked data");
    String result = service.process(); // ✅ Usa mock (rápido)
    assertThat(result).contains("mocked data");
}
```

#### 4. Testcontainers com Reuso

```java
@Testcontainers
class FastContainerTest {

    @Container
    private static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
        .withReuse(true); // ✅ Reusa container entre execuções
}
```

### 📊 Checklist de Performance

- ✅ Usar Awaitility ao invés de `Thread.sleep()`
- ✅ Paralelizar testes quando possível
- ✅ Definir timeouts para evitar travamentos
- ✅ Mockar I/O (APIs, arquivos, banco)
- ✅ Reusar containers (Testcontainers)
- ✅ Usar `@MockBean` ao invés de `@SpringBootTest` quando possível

---

## 6️⃣ Test Data Builders

### 📖 Definição

**Test Data Builders** criam objetos de teste de forma **fluida** e **legível**, evitando construtores telescópicos.

### ❌ Problema: Construção Manual

```java
// ❌ Construção manual repetitiva
@Test
void test1() {
    User user = new User();
    user.setName("John");
    user.setEmail("john@example.com");
    user.setAge(25);
    user.setActive(true);
    user.setRole("ADMIN");
}

@Test
void test2() {
    User user = new User();
    user.setName("Jane"); // Repetição
    user.setEmail("jane@example.com");
    user.setAge(30);
    user.setActive(true);
    user.setRole("USER");
}
```

### ✅ Solução: Builder Pattern

```java
public class UserBuilder {
    private String name = "Default User";
    private String email = "user@example.com";
    private int age = 25;
    private boolean active = true;
    private String role = "USER";

    public static UserBuilder aUser() {
        return new UserBuilder();
    }

    public UserBuilder withName(String name) {
        this.name = name;
        return this;
    }

    public UserBuilder withEmail(String email) {
        this.email = email;
        return this;
    }

    public UserBuilder withAge(int age) {
        this.age = age;
        return this;
    }

    public UserBuilder inactive() {
        this.active = false;
        return this;
    }

    public UserBuilder asAdmin() {
        this.role = "ADMIN";
        return this;
    }

    public User build() {
        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setAge(age);
        user.setActive(active);
        user.setRole(role);
        return user;
    }
}
```

### ✅ Uso do Builder

```java
@Test
void shouldCreateAdminUser() {
    // Arrange - fluente e legível
    User admin = UserBuilder.aUser()
        .withName("John")
        .withEmail("john@admin.com")
        .asAdmin()
        .build();

    // Act & Assert
    assertThat(admin.getRole()).isEqualTo("ADMIN");
}

@Test
void shouldCreateInactiveUser() {
    User user = UserBuilder.aUser()
        .withName("Jane")
        .inactive()
        .build();

    assertThat(user.isActive()).isFalse();
}

@Test
void shouldUseDefaults() {
    User user = UserBuilder.aUser().build(); // Usa todos os defaults

    assertThat(user.getName()).isEqualTo("Default User");
    assertThat(user.getAge()).isEqualTo(25);
}
```

### 💡 Object Mother Pattern

Para **cenários comuns**:

```java
public class UserMother {

    public static User anAdmin() {
        return UserBuilder.aUser()
            .withName("Admin User")
            .asAdmin()
            .build();
    }

    public static User aRegularUser() {
        return UserBuilder.aUser()
            .withName("Regular User")
            .build();
    }

    public static User anInactiveUser() {
        return UserBuilder.aUser()
            .withName("Inactive User")
            .inactive()
            .build();
    }
}

// Uso:
@Test
void shouldProcessAdminRequest() {
    User admin = UserMother.anAdmin(); // ✅ Simples e claro
    // teste...
}
```

---

## 7️⃣ Mocking Best Practices

### 📖 Quando Mockar?

#### ✅ Mockar quando:

- 🌐 Dependência externa (API, banco, fila)
- ⏱️ Operação lenta
- 🎲 Comportamento não determinístico
- 💰 Operação custosa (enviar email, cobrar cartão)

#### ❌ NÃO mockar quando:

- 📦 Objetos simples (DTOs, value objects)
- 🧮 Lógica de negócio que você quer testar
- 🏗️ Código da própria classe

### ✅ Mock vs Spy

```java
// Mock: Comportamento totalmente controlado
@Mock
private UserRepository mockRepository;

@Test
void testWithMock() {
    when(mockRepository.findById(1L)).thenReturn(Optional.of(user));
    // Apenas comportamentos explicitamente definidos funcionam
}

// Spy: Objeto real com alguns comportamentos sobrescritos
@Spy
private UserRepository spyRepository = new UserRepositoryImpl();

@Test
void testWithSpy() {
    doReturn(Optional.of(user)).when(spyRepository).findById(1L);
    // Outros métodos chamam implementação real
}
```

### ✅ Verificações (Verify)

```java
@Test
void shouldCallRepositorySave() {
    // Arrange
    User user = new User("John");

    // Act
    service.createUser(user);

    // Assert - verificar que save foi chamado
    verify(repository).save(user);
    verify(repository, times(1)).save(any(User.class));
    verify(repository, never()).delete(any());
}
```

### ✅ Argument Captors

```java
@Test
void shouldSendEmailWithCorrectContent() {
    // Arrange
    User user = new User("john@example.com");

    // Act
    service.registerUser(user);

    // Assert - capturar argumento passado para emailService
    ArgumentCaptor<Email> emailCaptor = ArgumentCaptor.forClass(Email.class);
    verify(emailService).send(emailCaptor.capture());

    Email sentEmail = emailCaptor.getValue();
    assertThat(sentEmail.getTo()).isEqualTo("john@example.com");
    assertThat(sentEmail.getSubject()).contains("Welcome");
}
```

### ❌ Anti-Patterns de Mocking

```java
// ❌ Mockar tudo (teste não testa nada)
@Test
void badTestMockingEverything() {
    when(validator.validate(any())).thenReturn(true);
    when(repository.save(any())).thenReturn(user);
    when(emailService.send(any())).thenReturn(true);

    boolean result = service.process(user);

    assertThat(result).isTrue(); // ❌ Não testa lógica real
}

// ❌ Mockar classe sob teste
@Mock
private UserService serviceMock; // ❌ Deveria testar real, não mock

// ❌ Muitas verificações (frágil)
verify(repository, times(1)).findById(1L);
verify(repository, times(1)).save(any());
verify(emailService, times(1)).send(any());
verify(logger, times(2)).info(anyString()); // ❌ Muito acoplado
```

---

## 📊 Checklist Geral de Princípios

| Princípio        | Verificação                                      | Status |
| ---------------- | ------------------------------------------------ | ------ |
| **AAA**          | Testes divididos em Arrange/Act/Assert claros    | ⬜     |
| **Determinismo** | Clock fixo para datas, seed para Random          | ⬜     |
| **Isolamento**   | @BeforeEach, @Transactional, containers isolados | ⬜     |
| **Naming**       | Nomes descritivos (should_When_Then)             | ⬜     |
| **Performance**  | Awaitility, timeouts, paralelização              | ⬜     |
| **Builders**     | Test Data Builders para objetos complexos        | ⬜     |
| **Mocking**      | Mockar apenas dependências externas              | ⬜     |

---

## 🔗 Referências

### Documentação Detalhada

- [Boas Práticas](05-transversal/05.2-boas-praticas.md)
- [Anti-Patterns](05-transversal/05.3-anti-patterns.md)
- [Glossário](05-transversal/05.4-glossario.md)

### Frameworks

- [JUnit 5 Documentation](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [Awaitility Documentation](http://www.awaitility.org/)
- [AssertJ Documentation](https://assertj.github.io/doc/)

### Livros

- **Growing Object-Oriented Software, Guided by Tests** - Steve Freeman, Nat Pryce
- **Test Driven Development: By Example** - Kent Beck
- **Unit Testing Principles, Practices, and Patterns** - Vladimir Khorikov

---

## 📝 Resumo

**Princípios Transversais** garantem:

- ✅ **AAA:** Estrutura clara (Arrange-Act-Assert)
- ✅ **Determinismo:** Testes previsíveis (Clock fixo, seed)
- ✅ **Isolamento:** Testes independentes (@BeforeEach, @Transactional)
- ✅ **Naming:** Nomenclatura descritiva (should_When_Then)
- ✅ **Performance:** Testes rápidos (Awaitility, paralelização)
- ✅ **Builders:** Criação fluida de dados de teste
- ✅ **Mocking:** Mockar apenas dependências externas

**Regra de ouro:** Testes devem ser **FIRST**:

- **F**ast (rápidos)
- **I**solated (isolados)
- **R**epeatable (repetíveis/determinísticos)
- **S**elf-validating (auto-validáveis)
- **T**imely (escritos no momento certo)

---

**Última Atualização:** 2025-11-15  
**Nível:** TRANSVERSAL  
**Fase:** 4 - Princípios Transversais
