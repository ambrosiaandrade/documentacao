# 🎯 Fuzz Testing - Especializações Avançadas

## Índice

1. [Introdução](#1-introdução)
2. [Fuzzing vs Property-Based](#2-fuzzing-vs-property-based)
3. [Ferramentas Open Source](#3-ferramentas-open-source)
4. [Coverage-Guided Fuzzing](#4-coverage-guided-fuzzing)
5. [Fuzzing em Java](#5-fuzzing-em-java)
6. [Fuzzing APIs](#6-fuzzing-apis)
7. [Métricas](#7-métricas)
8. [Boas Práticas](#8-boas-práticas)

---

## 1. Introdução

### O que é Fuzz Testing?

**Definição:** Técnica automatizada que fornece inputs aleatórios, malformados ou inesperados para encontrar bugs, crashes e vulnerabilidades.

**Objetivo:** Descobrir comportamento inesperado através de **mutação agressiva** de inputs.

### Tipos de Fuzzing

**1. Black-box Fuzzing:**

- Sem conhecimento do código
- Inputs completamente aleatórios
- Rápido mas ineficiente

**2. Coverage-Guided (Grey-box):**

- Monitora cobertura de código
- Mutações inteligentes para explorar novos caminhos
- **Mais eficaz** (AFL, libFuzzer)

**3. White-box Fuzzing:**

- Análise completa do código
- Symbolic execution
- Lento mas preciso

---

## 2. Fuzzing vs Property-Based

### Comparação

| Aspecto         | Fuzzing                    | Property-Based Testing       |
| --------------- | -------------------------- | ---------------------------- |
| **Objetivo**    | Encontrar crashes          | Validar propriedades lógicas |
| **Input**       | Bytes aleatórios           | Dados estruturados           |
| **Estratégia**  | Mutação agressiva          | Geração inteligente          |
| **Feedback**    | Cobertura de código        | Asserções                    |
| **Quando Usar** | Parsers, APIs, C/C++       | Lógica de negócio            |
| **Exemplo**     | `[0x00, 0xFF, 0xDEADBEEF]` | `add(a, b) == add(b, a)`     |

### Quando Usar Fuzzing

✅ **Use Fuzzing para:**

- Parsers (JSON, XML, protobuf)
- Decoders (imagem, vídeo, áudio)
- Network protocols
- File format handlers
- Código C/C++/Rust (memory safety)
- APIs com inputs complexos

✅ **Use Property-Based para:**

- Lógica de negócio pura
- Algoritmos matemáticos
- Transformações de dados
- Código funcional

**Melhor Juntos:** Combine ambos para máxima eficácia.

---

## 3. Ferramentas Open Source

### 3.1 AFL++ (American Fuzzy Lop)

**O que é:** Coverage-guided fuzzer para C/C++, considerado estado da arte.

**Instalação (Linux):**

```bash
git clone https://github.com/AFLplusplus/AFLplusplus
cd AFLplusplus
make
sudo make install
```

**Exemplo - Fuzz Parser JSON:**

```c
// json_parser.c
#include <stdio.h>
#include <stdlib.h>

extern void parse_json(const char* data, size_t size);

int main(int argc, char** argv) {
    if (argc < 2) return 1;

    FILE* f = fopen(argv[1], "rb");
    if (!f) return 1;

    fseek(f, 0, SEEK_END);
    size_t size = ftell(f);
    fseek(f, 0, SEEK_SET);

    char* data = malloc(size);
    fread(data, 1, size, f);
    fclose(f);

    parse_json(data, size);

    free(data);
    return 0;
}
```

**Compilar com instrumentação:**

```bash
afl-gcc -o json_parser json_parser.c -fsanitize=address
```

**Executar:**

```bash
# Criar diretório com inputs seed
mkdir -p input
echo '{"key": "value"}' > input/seed1.json

# Criar diretório de output
mkdir output

# Fuzz!
afl-fuzz -i input -o output -- ./json_parser @@
```

**Output:**

```
american fuzzy lop ++4.00a
┌─ process timing ─────────────────────────────────┐
│        run time : 0 days, 2 hrs, 15 min, 8 sec   │
│   last new find : 0 days, 0 hrs, 3 min, 42 sec   │
│last saved crash : none seen yet                   │
├─ overall results ────────────────────────────────┤
│   cycles done : 412                               │
│   corpus size : 84                                │
│ total crashes : 3                                 │
│  total hangs : 1                                  │
├─ cycle progress ─────────────────────────────────┤
│  now processing : 67 (79.8%)                      │
│ paths timed out : 0 (0.00%)                       │
├─ map coverage ───────────────────────────────────┤
│    map density : 2.14% / 4.78%                    │
│ count coverage : 3.21 bits/tuple                  │
└───────────────────────────────────────────────────┘
```

### 3.2 libFuzzer (LLVM)

**O que é:** In-process, coverage-guided fuzzer integrado ao LLVM.

**Exemplo - Fuzz função específica:**

```cpp
// fuzz_target.cpp
#include <stdint.h>
#include <stddef.h>
#include <string>

extern bool ValidateUserInput(const std::string& input);

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    std::string input(reinterpret_cast<const char*>(data), size);

    // Função testada
    ValidateUserInput(input);

    return 0;  // Retornar 0 sempre (crashes são detectados automaticamente)
}
```

**Compilar:**

```bash
clang++ -g -O1 -fsanitize=fuzzer,address fuzz_target.cpp -o fuzz_target
```

**Executar:**

```bash
./fuzz_target -max_total_time=600  # 10 minutos
```

### 3.3 Jazzer (Java)

**O que é:** Coverage-guided fuzzer para JVM (Java, Kotlin, Scala).

**Maven:**

```xml
<dependency>
    <groupId>com.code-intelligence</groupId>
    <artifactId>jazzer-junit</artifactId>
    <version>0.22.1</version>
    <scope>test</scope>
</dependency>
```

**Exemplo (Java 17+):**

```java
import com.code_intelligence.jazzer.junit.FuzzTest;
import com.code_intelligence.jazzer.api.FuzzedDataProvider;
import java.net.URL;
import java.net.MalformedURLException;

class UrlParserFuzzTest {

    @FuzzTest
    void fuzzUrlParser(FuzzedDataProvider data) {
        var url = data.consumeRemainingAsString();

        try {
            // Testar parser
            var parsed = new URL(url);

            // Se não crashou, validar propriedades básicas
            assertThat(parsed.toString()).isNotNull();

        } catch (MalformedURLException e) {
            // Exceção esperada para inputs inválidos - OK
        } catch (Exception e) {
            // Qualquer outra exceção = BUG
            throw new AssertionError("Unexpected exception", e);
        }
    }

    @FuzzTest
    void fuzzJsonDeserializer(FuzzedDataProvider data) {
        var json = data.consumeRemainingAsString();

        try {
            objectMapper.readValue(json, MyClass.class);
        } catch (JsonProcessingException e) {
            // OK - input inválido
        } catch (OutOfMemoryError | StackOverflowError e) {
            // BUG! - DoS vulnerability
            fail("DoS vulnerability found: " + e.getMessage());
        }
    }
}
```

**Executar:**

```bash
mvn test -Djazzer.instrument=com.example.*
```

### 3.4 RESTler (API Fuzzing)

**O que é:** Fuzzer para APIs REST, gera sequências de requests.

**Instalação:**

```bash
pip install restler-fuzzer
```

**Gerar Fuzzer Config:**

```bash
# A partir de OpenAPI spec
restler compile --api_spec swagger.json
```

**Executar:**

```bash
restler fuzz --grammar_file Compile/grammar.py \
  --dictionary_file Compile/dict.json \
  --settings Compile/engine_settings.json \
  --time_budget 2
```

**Exemplo de Bug Encontrado:**

```
[BUG] Status 500 Internal Server Error
Request:
  POST /api/orders
  Body: {"quantity": -999999999, "item_id": "\\x00\\xFF"}

Stack Trace:
  ArithmeticException: Integer overflow in calculateTotal()
```

---

## 4. Coverage-Guided Fuzzing

### 4.1 Como Funciona

**Algoritmo:**

```
1. Iniciar com corpus seed (inputs válidos)
2. Loop:
   a. Selecionar input do corpus
   b. Mutar input (bit flips, arithmetic, interesting values)
   c. Executar target com input mutado
   d. Se nova cobertura alcançada:
      └─> Adicionar ao corpus
   e. Se crash detectado:
      └─> Salvar input crasher
   f. Se hang detectado:
      └─> Salvar input hang
```

**Mutações Comuns:**

```
Original: [0x48, 0x65, 0x6C, 0x6C, 0x6F]  # "Hello"

Bit flip:       [0x49, 0x65, 0x6C, 0x6C, 0x6F]  # Trocar 1 bit
Byte flip:      [0xFF, 0x65, 0x6C, 0x6C, 0x6F]  # Trocar byte inteiro
Arithmetic:     [0x49, 0x65, 0x6C, 0x6C, 0x6F]  # +1
Interesting:    [0x00, 0x65, 0x6C, 0x6C, 0x6F]  # 0, -1, MAX_INT
Dictionary:     [0x41, 0x41, 0x41, 0x41, 0x41]  # "AAAA" (conhecido)
```

### 4.2 Corpus Management

**Bom Corpus Seed:**

```
input/
├── valid_simple.json       # {"a": 1}
├── valid_nested.json       # {"a": {"b": 2}}
├── valid_array.json        # [1, 2, 3]
├── valid_string.json       # {"s": "hello"}
├── valid_large.json        # 1MB de JSON válido
└── edge_unicode.json       # {"emoji": "🎉"}
```

**Corpus Minimization:**

```bash
# Remover inputs redundantes (mesma cobertura)
afl-cmin -i output/queue -o minimized_corpus -- ./target @@
```

**Distill (reduzir tamanho mantendo cobertura):**

```bash
afl-tmin -i crash.bin -o minimized_crash.bin -- ./target @@
```

---

## 5. Fuzzing em Java

### 5.1 Jazzer Avançado

**Custom Mutator (Java 17+ Records):**

```java
import com.code_intelligence.jazzer.api.FuzzerSecurityIssueHigh;
import com.code_intelligence.jazzer.mutation.annotation.NotNull;
import com.code_intelligence.jazzer.mutation.annotation.InRange;
import com.code_intelligence.jazzer.mutation.annotation.WithUtf8Length;

@FuzzTest
void fuzzWithCustomData(@NotNull CustomData data) {
    // data é automaticamente gerado
    service.process(data.value());
}

// Java 17+ Record - estrutura customizada imutável
record CustomData(
    @InRange(min = 0, max = 1000) int value,
    @WithUtf8Length(min = 1, max = 100) String name
) {}
```

**Detectar Vulnerabilidades (Java 17+):**

```java
@FuzzTest
void fuzzSqlQuery(FuzzedDataProvider data) {
    var userInput = data.consumeRemainingAsString();

    // Detectar SQL Injection
    if (userInput.contains("' OR '1'='1")) {
        throw new FuzzerSecurityIssueHigh("SQL Injection detected!");
    }

    // ❌ EXEMPLO DE CÓDIGO VULNERÁVEL (não usar em produção!)
    var query = "SELECT * FROM users WHERE name = '" + userInput + "'";

    try {
        jdbcTemplate.queryForList(query);
    } catch (DataAccessException e) {
        // Input inválido - OK
    }
}
```

### 5.2 JQF (Java Quick Fuzzer)

**Maven:**

```xml
<dependency>
    <groupId>edu.berkeley.cs.jqf</groupId>
    <artifactId>jqf-fuzz</artifactId>
    <version>2.0</version>
</dependency>
```

**Exemplo (Java 17+):**

```java
import edu.berkeley.cs.jqf.fuzz.Fuzz;
import edu.berkeley.cs.jqf.fuzz.JQF;
import com.pholser.junit.quickcheck.From;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import java.io.StringReader;
import java.io.IOException;

@RunWith(JQF.class)
public class XmlParserFuzzTest {

    @Fuzz
    public void fuzzXmlParser(@From(XmlDocumentGenerator.class) String xml) {
        try {
            var builder = factory.newDocumentBuilder();
            var doc = builder.parse(new InputSource(new StringReader(xml)));

            // Validar estrutura básica
            assertThat(doc.getDocumentElement()).isNotNull();

        } catch (SAXException | IOException e) {
            // Input inválido - esperado
        }
    }
}
```

**Executar:**

```bash
mvn jqf:fuzz -Dclass=XmlParserFuzzTest -Dmethod=fuzzXmlParser -Dtime=10m
```

---

## 6. Fuzzing APIs

### 6.1 REST API Fuzzing

**Schemathesis (OpenAPI):**

```python
import schemathesis

schema = schemathesis.from_uri("http://localhost:8080/v3/api-docs")

@schema.parametrize()
def test_api(case):
    response = case.call()

    # Validar status codes esperados
    assert response.status_code < 500, f"Server error: {response.status_code}"

    # Validar schema de resposta
    case.validate_response(response)
```

**Executar:**

```bash
schemathesis run http://localhost:8080/v3/api-docs \
  --checks all \
  --hypothesis-max-examples=1000
```

**Custom Checks:**

```python
@schema.parametrize()
@settings(max_examples=500)
def test_api_security(case):
    response = case.call()

    # Detectar information disclosure
    assert "stack trace" not in response.text.lower()
    assert "exception" not in response.text.lower()

    # Validar security headers
    assert "X-Content-Type-Options" in response.headers
    assert response.headers.get("X-Frame-Options") == "DENY"
```

### 6.2 GraphQL Fuzzing

**GraphQL Fuzzer:**

```python
from graphql_fuzzer import GraphQLFuzzer

fuzzer = GraphQLFuzzer(
    endpoint="http://localhost:4000/graphql",
    introspection=True
)

# Fuzz queries
for query in fuzzer.generate_queries(n=1000):
    response = requests.post(
        "http://localhost:4000/graphql",
        json={"query": query}
    )

    # Detectar crashes
    assert response.status_code != 500

    # Detectar DoS (timeout)
    assert response.elapsed.total_seconds() < 5
```

---

## 7. Métricas

### 7.1 Métricas-Chave

**Coverage Increase:**

```
Coverage Gain = (Cobertura_Após_Fuzz - Cobertura_Inicial) / Cobertura_Inicial × 100

Meta: +10-30% para parsers complexos
```

**Bug Detection Rate:**

```
Bug Rate = Total_Bugs_Encontrados / Tempo_Execução (bugs/hora)

Típico: 0.5-2 bugs/hora em código não-fuzzed previamente
```

**Corpus Growth:**

```
Corpus Growth = Tamanho_Corpus_Final / Tamanho_Corpus_Inicial

Ideal: 5-20x (muitos novos caminhos descobertos)
```

### 7.2 Coleta Automática

**Script:**

```bash
#!/bin/bash
# collect_fuzz_metrics.sh

FUZZER_OUTPUT="./output"
DURATION_HOURS=4

# Executar fuzzer
timeout ${DURATION_HOURS}h afl-fuzz -i input -o $FUZZER_OUTPUT -- ./target @@

# Coletar métricas
CRASHES=$(ls $FUZZER_OUTPUT/crashes/ | wc -l)
HANGS=$(ls $FUZZER_OUTPUT/hangs/ | wc -l)
CORPUS_SIZE=$(ls $FUZZER_OUTPUT/queue/ | wc -l)

EXECS=$(grep "execs_done" $FUZZER_OUTPUT/fuzzer_stats | awk '{print $3}')
EXEC_SPEED=$(grep "execs_per_sec" $FUZZER_OUTPUT/fuzzer_stats | awk '{print $3}')

echo "Fuzzing Metrics:"
echo "  Duration: ${DURATION_HOURS}h"
echo "  Total Execs: $EXECS"
echo "  Exec Speed: $EXEC_SPEED/sec"
echo "  Corpus Size: $CORPUS_SIZE"
echo "  Crashes: $CRASHES"
echo "  Hangs: $HANGS"

# Alertar se bugs encontrados
if [ $CRASHES -gt 0 ] || [ $HANGS -gt 0 ]; then
    echo "⚠️  BUGS ENCONTRADOS!"
    exit 1
fi
```

---

## 8. Boas Práticas

### ✅ DO

1. **Combinar com Sanitizers**

   ```bash
   # AddressSanitizer (memory bugs)
   clang -fsanitize=address,fuzzer

   # UndefinedBehaviorSanitizer
   clang -fsanitize=undefined,fuzzer
   ```

2. **Corpus Seed de Qualidade**

   - Começar com inputs válidos
   - Cobrir diferentes formatos/estruturas
   - Incluir edge cases conhecidos

3. **Continuous Fuzzing**

   ```yaml
   # .github/workflows/fuzz.yml
   - name: Continuous Fuzzing
     run: |
       ./fuzz_target -max_total_time=3600
       if [ $? -ne 0 ]; then
         echo "Crash found!"
         exit 1
       fi
   ```

4. **Reproduzir Bugs**

   ```bash
   # Crash encontrado
   ./target output/crashes/id:000000,sig:06,src:000042

   # Com debugger
   gdb --args ./target crash.bin
   ```

### ❌ DON'T

1. **Não fuzz código já validado por outros meios**
2. **Não ignorar crashes intermitentes** - São os mais perigosos
3. **Não fuzz sem timeouts** - Pode gerar hangings infinitos
4. **Não commit crashers no repo** - Criar issues separados

---

## 📊 Resumo

| Ferramenta       | Linguagem    | Uso                          |
| ---------------- | ------------ | ---------------------------- |
| **AFL++**        | C/C++        | Binários compilados          |
| **libFuzzer**    | C/C++/Rust   | In-process, integrado LLVM   |
| **Jazzer**       | Java/Kotlin  | JVM, integração JUnit        |
| **JQF**          | Java         | QuickCheck + Coverage-guided |
| **RESTler**      | APIs REST    | Fuzzing de endpoints         |
| **Schemathesis** | APIs OpenAPI | Property-based API testing   |

---

## 🎯 Checklist

- [ ] Identificar targets (parsers, decoders, APIs)
- [ ] Preparar corpus seed de qualidade
- [ ] Configurar sanitizers (ASan, UBSan)
- [ ] Executar fuzzing (mínimo 24h)
- [ ] Analisar crashes e hangs
- [ ] Criar regression tests para bugs
- [ ] Integrar no CI/CD
- [ ] Continuous fuzzing em produção (opcional)
- [ ] Métricas tracking (coverage, bugs/hora)
- [ ] Documentar findings e fixes
