# Trilha de Performance - Exercícios Práticos

**Objetivo:** Dominar técnicas de **otimização de performance** usando **profiling**, **benchmarks**, **otimização de queries SQL** e **caching estratégico**.

**Nível:** Avançado  
**Tempo Estimado:** 10-12 horas  
**Pré-requisitos:** JVM, SQL, Spring Boot, Redis, conhecimento de análise de performance

---

## 🔍 Exercício 1: Profiling com JProfiler/VisualVM

### 🎯 Objetivo

Identificar **hotspots de CPU**, **memory leaks** e **contenção de threads** usando ferramentas de profiling.

### 📖 Contexto

Sistema está lento em produção (P95 = 5s). Você precisa identificar onde o código está gastando tempo e memória.

### 🛠️ Passos

#### 1. Configurar Aplicação para Profiling

```bash
# Executar com Flight Recorder habilitado
java -XX:+FlightRecorder \
     -XX:StartFlightRecording=duration=60s,filename=recording.jfr \
     -jar order-service.jar
```

```yaml
# application.yml - Habilitar endpoints de debug
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,heapdump,threaddump
```

#### 2. Identificar CPU Hotspots

**Cenário:** Endpoint `/api/orders` está lento

```java
// ❌ ANTES: Código ineficiente
@Service
public class OrderService {

    public List<OrderDTO> getAllOrders() {
        List<Order> orders = orderRepository.findAll(); // 10.000 registros

        // Hotspot 1: Loop dentro de loop (O(n²))
        List<OrderDTO> dtos = new ArrayList<>();
        for (Order order : orders) {
            OrderDTO dto = new OrderDTO();
            dto.setId(order.getId());
            dto.setCustomerName(order.getCustomer().getName());

            // Hotspot 2: Query N+1 para cada order
            List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
            dto.setItemCount(items.size());

            // Hotspot 3: Cálculo caro dentro do loop
            dto.setTotalWithTax(calculateTaxForOrder(order)); // 100ms por ordem

            dtos.add(dto);
        }

        return dtos;
    }

    private BigDecimal calculateTaxForOrder(Order order) {
        // Simula cálculo complexo
        double sum = 0;
        for (int i = 0; i < 1_000_000; i++) {
            sum += Math.sqrt(i) * Math.sin(i);
        }
        return order.getTotal().multiply(BigDecimal.valueOf(0.15));
    }
}
```

**Profiling com VisualVM:**

1. Conectar ao processo Java
2. Iniciar CPU profiling
3. Executar requisição
4. Ver métodos que consomem mais tempo:
   - `calculateTaxForOrder()` → 80% do tempo
   - `orderItemRepository.findByOrderId()` → 15%
   - `Math.sqrt() / Math.sin()` → Inside calculateTaxForOrder

```java
// ✅ DEPOIS: Otimizado
@Service
public class OrderService {

    @Cacheable("orders-summary")
    public List<OrderDTO> getAllOrders() {
        // Otimização 1: JOIN FETCH para eliminar N+1
        List<Order> orders = orderRepository.findAllWithItems();

        // Otimização 2: Pré-calcular tax uma vez
        Map<Long, BigDecimal> taxCache = preCalculateTaxes(orders);

        // Otimização 3: Stream paralelo para processar
        return orders.parallelStream()
            .map(order -> {
                OrderDTO dto = new OrderDTO();
                dto.setId(order.getId());
                dto.setCustomerName(order.getCustomer().getName());
                dto.setItemCount(order.getItems().size()); // Já carregado com JOIN FETCH
                dto.setTotalWithTax(taxCache.get(order.getId())); // Cache
                return dto;
            })
            .collect(Collectors.toList());
    }

    private Map<Long, BigDecimal> preCalculateTaxes(List<Order> orders) {
        // Calcular tax em batch
        return orders.stream()
            .collect(Collectors.toMap(
                Order::getId,
                order -> order.getTotal().multiply(BigDecimal.valueOf(0.15))
            ));
    }
}
```

**Resultado:**

- **Antes:** P95 = 5.000ms (10k orders)
- **Depois:** P95 = 120ms (10k orders)
- **Ganho:** 97.6% mais rápido

#### 3. Detectar Memory Leak

