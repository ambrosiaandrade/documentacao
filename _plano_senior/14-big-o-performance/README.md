# 📐 Fase 14: Big O Notation & Performance Analysis

> **Objetivo:** Dominar análise de complexidade algorítmica e técnicas de otimização de performance.

---

## 🎯 Overview

Esta fase oferece guia completo sobre:

- **Big O Notation:** Analisar complexidade de algoritmos (tempo e espaço)
- **Data Structures:** Escolher estrutura de dados correta (ArrayList vs LinkedList, HashMap vs TreeMap)
- **Algorithms:** Entender complexidade de algoritmos clássicos (sorting, searching, graphs)
- **Profiling:** Identificar bottlenecks com ferramentas (JProfiler, async-profiler, JFR)
- **Benchmarking:** Medir performance com JMH (evitar pitfalls como DCE, constant folding)
- **Memory Analysis:** Diagnosticar memory leaks com heap dumps e GC logs
- **Optimization:** Aplicar técnicas reais (N+1 fix, caching, parallel processing)

---

## 📚 Módulos

### 🎈 14.0 - Big O Para Crianças

**🎯 Para Quem?** Qualquer pessoa que quer entender Big O de forma simples e divertida!

**Conteúdo:**

- O que é Big O com analogias do dia a dia
- Todos os tipos de complexidade explicados com histórias
- Corrida de algoritmos, mini-jogos, desenhos visuais
- Comparações práticas (livros, fila do sorvete, festa de aniversário)

**Quando Usar:**

- Primeiro contato com Big O (começar aqui!)
- Revisar conceitos de forma leve
- Explicar para alguém não-técnico

**[👉 Começar por aqui!](14.0-big-o-para-criancas.md)**

---

### 14.1 - Fundamentos de Big O

**Conteúdo:**

- Big O, Omega (Ω), Theta (Θ) notation
- Complexidades comuns: O(1), O(log n), O(n), O(n log n), O(n²), O(2ⁿ)
- Regras de simplificação (ignorar constantes, domínio)
- Análise passo a passo de algoritmos

**Código:**

```java
// Binary search: O(log n)
public int binarySearch(int[] sortedArray, int target) {
    int left = 0, right = sortedArray.length - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (sortedArray[mid] == target) return mid;
        else if (sortedArray[mid] < target) left = mid + 1;
        else right = mid - 1;
    }
    return -1;
}
// n=1.000.000 → ~20 comparações (log₂(1.000.000))
```

**Quando Usar:**

- Analisar performance de novo algoritmo
- Escolher entre múltiplas implementações
- Code review (identificar O(n²) em hot paths)

---

### 14.2 - Estruturas de Dados

**Conteúdo:**

- ArrayList vs LinkedList (get: O(1) vs O(n), add: O(1) vs O(1))
- HashMap vs TreeMap (get: O(1) vs O(log n), ordenação)
- HashSet vs TreeSet (add/contains: O(1) vs O(log n))
- PriorityQueue, ArrayDeque complexidades
- Tabelas comparativas de complexidade

**Código:**

```java
// Top K elementos com PriorityQueue: O(n log k)
public List<Integer> topK(int[] array, int k) {
    var minHeap = new PriorityQueue<Integer>(k);
    for (int num : array) {  // O(n)
        if (minHeap.size() < k) {
            minHeap.add(num);  // O(log k)
        } else if (num > minHeap.peek()) {
            minHeap.poll();
            minHeap.add(num);
        }
    }
    return new ArrayList<>(minHeap);
}
// vs Arrays.sort(): O(n log n)
// n=1.000.000, k=10: O(n log k) é 6x mais rápido
```

**Quando Usar:**

- Escolher estrutura de dados para novo feature
- Otimizar código existente (ArrayList.contains() → HashSet)
- Code review (verificar escolhas de estruturas)

---

### 14.3 - Algoritmos Clássicos

**Conteúdo:**

- Sorting: QuickSort (O(n log n) avg), MergeSort (O(n log n) worst), TimSort (Java default)
- Searching: Binary Search (O(log n)), variants (first occurrence, ceiling)
- Graphs: BFS (O(V+E)), DFS (O(V+E)), Dijkstra (O((V+E) log V))
- Dynamic Programming: Fibonacci (O(2ⁿ) → O(n) com memoization)

**Código:**

```java
// Fibonacci com memoization: O(n) tempo, O(n) espaço
public int fibMemo(int n, Map<Integer, Integer> memo) {
    if (n <= 1) return n;
    if (memo.containsKey(n)) return memo.get(n);

    int result = fibMemo(n - 1, memo) + fibMemo(n - 2, memo);
    memo.put(n, result);
    return result;
}
// n=40: Recursivo naive = 1000ms, Memoization = 1ms (1000x faster)
```

