# 🎲 Property-Based Testing - Especializações Avançadas

## Índice

1. [Introdução](#1-introdução)
2. [Fundamentos](#2-fundamentos)
3. [Ferramentas Open Source](#3-ferramentas-open-source)
4. [Estratégias de Propriedades](#4-estratégias-de-propriedades)
5. [Shrinking e Debugging](#5-shrinking-e-debugging)
6. [Casos de Uso Avançados](#6-casos-de-uso-avançados)
7. [Integração com CI/CD](#7-integração-com-cicd)
8. [Boas Práticas](#8-boas-práticas)

---

## 1. Introdução

### O que é Property-Based Testing?

**Definição:** Testar propriedades matemáticas/lógicas do código com dados gerados automaticamente, em vez de escrever exemplos manualmente.

**Diferença de Testes Tradicionais:**

| Aspecto        | Example-Based Testing                 | Property-Based Testing          |
| -------------- | ------------------------------------- | ------------------------------- |
| **Dados**      | Escolhidos manualmente                | Gerados automaticamente         |
| **Quantidade** | Poucos casos (3-10)                   | Centenas/milhares               |
| **Cobertura**  | Edge cases conhecidos                 | Edge cases inesperados          |
| **Manutenção** | Adicionar casos quando bug encontrado | Propriedade já cobre            |
| **Exemplo**    | `assert add(2, 3) == 5`               | `assert add(a, b) == add(b, a)` |

### Por que Property-Based Testing?

**Problemas que Resolve:**

1. 🐛 **Encontra bugs inesperados** - Casos que você nunca pensaria
2. 🎲 **Testa combinações impossíveis de cobrir manualmente** - 100.000 inputs diferentes
3. 📝 **Especificação viva** - Propriedades são documentação executável
4. 🔄 **Evita viés** - Não escolhemos apenas casos "felizes"

**Exemplo Motivacional:**

```python
# Teste tradicional (fraco)
def test_reverse():
    assert reverse([1, 2, 3]) == [3, 2, 1]
    assert reverse([]) == []
    # E se houver duplicatas? E se houver milhões de elementos?

# Property-based (forte)
@given(lists(integers()))
def test_reverse_twice_is_identity(xs):
    assert reverse(reverse(xs)) == xs
    # Testa QUALQUER lista de inteiros
```

---

## 2. Fundamentos

### 2.1 Anatomia de uma Propriedade

**Estrutura:**

```
GIVEN: Inputs gerados automaticamente
WHEN: Executar operação
THEN: Verificar propriedade invariante
```

**Tipos de Propriedades:**

#### 1. **Idempotência**

```python
# f(f(x)) == f(x)
@given(text())
def test_lowercase_is_idempotent(s):
    assert s.lower().lower() == s.lower()
```

#### 2. **Identidade/Inversos**

```python
# encode(decode(x)) == x
@given(binary())
def test_base64_roundtrip(data):
    encoded = base64.b64encode(data)
    decoded = base64.b64decode(encoded)
    assert decoded == data
```

#### 3. **Comutatividade**

```python
# f(a, b) == f(b, a)
@given(integers(), integers())
def test_add_commutative(a, b):
    assert add(a, b) == add(b, a)
```

#### 4. **Associatividade**

```python
# f(f(a, b), c) == f(a, f(b, c))
@given(integers(), integers(), integers())
def test_add_associative(a, b, c):
    assert add(add(a, b), c) == add(a, add(b, c))
```

#### 5. **Invariantes**

```python
# Propriedades que devem ser sempre verdadeiras
@given(lists(integers()))
def test_sorted_is_ordered(xs):
    sorted_xs = sorted(xs)
    for i in range(len(sorted_xs) - 1):
        assert sorted_xs[i] <= sorted_xs[i + 1]
```

#### 6. **Oráculo (comparação com referência)**

```python
# f_custom(x) == f_stdlib(x)
@given(lists(integers()))
def test_custom_sort_matches_builtin(xs):
    assert custom_sort(xs) == sorted(xs)
```

---

## 3. Ferramentas Open Source

### 3.1 Hypothesis (Python)

**Instalação:**

```bash
pip install hypothesis
```

**Exemplo Básico:**

```python
from hypothesis import given, strategies as st

@given(st.integers(), st.integers())
def test_addition_commutative(a, b):
    assert a + b == b + a

# Executar com pytest
pytest test_properties.py
```

**Estratégias Comuns:**

```python
from hypothesis import strategies as st

# Primitivos
st.integers()                    # Qualquer inteiro
st.integers(min_value=0, max_value=100)  # Inteiros 0-100
st.floats()                      # Floats (incluindo NaN, inf)
st.text()                        # Strings Unicode
st.binary()                      # Bytes
st.booleans()                    # True/False

# Coleções
st.lists(st.integers())          # Lista de inteiros
st.lists(st.integers(), min_size=1, max_size=10)  # 1-10 elementos
st.sets(st.text())               # Set de strings
st.dictionaries(st.text(), st.integers())  # Dict str -> int

# Composição
st.tuples(st.text(), st.integers())  # Tupla (str, int)
st.one_of(st.integers(), st.none())  # int ou None

# Dados estruturados
from dataclasses import dataclass

@dataclass
class User:
    name: str
    age: int
    email: str

st.builds(
    User,
    name=st.text(min_size=1),
    age=st.integers(min_value=0, max_value=120),
    email=st.emails()
)

# Recursive (árvores, JSONs)
json_strategy = st.recursive(
    st.one_of(st.none(), st.booleans(), st.floats(), st.text()),
    lambda children: st.lists(children) | st.dictionaries(st.text(), children)
)
```

**Exemplo Avançado - API REST:**

```python
from hypothesis import given, strategies as st
from hypothesis.stateful import RuleBasedStateMachine, rule, invariant
import requests

# Strategy para gerar requests válidos
http_methods = st.sampled_from(['GET', 'POST', 'PUT', 'DELETE'])
valid_ids = st.integers(min_value=1, max_value=1000)
user_data = st.fixed_dictionaries({
    'name': st.text(min_size=1, max_size=100),
    'email': st.emails(),
    'age': st.integers(min_value=18, max_value=100)
})

@given(user_data)
def test_create_user_returns_valid_id(data):
    response = requests.post('http://api/users', json=data)
    assert response.status_code == 201
    user_id = response.json()['id']
    assert isinstance(user_id, int)
    assert user_id > 0

@given(valid_ids)
def test_get_user_idempotent(user_id):
    response1 = requests.get(f'http://api/users/{user_id}')
    response2 = requests.get(f'http://api/users/{user_id}')

    if response1.status_code == 200:
        assert response1.json() == response2.json()

@given(user_data)
def test_create_and_delete_user(data):
    # Create
    create_response = requests.post('http://api/users', json=data)
    user_id = create_response.json()['id']

    # Delete
    delete_response = requests.delete(f'http://api/users/{user_id}')
    assert delete_response.status_code == 204

    # Verify deleted
    get_response = requests.get(f'http://api/users/{user_id}')
    assert get_response.status_code == 404
```

---

### 3.2 fast-check (JavaScript/TypeScript)

**Instalação:**

```bash
npm install --save-dev fast-check
```

**Exemplo Básico:**

```typescript
import fc from "fast-check";

describe("String operations", () => {
  it("reverse twice is identity", () => {
    fc.assert(
      fc.property(fc.string(), (s) => {
        return reverse(reverse(s)) === s;
      })
    );
  });
});
```

**Arbitraries Comuns:**

```typescript
import fc from "fast-check";

// Primitivos
fc.integer(); // Qualquer inteiro
fc.integer({ min: 0, max: 100 }); // 0-100
fc.double(); // Float
fc.string(); // String
fc.boolean(); // Boolean
fc.date(); // Date

// Coleções
fc.array(fc.integer()); // Array de inteiros
fc.array(fc.string(), { minLength: 1, maxLength: 10 });
fc.set(fc.integer()); // Set
fc.dictionary(fc.string(), fc.integer()); // Object

// Composição
fc.tuple(fc.string(), fc.integer()); // [string, number]
fc.oneof(fc.integer(), fc.constant(null)); // number | null

// Dados customizados
interface User {
  id: number;
  name: string;
  email: string;
}

const userArbitrary = fc.record<User>({
  id: fc.integer({ min: 1 }),
  name: fc.string({ minLength: 1 }),
  email: fc.emailAddress(),
});

fc.assert(
  fc.property(userArbitrary, (user) => {
    return validateUser(user);
  })
);
```

**Exemplo - React Component:**

```typescript
import fc from "fast-check";
import { render, screen } from "@testing-library/react";
import { UserProfile } from "./UserProfile";

describe("UserProfile component", () => {
  it("always displays user name", () => {
    fc.assert(
      fc.property(
        fc.record({
          id: fc.integer({ min: 1 }),
          name: fc.string({ minLength: 1 }),
          email: fc.emailAddress(),
          age: fc.integer({ min: 18, max: 100 }),
        }),
        (user) => {
          render(<UserProfile user={user} />);
          expect(screen.getByText(user.name)).toBeInTheDocument();
        }
      ),
      { numRuns: 100 }
    );
  });

  it("email is valid format", () => {
    fc.assert(
      fc.property(fc.emailAddress(), (email) => {
        render(<UserProfile user={{ email }} />);
        const emailElement = screen.getByTestId("user-email");
        expect(emailElement.textContent).toMatch(/^[^\s@]+@[^\s@]+\.[^\s@]+$/);
      })
    );
  });
});
```

---

### 3.3 jqwik (Java)

**Instalação (Maven):**

```xml
<dependency>
    <groupId>net.jqwik</groupId>
    <artifactId>jqwik</artifactId>
    <version>1.7.4</version>
    <scope>test</scope>
</dependency>
```

**Exemplo Básico:**

```java
import net.jqwik.api.*;

class StringProperties {

    @Property
    void reverseTwiceIsIdentity(@ForAll String s) {
        String reversed = reverse(reverse(s));
        Assertions.assertEquals(s, reversed);
    }

    @Property
    void lengthIsPreserved(@ForAll String s) {
        String reversed = reverse(s);
        Assertions.assertEquals(s.length(), reversed.length());
    }
}
```

**Providers Comuns:**

```java
import net.jqwik.api.*;
import net.jqwik.api.arbitraries.*;

class ArbitraryExamples {

    // Inteiros
    @Property
    void integerExample(@ForAll @IntRange(min = 0, max = 100) int n) {
        // n entre 0-100
    }

    // Strings
    @Property
    void stringExample(@ForAll @StringLength(min = 1, max = 50) String s) {
        // String 1-50 caracteres
    }

    // Listas
    @Property
    void listExample(@ForAll List<@IntRange(min = 0, max = 100) Integer> numbers) {
        // Lista de inteiros 0-100
    }

    // Customizado
    @Provide
    Arbitrary<User> users() {
        return Combinators.combine(
            Arbitraries.strings().ofMinLength(1),
            Arbitraries.integers().between(18, 100),
            Arbitraries.emails()
        ).as((name, age, email) -> new User(name, age, email));
    }

    @Property
    void userExample(@ForAll("users") User user) {
        // Usa provider customizado
    }
}
```

**Exemplo - Domain Model:**

```java
class OrderProperties {

    @Property
    void totalPriceIsPositive(@ForAll("validOrders") Order order) {
        BigDecimal total = order.calculateTotal();
        assertThat(total).isGreaterThanOrEqualTo(BigDecimal.ZERO);
    }

    @Property
    void addingItemIncreasesTotal(@ForAll("validOrders") Order order,
                                   @ForAll("validItems") OrderItem item) {
        BigDecimal totalBefore = order.calculateTotal();
        order.addItem(item);
        BigDecimal totalAfter = order.calculateTotal();

        assertThat(totalAfter).isGreaterThanOrEqualTo(totalBefore);
    }

    @Property
    void removingItemDecreasesTotal(@ForAll("nonEmptyOrders") Order order) {
        Assume.that(!order.getItems().isEmpty());

        BigDecimal totalBefore = order.calculateTotal();
        OrderItem item = order.getItems().get(0);
        order.removeItem(item.getId());
        BigDecimal totalAfter = order.calculateTotal();

        assertThat(totalAfter).isLessThan(totalBefore);
    }

    @Provide
    Arbitrary<Order> validOrders() {
        return Combinators.combine(
            Arbitraries.longs().greaterOrEqual(1L),
            Arbitraries.longs().greaterOrEqual(1L),
            Arbitraries.lists(validItems()).ofMinSize(1).ofMaxSize(10)
        ).as((orderId, customerId, items) -> {
            Order order = new Order(orderId, customerId);
            items.forEach(order::addItem);
            return order;
        });
    }

    @Provide
    Arbitrary<OrderItem> validItems() {
        return Combinators.combine(
            Arbitraries.strings().alpha().ofMinLength(1).ofMaxLength(50),
            Arbitraries.integers().between(1, 100),
            Arbitraries.bigDecimals()
                .between(BigDecimal.valueOf(0.01), BigDecimal.valueOf(10000))
                .ofScale(2)
        ).as(OrderItem::new);
    }

    @Provide
    Arbitrary<Order> nonEmptyOrders() {
        return validOrders().filter(o -> !o.getItems().isEmpty());
    }
}
```

---

## 4. Estratégias de Propriedades

### 4.1 Padrão: Oracle

**Quando usar:** Comparar implementação custom com referência conhecida

```python
from hypothesis import given, strategies as st

# Comparar com implementação da stdlib
@given(st.lists(st.integers()))
def test_custom_sort_matches_builtin(xs):
    assert custom_sort(xs) == sorted(xs)

# Comparar duas implementações
@given(st.text())
def test_hash_implementations_match(s):
    assert hash_v1(s) == hash_v2(s)
```

### 4.2 Padrão: Roundtrip (Encode/Decode)

**Quando usar:** Serialização, parsing, conversões

```python
# JSON
@given(st.dictionaries(st.text(), st.integers()))
def test_json_roundtrip(data):
    serialized = json.dumps(data)
    deserialized = json.loads(serialized)
    assert deserialized == data

# Protobuf
@given(st.builds(UserProto))
def test_protobuf_roundtrip(user):
    serialized = user.SerializeToString()
    deserialized = UserProto()
    deserialized.ParseFromString(serialized)
    assert deserialized == user

# Base64
@given(st.binary())
def test_base64_roundtrip(data):
    encoded = base64.b64encode(data)
    decoded = base64.b64decode(encoded)
    assert decoded == data
```

### 4.3 Padrão: Metamorphic Relations

**Quando usar:** Mudanças no input produzem mudanças previsíveis no output

```python
# Se input ordenado, output também ordenado
@given(st.lists(st.integers()))
def test_sorting_preserves_order(xs):
    sorted_xs = sorted(xs)
    assert all(sorted_xs[i] <= sorted_xs[i+1] for i in range(len(sorted_xs)-1))

# Busca case-insensitive
@given(st.text(), st.text())
def test_search_case_insensitive(query, text):
    result_lower = search(query.lower(), text.lower())
    result_original = search(query, text)
    assert result_lower == result_original
```

### 4.4 Padrão: Model-Based Testing

**Quando usar:** Testar sequências de operações (state machines)

```python
from hypothesis.stateful import RuleBasedStateMachine, rule, invariant

class ShoppingCartStateMachine(RuleBasedStateMachine):

    def __init__(self):
        super().__init__()
        self.cart = ShoppingCart()
        self.model = {}  # Modelo simplificado

    @rule(item_id=st.integers(min_value=1, max_value=100),
          quantity=st.integers(min_value=1, max_value=10))
    def add_item(self, item_id, quantity):
        self.cart.add(item_id, quantity)
        self.model[item_id] = self.model.get(item_id, 0) + quantity

    @rule(item_id=st.integers(min_value=1, max_value=100))
    def remove_item(self, item_id):
        self.cart.remove(item_id)
        self.model.pop(item_id, None)

    @invariant()
    def total_matches_model(self):
        assert self.cart.total_items() == sum(self.model.values())

    @invariant()
    def items_match_model(self):
        for item_id, quantity in self.model.items():
            assert self.cart.get_quantity(item_id) == quantity

TestShoppingCart = ShoppingCartStateMachine.TestCase
```

---

## 5. Shrinking e Debugging

### 5.1 O que é Shrinking?

**Problema:** Property falha com input gigante

```python
# Falha encontrada:
xs = [47382, -9284, 0, 5920, ..., 2847]  # 500 elementos
```

**Shrinking:** Reduzir automaticamente para menor input que ainda falha

```python
# Após shrinking:
xs = [0, -1]  # Mínimo que reproduz o bug
```

### 5.2 Estratégias de Shrinking

**Hypothesis faz automaticamente:**

```python
from hypothesis import given, strategies as st, settings, Phase

@given(st.lists(st.integers(), min_size=1))
@settings(
    max_examples=1000,  # Quantos inputs testar
    phases=[Phase.generate, Phase.shrink]  # Explícito
)
def test_find_bug(xs):
    # Bug: crash quando há zero negativo
    result = sum(xs) / len(xs)
    assert result != float('-inf')

# Hypothesis encontra:
# - Input original: [1, 2, 3, ..., -0, ..., 999]
# - Após shrinking: [-0]
```

**Custom Shrinking (fast-check):**

```typescript
import fc from "fast-check";

// Arbitrary customizado com shrinking
const customInteger = fc.integer().map(
  (n) => n * 2, // Transform
  (n) => n / 2 // Shrink (reverso)
);

fc.assert(
  fc.property(customInteger, (n) => {
    // Property que falha
  }),
  { verbose: true } // Ver processo de shrinking
);
```

### 5.3 Reproduzir Falhas

**Hypothesis:**

```python
# Falha encontrada, Hypothesis imprime:
# Falsifying example: test_my_property(x=42, y=-1)

# Reproduzir exatamente:
from hypothesis import given, example

@given(st.integers(), st.integers())
@example(42, -1)  # Caso que falhou
def test_my_property(x, y):
    assert x + y > 0
```

**fast-check:**

```typescript
// Falha mostra seed
// "Property failed after 23 runs (seed: 1234567890)"

fc.assert(
  fc.property(fc.integer(), (n) => n > 0),
  { seed: 1234567890 } // Reproduzir exato
);
```

**jqwik:**

```java
@Property
@FromData("previousFailure")  // Reproduzir caso específico
void testProperty(@ForAll int x) {
    // ...
}

@Data
Iterable<Tuple1<Integer>> previousFailure() {
    return Table.of(42);  // Valor que falhou antes
}
```

---

## 6. Casos de Uso Avançados

### 6.1 Testing Parsers

**Problema:** Garantir que parser é inverso do printer

```python
from hypothesis import given, strategies as st

# Strategy para gerar SQL válido
sql_query = st.sampled_from([
    st.text(alphabet='abcdefghijklmnopqrstuvwxyz', min_size=1).map(lambda t: f"SELECT * FROM {t}"),
    st.integers(min_value=0).map(lambda n: f"SELECT * FROM users LIMIT {n}"),
])

@given(sql_query)
def test_sql_parser_printer_roundtrip(query):
    parsed = parse_sql(query)
    printed = print_sql(parsed)
    reparsed = parse_sql(printed)

    # Mesmo AST
    assert parsed == reparsed
```

### 6.2 Testing Distributed Systems

**Propriedade: Idempotência de Requests**

```python
from hypothesis import given, strategies as st
import requests

@given(st.uuids(), st.dictionaries(st.text(), st.integers()))
def test_idempotent_post(idempotency_key, payload):
    headers = {'Idempotency-Key': str(idempotency_key)}

    # Enviar 3x o mesmo request
    response1 = requests.post('http://api/orders', json=payload, headers=headers)
    response2 = requests.post('http://api/orders', json=payload, headers=headers)
    response3 = requests.post('http://api/orders', json=payload, headers=headers)

    # Todas devem retornar mesmo ID
    assert response1.json()['order_id'] == response2.json()['order_id']
    assert response2.json()['order_id'] == response3.json()['order_id']

    # Apenas 1 order criada no banco
    orders = requests.get(f'http://api/orders?idempotency_key={idempotency_key}').json()
    assert len(orders) == 1
```

### 6.3 Testing Compression

```python
import gzip
from hypothesis import given, strategies as st

@given(st.binary(min_size=100, max_size=10000))
def test_gzip_compresses_and_decompresses(data):
    compressed = gzip.compress(data)
    decompressed = gzip.decompress(compressed)

    # Roundtrip
    assert decompressed == data

    # Compressão reduz tamanho (dados aleatórios podem não comprimir)
    # Então testamos que NÃO aumenta absurdamente
    assert len(compressed) <= len(data) * 1.1 + 100

@given(st.binary())
def test_double_compression_doesnt_help(data):
    once = gzip.compress(data)
    twice = gzip.compress(once)

    # Segunda compressão não ajuda (dados já comprimidos são aleatórios)
    assert len(twice) >= len(once)
```

### 6.4 Testing Concurrency

```python
from hypothesis import given, strategies as st
from concurrent.futures import ThreadPoolExecutor

@given(st.lists(st.integers(), min_size=100, max_size=1000))
def test_concurrent_append_threadsafe(items):
    safe_list = ThreadSafeList()

    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(safe_list.append, item) for item in items]
        for future in futures:
            future.result()

    # Todos itens foram adicionados
    assert len(safe_list) == len(items)
    assert sorted(safe_list.to_list()) == sorted(items)
```

---

## 7. Integração com CI/CD

### 7.1 GitHub Actions

```yaml
name: Property Tests

on: [push, pull_request]

jobs:
  property-tests:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: |
          pip install hypothesis pytest

      - name: Run property tests (quick)
        run: |
          pytest tests/properties/ --hypothesis-seed=0 -v

      - name: Run property tests (extended - nightly)
        if: github.event_name == 'schedule'
        run: |
          pytest tests/properties/ \
            --hypothesis-profile=ci \
            --hypothesis-show-statistics
        env:
          HYPOTHESIS_MAX_EXAMPLES: 10000

  property-tests-nightly:
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'

    strategy:
      matrix:
        seed: [1, 2, 3, 4, 5] # Rodar com seeds diferentes

    steps:
      - uses: actions/checkout@v3
      - name: Run with seed ${{ matrix.seed }}
        run: |
          pytest tests/properties/ --hypothesis-seed=${{ matrix.seed }}
```

### 7.2 Configuração Hypothesis

**pytest.ini:**

```ini
[pytest]
markers =
    property: Property-based tests

[hypothesis]
# Perfil padrão (fast feedback)
default:
  max_examples = 100
  derandomize = true

# Perfil CI (mais rigoroso)
ci:
  max_examples = 1000
  deadline = 5000  # 5s timeout por exemplo

# Perfil nightly (exaustivo)
nightly:
  max_examples = 10000
  deadline = None
```

**Uso:**

```python
from hypothesis import given, settings, strategies as st

@given(st.integers())
@settings(max_examples=100)  # Override
def test_fast(n):
    pass

@given(st.integers())
@settings(max_examples=10000)  # Exaustivo
def test_thorough(n):
    pass
```

### 7.3 Cobertura de Propriedades

**Medir cobertura:**

```bash
# Com pytest-cov
pytest tests/properties/ --cov=src --cov-report=html --hypothesis-show-statistics

# Hypothesis mostra:
# - Quantos exemplos testados
# - Distribuição de inputs
# - Cobertura de branches
```

---

## 8. Boas Práticas

### 8.1 Escolhendo Boas Propriedades

**✅ Boas Propriedades:**

1. **Invariantes** - Sempre verdadeiro independente do input

   ```python
   @given(st.lists(st.integers()))
   def test_sorted_is_ordered(xs):
       sorted_xs = sorted(xs)
       assert all(sorted_xs[i] <= sorted_xs[i+1] for i in range(len(sorted_xs)-1))
   ```

2. **Simetrias** - Operações que comutam

   ```python
   @given(st.integers(), st.integers())
   def test_add_commutative(a, b):
       assert a + b == b + a
   ```

3. **Roundtrips** - Encode/decode
   ```python
   @given(st.binary())
   def test_base64_roundtrip(data):
       assert base64.b64decode(base64.b64encode(data)) == data
   ```

**❌ Propriedades Fracas (evitar):**

1. **Tautologias**

   ```python
   @given(st.integers())
   def test_weak(n):
       result = f(n)
       assert result == f(n)  # Obviamente verdade
   ```

2. **Reimplementar código**
   ```python
   @given(st.lists(st.integers()))
   def test_bad(xs):
       # Reimplementando sort (não testa nada)
       sorted_xs = sorted(xs)
       assert sorted_xs == manually_sort(xs)
   ```

### 8.2 Performance

**Gerar dados eficientemente:**

```python
# ❌ Lento - valida após geração
@given(st.lists(st.integers()).filter(lambda xs: len(xs) == 10))
def test_slow(xs):
    pass

# ✅ Rápido - gera correto
@given(st.lists(st.integers(), min_size=10, max_size=10))
def test_fast(xs):
    pass
```

**Limitar complexidade:**

```python
from hypothesis import given, strategies as st, assume

@given(st.lists(st.integers()))
def test_with_assumption(xs):
    assume(len(xs) < 1000)  # Rejeitar inputs muito grandes
    # ...
```

### 8.3 Debuggabilidade

**Adicionar contexto:**

```python
from hypothesis import given, note

@given(st.integers(), st.integers())
def test_with_notes(a, b):
    note(f"Testing with a={a}, b={b}")
    result = divide(a, b)
    note(f"Result: {result}")
    assert result * b == a
```

**Exemplo detalhado:**

```python
from hypothesis import given, strategies as st, note, event

@given(st.lists(st.integers(), min_size=1))
def test_median_property(xs):
    sorted_xs = sorted(xs)
    median = calculate_median(xs)

    # Debug info
    note(f"Input size: {len(xs)}")
    note(f"Min: {min(xs)}, Max: {max(xs)}")
    note(f"Median: {median}")

    # Classificar exemplos
    if len(xs) < 10:
        event("small list")
    elif len(xs) < 100:
        event("medium list")
    else:
        event("large list")

    # Propriedade
    assert sorted_xs[len(sorted_xs)//2 - 1] <= median <= sorted_xs[len(sorted_xs)//2]
```

### 8.4 Quando Não Usar Property-Based Testing

**❌ Evitar quando:**

1. **Lógica de negócio específica** - "Black Friday deve ter 20% desconto"
2. **UI/UX** - "Botão deve ser azul"
3. **Integrações externas sem mock** - API do Stripe (custo)
4. **Performance crítica** - Property tests são lentos

**✅ Combinar com example-based:**

```python
# Example-based para casos específicos
def test_black_friday_discount():
    order = Order(items=[Item(price=100)])
    discount = calculate_discount(order, date="2024-11-29")
    assert discount == 20.0

# Property-based para invariantes
@given(st.builds(Order), st.dates())
def test_discount_never_negative(order, date):
    discount = calculate_discount(order, date)
    assert discount >= 0
```

---

## 📊 Checklist de Implementação

### Setup Inicial

- [ ] Instalar ferramenta (Hypothesis/fast-check/jqwik)
- [ ] Configurar profiles (default/ci/nightly)
- [ ] Adicionar ao CI/CD
- [ ] Definir seed fixa para reprodutibilidade

### Escrever Propriedades

- [ ] Identificar invariantes do domínio
- [ ] Criar estratégias/arbitraries customizados
- [ ] Adicionar assumes quando necessário
- [ ] Documentar propriedades (comentários)

### Debugging

- [ ] Configurar verbose mode
- [ ] Adicionar `note()` para contexto
- [ ] Usar `example()` para casos conhecidos
- [ ] Salvar seeds de falhas

### CI/CD

- [ ] Fast feedback (100 examples)
- [ ] Nightly builds (10k examples)
- [ ] Notificações de falhas
- [ ] Dashboard de cobertura

---

## 📚 Recursos

### Ferramentas

- **Python**: [Hypothesis](https://hypothesis.readthedocs.io/)
- **JavaScript**: [fast-check](https://fast-check.dev/)
- **Java**: [jqwik](https://jqwik.net/)
- **Scala**: [ScalaCheck](https://scalacheck.org/)
- **Haskell**: [QuickCheck](http://www.cse.chalmers.se/~rjmh/QuickCheck/)

### Artigos

- [Choosing properties for property-based testing](https://fsharpforfunandprofit.com/posts/property-based-testing-2/)
- [Metamorphic Testing](https://www.hillelwayne.com/post/metamorphic-testing/)
- [How to specify it in Z](https://spivey.oriel.ox.ac.uk/corner/How_to_specify_it)

### Livros

- **Property-Based Testing with PropEr, Erlang, and Elixir** (Fred Hebert)
- **Haskell: The Craft of Functional Programming** (Simon Thompson) - Cap. QuickCheck

---

**Próximos passos:**

- Ler [Supply Chain Security](supply-chain-security.md)
- Ver [Trace-Based Testing](trace-based-testing.md)
- Consultar [Glossário](../12-taxonomia/glossario.md)