**Cenário:** Heap usage aumenta continuamente, OutOfMemoryError após 2h

```java
// ❌ ANTES: Memory leak
@Service
public class CacheService {

    // Leak: Map cresce infinitamente
    private final Map<String, CachedOrder> cache = new HashMap<>();

    public CachedOrder getOrder(String orderId) {
        if (!cache.containsKey(orderId)) {
            Order order = orderRepository.findById(orderId).orElseThrow();
            cache.put(orderId, new CachedOrder(order));
        }
        return cache.get(orderId);
    }
}
```

**Profiling com JProfiler:**

1. Memory View → Biggest Objects
2. Ver `HashMap` com 500MB
3. GC Roots → `CacheService.cache` nunca é limpo

```java
// ✅ DEPOIS: Usar cache com eviction
@Service
public class CacheService {

    private final Cache<String, CachedOrder> cache;

    public CacheService() {
        this.cache = Caffeine.newBuilder()
            .maximumSize(1000)
            .expireAfterWrite(Duration.ofMinutes(10))
            .recordStats()
            .build();
    }

    public CachedOrder getOrder(String orderId) {
        return cache.get(orderId, key -> {
            Order order = orderRepository.findById(key).orElseThrow();
            return new CachedOrder(order);
        });
    }
}
```

#### 4. Detectar Thread Contention

```java
// ❌ ANTES: Lock contention
@Service
public class CounterService {

    private final Map<String, AtomicLong> counters = new HashMap<>();

    // Synchronized em método inteiro causa contenção
    public synchronized void increment(String key) {
        counters.computeIfAbsent(key, k -> new AtomicLong(0))
            .incrementAndGet();
    }

    public synchronized long get(String key) {
        return counters.getOrDefault(key, new AtomicLong(0)).get();
    }
}
```

**Profiling:**

- Threads View → 50 threads bloqueadas em `increment()`
- Lock contention graph → 80% wait time

```java
// ✅ DEPOIS: ConcurrentHashMap
@Service
public class CounterService {

    private final ConcurrentMap<String, LongAdder> counters = new ConcurrentHashMap<>();

    public void increment(String key) {
        counters.computeIfAbsent(key, k -> new LongAdder())
            .increment();
    }

    public long get(String key) {
        LongAdder adder = counters.get(key);
        return adder != null ? adder.sum() : 0L;
    }
}
```

### ✅ Critério de Sucesso

- ✅ CPU hotspots identificados (métodos que consomem > 10% CPU)
- ✅ Memory leaks detectados (heap dump analysis)
- ✅ Thread contention identificado (lock graphs)
- ✅ Código otimizado com ganho mensurável (> 50% melhoria)
- ✅ Before/After comparado com benchmarks

### ⚠️ Pitfalls

- ❌ **Profiling em prod sem sampling:** Overhead alto
- ❌ **Otimizar código que não é hotspot:** Perda de tempo
- ❌ **Não medir antes/depois:** Não sabe se otimizou
- ❌ **Premature optimization:** Otimizar antes de profiling

### 🚀 Extensão

1. **Async Profiler:** Profiling com overhead quase zero
2. **Flame Graphs:** Visualizar call stacks
3. **Allocation Profiling:** Ver onde objetos são criados

---

## ⚡ Exercício 2: Microbenchmarks com JMH

### 🎯 Objetivo

Criar **microbenchmarks científicos** para comparar **algoritmos** e **estruturas de dados** com precisão.

### 📖 Contexto

Você precisa escolher entre `ArrayList` vs `LinkedList`, `HashMap` vs `ConcurrentHashMap`, ou qual algoritmo de ordenação usar.

### 🛠️ Passos

#### 1. Configurar JMH

```xml
<dependency>
    <groupId>org.openjdk.jmh</groupId>
    <artifactId>jmh-core</artifactId>
    <version>1.37</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.openjdk.jmh</groupId>
    <artifactId>jmh-generator-annprocess</artifactId>
    <version>1.37</version>
    <scope>test</scope>
</dependency>
```

#### 2. Benchmark: ArrayList vs LinkedList

