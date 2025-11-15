# Guia Completo: HackerRank Java Backend - Aprovação Garantida

**Objetivo:** Preparação focada para provas técnicas HackerRank de Java Backend com estratégias, padrões de código e recursos práticos.

**Última Atualização:** 2025-11-15  
**Tempo de Preparação:** 2-4 semanas (2h/dia)  
**Nível:** Pleno/Senior

---

## 📋 Índice

1. [Anatomia das Provas HackerRank](#1-anatomia-das-provas-hackerrank)
2. [Setup do Ambiente](#2-setup-do-ambiente)
3. [Estruturas de Dados Essenciais](#3-estruturas-de-dados-essenciais)
4. [Algoritmos Mais Cobrados](#4-algoritmos-mais-cobrados)
5. [Padrões de Código Rápido](#5-padrões-de-código-rápido)
6. [Java Moderno (Streams, Records, Optionals)](#6-java-moderno)
7. [REST API e Spring Boot](#7-rest-api-e-spring-boot)
8. [SQL e Banco de Dados](#8-sql-e-banco-de-dados)
9. [Complexidade e Otimização](#9-complexidade-e-otimização)
10. [Exercícios Práticos por Categoria](#10-exercícios-práticos)
11. [Checklist 24h Antes da Prova](#11-checklist-24h-antes)
12. [Recursos e Links](#12-recursos-e-links)

---

## 1️⃣ Anatomia das Provas HackerRank

### Tipos de Questões

**A. Algoritmos e Estruturas de Dados (60%)**

- Manipulação de Arrays/Lists
- String Processing
- Hash Tables (HashMap/HashSet)
- Sorting e Searching
- Two Pointers / Sliding Window
- Recursão e Backtracking

**B. Java Específico (20%)**

- Collections Framework
- Streams API
- Exception Handling
- Multithreading Básico
- I/O (File, Console)

**C. Backend/Spring Boot (15%)**

- REST Controllers
- Service Layer
- Repository/DAO
- DTOs e Mapeamento
- Exception Handling Global

**D. SQL (5%)**

- JOINs (INNER, LEFT)
- Agregações (GROUP BY, HAVING)
- Subqueries
- Window Functions (menos comum)

### Formato Típico

```
Duração: 60-90 minutos
Questões: 3-5 problemas
Pontuação: 100 pontos total
Ambiente: Editor online (sem IDE)
Linguagens: Java 8, 11, 17 (geralmente)

Distribuição:
- 1 problema fácil (warmup) - 15-20 pontos
- 2 problemas médios (core) - 25-35 pontos cada
- 1 problema difícil (challenge) - 30-40 pontos
```

### O Que É Avaliado

✅ **Corretude:** Todos os test cases passam  
✅ **Eficiência:** Complexidade temporal adequada  
✅ **Legibilidade:** Código limpo (nomes, estrutura)  
✅ **Edge Cases:** Tratamento de entradas vazias, nulas, grandes  
❌ **Não importa:** Comentários excessivos, design patterns complexos

---

## 2️⃣ Setup do Ambiente

### Editor Local para Prática

**Recomendação:** IntelliJ IDEA Community (grátis)

```bash
# Download
https://www.jetbrains.com/idea/download/

# Plugins essenciais
- Key Promoter X (aprende atalhos)
- Rainbow Brackets (visualiza parenteses)
```

### Template de Código Rápido

Crie este template para iniciar rápido:

```java
import java.io.*;
import java.util.*;
import java.util.stream.*;

public class Solution {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        // Leitura rápida
        int n = Integer.parseInt(br.readLine());
        String[] tokens = br.readLine().split(" ");
        int[] arr = Arrays.stream(tokens).mapToInt(Integer::parseInt).toArray();

        // Solução
        int result = solve(arr);

        // Output
        System.out.println(result);
    }

    public static int solve(int[] arr) {
        // Sua lógica aqui
        return 0;
    }
}
```

### Atalhos Essenciais (IntelliJ)

| Atalho               | Ação                      |
| -------------------- | ------------------------- |
| `psvm` + Tab         | `public static void main` |
| `sout` + Tab         | `System.out.println()`    |
| `fori` + Tab         | For loop com índice       |
| `iter` + Tab         | Enhanced for loop         |
| `Ctrl + Alt + V`     | Extrair variável          |
| `Ctrl + Alt + M`     | Extrair método            |
| `Alt + Enter`        | Quick fix                 |
| `Ctrl + Shift + F10` | Run                       |

---

## 3️⃣ Estruturas de Dados Essenciais

### Array/ArrayList

**Quando usar:** Acesso por índice, ordem importa

```java
// Criação
int[] arr = new int[n];
List<Integer> list = new ArrayList<>();

// Operações O(1)
arr[i] = value;           // Set
int x = arr[i];           // Get
list.add(value);          // Append

// Operações O(n)
Arrays.sort(arr);         // Sort
Collections.sort(list);
list.contains(x);         // Contains

// Conversões úteis
int[] arr = list.stream().mapToInt(i -> i).toArray();
List<Integer> list = Arrays.stream(arr).boxed().collect(Collectors.toList());
```

**📹 Vídeo:** [ArrayList Deep Dive - Coding with John](https://www.youtube.com/watch?v=NbYgm0r7u6o)

### HashMap/HashSet

**Quando usar:** Lookup rápido O(1), eliminar duplicatas

```java
// HashMap - Mapear chave → valor
Map<String, Integer> map = new HashMap<>();
map.put("apple", 5);
map.getOrDefault("banana", 0);
map.containsKey("apple");
map.remove("apple");

// Iterar
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    String key = entry.getKey();
    Integer value = entry.getValue();
}

// HashSet - Valores únicos
Set<Integer> set = new HashSet<>();
set.add(5);
set.contains(5);  // O(1)
set.size();

// Problema clássico: Two Sum
public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> map = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (map.containsKey(complement)) {
            return new int[] { map.get(complement), i };
        }
        map.put(nums[i], i);
    }
    return new int[] {};
}
```

**📹 Vídeo:** [HashMap Internals - Defog Tech](https://www.youtube.com/watch?v=c3RVW3KGIIE)  
**🔗 Link:** [HackerRank - Hash Tables Tutorial](https://www.hackerrank.com/domains/tutorials/cracking-the-coding-interview)

### LinkedList

**Quando usar:** Inserção/remoção frequente no início/meio

```java
// Criação
LinkedList<Integer> list = new LinkedList<>();

// Operações O(1) nas pontas
list.addFirst(1);
list.addLast(5);
list.removeFirst();
list.removeLast();

// Problema clássico: Reverse Linked List
class ListNode {
    int val;
    ListNode next;
    ListNode(int val) { this.val = val; }
}

public ListNode reverseList(ListNode head) {
    ListNode prev = null;
    ListNode current = head;

    while (current != null) {
        ListNode next = current.next;
        current.next = prev;
        prev = current;
        current = next;
    }
    return prev;
}
```

**📹 Vídeo:** [LinkedList Coding Interview - NeetCode](https://www.youtube.com/watch?v=G0_I-ZF0S38)

### Stack/Queue

**Stack (LIFO):** Parênteses balanceados, DFS, undo/redo

```java
// Stack
Stack<Integer> stack = new Stack<>();
stack.push(5);
int top = stack.pop();
int peek = stack.peek();  // Não remove
boolean empty = stack.isEmpty();

// Problema: Valid Parentheses
public boolean isValid(String s) {
    Stack<Character> stack = new Stack<>();
    Map<Character, Character> pairs = Map.of(')', '(', '}', '{', ']', '[');

    for (char c : s.toCharArray()) {
        if (pairs.containsValue(c)) {
            stack.push(c);
        } else if (stack.isEmpty() || stack.pop() != pairs.get(c)) {
            return false;
        }
    }
    return stack.isEmpty();
}
```

**Queue (FIFO):** BFS, processamento em ordem

```java
// Queue
Queue<Integer> queue = new LinkedList<>();
queue.offer(5);          // Add
int first = queue.poll(); // Remove
int peek = queue.peek();  // Não remove

// Priority Queue (Heap)
PriorityQueue<Integer> minHeap = new PriorityQueue<>();
PriorityQueue<Integer> maxHeap = new PriorityQueue<>(Collections.reverseOrder());

minHeap.offer(5);
int min = minHeap.poll();  // Remove menor
```

**📹 Vídeo:** [Stack and Queue - CS Dojo](https://www.youtube.com/watch?v=wjI1WNcIntg)

### TreeMap/TreeSet (Sorted)

**Quando usar:** Dados ordenados, range queries

```java
// TreeMap - Mantém chaves ordenadas
TreeMap<Integer, String> map = new TreeMap<>();
map.put(3, "three");
map.put(1, "one");
map.firstKey();  // 1
map.lastKey();   // 3

// TreeSet - Valores ordenados únicos
TreeSet<Integer> set = new TreeSet<>();
set.add(5);
set.add(1);
set.first();  // 1
set.last();   // 5
set.ceiling(3);  // Menor valor >= 3
set.floor(3);    // Maior valor <= 3
```

**🔗 Link:** [Java Collections Cheat Sheet](https://www.baeldung.com/java-collections)

---

## 4️⃣ Algoritmos Mais Cobrados

### A. Two Pointers

**Problema Tipo:** Encontrar par, remover duplicatas, palindrome

```java
// Exemplo 1: Remove Duplicates from Sorted Array
public int removeDuplicates(int[] nums) {
    if (nums.length == 0) return 0;

    int slow = 0;
    for (int fast = 1; fast < nums.length; fast++) {
        if (nums[fast] != nums[slow]) {
            slow++;
            nums[slow] = nums[fast];
        }
    }
    return slow + 1;
}

// Exemplo 2: Container With Most Water
public int maxArea(int[] height) {
    int left = 0, right = height.length - 1;
    int maxArea = 0;

    while (left < right) {
        int area = Math.min(height[left], height[right]) * (right - left);
        maxArea = Math.max(maxArea, area);

        if (height[left] < height[right]) {
            left++;
        } else {
            right--;
        }
    }
    return maxArea;
}
```

**📹 Vídeo:** [Two Pointers Technique - NeetCode](https://www.youtube.com/watch?v=cQ1Oz4ckceM)  
**🔗 Pratique:** [HackerRank - Two Pointers](https://www.hackerrank.com/domains/algorithms?filters%5Bsubdomains%5D%5B%5D=arrays)

### B. Sliding Window

**Problema Tipo:** Subarray/substring de tamanho fixo ou variável

```java
// Exemplo 1: Maximum Sum Subarray of Size K (Fixed Window)
public int maxSum(int[] arr, int k) {
    int maxSum = 0, windowSum = 0;

    // Primeira janela
    for (int i = 0; i < k; i++) {
        windowSum += arr[i];
    }
    maxSum = windowSum;

    // Deslizar janela
    for (int i = k; i < arr.length; i++) {
        windowSum += arr[i] - arr[i - k];
        maxSum = Math.max(maxSum, windowSum);
    }
    return maxSum;
}

// Exemplo 2: Longest Substring Without Repeating Characters (Variable Window)
public int lengthOfLongestSubstring(String s) {
    Map<Character, Integer> map = new HashMap<>();
    int maxLength = 0;
    int left = 0;

    for (int right = 0; right < s.length(); right++) {
        char c = s.charAt(right);

        if (map.containsKey(c)) {
            left = Math.max(left, map.get(c) + 1);
        }

        map.put(c, right);
        maxLength = Math.max(maxLength, right - left + 1);
    }
    return maxLength;
}
```

**📹 Vídeo:** [Sliding Window Technique - Abdul Bari](https://www.youtube.com/watch?v=jM2dhDPYMQM)  
**🔗 Template:** [Sliding Window Patterns - LeetCode Discuss](https://leetcode.com/problems/minimum-window-substring/solutions/26808/here-is-a-10-line-template-that-can-solve-most-substring-problems/)

### C. Binary Search

**Problema Tipo:** Busca em array ordenado, encontrar limite

```java
// Template básico
public int binarySearch(int[] arr, int target) {
    int left = 0, right = arr.length - 1;

    while (left <= right) {
        int mid = left + (right - left) / 2;  // Evita overflow

        if (arr[mid] == target) {
            return mid;
        } else if (arr[mid] < target) {
            left = mid + 1;
        } else {
            right = mid - 1;
        }
    }
    return -1;  // Não encontrado
}

// Variante: First Bad Version
public int firstBadVersion(int n) {
    int left = 1, right = n;

    while (left < right) {
        int mid = left + (right - left) / 2;

        if (isBadVersion(mid)) {
            right = mid;  // Pode ser a resposta
        } else {
            left = mid + 1;
        }
    }
    return left;
}
```

**📹 Vídeo:** [Binary Search - NeetCode](https://www.youtube.com/watch?v=s4DPM8ct1pI)  
**🔗 Link:** [Binary Search Patterns - topcoder](https://www.topcoder.com/thrive/articles/Binary%20Search)

### D. Sorting Algorithms

**Quando usar:** QuickSort/MergeSort para discussão, Arrays.sort() na prática

```java
// Uso prático
Arrays.sort(arr);  // Primitivos: DualPivotQuicksort O(n log n)
Collections.sort(list);  // Objetos: TimSort O(n log n)

// Comparator customizado
Arrays.sort(arr, (a, b) -> a[0] - b[0]);  // Por primeiro elemento
Collections.sort(list, Comparator.comparingInt(x -> x));

// MergeSort manual (para entrevista conceitual)
public void mergeSort(int[] arr, int left, int right) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        mergeSort(arr, left, mid);
        mergeSort(arr, mid + 1, right);
        merge(arr, left, mid, right);
    }
}

private void merge(int[] arr, int left, int mid, int right) {
    int[] temp = new int[right - left + 1];
    int i = left, j = mid + 1, k = 0;

    while (i <= mid && j <= right) {
        temp[k++] = (arr[i] <= arr[j]) ? arr[i++] : arr[j++];
    }

    while (i <= mid) temp[k++] = arr[i++];
    while (j <= right) temp[k++] = arr[j++];

    System.arraycopy(temp, 0, arr, left, temp.length);
}
```

**📹 Vídeo:** [Sorting Algorithms Visualized](https://www.youtube.com/watch?v=kPRA0W1kECg)  
**🔗 Interativo:** [VisuAlgo - Sorting](https://visualgo.net/en/sorting)

### E. Recursão e Backtracking

**Problema Tipo:** Combinações, permutações, N-Queens

```java
// Exemplo 1: Fibonacci (Memoization)
public int fib(int n) {
    return fibMemo(n, new HashMap<>());
}

private int fibMemo(int n, Map<Integer, Integer> memo) {
    if (n <= 1) return n;
    if (memo.containsKey(n)) return memo.get(n);

    int result = fibMemo(n - 1, memo) + fibMemo(n - 2, memo);
    memo.put(n, result);
    return result;
}

// Exemplo 2: Subsets (Backtracking)
public List<List<Integer>> subsets(int[] nums) {
    List<List<Integer>> result = new ArrayList<>();
    backtrack(result, new ArrayList<>(), nums, 0);
    return result;
}

private void backtrack(List<List<Integer>> result, List<Integer> temp, int[] nums, int start) {
    result.add(new ArrayList<>(temp));

    for (int i = start; i < nums.length; i++) {
        temp.add(nums[i]);
        backtrack(result, temp, nums, i + 1);
        temp.remove(temp.size() - 1);  // Backtrack
    }
}
```

**📹 Vídeo:** [Recursion and Backtracking - Abdul Bari](https://www.youtube.com/watch?v=DKCbsiDBN6c)  
**🔗 Link:** [Backtracking Patterns](https://leetcode.com/problems/subsets/solutions/27281/a-general-approach-to-backtracking-questions-in-java-subsets-permutations-combination-sum-palindrome-partitioning/)

### F. Graph Algorithms (BFS/DFS)

**Problema Tipo:** Shortest path, conectividade, ciclos

```java
// BFS (Level-order traversal)
public void bfs(int start, List<List<Integer>> graph) {
    Queue<Integer> queue = new LinkedList<>();
    Set<Integer> visited = new HashSet<>();

    queue.offer(start);
    visited.add(start);

    while (!queue.isEmpty()) {
        int node = queue.poll();
        System.out.println(node);

        for (int neighbor : graph.get(node)) {
            if (!visited.contains(neighbor)) {
                queue.offer(neighbor);
                visited.add(neighbor);
            }
        }
    }
}

// DFS (Recursivo)
public void dfs(int node, List<List<Integer>> graph, Set<Integer> visited) {
    visited.add(node);
    System.out.println(node);

    for (int neighbor : graph.get(node)) {
        if (!visited.contains(neighbor)) {
            dfs(neighbor, graph, visited);
        }
    }
}

// Problema: Number of Islands
public int numIslands(char[][] grid) {
    if (grid == null || grid.length == 0) return 0;

    int count = 0;
    for (int i = 0; i < grid.length; i++) {
        for (int j = 0; j < grid[0].length; j++) {
            if (grid[i][j] == '1') {
                dfsIsland(grid, i, j);
                count++;
            }
        }
    }
    return count;
}

private void dfsIsland(char[][] grid, int i, int j) {
    if (i < 0 || j < 0 || i >= grid.length || j >= grid[0].length || grid[i][j] != '1') {
        return;
    }

    grid[i][j] = '0';  // Marca como visitado
    dfsIsland(grid, i + 1, j);
    dfsIsland(grid, i - 1, j);
    dfsIsland(grid, i, j + 1);
    dfsIsland(grid, i, j - 1);
}
```

**📹 Vídeo:** [Graph Algorithms - William Fiset](https://www.youtube.com/watch?v=09_LlHjoEiY)  
**🔗 Link:** [Graph Theory Playlist](https://www.youtube.com/playlist?list=PLDV1Zeh2NRsDGO4--qE8yH72HFL1Km93P)

---

## 5️⃣ Padrões de Código Rápido

### Input/Output Otimizado

```java
// Scanner (simples mas lento)
Scanner sc = new Scanner(System.in);
int n = sc.nextInt();
String s = sc.next();  // Sem espaços
String line = sc.nextLine();  // Linha completa

// BufferedReader (rápido)
BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
int n = Integer.parseInt(br.readLine());
String[] tokens = br.readLine().split(" ");

// Output otimizado
StringBuilder sb = new StringBuilder();
for (int x : arr) {
    sb.append(x).append(" ");
}
System.out.println(sb.toString().trim());
```

### String Manipulation

```java
// Conversões
char[] chars = s.toCharArray();
String s = new String(chars);
String s = String.valueOf(123);  // "123"

// Operações comuns
s.substring(0, 3);       // Primeiros 3 chars
s.indexOf("abc");        // Posição ou -1
s.replace("a", "b");     // Substitui todas
s.split(" ");            // Array de strings

// StringBuilder para concatenação
StringBuilder sb = new StringBuilder();
sb.append("hello");
sb.append(" world");
sb.reverse();
String result = sb.toString();

// Problema: Reverse Words
public String reverseWords(String s) {
    String[] words = s.trim().split("\\s+");
    Collections.reverse(Arrays.asList(words));
    return String.join(" ", words);
}
```

### Array Tricks

```java
// Inicialização
int[] arr = new int[n];
Arrays.fill(arr, -1);

// Cópia
int[] copy = Arrays.copyOf(arr, arr.length);
int[] range = Arrays.copyOfRange(arr, 2, 5);  // [2, 5)

// Comparação
Arrays.equals(arr1, arr2);

// Max/Min
int max = Arrays.stream(arr).max().getAsInt();
int min = Arrays.stream(arr).min().getAsInt();

// Sum
int sum = Arrays.stream(arr).sum();

// Ordenar descrescente (ArrayList)
Collections.sort(list, Collections.reverseOrder());
```

### Math Utilities

```java
// Operações comuns
Math.max(a, b);
Math.min(a, b);
Math.abs(x);
Math.pow(2, 3);  // 8.0
Math.sqrt(25);   // 5.0
Math.ceil(3.2);  // 4.0
Math.floor(3.8); // 3.0

// Módulo (evita negativo)
int mod = ((x % m) + m) % m;

// GCD (Greatest Common Divisor)
public int gcd(int a, int b) {
    return b == 0 ? a : gcd(b, a % b);
}

// LCM (Least Common Multiple)
public int lcm(int a, int b) {
    return (a * b) / gcd(a, b);
}

// Primo
public boolean isPrime(int n) {
    if (n <= 1) return false;
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) return false;
    }
    return true;
}
```

---

## 6️⃣ Java Moderno (Streams, Records, Optionals)

### Streams API

**Quando usar:** Transformações, filtros, agregações (se não prejudicar performance)

```java
// Filtrar e mapear
List<Integer> evens = numbers.stream()
    .filter(n -> n % 2 == 0)
    .collect(Collectors.toList());

// Map to outro tipo
List<String> names = users.stream()
    .map(User::getName)
    .collect(Collectors.toList());

// Redução
int sum = numbers.stream()
    .reduce(0, Integer::sum);

int max = numbers.stream()
    .max(Integer::compareTo)
    .orElse(0);

// Agrupar
Map<String, List<User>> byCity = users.stream()
    .collect(Collectors.groupingBy(User::getCity));

// Contar
long count = users.stream()
    .filter(u -> u.getAge() > 18)
    .count();

// FlatMap (lista de listas)
List<Integer> allNumbers = lists.stream()
    .flatMap(List::stream)
    .collect(Collectors.toList());
```

**⚠️ Atenção:** Streams podem ser mais lentas que loops tradicionais em arrays pequenos. Use quando clareza > performance marginal.

**📹 Vídeo:** [Java Streams - Amigoscode](https://www.youtube.com/watch?v=Q93JsQ8vcwY)

### Optional (Evitar NullPointerException)

```java
// Criar Optional
Optional<String> opt = Optional.of("value");
Optional<String> nullable = Optional.ofNullable(maybeNull);
Optional<String> empty = Optional.empty();

// Uso seguro
String result = opt.orElse("default");
String result = opt.orElseGet(() -> computeDefault());
String result = opt.orElseThrow(() -> new Exception("Not found"));

// Transformação
Optional<Integer> length = opt.map(String::length);

// Exemplo prático
public Optional<User> findUserById(int id) {
    User user = database.get(id);
    return Optional.ofNullable(user);
}

// Uso
findUserById(1)
    .map(User::getEmail)
    .orElse("no-email@example.com");
```

### Records (Java 14+)

**Quando usar:** DTOs imutáveis, retorno de múltiplos valores

```java
// Definição
record Point(int x, int y) {}

// Uso
Point p = new Point(5, 10);
int x = p.x();  // Getter automático
int y = p.y();

// Equals/hashCode automáticos
Point p2 = new Point(5, 10);
p.equals(p2);  // true

// Com validação
record User(String name, int age) {
    public User {
        if (age < 0) throw new IllegalArgumentException("Age must be positive");
    }
}

// Problema: Retornar múltiplos valores
record MinMax(int min, int max) {}

public MinMax findMinMax(int[] arr) {
    int min = Arrays.stream(arr).min().orElse(0);
    int max = Arrays.stream(arr).max().orElse(0);
    return new MinMax(min, max);
}
```

**📹 Vídeo:** [Java Records - Java Brains](https://www.youtube.com/watch?v=YwWh_NaRnKg)

---

## 7️⃣ REST API e Spring Boot

### Estrutura Típica de Questão

**Cenário:** Implementar CRUD para `Product` com validações

```java
// Model/Entity
@Entity
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String name;

    @Min(0)
    private BigDecimal price;

    // Getters/Setters ou use Lombok @Data
}

// Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByNameContaining(String name);
    List<Product> findByPriceLessThan(BigDecimal price);
}

// Service
@Service
public class ProductService {

    @Autowired
    private ProductRepository repository;

    public List<Product> findAll() {
        return repository.findAll();
    }

    public Product findById(Long id) {
        return repository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
    }

    public Product save(Product product) {
        return repository.save(product);
    }

    public void deleteById(Long id) {
        if (!repository.existsById(id)) {
            throw new ResourceNotFoundException("Product not found");
        }
        repository.deleteById(id);
    }
}

// Controller
@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductService service;

    @GetMapping
    public ResponseEntity<List<Product>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.findById(id));
    }

    @PostMapping
    public ResponseEntity<Product> create(@Valid @RequestBody Product product) {
        Product saved = service.save(product);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> update(@PathVariable Long id, @Valid @RequestBody Product product) {
        Product existing = service.findById(id);
        existing.setName(product.getName());
        existing.setPrice(product.getPrice());
        return ResponseEntity.ok(service.save(existing));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}

// Exception Handling Global
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        ErrorResponse error = new ErrorResponse(HttpStatus.NOT_FOUND.value(), ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
            .map(err -> err.getField() + ": " + err.getDefaultMessage())
            .collect(Collectors.joining(", "));
        ErrorResponse error = new ErrorResponse(HttpStatus.BAD_REQUEST.value(), message);
        return ResponseEntity.badRequest().body(error);
    }
}

record ErrorResponse(int status, String message) {}
```

### Anotações Essenciais

| Anotação                        | Uso                        |
| ------------------------------- | -------------------------- |
| `@RestController`               | Controller REST            |
| `@RequestMapping("/api/users")` | Base path                  |
| `@GetMapping`                   | HTTP GET                   |
| `@PostMapping`                  | HTTP POST                  |
| `@PutMapping`                   | HTTP PUT                   |
| `@DeleteMapping`                | HTTP DELETE                |
| `@PathVariable`                 | Captura variável da URL    |
| `@RequestBody`                  | Body da requisição         |
| `@Valid`                        | Valida com Bean Validation |
| `@Service`                      | Service layer              |
| `@Autowired`                    | Injeção de dependência     |

**📹 Vídeo:** [Spring Boot REST API - Amigoscode](https://www.youtube.com/watch?v=9SGDpanrc8U)  
**🔗 Link:** [Spring Boot Testing](https://www.baeldung.com/spring-boot-testing)

---

## 8️⃣ SQL e Banco de Dados

### JOINs Essenciais

```sql
-- INNER JOIN (apenas registros com match)
SELECT u.name, o.total
FROM users u
INNER JOIN orders o ON u.id = o.user_id;

-- LEFT JOIN (todos da esquerda + matches)
SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- Self JOIN (hierarquia)
SELECT e.name as employee, m.name as manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

### Agregações

```sql
-- GROUP BY + HAVING
SELECT category, AVG(price) as avg_price
FROM products
GROUP BY category
HAVING AVG(price) > 100;

-- Funções agregadas
SELECT
    COUNT(*) as total,
    SUM(price) as total_sales,
    AVG(price) as avg_price,
    MIN(price) as min_price,
    MAX(price) as max_price
FROM products;

-- DISTINCT
SELECT COUNT(DISTINCT user_id) as unique_users
FROM orders;
```

### Subqueries

```sql
-- Subquery no WHERE
SELECT name
FROM users
WHERE id IN (SELECT user_id FROM orders WHERE total > 1000);

-- Subquery no FROM
SELECT category, avg_price
FROM (
    SELECT category, AVG(price) as avg_price
    FROM products
    GROUP BY category
) AS avg_by_category
WHERE avg_price > 50;

-- Correlated Subquery
SELECT p.name, p.price
FROM products p
WHERE p.price > (
    SELECT AVG(price)
    FROM products
    WHERE category = p.category
);
```

### Window Functions (Menos Comum)

```sql
-- ROW_NUMBER (ranking)
SELECT
    name,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as rank
FROM employees;

-- RANK com partição
SELECT
    department,
    name,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank
FROM employees;
```

**📹 Vídeo:** [SQL Tutorial - Programming with Mosh](https://www.youtube.com/watch?v=7S_tz1z_5bA)  
**🔗 Pratique:** [SQLBolt - Interactive Tutorial](https://sqlbolt.com/)  
**🔗 Avançado:** [Mode Analytics SQL Tutorial](https://mode.com/sql-tutorial/)

### JPA Query Methods

```java
// Naming conventions (Spring Data JPA)
List<User> findByName(String name);
List<User> findByAgeGreaterThan(int age);
List<User> findByNameContainingIgnoreCase(String keyword);
List<User> findByAgeBetween(int min, int max);
List<User> findTop10ByOrderBySalaryDesc();

// @Query custom
@Query("SELECT u FROM User u WHERE u.email LIKE %:domain")
List<User> findByEmailDomain(@Param("domain") String domain);

@Query(value = "SELECT * FROM users WHERE active = true", nativeQuery = true)
List<User> findActiveUsersNative();
```

---

## 9️⃣ Complexidade e Otimização

### Big O Cheat Sheet

| Notação    | Nome         | Exemplo                                |
| ---------- | ------------ | -------------------------------------- |
| O(1)       | Constante    | Acesso a array por índice, HashMap get |
| O(log n)   | Logarítmica  | Binary search, TreeMap operações       |
| O(n)       | Linear       | Loop simples, busca linear             |
| O(n log n) | Linearítmica | Merge sort, Quick sort (médio)         |
| O(n²)      | Quadrática   | Loop aninhado, Bubble sort             |
| O(2^n)     | Exponencial  | Recursão ingênua de Fibonacci          |
| O(n!)      | Fatorial     | Gerar todas permutações                |

### Como Otimizar

**Problema:** Two Sum em O(n²)

```java
// ❌ Solução O(n²) - TLE (Time Limit Exceeded)
public int[] twoSumSlow(int[] nums, int target) {
    for (int i = 0; i < nums.length; i++) {
        for (int j = i + 1; j < nums.length; j++) {
            if (nums[i] + nums[j] == target) {
                return new int[] {i, j};
            }
        }
    }
    return null;
}

// ✅ Solução O(n) - HashMap
public int[] twoSumFast(int[] nums, int target) {
    Map<Integer, Integer> map = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (map.containsKey(complement)) {
            return new int[] {map.get(complement), i};
        }
        map.put(nums[i], i);
    }
    return null;
}
```

### Dicas de Otimização

1. **HashSet/HashMap para lookup O(1)**

   - Substituir `list.contains()` (O(n)) por `set.contains()` (O(1))

2. **Ordenar + Two Pointers**

   - Alternativa a HashMap quando busca de pares

3. **Prefix Sum para range queries**

   ```java
   // Soma de subarray [i, j] em O(1)
   int[] prefix = new int[n + 1];
   for (int i = 0; i < n; i++) {
       prefix[i + 1] = prefix[i] + arr[i];
   }
   int sum = prefix[j + 1] - prefix[i];
   ```

4. **Sliding Window para subarrays**

   - Evita recalcular soma repetidamente

5. **Binary Search em dados ordenados**
   - O(log n) vs O(n) linear search

**📹 Vídeo:** [Time Complexity Analysis - CS Dojo](https://www.youtube.com/watch?v=D6xkbGLQesk)  
**🔗 Link:** [Big-O Cheat Sheet](https://www.bigocheatsheet.com/)

---

## 🔟 Exercícios Práticos por Categoria

### Warm-up (Fáceis - 15min cada)

**HackerRank:**

- [Compare the Triplets](https://www.hackerrank.com/challenges/compare-the-triplets)
- [A Very Big Sum](https://www.hackerrank.com/challenges/a-very-big-sum)
- [Diagonal Difference](https://www.hackerrank.com/challenges/diagonal-difference)
- [Staircase](https://www.hackerrank.com/challenges/staircase)
- [Mini-Max Sum](https://www.hackerrank.com/challenges/mini-max-sum)

**LeetCode:**

- [Two Sum](https://leetcode.com/problems/two-sum/) ⭐
- [Reverse String](https://leetcode.com/problems/reverse-string/)
- [Valid Palindrome](https://leetcode.com/problems/valid-palindrome/)
- [Maximum Subarray](https://leetcode.com/problems/maximum-subarray/)

### Estruturas de Dados (Médio - 30min cada)

**HackerRank:**

- [Hash Tables: Ransom Note](https://www.hackerrank.com/challenges/ctci-ransom-note)
- [Linked Lists: Detect a Cycle](https://www.hackerrank.com/challenges/ctci-linked-list-cycle)
- [Stacks: Balanced Brackets](https://www.hackerrank.com/challenges/ctci-balanced-brackets)
- [Queues: A Tale of Two Stacks](https://www.hackerrank.com/challenges/ctci-queue-using-two-stacks)

**LeetCode:**

- [Valid Parentheses](https://leetcode.com/problems/valid-parentheses/) ⭐
- [Merge Two Sorted Lists](https://leetcode.com/problems/merge-two-sorted-lists/)
- [Binary Tree Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/)
- [LRU Cache](https://leetcode.com/problems/lru-cache/)

### Algoritmos (Médio/Difícil - 45min cada)

**HackerRank:**

- [Array Manipulation](https://www.hackerrank.com/challenges/crush)
- [Sorting: Bubble Sort](https://www.hackerrank.com/challenges/ctci-bubble-sort)
- [BFS: Shortest Reach](https://www.hackerrank.com/challenges/ctci-bfs-shortest-reach)
- [DFS: Connected Cell in a Grid](https://www.hackerrank.com/challenges/ctci-connected-cell-in-a-grid)

**LeetCode:**

- [Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/) ⭐
- [3Sum](https://leetcode.com/problems/3sum/)
- [Merge Intervals](https://leetcode.com/problems/merge-intervals/)
- [Course Schedule](https://leetcode.com/problems/course-schedule/)
- [Number of Islands](https://leetcode.com/problems/number-of-islands/) ⭐

### Spring Boot / REST API

**HackerRank:**

- [REST API: Total Goals](https://www.hackerrank.com/challenges/rest-api-total-goals-by-team)
- [REST API: Weather Finder](https://www.hackerrank.com/challenges/rest-api-weather-finder)
- Busque "Spring Boot" no HackerRank Skills Certification

**Prática:**

- Implemente CRUD completo de `Book` com paginação
- Adicione filtros: `findByTitleContaining`, `findByAuthor`
- Implemente validações: título não vazio, preço > 0
- Adicione testes com MockMvc

### SQL

**HackerRank:**

- [Revising the Select Query](https://www.hackerrank.com/challenges/revising-the-select-query)
- [Employee Salaries](https://www.hackerrank.com/challenges/salary-of-employees)
- [Weather Observation Station](https://www.hackerrank.com/challenges/weather-observation-station-5)
- [Top Earners](https://www.hackerrank.com/challenges/earnings-of-employees)

**LeetCode:**

- [Combine Two Tables](https://leetcode.com/problems/combine-two-tables/)
- [Second Highest Salary](https://leetcode.com/problems/second-highest-salary/)
- [Department Highest Salary](https://leetcode.com/problems/department-highest-salary/)

---

## 1️⃣1️⃣ Checklist 24h Antes da Prova

### Preparação Técnica

- [ ] **Revisar templates de código** (I/O, loops, estruturas)
- [ ] **Testar ambiente HackerRank** (criar conta, fazer 1 problema teste)
- [ ] **Revisar complexidade** (Big-O das operações principais)
- [ ] **Praticar 3 problemas** (1 fácil, 1 médio, 1 difícil)
- [ ] **Revisar edge cases comuns:**
  - Array vazio `[]`
  - Único elemento `[5]`
  - Valores negativos
  - Zeros
  - Duplicatas
  - String vazia `""`
  - Null inputs

### Preparação Mental

- [ ] **Dormir 7-8h** (performance cognitiva é crítica)
- [ ] **Hidratação** (água, evitar café em excesso)
- [ ] **Ambiente silencioso** (fone de ouvido se necessário)
- [ ] **Relógio/Timer** visível (gerenciar tempo)

### Estratégia Durante a Prova

**1. Leia TODOS os problemas primeiro (5min)**

- Identifique o mais fácil
- Planeje ordem de resolução

**2. Resolva na ordem: Fácil → Médio → Difícil**

- Garanta pontos seguros primeiro
- Não trave em um problema

**3. Para cada problema (5min análise):**

```
[ ] Entendi o problema? (ler 2x)
[ ] Identifiquei exemplos/edge cases?
[ ] Qual estrutura de dados usar?
[ ] Qual algoritmo aplicar?
[ ] Qual a complexidade esperada?
```

**4. Implemente em etapas:**

```
1. Solução bruta (força bruta) - funciona? ✅
2. Otimize se necessário
3. Teste com exemplos fornecidos
4. Teste edge cases mentalmente
5. Submit
```

**5. Gerenciamento de tempo:**

```
60min prova = 20min por problema (médio)

- 5min: Ler e planejar
- 10min: Implementar
- 3min: Testar
- 2min: Buffer
```

**6. Se travar (>10min sem progresso):**

- ❌ Não: Ficar travado, apagar tudo
- ✅ Sim: Skip → resolver outros → voltar depois

**7. Antes de submeter:**

```
[ ] Compila sem erros?
[ ] Testei com exemplos fornecidos?
[ ] Edge cases cobertos?
[ ] Complexidade aceitável?
```

---

## 1️⃣2️⃣ Recursos e Links

### Plataformas de Prática

| Plataforma     | Foco                 | Link                                                         |
| -------------- | -------------------- | ------------------------------------------------------------ |
| **HackerRank** | Entrevistas reais    | [hackerrank.com](https://www.hackerrank.com/)                |
| **LeetCode**   | Algoritmos profundos | [leetcode.com](https://leetcode.com/)                        |
| **Exercism**   | Java idiomático      | [exercism.org/tracks/java](https://exercism.org/tracks/java) |
| **Codewars**   | Katas divertidos     | [codewars.com](https://www.codewars.com/)                    |

### Cursos e Tutoriais

**YouTube:**

- [Java Full Course - Bro Code](https://www.youtube.com/watch?v=xk4_1vDrzzo) (12h)
- [Data Structures Easy to Advanced - freeCodeCamp](https://www.youtube.com/watch?v=RBSGKlAvoiM) (10h)
- [Algorithms Course - Abdul Bari](https://www.youtube.com/playlist?list=PLDN4rrl48XKpZkf03iYFl-O29szjTrs_O)
- [Spring Boot Tutorial - Amigoscode](https://www.youtube.com/watch?v=9SGDpanrc8U) (3h)

**Cursos Pagos (Opcionais):**

- [Master Coding Interview - Zero To Mastery](https://www.udemy.com/course/master-the-coding-interview-data-structures-algorithms/) - Udemy $15
- [Java Interview Guide - in28minutes](https://www.udemy.com/course/java-interview-guide/) - Udemy $15

### Livros

- **Cracking the Coding Interview** (Gayle McDowell) - Bíblia das entrevistas
- **Effective Java** (Joshua Bloch) - Best practices Java
- **Grokking Algorithms** (Aditya Bhargava) - Visual e fácil

### Cheat Sheets

- [Java Collections Cheat Sheet](https://www.baeldung.com/java-collections)
- [Big-O Cheat Sheet](https://www.bigocheatsheet.com/)
- [Spring Boot Annotations](https://www.baeldung.com/spring-boot-annotations)
- [SQL Cheat Sheet](https://www.sqltutorial.org/sql-cheat-sheet/)

### Ferramentas

- [VisuAlgo](https://visualgo.net/) - Visualizar algoritmos
- [Regex101](https://regex101.com/) - Testar regex
- [JSON Formatter](https://jsonformatter.org/) - Validar JSON
- [OnlineGDB](https://www.onlinegdb.com/online_java_compiler) - Compilador online

### Comunidades

- [r/learnjava](https://www.reddit.com/r/learnjava/) - Reddit Java
- [Stack Overflow](https://stackoverflow.com/questions/tagged/java) - Dúvidas
- [Dev.to #java](https://dev.to/t/java) - Artigos

---

## 🎯 Plano de Estudos 4 Semanas

### Semana 1: Fundamentos + Estruturas de Dados

**Dia 1-2:** Arrays, Strings, Two Pointers

- 📹 [Array Algorithms - NeetCode](https://www.youtube.com/watch?v=KLlXCFG5TnA)
- ✍️ Resolver 5 problemas HackerRank arrays
- ✍️ Two Sum, Remove Duplicates (LeetCode)

**Dia 3-4:** HashMap, HashSet

- 📹 [HashMap Internals](https://www.youtube.com/watch?v=c3RVW3KGIIE)
- ✍️ Ransom Note, Two Sum variants
- ✍️ 5 problemas hash tables

**Dia 5-6:** Stack, Queue, LinkedList

- 📹 [Stack and Queue](https://www.youtube.com/watch?v=wjI1WNcIntg)
- ✍️ Valid Parentheses, Reverse LinkedList
- ✍️ 5 problemas stacks/queues

**Dia 7:** Revisão semana 1

- Refazer problemas que travou
- Mock test: 3 problemas em 60min

### Semana 2: Algoritmos Core

**Dia 8-9:** Sorting, Binary Search

- 📹 [Binary Search](https://www.youtube.com/watch?v=s4DPM8ct1pI)
- ✍️ First Bad Version, Search Insert Position
- ✍️ 5 problemas binary search

**Dia 10-11:** Sliding Window

- 📹 [Sliding Window Patterns](https://www.youtube.com/watch?v=jM2dhDPYMQM)
- ✍️ Longest Substring, Max Sum Subarray
- ✍️ 5 problemas sliding window

**Dia 12-13:** Recursão, Backtracking

- 📹 [Recursion Tutorial](https://www.youtube.com/watch?v=DKCbsiDBN6c)
- ✍️ Fibonacci, Subsets, Permutations
- ✍️ 3 problemas recursão

**Dia 14:** Revisão semana 2

- Mock test: 3 problemas em 60min
- Revisar complexidade

### Semana 3: Avançado + Backend

**Dia 15-16:** Graphs (BFS, DFS)

- 📹 [Graph Algorithms](https://www.youtube.com/watch?v=09_LlHjoEiY)
- ✍️ Number of Islands, Course Schedule
- ✍️ 4 problemas graphs

**Dia 17-18:** Dynamic Programming (Introdução)

- 📹 [DP Patterns](https://www.youtube.com/watch?v=oBt53YbR9Kk)
- ✍️ Climbing Stairs, House Robber
- ✍️ 3 problemas DP fáceis

**Dia 19-20:** Spring Boot REST API

- 📹 [Spring Boot Tutorial](https://www.youtube.com/watch?v=9SGDpanrc8U)
- ✍️ Criar CRUD completo de `Product`
- ✍️ Resolver 3 problemas REST API HackerRank

**Dia 21:** Revisão semana 3

- Mock test backend: implementar API em 90min

### Semana 4: SQL + Mock Tests

**Dia 22-23:** SQL

- 📹 [SQL Tutorial](https://www.youtube.com/watch?v=7S_tz1z_5bA)
- ✍️ Resolver 10 problemas SQL HackerRank
- ✍️ JOINs, GROUP BY, subqueries

**Dia 24-25:** Java Moderno (Streams, Optionals, Records)

- 📹 [Java Streams](https://www.youtube.com/watch?v=Q93JsQ8vcwY)
- ✍️ Refatorar 5 problemas com Streams
- ✍️ Criar DTOs com Records

**Dia 26-27:** Mock Tests Completos

- Mock 1: 5 problemas mistos (90min)
- Mock 2: 3 problemas + 1 REST API (90min)
- Revisar erros

**Dia 28:** Revisão Final

- Revisar templates de código
- Edge cases comuns
- Complexidade Big-O
- Descansar antes da prova

---

## 💡 Dicas Finais de Ouro

### Durante a Prova

1. **Leia o problema 2x** - Não pule detalhes
2. **Escreva exemplos no papel** - Visualize entrada/saída
3. **Pense alto (mentalmente)** - "O que esse loop faz?"
4. **Teste com exemplo fornecido ANTES de submeter**
5. **Edge cases prioritários:**
   - Empty: `[]`, `""`
   - Single: `[1]`, `"a"`
   - Duplicates: `[1,1,1]`
   - Negatives: `[-5, -2]`
   - Large: `n = 10^5`

### Debugging Rápido

```java
// Print para debug (remover antes de submeter)
System.err.println("DEBUG: arr = " + Arrays.toString(arr));
System.err.println("DEBUG: i = " + i + ", sum = " + sum);

// Assert (para validar hipóteses)
assert arr.length > 0 : "Array não pode ser vazio";
```

### Erro Comum: Off-by-One

```java
// ❌ Erro
for (int i = 0; i <= arr.length; i++) { }  // ArrayIndexOutOfBoundsException

// ✅ Correto
for (int i = 0; i < arr.length; i++) { }

// ❌ Erro substring
s.substring(0, s.length());  // OK
s.substring(0, s.length() + 1);  // StringIndexOutOfBoundsException
```

### Quando Usar Cada Estrutura

```
Precisa de ordem?
├─ Sim → ArrayList, LinkedList
└─ Não → HashSet, HashMap

Precisa de lookup rápido?
├─ Sim → HashMap, HashSet
└─ Não → ArrayList (se ordem importa)

Precisa de valores únicos?
├─ Sim → HashSet, TreeSet
└─ Não → ArrayList

Precisa ordenar?
├─ Inserção → TreeSet, TreeMap
└─ Final → ArrayList + Collections.sort()

Precisa de FIFO?
└─ Queue (LinkedList)

Precisa de LIFO?
└─ Stack

Precisa de prioridade?
└─ PriorityQueue
```

---

## 🏆 Certificações HackerRank

Após praticar, considere certificações oficiais:

- **Problem Solving (Basic)** - Fácil, bom para currículo
- **Problem Solving (Intermediate)** - Médio, diferencial
- **Java (Basic)** - Collections, OOP, Exceptions
- **REST API (Intermediate)** - Spring Boot
- **SQL (Basic/Intermediate)** - Queries, JOINs

**🔗 Link:** [HackerRank Certifications](https://www.hackerrank.com/skills-verification)

---

## ✅ Checklist de Prontidão

**Você está pronto quando conseguir:**

- [ ] Resolver 5 problemas fáceis em 30min
- [ ] Resolver 3 problemas médios em 60min
- [ ] Implementar Two Sum em 5min
- [ ] Explicar complexidade de HashMap, ArrayList, TreeMap
- [ ] Implementar Binary Search sem olhar código
- [ ] Criar CRUD REST API em 45min
- [ ] Escrever 5 queries SQL com JOIN/GROUP BY
- [ ] Identificar quando usar Two Pointers vs HashMap
- [ ] Testar código com edge cases mentalmente
- [ ] Não travar >5min em um problema

---

**Boa sorte! 🚀 Você consegue!**

**Última Atualização:** 2025-11-15  
**Tempo de Preparação Recomendado:** 2-4 semanas (2h/dia)  
**Fase do Plano:** 09-entrevistas

---

## 📞 Feedback

Se conseguiu aprovação após este guia, abra uma issue no GitHub compartilhando:

- Empresa
- Tipo de prova
- Problemas que caíram
- Dicas extras

Ajude outros devs! 💙
