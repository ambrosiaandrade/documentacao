# Guia de Setup de Ambiente de Testes

**Objetivo:** Configurar ambiente de testes profissional com **Docker Compose**, **Testcontainers**, gerenciamento de dados de teste e migrações.

**Público:** Desenvolvedores Pleno e Senior

---

## 📋 Índice

1. [Docker Compose para Testes Locais](#1-docker-compose-para-testes-locais)
2. [Testcontainers para Testes de Integração](#2-testcontainers-para-testes-de-integração)
3. [Gerenciamento de Dados de Teste](#3-gerenciamento-de-dados-de-teste)
4. [Test Data Builders e Factories](#4-test-data-builders-e-factories)
5. [Database Migrations em Testes](#5-database-migrations-em-testes)
6. [CI/CD Setup](#6-cicd-setup)

---

## 1️⃣ Docker Compose para Testes Locais

### Objetivo

Subir dependências (PostgreSQL, Redis, Kafka) localmente para testes manuais e desenvolvimento.

### Setup Básico

```yaml
# docker-compose.test.yml
version: "3.8"

services:
  postgres:
    image: postgres:15-alpine
    container_name: test-postgres
    environment:
      POSTGRES_DB: testdb
      POSTGRES_USER: testuser
      POSTGRES_PASSWORD: testpass
    ports:
      - "5433:5432" # Porta diferente de produção
    volumes:
      - postgres-test-data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U testuser -d testdb"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: test-redis
    ports:
      - "6380:6379" # Porta diferente de produção
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    container_name: test-kafka
    ports:
      - "9093:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9093
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    depends_on:
      - zookeeper

  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    container_name: test-zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2182:2181"

volumes:
  postgres-test-data:
```

### Comandos Úteis

```bash
# Subir todos os serviços
docker-compose -f docker-compose.test.yml up -d

# Ver logs
docker-compose -f docker-compose.test.yml logs -f postgres

# Parar e remover (mantém volumes)
docker-compose -f docker-compose.test.yml down

# Parar e remover tudo (inclusive dados)
docker-compose -f docker-compose.test.yml down -v

# Verificar saúde dos serviços
docker-compose -f docker-compose.test.yml ps
```

### application-test.yml

```yaml
# src/test/resources/application-test.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5433/testdb
    username: testuser
    password: testpass
    driver-class-name: org.postgresql.Driver

  data:
    redis:
      host: localhost
      port: 6380

  kafka:
    bootstrap-servers: localhost:9093

  jpa:
    hibernate:
      ddl-auto: validate # Usa Flyway para criar schema
    show-sql: true
    properties:
      hibernate:
        format_sql: true

  flyway:
    enabled: true
    locations: classpath:db/migration
    clean-disabled: false # Permite clean em testes
```

### Script de Inicialização

```sql
-- scripts/init-db.sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS test_metadata (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    test_run_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Outras tabelas serão criadas via Flyway
```

---

## 2️⃣ Testcontainers para Testes de Integração

### Por que Testcontainers?

- ✅ Banco real (não H2) em testes
- ✅ Isolamento completo entre testes
- ✅ CI/CD sem configuração extra
- ✅ Múltiplos serviços (Postgres + Redis + Kafka)

### Dependências

```xml
<!-- pom.xml -->
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>testcontainers</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>junit-jupiter</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>
```

### Setup Básico

```java
@SpringBootTest
@Testcontainers
class OrderServiceIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
        .withDatabaseName("testdb")
        .withUsername("testuser")
        .withPassword("testpass")
        .withReuse(true);  // Reusa container entre testes

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderRepository orderRepository;

    @BeforeEach
    void setUp() {
        // Limpar dados entre testes
        orderRepository.deleteAll();
    }

    @Test
    void shouldCreateOrder_andPersistToDatabase() {
        // Arrange
        OrderRequest request = OrderBuilder.aRequest()
            .withItems(3)
            .build();

        // Act
        Order result = orderService.create(request);

        // Assert
        assertThat(result.getId()).isNotNull();

        // Verificar que persistiu no banco
        Optional<Order> found = orderRepository.findById(result.getId());
        assertThat(found).isPresent();
        assertThat(found.get().getItems()).hasSize(3);
    }
}
```

### Setup com Múltiplos Containers

```java
@SpringBootTest
@Testcontainers
class MultiContainerIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
        .withReuse(true);

    @Container
    static GenericContainer<?> redis = new GenericContainer<>("redis:7-alpine")
        .withExposedPorts(6379)
        .withReuse(true);

    @Container
    static KafkaContainer kafka = new KafkaContainer(
        DockerImageName.parse("confluentinc/cp-kafka:7.5.0")
    ).withReuse(true);

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        // Postgres
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);

        // Redis
        registry.add("spring.data.redis.host", redis::getHost);
        registry.add("spring.data.redis.port", redis::getFirstMappedPort);

        // Kafka
        registry.add("spring.kafka.bootstrap-servers", kafka::getBootstrapServers);
    }
}
```

### Base Class para Testes

```java
@SpringBootTest
@Testcontainers
@ActiveProfiles("test")
public abstract class IntegrationTestBase {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
        .withReuse(true);

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @BeforeEach
    void cleanDatabase() {
        // Limpar todas as tabelas
        jdbcTemplate.execute("TRUNCATE TABLE orders CASCADE");
        jdbcTemplate.execute("TRUNCATE TABLE customers CASCADE");
    }
}

// Uso
class OrderServiceIntegrationTest extends IntegrationTestBase {
    // Herda configuração de containers
}
```

### Performance: Reuso de Containers

```java
// testcontainers.properties (src/test/resources)
testcontainers.reuse.enable=true
```

```java
@Container
static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
    .withReuse(true);  // Container sobrevive entre execuções de teste
```

**Benefício:** Primeira execução: 15s startup. Próximas: 2s (reusa container).

---

## 3️⃣ Gerenciamento de Dados de Teste

### Estratégias

1. **@Transactional com Rollback** (recomendado para unitários)
2. **@Sql Scripts** (útil para setup complexo)
3. **Test Data Builders** (flexível e legível)
4. **Object Mother Pattern** (scenarios pré-definidos)
5. **Fixtures com DBUnit** (quando precisa snapshot exato)

### 1. @Transactional Rollback

```java
@SpringBootTest
@Transactional  // Cada teste roda em transação que faz rollback automático
class OrderServiceTest {

    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderRepository orderRepository;

    @Test
    void shouldCreateOrder() {
        // Arrange
        Order order = new Order();
        order.setStatus(OrderStatus.CREATED);

        // Act
        Order saved = orderRepository.save(order);

        // Assert
        assertThat(saved.getId()).isNotNull();

        // Rollback automático - não polui próximo teste
    }
}
```

### 2. @Sql Scripts

```java
@SpringBootTest
class OrderReportTest {

    @Test
    @Sql("/test-data/10-orders.sql")  // Executa antes do teste
    @Sql(scripts = "/cleanup.sql", executionPhase = Sql.ExecutionPhase.AFTER_TEST_METHOD)
    void shouldGenerateReport_with10Orders() {
        // Dados já carregados pelo script
        List<Order> orders = orderRepository.findAll();
        assertThat(orders).hasSize(10);
    }
}
```

```sql
-- src/test/resources/test-data/10-orders.sql
INSERT INTO customers (id, name, email) VALUES
    ('CUST-1', 'Alice', 'alice@example.com'),
    ('CUST-2', 'Bob', 'bob@example.com');

INSERT INTO orders (id, customer_id, status, total_amount, created_at) VALUES
    ('ORD-1', 'CUST-1', 'COMPLETED', 100.00, '2025-01-01'),
    ('ORD-2', 'CUST-1', 'COMPLETED', 200.00, '2025-01-02'),
    ('ORD-3', 'CUST-2', 'PENDING', 50.00, '2025-01-03');
-- ... mais 7 orders
```

### 3. Cleanup entre Testes

```java
@SpringBootTest
class IntegrationTestWithCleanup {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void cleanDatabase() {
        // Método 1: TRUNCATE (rápido, reseta sequences)
        jdbcTemplate.execute("TRUNCATE TABLE orders CASCADE");
        jdbcTemplate.execute("TRUNCATE TABLE customers CASCADE");

        // Método 2: DELETE (mais lento, mantém sequences)
        jdbcTemplate.execute("DELETE FROM orders");
        jdbcTemplate.execute("DELETE FROM customers");

        // Método 3: Usar @Sql script
    }

    @AfterEach
    void verifyNoLeakedData() {
        // Verificar que teste limpou tudo
        long orderCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM orders", Long.class
        );
        assertThat(orderCount).isZero();
    }
}
```

---

## 4️⃣ Test Data Builders e Factories

### Test Data Builder Pattern

```java
public class OrderBuilder {

    private String id = UUID.randomUUID().toString();
    private Customer customer = CustomerBuilder.aCustomer().build();
    private List<OrderItem> items = new ArrayList<>();
    private OrderStatus status = OrderStatus.CREATED;
    private BigDecimal totalAmount = BigDecimal.ZERO;
    private LocalDateTime createdAt = LocalDateTime.now();

    public static OrderBuilder anOrder() {
        return new OrderBuilder();
    }

    public OrderBuilder withId(String id) {
        this.id = id;
        return this;
    }

    public OrderBuilder withCustomer(Customer customer) {
        this.customer = customer;
        return this;
    }

    public OrderBuilder withItems(int count) {
        for (int i = 0; i < count; i++) {
            this.items.add(OrderItemBuilder.anItem()
                .withProduct("Product-" + i)
                .withPrice(BigDecimal.valueOf(10.00 * (i + 1)))
                .build());
        }
        recalculateTotal();
        return this;
    }

    public OrderBuilder withStatus(OrderStatus status) {
        this.status = status;
        return this;
    }

    public OrderBuilder completed() {
        this.status = OrderStatus.COMPLETED;
        return this;
    }

    public OrderBuilder pending() {
        this.status = OrderStatus.PENDING;
        return this;
    }

    public OrderBuilder withTotalAmount(BigDecimal amount) {
        this.totalAmount = amount;
        return this;
    }

    public OrderBuilder createdAt(LocalDateTime dateTime) {
        this.createdAt = dateTime;
        return this;
    }

    public OrderBuilder yesterday() {
        this.createdAt = LocalDateTime.now().minusDays(1);
        return this;
    }

    public Order build() {
        Order order = new Order();
        order.setId(id);
        order.setCustomer(customer);
        order.setItems(items);
        order.setStatus(status);
        order.setTotalAmount(totalAmount);
        order.setCreatedAt(createdAt);
        return order;
    }

    public Order buildAndSave(OrderRepository repository) {
        return repository.save(build());
    }

    private void recalculateTotal() {
        this.totalAmount = items.stream()
            .map(OrderItem::getPrice)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}

// Uso
@Test
void shouldCalculateDiscount() {
    Order order = OrderBuilder.anOrder()
        .withCustomer(CustomerBuilder.vip().build())
        .withItems(3)
        .completed()
        .build();

    assertThat(order.getTotalAmount()).isGreaterThan(BigDecimal.ZERO);
}
```

### Object Mother Pattern

```java
public class OrderMother {

    // Scenarios pré-definidos

    public static Order completedOrderWithThreeItems() {
        return OrderBuilder.anOrder()
            .withItems(3)
            .completed()
            .build();
    }

    public static Order pendingOrderForVipCustomer() {
        return OrderBuilder.anOrder()
            .withCustomer(CustomerMother.vipCustomer())
            .withItems(5)
            .pending()
            .build();
    }

    public static Order expensiveOrder() {
        return OrderBuilder.anOrder()
            .withItems(10)
            .withTotalAmount(new BigDecimal("5000.00"))
            .build();
    }

    public static Order orderFromYesterday() {
        return OrderBuilder.anOrder()
            .yesterday()
            .completed()
            .build();
    }
}

public class CustomerMother {

    public static Customer vipCustomer() {
        return CustomerBuilder.aCustomer()
            .withName("Alice VIP")
            .withEmail("alice@vip.com")
            .withVipStatus(true)
            .build();
    }

    public static Customer regularCustomer() {
        return CustomerBuilder.aCustomer()
            .withName("Bob Regular")
            .withEmail("bob@example.com")
            .build();
    }
}

// Uso
@Test
void shouldApplyVipDiscount() {
    Order order = OrderMother.pendingOrderForVipCustomer();

    BigDecimal discount = discountService.calculate(order);

    assertThat(discount).isGreaterThan(BigDecimal.ZERO);
}
```

### Factory com Persistência

```java
@Component
public class TestDataFactory {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private CustomerRepository customerRepository;

    public Customer createCustomer(String name) {
        Customer customer = CustomerBuilder.aCustomer()
            .withName(name)
            .build();
        return customerRepository.save(customer);
    }

    public Order createCompletedOrder(Customer customer) {
        Order order = OrderBuilder.anOrder()
            .withCustomer(customer)
            .withItems(3)
            .completed()
            .build();
        return orderRepository.save(order);
    }

    public List<Order> create10CompletedOrders() {
        Customer customer = createCustomer("Test Customer");
        return IntStream.range(0, 10)
            .mapToObj(i -> createCompletedOrder(customer))
            .collect(Collectors.toList());
    }
}

// Uso
@SpringBootTest
class ReportServiceTest {

    @Autowired
    private TestDataFactory testData;

    @Test
    void shouldGenerateReport() {
        // Arrange
        List<Order> orders = testData.create10CompletedOrders();

        // Act
        Report report = reportService.generate();

        // Assert
        assertThat(report.getTotalOrders()).isEqualTo(10);
    }
}
```

---

## 5️⃣ Database Migrations em Testes

### Flyway Setup

```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
```

```yaml
# application-test.yml
spring:
  flyway:
    enabled: true
    locations: classpath:db/migration
    clean-disabled: false # Permite clean em testes
    baseline-on-migrate: true
```

### Estrutura de Migrations

```
src/
├── main/
│   └── resources/
│       └── db/
│           └── migration/
│               ├── V1__create_customers_table.sql
│               ├── V2__create_orders_table.sql
│               └── V3__add_vip_status_to_customers.sql
└── test/
    └── resources/
        └── db/
            └── migration/
                └── V99__test_data.sql  # Opcional: dados de teste
```

### Migration Example

```sql
-- V1__create_customers_table.sql
CREATE TABLE customers (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    vip_status BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customers_email ON customers(email);
```

```sql
-- V2__create_orders_table.sql
CREATE TABLE orders (
    id VARCHAR(255) PRIMARY KEY,
    customer_id VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
```

### Test-Specific Migrations

```sql
-- src/test/resources/db/migration/V99__test_data.sql
-- Apenas executado em testes

INSERT INTO customers (id, name, email, vip_status) VALUES
    ('TEST-CUST-1', 'Test Alice', 'alice@test.com', true),
    ('TEST-CUST-2', 'Test Bob', 'bob@test.com', false);
```

### Flyway Clean para Testes

```java
@SpringBootTest
class DatabaseMigrationTest {

    @Autowired
    private Flyway flyway;

    @Test
    void shouldRunMigrationsSuccessfully() {
        // Clean database
        flyway.clean();

        // Re-run migrations
        MigrateResult result = flyway.migrate();

        // Assert
        assertThat(result.migrationsExecuted).isGreaterThan(0);
        assertThat(result.success).isTrue();
    }
}
```

---

## 6️⃣ CI/CD Setup

### GitHub Actions Example

```yaml
# .github/workflows/tests.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: "17"
          distribution: "temurin"

      - name: Cache Maven packages
        uses: actions/cache@v3
        with:
          path: ~/.m2
          key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}

      - name: Run tests
        run: mvn clean verify

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./target/site/jacoco/jacoco.xml

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: target/surefire-reports
```

### Maven Surefire Config

```xml
<!-- pom.xml -->
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <version>3.0.0</version>
            <configuration>
                <!-- Executar testes em paralelo -->
                <parallel>classes</parallel>
                <threadCount>4</threadCount>

                <!-- Fail fast -->
                <skipAfterFailureCount>1</skipAfterFailureCount>

                <!-- Retry flaky tests -->
                <rerunFailingTestsCount>2</rerunFailingTestsCount>
            </configuration>
        </plugin>
    </plugins>
</build>
```

---

## 📊 Checklist de Setup Completo

### Ambiente Local

- [ ] Docker Compose configurado com PostgreSQL, Redis, Kafka
- [ ] Portas diferentes de produção (5433, 6380, 9093)
- [ ] Health checks configurados
- [ ] Scripts de inicialização (init-db.sql)
- [ ] application-test.yml aponta para Docker Compose

### Testcontainers

- [ ] Dependências adicionadas (testcontainers, postgresql)
- [ ] @Testcontainers em testes de integração
- [ ] @Container configurados
- [ ] @DynamicPropertySource injeta configurações
- [ ] Reuso de containers habilitado (testcontainers.reuse.enable=true)
- [ ] Base class para testes (IntegrationTestBase)

### Dados de Teste

- [ ] Test Data Builders implementados (OrderBuilder, CustomerBuilder)
- [ ] Object Mother para scenarios comuns
- [ ] TestDataFactory com métodos de criação
- [ ] @Transactional com rollback automático
- [ ] @BeforeEach limpa banco entre testes

### Database Migrations

- [ ] Flyway configurado
- [ ] Migrations versionadas (V1, V2, ...)
- [ ] Índices criados em migrations
- [ ] Migrations de teste opcionais (V99)
- [ ] flyway.clean habilitado apenas em testes

### CI/CD

- [ ] GitHub Actions / GitLab CI configurado
- [ ] Testcontainers funciona no CI (docker disponível)
- [ ] Coverage reports gerados
- [ ] Test results como artifact
- [ ] Cache de dependências Maven/Gradle

---

## 🎯 Próximos Passos

1. **Setup inicial:** Docker Compose + Testcontainers
2. **Builders:** Criar Test Data Builders para entidades principais
3. **Migrations:** Configurar Flyway com índices adequados
4. **CI/CD:** Garantir testes passam no pipeline
5. **Documentação:** README com instruções de setup

---

**Última Atualização:** 2025-11-15  
**Versão:** 1.0  
**Criado em:** Fase 6 - Checklists & Autoavaliação