```java
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@State(Scope.Thread)
@Warmup(iterations = 3, time = 1)
@Measurement(iterations = 5, time = 1)
@Fork(1)
public class ListBenchmark {

    @Param({"10", "100", "1000", "10000"})
    private int size;

    private List<Integer> arrayList;
    private List<Integer> linkedList;

    @Setup
    public void setup() {
        arrayList = new ArrayList<>();
        linkedList = new LinkedList<>();

        for (int i = 0; i < size; i++) {
            arrayList.add(i);
            linkedList.add(i);
        }
    }

    @Benchmark
    public int arrayListGet() {
        // Random access
        return arrayList.get(size / 2);
    }

    @Benchmark
    public int linkedListGet() {
        return linkedList.get(size / 2);
    }

    @Benchmark
    public void arrayListAdd() {
        arrayList.add(999);
        arrayList.remove(arrayList.size() - 1);
    }

    @Benchmark
    public void linkedListAdd() {
        linkedList.add(999);
        linkedList.remove(linkedList.size() - 1);
    }
}
```

**Executar:**

```bash
mvn clean package
java -jar target/benchmarks.jar ListBenchmark
```

**Resultados:**

```
Benchmark                      (size)  Mode  Cnt    Score    Error  Units
ListBenchmark.arrayListGet         10  avgt    5    2.345 ±  0.123  ns/op
ListBenchmark.linkedListGet        10  avgt    5   15.678 ±  1.234  ns/op
ListBenchmark.arrayListGet       1000  avgt    5    2.456 ±  0.234  ns/op
ListBenchmark.linkedListGet      1000  avgt    5  502.345 ± 23.456  ns/op

# Conclusão: ArrayList é 200x mais rápido para random access
```

#### 3. Benchmark: Serialização JSON

```java
@BenchmarkMode(Mode.Throughput)
@OutputTimeUnit(TimeUnit.SECONDS)
@State(Scope.Thread)
public class JsonSerializationBenchmark {

    private ObjectMapper jacksonMapper;
    private Gson gson;
    private Order order;

    @Setup
    public void setup() {
        jacksonMapper = new ObjectMapper();
        gson = new Gson();

        order = new Order();
        order.setId("ORDER-123");
        order.setItems(createItems(100));
    }

    @Benchmark
    public String jacksonSerialize() throws Exception {
        return jacksonMapper.writeValueAsString(order);
    }

    @Benchmark
    public String gsonSerialize() {
        return gson.toJson(order);
    }

    @Benchmark
    public Order jacksonDeserialize() throws Exception {
        String json = jacksonMapper.writeValueAsString(order);
        return jacksonMapper.readValue(json, Order.class);
    }

    @Benchmark
    public Order gsonDeserialize() {
        String json = gson.toJson(order);
        return gson.fromJson(json, Order.class);
    }
}
```

**Resultados:**

```
Benchmark                                Mode  Cnt      Score       Error  Units
JsonSerializationBenchmark.jacksonSerialize    thrpt    5  25000.123 ±  1234.567  ops/s
JsonSerializationBenchmark.gsonSerialize       thrpt    5  18000.456 ±  2345.678  ops/s

# Conclusão: Jackson é 38% mais rápido que Gson
```

#### 4. Benchmark: Validação com @Valid vs Manual

```java
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MICROSECONDS)
@State(Scope.Thread)
public class ValidationBenchmark {

    private Validator validator;
    private OrderRequest validRequest;
    private OrderRequest invalidRequest;

    @Setup
    public void setup() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();

        validRequest = createValidRequest();
        invalidRequest = createInvalidRequest();
    }

    @Benchmark
    public Set<ConstraintViolation<OrderRequest>> beanValidation() {
        return validator.validate(validRequest);
    }

    @Benchmark
    public List<String> manualValidation() {
        List<String> errors = new ArrayList<>();

        if (validRequest.getItems() == null || validRequest.getItems().isEmpty()) {
            errors.add("Items cannot be empty");
        }

        if (validRequest.getTotalAmount() == null ||
            validRequest.getTotalAmount().compareTo(BigDecimal.ZERO) <= 0) {
            errors.add("Total amount must be positive");
        }

        return errors;
    }
}
```

**Resultados:**

```
Benchmark                              Mode  Cnt    Score   Error  Units
ValidationBenchmark.beanValidation     avgt    5   45.123 ± 2.345  μs/op
ValidationBenchmark.manualValidation   avgt    5    2.456 ± 0.123  μs/op

# Conclusão: Validação manual é 18x mais rápida, mas perde features
```