**Quando Usar:**

- Implementar algoritmo de sorting/searching
- Resolver problemas de grafo (pathfinding, shortest path)
- Entrevistas técnicas (LeetCode, HackerRank)

---

### 14.4 - Profiling Tools

**Conteúdo:**

- JProfiler: CPU profiling, memory profiling, thread profiling
- YourKit: CPU sampling, allocation recording
- async-profiler: Flame graphs, production profiling (<1% overhead)
- Java Flight Recorder (JFR): Built-in profiling, custom events

**Código:**

```bash
# async-profiler: Flame graph
./profiler.sh -d 60 -f flamegraph.html <PID>

# JFR: Recording
jcmd <PID> JFR.start duration=60s filename=recording.jfr
jmc recording.jfr  # Analisar com JDK Mission Control
```

**Quando Usar:**

- Identificar bottleneck de performance (qual método é lento?)
- Diagnosticar memory leak (qual objeto está acumulando?)
- Analisar lock contention (threads bloqueadas?)
- Production profiling (async-profiler, JFR)

---

### 14.5 - JMH Benchmarking

**Conteúdo:**

- Setup JMH (Maven, Gradle)
- Annotations: @Benchmark, @BenchmarkMode, @State, @Param
- Pitfalls: Dead Code Elimination, Constant Folding, Loop Unrolling, GC Interference
- Blackhole para evitar DCE
- Interpretar resultados (Score, Error, Percentis)

**Código:**

```java
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@State(Scope.Thread)
@Warmup(iterations = 3)
@Measurement(iterations = 5)
@Fork(2)
public class StringBenchmark {
    @Param({"10", "100", "1000"})
    private int iterations;

    @Benchmark
    public String stringConcat() {
        String result = "";
        for (int i = 0; i < iterations; i++) {
            result += "item" + i;  // O(n²)
        }
        return result;
    }

    @Benchmark
    public String stringBuilder() {
        var sb = new StringBuilder();
        for (int i = 0; i < iterations; i++) {
            sb.append("item").append(i);  // O(n)
        }
        return sb.toString();
    }
}
// n=1000: concat=5000μs, builder=10μs (500x faster)
```

**Quando Usar:**

- Comparar implementações (qual é mais rápida?)
- Validar otimização (benchmark antes/depois)
- Detectar regressões de performance (CI/CD)

---

### 14.6 - Memory Analysis

**Conteúdo:**

- Heap dumps: Capturar (jmap, jcmd, OOM), analisar (MAT)
- Shallow vs Retained Size
- Dominator Tree (quem "segura" memória?)
- GC Logs: Interpretar pausas, allocation rate, Old Gen growth
- Memory Leaks: Padrões comuns (static collections, listeners, ThreadLocal)
- Reference Types: Strong, Weak, Soft, Phantom

**Código:**

```java
// Memory leak: Cache sem eviction
@Service
public class CacheService {
    // ❌ HashMap nunca limpa = LEAK
    private final Map<String, byte[]> cache = new HashMap<>();

    public void cache(String key, byte[] data) {
        cache.put(key, data);  // Acumula indefinidamente
    }
}

// ✅ Fix: Caffeine com eviction
private final Cache<String, byte[]> cache = Caffeine.newBuilder()
    .maximumSize(1000)
    .expireAfterWrite(Duration.ofMinutes(10))
    .build();
```

**Quando Usar:**

- OutOfMemoryError (diagnosticar leak)
- GC pausas longas (analisar GC logs)
- Production memory issues (heap dump)
- Otimizar alocações (allocation profiling)

---

### 14.7 - Otimização Real

**Conteúdo:**

- Metodologia: Measure → Identify → Optimize → Measure → Validate
- Database: N+1 problem (JOIN FETCH), pagination, indexing
- Caching: Cache-Aside (Caffeine), invalidation, hit rate
- Parallel Processing: parallelStream(), CompletableFuture
- Network: Batch requests, compression
- Case Studies: API lenta (N+1 fix: 24x faster), Memory leak (EventBus)

**Código:**

```java
// N+1 problem fix
// ❌ Before: 1 + N queries
public List<OrderDto> getAllOrders() {
    List<Order> orders = orderRepository.findAll();  // 1 query
    return orders.stream()
        .map(order -> {
            User user = userRepository.findById(order.getUserId()).orElse(null);  // N queries
            return new OrderDto(order, user);
        })
        .collect(Collectors.toList());
}

// ✅ After: 2 queries (batch loading)
public List<OrderDto> getAllOrders() {
    List<Order> orders = orderRepository.findAll();  // 1 query

    Set<Long> userIds = orders.stream().map(Order::getUserId).collect(Collectors.toSet());
    Map<Long, User> usersMap = userRepository.findByIdIn(userIds).stream()
        .collect(Collectors.toMap(User::getId, u -> u));  // 1 query

    return orders.stream()
        .map(order -> new OrderDto(order, usersMap.get(order.getUserId())))
        .collect(Collectors.toList());
}
// n=1000: 2001 queries → 2 queries (100x faster)
```