#### 5. Testar Benchmarks

```java
class BenchmarkTest {

    @Test
    void shouldRunBenchmark() throws Exception {
        // Executar benchmark programaticamente
        Options opt = new OptionsBuilder()
            .include(ListBenchmark.class.getSimpleName())
            .warmupIterations(1)
            .measurementIterations(1)
            .forks(1)
            .build();

        Collection<RunResult> results = new Runner(opt).run();

        // Verificar que não houve erros
        assertThat(results).isNotEmpty();

        // Comparar resultados
        RunResult arrayResult = results.stream()
            .filter(r -> r.getParams().getBenchmark().contains("arrayListGet"))
            .findFirst()
            .orElseThrow();

        RunResult linkedResult = results.stream()
            .filter(r -> r.getParams().getBenchmark().contains("linkedListGet"))
            .findFirst()
            .orElseThrow();

        // ArrayList deve ser mais rápido
        assertThat(arrayResult.getPrimaryResult().getScore())
            .isLessThan(linkedResult.getPrimaryResult().getScore());
    }
}
```

### ✅ Critério de Sucesso

- ✅ Benchmarks com warmup adequado (3+ iterações)
- ✅ Múltiplas medições (5+ iterações)
- ✅ Parâmetros variados (@Param para testar tamanhos)
- ✅ Comparação entre alternativas (ArrayList vs LinkedList)
- ✅ Resultados documentados com conclusões

### ⚠️ Pitfalls

- ❌ **Sem warmup:** JIT não otimizou ainda
- ❌ **Poucas iterações:** Resultados instáveis
- ❌ **Dead code elimination:** JVM otimiza código não usado
- ❌ **Comparar tempos absolutos:** Varia por máquina, usar ratios

### 🚀 Extensão

1. **Profiling dentro de benchmark:** Ver flamegraphs
2. **GC logs:** Analisar pressão de memória
3. **Blackhole.consume():** Prevenir DCE

---

## 🗄️ Exercício 3: Otimização de Queries SQL

### 🎯 Objetivo

Identificar e otimizar **queries lentas** usando **EXPLAIN**, **índices** e **reescrita de queries**.

### 📖 Contexto

Query levando 5s para retornar 100 registros. Banco tem 1M de orders.

### 🛠️ Passos

#### 1. Identificar Queries Lentas

```yaml
# application.yml - Habilitar query logging
spring:
  jpa:
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        use_sql_comments: true
logging:
  level:
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
```

**Slow Query Log (MySQL):**

```sql
-- my.cnf
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1  -- Queries > 1s
log_queries_not_using_indexes = 1
```

#### 2. Analisar com EXPLAIN

```java
// ❌ ANTES: Query lenta
@Query("SELECT o FROM Order o WHERE o.customer.email = :email AND o.status = :status")
List<Order> findByCustomerEmailAndStatus(String email, OrderStatus status);
```

**EXPLAIN:**

```sql
EXPLAIN SELECT *
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE c.email = 'user@example.com' AND o.status = 'COMPLETED';

+----+-------------+-------+------+---------------+------+---------+------+--------+-------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows   | Extra       |
+----+-------------+-------+------+---------------+------+---------+------+--------+-------------+
|  1 | SIMPLE      | c     | ALL  | NULL          | NULL | NULL    | NULL | 500000 | Using where |
|  1 | SIMPLE      | o     | ALL  | NULL          | NULL | NULL    | NULL | 1000000| Using where |
+----+-------------+-------+------+---------------+------+---------+------+--------+-------------+

-- Problema: Full table scan em 1.5M registros (type=ALL)
```

#### 3. Criar Índices

```sql
-- Criar índice composto
CREATE INDEX idx_customer_email ON customers(email);
CREATE INDEX idx_order_status_customer ON orders(status, customer_id);

-- Verificar índices existentes
SHOW INDEX FROM orders;
```

**EXPLAIN depois:**

```sql
EXPLAIN SELECT *
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE c.email = 'user@example.com' AND o.status = 'COMPLETED';

+----+-------------+-------+-------+---------------------------+--------------+---------+-------+------+-------------+
| id | select_type | table | type  | possible_keys             | key          | key_len | ref   | rows | Extra       |
+----+-------------+-------+-------+---------------------------+--------------+---------+-------+------+-------------+
|  1 | SIMPLE      | c     | ref   | idx_customer_email        | idx_cust...  | 255     | const |    1 | Using index |
|  1 | SIMPLE      | o     | ref   | idx_order_status_customer | idx_ord...   | 264     | const |   10 | NULL        |
+----+-------------+-------+-------+---------------------------+--------------+---------+-------+------+-------------+

-- Resultado: Apenas 11 registros escaneados (was 1.5M)
```

**Performance:**

- **Antes:** 5.234s
- **Depois:** 0.012s
- **Ganho:** 436x mais rápido

#### 4. Evitar SELECT \*

```java
// ❌ ANTES: Traz todos os campos
@Query("SELECT o FROM Order o WHERE o.id = :id")
Order findById(String id);

// ✅ DEPOIS: Projection com campos necessários
@Query("SELECT new com.example.OrderSummaryDTO(o.id, o.status, o.totalAmount) " +
       "FROM Order o WHERE o.id = :id")
OrderSummaryDTO findSummaryById(String id);
```

#### 5. Otimizar JOINs

```java
// ❌ ANTES: Cartesian product
@Query("SELECT o FROM Order o, Customer c WHERE o.customer.id = c.id")
List<Order> findAllWithCustomers(); // Gera CROSS JOIN

// ✅ DEPOIS: JOIN explícito
@Query("SELECT o FROM Order o JOIN FETCH o.customer")
List<Order> findAllWithCustomers();
```

#### 6. Usar Covering Index

```sql
-- Query comum
SELECT order_id, total_amount, status
FROM orders
WHERE customer_id = 123 AND status = 'COMPLETED';

-- Covering index: Todas as colunas do SELECT estão no índice
CREATE INDEX idx_covering ON orders(customer_id, status, order_id, total_amount);

-- EXPLAIN mostra "Using index" (não precisa acessar tabela)
```

### ✅ Critério de Sucesso

- ✅ Slow queries identificadas (> 1s)
- ✅ EXPLAIN mostra uso de índices (type = ref/range, not ALL)
- ✅ Índices criados para colunas de filtro (WHERE, JOIN, ORDER BY)
- ✅ Query reescrita elimina full table scans
- ✅ Performance melhorou > 10x

### ⚠️ Pitfalls

- ❌ **Muitos índices:** Degradam INSERT/UPDATE
- ❌ **Índices não usados:** EXPLAIN mostra NULL em key
- ❌ **Função na coluna:** `WHERE YEAR(created_at) = 2025` não usa índice
- ❌ **OR em colunas diferentes:** Pode não usar índice

### 🚀 Extensão

1. **Partitioning:** Dividir tabela grande por mês
2. **Materialized Views:** Pré-calcular agregações
3. **Query rewrite:** Transformar OR em UNION

---

## 🔁 Exercício 4: Detectar e Corrigir N+1 Queries

### 🎯 Objetivo

Detectar **N+1 queries** com **Hibernate Statistics** e corrigir com **JOIN FETCH** ou **@EntityGraph**.

### 📖 Contexto

Endpoint retorna 100 orders. Você vê 101 queries no log (1 para orders + 100 para items).

### 🛠️ Passos

#### 1. Habilitar Hibernate Statistics

```yaml
# application.yml
spring:
  jpa:
    properties:
      hibernate:
        generate_statistics: true
        session:
          events:
            log:
              LOG_QUERIES_SLOWER_THAN_MS: 10
logging:
  level:
    org.hibernate.stat: DEBUG
```

#### 2. Reproduzir N+1

```java
// ❌ CÓDIGO COM N+1
@Entity
public class Order {
    @Id
    private String id;

    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    private List<OrderItem> items;
}

@Service
public class OrderService {

    public List<OrderDTO> getAllOrders() {
        List<Order> orders = orderRepository.findAll(); // 1 query

        return orders.stream()
            .map(order -> {
                OrderDTO dto = new OrderDTO();
                dto.setId(order.getId());
                dto.setItemCount(order.getItems().size()); // N queries!
                return dto;
            })
            .collect(Collectors.toList());
    }
}
```

**Log mostra:**