**Quando Usar:**

- API com latência alta (> 1s)
- Database queries lentas (> 100ms)
- Memory leaks em produção
- Throughput baixo (< 100 req/s)

---

## 🔗 Integrações

### Com Outras Fases

| Fase            | Integração            | Exemplo                                      |
| --------------- | --------------------- | -------------------------------------------- |
| **08-Métricas** | Monitorar performance | Prometheus metrics (latency p99, throughput) |
| **12-Database** | Otimizar queries      | N+1 fix, indexing, pagination                |
| **13-Alertas**  | Alertar degradação    | Alert se latency p99 > threshold             |
| **03-Avançado** | Testes de performance | JMH em CI/CD, load tests                     |

### Ferramentas

| Ferramenta         | Uso                   | Overhead | Quando Usar               |
| ------------------ | --------------------- | -------- | ------------------------- |
| **JProfiler**      | CPU/Memory profiling  | 10-50%   | Development, deep dive    |
| **YourKit**        | Allocation recording  | 10-50%   | Development               |
| **async-profiler** | Flame graphs          | <1%      | Production profiling      |
| **JFR**            | Production monitoring | <1%      | Continuous profiling      |
| **JMH**            | Microbenchmarking     | N/A      | Comparar implementações   |
| **MAT**            | Heap dump analysis    | N/A      | Memory leak investigation |

---

## 📊 Métricas de Sucesso

### Performance Benchmarks

```java
// Baseline
Benchmark              Score     Units
API.getUsers           1000ms    latency p99
API.getUsers           10 req/s  throughput

// Target (após otimizações)
API.getUsers           100ms     latency p99  (10x improvement)
API.getUsers           200 req/s throughput   (20x improvement)
```

### Code Quality

```java
// Antes
public List<User> getActiveUsers() {
    return userRepository.findAll().stream()  // O(n) - 1M users
        .filter(u -> u.isActive())  // O(n)
        .collect(Collectors.toList());
}

// Depois (com análise Big O)
@Query("SELECT u FROM User u WHERE u.active = true")
List<User> findAllActive();  // O(k) onde k = # active users

public List<User> getActiveUsers() {
    return userRepository.findAllActive();  // Database faz filtro
}
// 10x mais rápido + menos memória
```

### Memory Efficiency

```
Before optimization:
- Heap usage: 4GB (90% utilization)
- GC pause: 500ms avg
- Allocation rate: 2GB/sec

After optimization:
- Heap usage: 1GB (25% utilization)
- GC pause: 50ms avg
- Allocation rate: 200MB/sec

10x less memory, 10x faster GC
```

---

## ✅ Checklist de Qualidade

### Big O Analysis

- [ ] Identificar complexidade de algoritmos críticos (hot paths)
- [ ] Documentar Big O em métodos complexos (comentários)
- [ ] Evitar O(n²) ou pior em hot paths
- [ ] Trade-offs tempo vs espaço documentados

### Data Structures

- [ ] ArrayList para acesso aleatório (get)
- [ ] LinkedList para inserções no início (addFirst)
- [ ] HashMap para O(1) lookup (vs TreeMap O(log n))
- [ ] PriorityQueue para top K (vs sorting O(n log n))

### Profiling

- [ ] Profiling regular em staging (JProfiler, YourKit)
- [ ] JFR habilitado em produção (continuous profiling)
- [ ] Flame graphs para identificar hot paths
- [ ] Baseline benchmarks antes de otimizar

### Benchmarking

- [ ] JMH para microbenchmarks (não System.nanoTime())
- [ ] Warmup suficiente (mínimo 3 iterations)
- [ ] Blackhole para evitar Dead Code Elimination
- [ ] @Param para testar múltiplos tamanhos

### Memory

- [ ] Heap dump em OOM (`-XX:+HeapDumpOnOutOfMemoryError`)
- [ ] GC logging habilitado em produção
- [ ] Monitorar Old Gen growth (leak detection)
- [ ] Evitar static collections sem bounded size
- [ ] Limpar ThreadLocal em thread pools

### Optimization