```sql
-- Query 1: Buscar orders
SELECT * FROM orders;

-- Query 2-101: Para cada order, buscar items
SELECT * FROM order_items WHERE order_id = 'ORDER-1';
SELECT * FROM order_items WHERE order_id = 'ORDER-2';
...
SELECT * FROM order_items WHERE order_id = 'ORDER-100';

-- Hibernate Statistics
StatisticsImpl[queries executed=101, time=2345ms]
```

#### 3. Solução 1: JOIN FETCH

```java
// ✅ SOLUÇÃO 1: JOIN FETCH
@Repository
public interface OrderRepository extends JpaRepository<Order, String> {

    @Query("SELECT DISTINCT o FROM Order o LEFT JOIN FETCH o.items")
    List<Order> findAllWithItems();
}

@Service
public class OrderService {

    public List<OrderDTO> getAllOrders() {
        List<Order> orders = orderRepository.findAllWithItems(); // 1 query apenas!

        return orders.stream()
            .map(order -> {
                OrderDTO dto = new OrderDTO();
                dto.setId(order.getId());
                dto.setItemCount(order.getItems().size());
                return dto;
            })
            .collect(Collectors.toList());
    }
}
```

**Query gerada:**

```sql
SELECT DISTINCT o.*, i.*
FROM orders o
LEFT JOIN order_items i ON o.id = i.order_id;

-- Hibernate Statistics
StatisticsImpl[queries executed=1, time=45ms]
```

#### 4. Solução 2: @EntityGraph

```java
// ✅ SOLUÇÃO 2: @EntityGraph
@Repository
public interface OrderRepository extends JpaRepository<Order, String> {

    @EntityGraph(attributePaths = {"items", "customer"})
    List<Order> findAll();
}
```

#### 5. Solução 3: Batch Fetching

```java
@Entity
public class Order {

    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    @BatchSize(size = 10) // Buscar items de 10 orders por vez
    private List<OrderItem> items;
}
```

**Queries geradas:**

```sql
-- Query 1: Buscar orders
SELECT * FROM orders;

-- Queries 2-11: Buscar items em batches de 10
SELECT * FROM order_items WHERE order_id IN ('ORDER-1', ..., 'ORDER-10');
SELECT * FROM order_items WHERE order_id IN ('ORDER-11', ..., 'ORDER-20');
...

-- Hibernate Statistics
StatisticsImpl[queries executed=11, time=150ms]  -- Foi 101, agora 11
```

#### 6. Detectar N+1 em Testes

```java
@SpringBootTest
class N1QueryTest {

    @Autowired
    private OrderService orderService;

    @Autowired
    private EntityManagerFactory emf;

    @Test
    void shouldNotHaveN1Queries() {
        // Arrange
        createTestOrders(100);

        Statistics stats = emf.unwrap(SessionFactory.class).getStatistics();
        stats.clear();

        // Act
        orderService.getAllOrders();

        // Assert
        long queryCount = stats.getPrepareStatementCount();
        assertThat(queryCount)
            .as("Should use JOIN FETCH to avoid N+1")
            .isLessThanOrEqualTo(1); // Apenas 1 query!
    }
}
```

### ✅ Critério de Sucesso

- ✅ Hibernate Statistics habilitado
- ✅ N+1 detectado (query count > expected)
- ✅ JOIN FETCH ou @EntityGraph aplicado
- ✅ Query count reduzido para 1 (ou batch size)
- ✅ Performance melhorou > 10x

### ⚠️ Pitfalls

- ❌ **DISTINCT esquecido:** Duplicatas no result
- ❌ **MultipleBagFetchException:** Múltiplos JOIN FETCH de listas
- ❌ **Fetch desnecessário:** Traz dados não usados
- ❌ **Cartesian product:** JOIN FETCH em 2+ coleções

### 🚀 Extensão

1. **@NamedEntityGraph:** Reutilizar entity graphs
2. **Spring Data Projections:** Buscar apenas campos necessários
3. **Blaze Persistence:** Entity Views com fetch otimizado

---

## 🚀 Exercício 5: Caching Estratégico com Redis

### 🎯 Objetivo

Implementar **cache distribuído** com **Redis** usando **estratégias adequadas** (Cache-Aside, Write-Through, Write-Behind).

### 📖 Contexto

API de catálogo de produtos com 10k req/s. Banco não aguenta carga. Cache hit ratio = 0%.

### 🛠️ Passos

#### 1. Configurar Redis

```yaml
# docker-compose.yml
version: "3.8"
services:
  redis:
    image: redis:7.2-alpine
    ports:
      - "6379:6379"
    command: redis-server --maxmemory 512mb --maxmemory-policy allkeys-lru
```

```yaml
# application.yml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      timeout: 2000ms
  cache:
    type: redis
    redis:
      time-to-live: 600000 # 10 minutos
      cache-null-values: false
```

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

#### 2. Estratégia 1: Cache-Aside (Lazy Loading)

```java
@Service
@Slf4j
public class ProductService {

    private final ProductRepository repository;
    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;

    // Cache-Aside: Aplicação gerencia cache
    public Product getProduct(String productId) {
        // 1. Tentar buscar no cache
        String cacheKey = "product:" + productId;
        String cached = redisTemplate.opsForValue().get(cacheKey);

        if (cached != null) {
            log.info("Cache HIT for product {}", productId);
            return objectMapper.readValue(cached, Product.class);
        }

        log.info("Cache MISS for product {}", productId);

        // 2. Buscar no banco
        Product product = repository.findById(productId)
            .orElseThrow(() -> new NotFoundException("Product not found"));

        // 3. Armazenar no cache
        redisTemplate.opsForValue().set(
            cacheKey,
            objectMapper.writeValueAsString(product),
            Duration.ofMinutes(10)
        );

        return product;
    }

    // Invalidar cache ao atualizar
    public Product updateProduct(String productId, ProductRequest request) {
        Product product = repository.findById(productId).orElseThrow();
        product.setName(request.getName());
        product.setPrice(request.getPrice());

        Product updated = repository.save(product);

        // Invalidar cache
        redisTemplate.delete("product:" + productId);

        return updated;
    }
}
```

#### 3. Estratégia 2: Spring Cache Abstraction

```java
@Service
@CacheConfig(cacheNames = "products")
public class ProductService {

    @Cacheable(key = "#productId", unless = "#result == null")
    public Product getProduct(String productId) {
        log.info("Fetching from database: {}", productId);
        return repository.findById(productId).orElseThrow();
    }

    @CachePut(key = "#productId")
    public Product updateProduct(String productId, ProductRequest request) {
        Product product = repository.findById(productId).orElseThrow();
        product.setName(request.getName());
        return repository.save(product);
    }

    @CacheEvict(key = "#productId")
    public void deleteProduct(String productId) {
        repository.deleteById(productId);
    }

    @CacheEvict(allEntries = true)
    public void clearCache() {
        log.info("Clearing all product cache");
    }
}
```

#### 4. Estratégia 3: Cache com Padrão Cache-Aside + Fallback

```java
@Service
public class ResilientProductService {

    @Cacheable(value = "products", key = "#productId")
    public Product getProduct(String productId) {
        try {
            return repository.findById(productId).orElseThrow();
        } catch (Exception e) {
            log.error("Database error, checking stale cache", e);

            // Fallback: Tentar cache stale (expired)
            String staleKey = "product:stale:" + productId;
            String stale = redisTemplate.opsForValue().get(staleKey);

            if (stale != null) {
                log.warn("Returning stale cached data for {}", productId);
                return objectMapper.readValue(stale, Product.class);
            }

            throw e;
        }
    }

    // Background job para aquecer cache
    @Scheduled(fixedDelay = 60000) // A cada 1min
    public void warmupCache() {
        List<String> popularProducts = List.of("PROD-1", "PROD-2", "PROD-3");

        popularProducts.forEach(productId -> {
            try {
                getProduct(productId); // Força cache hit
            } catch (Exception e) {
                log.error("Failed to warmup cache for {}", productId, e);
            }
        });
    }
}
```

#### 5. Monitorar Cache Metrics