- [ ] Resolver N+1 queries (JOIN FETCH, batch loading)
- [ ] Pagination para listas grandes (> 100 items)
- [ ] Cache para dados read-heavy (Caffeine, Redis)
- [ ] Invalidar cache após updates
- [ ] Parallel processing para operações pesadas
- [ ] Compression para responses grandes (> 1KB)

---

## 🎯 Roadmap de Aprendizado

### Iniciante (1-2 semanas)

1. Estudar notação Big O (módulo 14.1)
2. Praticar análise de complexidade em código existente
3. Aprender diferenças ArrayList vs LinkedList, HashMap vs TreeMap (módulo 14.2)
4. Fazer exercícios de algoritmos clássicos (módulo 14.3)

### Intermediário (2-3 semanas)

5. Usar JProfiler/YourKit para profiling (módulo 14.4)
6. Criar benchmarks com JMH (módulo 14.5)
7. Analisar heap dumps com MAT (módulo 14.6)
8. Resolver N+1 problems em projetos reais (módulo 14.7)

### Avançado (3-4 semanas)

9. Production profiling com async-profiler, JFR (módulo 14.4)
10. Custom JFR events para rastreamento (módulo 14.4)
11. Detectar memory leaks com GC log analysis (módulo 14.6)
12. Otimizar aplicações end-to-end (case studies - módulo 14.7)

---

## 🏆 Exercícios Práticos

### Nível 1: Fundamentos

1. **Big O Analysis:** Identificar complexidade de 10 algoritmos (bubbleSort, binarySearch, etc.)
2. **Data Structures:** Benchmark ArrayList.add() vs LinkedList.add() com JMH
3. **Algorithms:** Implementar QuickSort e MergeSort, comparar performance

### Nível 2: Profiling

4. **JProfiler:** Identificar hot spots em aplicação Spring Boot
5. **async-profiler:** Gerar flame graph e interpretar bottlenecks
6. **JFR:** Criar custom events para rastrear operações críticas

### Nível 3: Optimization

7. **N+1 Fix:** Resolver N+1 problem em endpoint com JOIN FETCH
8. **Caching:** Implementar cache com Caffeine, medir hit rate
9. **Memory Leak:** Detectar e corrigir leak com heap dump (MAT)
10. **End-to-End:** Otimizar API de 5s para 500ms (profiling → fix → benchmark)

---

## 📚 Referências Essenciais

### Livros

- **Introduction to Algorithms (CLRS)** - Big O theory, algoritmos clássicos
- **Effective Java (Joshua Bloch)** - Performance best practices
- **Java Performance: The Definitive Guide** - Profiling, GC tuning
- **High Performance Java Persistence (Vlad Mihalcea)** - Database optimization

### Online

- [Big O Cheat Sheet](https://www.bigocheatsheet.com/) - Complexidades de estruturas e algoritmos
- [JMH Samples](https://github.com/openjdk/jmh/tree/master/jmh-samples) - Exemplos oficiais
- [Flame Graphs (Brendan Gregg)](https://www.brendangregg.com/flamegraphs.html) - Interpretação
- [Eclipse MAT](https://www.eclipse.org/mat/) - Memory analysis

### Ferramentas

- [JProfiler](https://www.ej-technologies.com/products/jprofiler/overview.html) - Trial 10 dias
- [YourKit](https://www.yourkit.com/) - Trial 15 dias
- [async-profiler](https://github.com/jvm-profiling-tools/async-profiler) - Open source
- [JMH](https://github.com/openjdk/jmh) - Open source

---

## 🔥 Dicas Finais

### DO's ✅

- **Profile antes de otimizar:** "Premature optimization is the root of all evil"
- **Medir sempre:** Baseline → Optimize → Measure → Validate
- **Documentar trade-offs:** "Otimizamos X, mas aumentou uso de memória em Y"
- **Usar JMH para benchmarks:** System.nanoTime() não é confiável
- **Flame graphs para quick insights:** Identifica hot paths rapidamente
- **GC logs em produção:** Detecta memory leaks cedo

### DON'Ts ❌

- **Não otimize sem dados:** Profiling primeiro!
- **Não ignore Big O:** O(n²) em hot path = problema garantido
- **Não confie em intuição:** Benchmarks revelam surpresas
- **Não negligencie memory:** Leaks causam OOM em produção
- **Não otimize tudo:** 20% do código = 80% do tempo (Pareto)
- **Não esqueça legibilidade:** Performance ≠ código ilegível

---

**Próximo:** [Fase 15 - Code Review](../15-code-review/)

---

## 📝 Changelog

- **2024-01:** Criação inicial da fase 14 (Big O & Performance)
- Módulos: 7 (14.1 a 14.7)
- Total: ~5.800 linhas
- Ferramentas: JProfiler, YourKit, async-profiler, JFR, JMH, MAT