```java
@Component
public class CacheMetrics {

    private final MeterRegistry registry;
    private final CacheManager cacheManager;

    @Scheduled(fixedDelay = 5000)
    public void recordCacheMetrics() {
        Cache cache = cacheManager.getCache("products");

        if (cache instanceof RedisCache redisCache) {
            RedisCacheMetrics metrics = redisCache.getMetrics();

            registry.gauge("cache.size", metrics.getSize());
            registry.gauge("cache.hit.ratio", metrics.getHitRatio());

            log.info("Cache metrics: size={}, hitRatio={}",
                metrics.getSize(),
                metrics.getHitRatio()
            );
        }
    }
}
```

#### 6. Testar Cache

```java
@SpringBootTest
@Testcontainers
class CacheTest {

    @Container
    static GenericContainer<?> redis = new GenericContainer<>("redis:7.2-alpine")
        .withExposedPorts(6379);

    @DynamicPropertySource
    static void redisProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.data.redis.host", redis::getHost);
        registry.add("spring.data.redis.port", redis::getFirstMappedPort);
    }

    @Autowired
    private ProductService productService;

    @Autowired
    private ProductRepository repository;

    @Test
    void shouldCacheProduct_onFirstAccess() {
        // Arrange
        Product product = repository.save(createProduct("PROD-1"));

        // Act - Primeira chamada (cache miss)
        long start1 = System.currentTimeMillis();
        Product result1 = productService.getProduct("PROD-1");
        long time1 = System.currentTimeMillis() - start1;

        // Act - Segunda chamada (cache hit)
        long start2 = System.currentTimeMillis();
        Product result2 = productService.getProduct("PROD-1");
        long time2 = System.currentTimeMillis() - start2;

        // Assert
        assertThat(result1).isEqualTo(result2);
        assertThat(time2).isLessThan(time1 / 10); // Cache é 10x+ mais rápido
    }

    @Test
    void shouldEvictCache_onUpdate() {
        // Arrange
        Product product = repository.save(createProduct("PROD-1"));
        productService.getProduct("PROD-1"); // Aquecer cache

        // Act - Atualizar produto (deve invalidar cache)
        productService.updateProduct("PROD-1", new ProductRequest("New Name", 99.99));

        // Assert - Próxima chamada deve buscar do banco
        Product updated = productService.getProduct("PROD-1");
        assertThat(updated.getName()).isEqualTo("New Name");
    }
}
```

### ✅ Critério de Sucesso

- ✅ Redis configurado e conectado
- ✅ Cache hit ratio > 80% para dados frequentes
- ✅ TTL configurado (evitar dados stale)
- ✅ Cache invalidado ao atualizar/deletar
- ✅ Fallback para cache stale em caso de erro
- ✅ Métricas de cache monitoradas

### ⚠️ Pitfalls

- ❌ **Cache sem TTL:** Dados stale indefinidamente
- ❌ **Cache thundering herd:** Múltiplos threads recarregam cache simultaneamente
- ❌ **Cache de objetos grandes:** Overhead de serialização
- ❌ **Invalidação inconsistente:** Cache e DB desincronizados

### 🚀 Extensão

1. **Cache warming:** Pré-carregar cache no startup
2. **Cache stampede protection:** Usar locks (Redisson)
3. **Multi-level cache:** L1 (Caffeine local) + L2 (Redis distribuído)

---

## 📊 Checkpoint: Autoavaliação da Trilha Performance

### Nível Intermediário (41-70%)

- ⬜ Profiling básico com VisualVM
- ⬜ Identificar hotspots de CPU
- ⬜ Criar índices em colunas de filtro
- ⬜ Usar @Cacheable básico

### Nível Avançado (71-90%)

- ⬜ Detectar memory leaks com heap dumps
- ⬜ JMH benchmarks comparando alternativas
- ⬜ EXPLAIN queries e otimizar com índices
- ⬜ Detectar e corrigir N+1 queries
- ⬜ Cache distribuído com Redis
- ⬜ Monitorar cache hit ratio

### Nível Senior (91-100%)

- ⬜ Async Profiler com flame graphs
- ⬜ Allocation profiling
- ⬜ Covering indexes e query rewrite
- ⬜ Partitioning e materialized views
- ⬜ Multi-level caching (L1 + L2)
- ⬜ Cache stampede protection
- ⬜ Performance budgets em CI/CD

---

**Criado em:** 2025-11-15  
**Tempo Estimado:** 10-12 horas  
**Próxima Trilha:** [Segurança](trilhas/05-seguranca.md)
