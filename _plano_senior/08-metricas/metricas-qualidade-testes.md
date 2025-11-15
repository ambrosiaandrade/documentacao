# 📊 Métricas de Qualidade de Testes

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Mutation Score](#2-mutation-score)
3. [Diff Coverage](#3-diff-coverage)
4. [Flaky Rate](#4-flaky-rate)
5. [Lead Time de Testes](#5-lead-time-de-testes)
6. [Cobertura de Código](#6-cobertura-de-código)
7. [Métricas de Resiliência](#7-métricas-de-resiliência)
8. [Métricas de Performance](#8-métricas-de-performance)
9. [Métricas de Negócio](#9-métricas-de-negócio)
10. [Dashboard e Visualização](#10-dashboard-e-visualização)

---

## 1. Visão Geral

### 🎯 Por que Métricas?

Métricas objetivas transformam qualidade de testes de conceito subjetivo em prática mensurável. Permitem:

- **Decisões baseadas em dados**: Quality gates automatizados
- **Visibilidade**: Progresso e regressões ficam óbvios
- **Melhoria contínua**: Identificação de padrões e tendências
- **Accountability**: Responsabilidade clara sobre qualidade

### 📈 Princípios

1. **Mensurável**: Deve poder ser coletada automaticamente
2. **Acionável**: Deve orientar ações concretas
3. **Relevante**: Deve correlacionar com qualidade real
4. **Simples**: Deve ser compreensível por todos

### ⚠️ Anti-patterns

- ❌ Usar apenas cobertura de linhas como métrica única
- ❌ Não estabelecer baselines e metas
- ❌ Métricas como fim (gaming the metrics)
- ❌ Ignorar contexto e trade-offs

---

## 2. Mutation Score

### 🎯 Conceito

**Mutation Score** mede a eficácia dos testes em detectar bugs através da introdução deliberada de mutações (bugs sintéticos) no código.

**Fórmula:**

```
Mutation Score = (Mutantes Mortos / Mutantes Totais) × 100
```

- **Mutante Morto**: Mutação que faz pelo menos 1 teste falhar (✅ bom)
- **Mutante Sobrevivente**: Mutação que passa em todos os testes (❌ gap)

### 🧪 Exemplo Prático

**Código Original:**

```java
public class DiscountCalculator {
    public double calculateDiscount(double price, int quantity) {
        if (quantity >= 10) {
            return price * 0.9; // 10% desconto
        }
        return price;
    }
}
```

**Mutações Possíveis:**

```java
// Mutação 1: Operador relacional (>= → >)
if (quantity > 10) { ... }

// Mutação 2: Constante (10 → 11)
if (quantity >= 11) { ... }

// Mutação 3: Operador aritmético (* → /)
return price / 0.9;

// Mutação 4: Constante (0.9 → 0.8)
return price * 0.8;

// Mutação 5: Remoção de condição
return price * 0.9; // sempre aplica desconto
```

**Teste Básico (Mata 3 de 5):**

```java
@Test
void deveAplicarDescontoPara10Itens() {
    var calc = new DiscountCalculator();
    assertEquals(90.0, calc.calculateDiscount(100.0, 10));
}
// Mata: Mutação 2, 3, 5
// Sobrevive: Mutação 1 (quantity > 10), Mutação 4 (0.9 vs 0.8)
// Mutation Score: 60%
```

**Teste Completo (Mata 5 de 5):**

```java
@ParameterizedTest
@CsvSource({
    "100.0, 9, 100.0",   // boundary inferior
    "100.0, 10, 90.0",   // boundary exato (mata Mutação 1)
    "100.0, 11, 90.0",   // acima do limite
    "50.0, 10, 45.0"     // valor diferente (mata Mutação 4)
})
void deveCalcularDescontoCorretamente(double price, int qty, double expected) {
    assertEquals(expected, new DiscountCalculator().calculateDiscount(price, qty));
}
// Mutation Score: 100%
```

### 🔧 Ferramentas

#### PITest (Java)

**pom.xml:**

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
            <param>com.example.core.*</param>
        </targetClasses>
        <targetTests>
            <param>com.example.core.*</param>
        </targetTests>
        <mutators>
            <mutator>DEFAULTS</mutator>
        </mutators>
        <outputFormats>
            <outputFormat>HTML</outputFormat>
            <outputFormat>XML</outputFormat>
        </outputFormats>
        <timestampedReports>false</timestampedReports>
    </configuration>
</plugin>
```

**Execução:**

```bash
mvn org.pitest:pitest-maven:mutationCoverage
# Relatório em: target/pit-reports/index.html
```

#### Stryker (JavaScript/TypeScript)

**stryker.conf.json:**

```json
{
  "packageManager": "npm",
  "reporters": ["html", "clear-text", "progress", "dashboard"],
  "testRunner": "jest",
  "coverageAnalysis": "perTest",
  "mutate": ["src/**/*.ts", "!src/**/*.spec.ts"],
  "thresholds": {
    "high": 80,
    "low": 60,
    "break": 50
  }
}
```

**Execução:**

```bash
npx stryker run
# Relatório em: reports/mutation/html/index.html
```

### 📊 Metas e Limiares

| Contexto                      | Meta  | Limiar Crítico | Ação                         |
| ----------------------------- | ----- | -------------- | ---------------------------- |
| **Código de negócio crítico** | ≥ 90% | < 80%          | ❌ Bloquear merge            |
| **Código de negócio padrão**  | ≥ 75% | < 60%          | ⚠️ Review obrigatório        |
| **Utilitários**               | ≥ 60% | < 40%          | 📝 Documentar dívida         |
| **Código legado**             | ≥ 40% | N/A            | 📈 Melhorar incrementalmente |

### 🎯 Estratégias de Melhoria

#### 1. Priorizar Mutantes Sobreviventes

**Script de análise:**

```bash
# Extrair mutantes sobreviventes críticos
grep "SURVIVED" target/pit-reports/mutations.xml \
  | grep -E "(CONDITIONAL|MATH|RETURN)" \
  | sort | uniq -c | sort -rn
```

#### 2. Foco em Boundaries

```java
// ❌ Teste fraco
@Test
void testeGenerico() {
    assertTrue(validator.isValid(5));
}

// ✅ Teste forte (mata mutações de boundary)
@ParameterizedTest
@ValueSource(ints = {0, 1, 9, 10, 11, 99, 100, 101})
void deveValidarBoundaries(int value) {
    boolean expected = value >= 1 && value <= 100;
    assertEquals(expected, validator.isValid(value));
}
```

#### 3. Testar Negações

```java
// ❌ Testa apenas happy path
@Test
void deveRetornarUsuarioQuandoExistir() {
    when(repo.findById(1L)).thenReturn(Optional.of(user));
    assertNotNull(service.getUser(1L));
}

// ✅ Testa ambos os caminhos
@Test
void deveRetornarUsuarioQuandoExistir() {
    when(repo.findById(1L)).thenReturn(Optional.of(user));
    assertEquals("John", service.getUser(1L).getName());
}

@Test
void deveLancarExcecaoQuandoNaoExistir() {
    when(repo.findById(999L)).thenReturn(Optional.empty());
    assertThrows(NotFoundException.class, () -> service.getUser(999L));
}
```

### 📈 Coleta Contínua

**GitHub Actions:**

```yaml
name: Mutation Testing

on:
  pull_request:
    branches: [main]

jobs:
  pitest:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0 # histórico completo para diff

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: 17

      - name: Run Mutation Tests
        run: mvn clean test org.pitest:pitest-maven:mutationCoverage

      - name: Extract Score
        id: score
        run: |
          SCORE=$(grep -oP 'mutationCoverage>\K[0-9]+' target/pit-reports/mutations.xml | head -1)
          echo "score=$SCORE" >> $GITHUB_OUTPUT

      - name: Check Threshold
        run: |
          if [ ${{ steps.score.outputs.score }} -lt 70 ]; then
            echo "❌ Mutation score (${{ steps.score.outputs.score }}%) abaixo do limiar (70%)"
            exit 1
          fi
          echo "✅ Mutation score: ${{ steps.score.outputs.score }}%"

      - name: Upload Report
        uses: actions/upload-artifact@v3
        with:
          name: pitest-report
          path: target/pit-reports/
```

### ⚠️ Pitfalls

1. **Mutação de código não crítico**: Foco em paths importantes
2. **Timeouts**: Ajustar timeout para testes lentos
3. **Equivalentes**: Alguns mutantes são logicamente equivalentes (falso positivo)
4. **Custo**: Mutation testing é lento (rodar incremental ou agendado)

---

## 3. Diff Coverage

### 🎯 Conceito

**Diff Coverage** mede a cobertura de testes **apenas nas linhas modificadas** em um PR/commit. Mais relevante que cobertura total para quality gates.

**Fórmula:**

```
Diff Coverage = (Linhas Modificadas Cobertas / Linhas Modificadas Totais) × 100
```

### 🧪 Exemplo

**Git Diff:**

```diff
 public class OrderService {
     public void createOrder(Order order) {
         validateOrder(order);
+        if (order.getTotal() > 1000) {
+            applyVipDiscount(order);
+        }
         repository.save(order);
     }
 }
```

**Análise:**

- **Linhas modificadas**: 3 (linhas com `+`)
- **Linhas cobertas por testes**: 2
- **Diff Coverage**: 66.7%

### 🔧 Ferramentas

#### Codecov

**codecov.yml:**

```yaml
coverage:
  status:
    project:
      default:
        target: auto # mantém cobertura total
        threshold: 0.5% # tolerância
    patch: # diff coverage
      default:
        target: 80% # linhas novas devem ter 80%+
        threshold: 5%
        if_ci_failed: error

comment:
  layout: "diff, files"
  behavior: default
```

**GitHub Actions:**

```yaml
- name: Upload Coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    token: ${{ secrets.CODECOV_TOKEN }}
    files: ./target/site/jacoco/jacoco.xml
    flags: unittests
    fail_ci_if_error: true
```

#### Diff-Cover (Python)

```bash
# Gerar coverage
pytest --cov=src --cov-report=xml

# Analisar diff
diff-cover coverage.xml --compare-branch=origin/main --fail-under=80

# Saída:
# Diff Coverage: 85.7%
# src/order_service.py (3 lines): 66.7%
#   Line 42: NOT COVERED
# ✅ PASSED (threshold: 80%)
```

#### JaCoCo + Diffblue Cover (Java)

**Maven Plugin:**

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <executions>
        <execution>
            <id>default-prepare-agent</id>
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
        <execution>
            <id>check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>BUNDLE</element>
                        <limits>
                            <limit>
                                <counter>LINE</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**Script de Diff Coverage:**

```bash
#!/bin/bash
# scripts/diff-coverage.sh

BASE_BRANCH=${1:-origin/main}
THRESHOLD=${2:-80}

# Gerar coverage report
mvn clean test jacoco:report

# Obter linhas modificadas
git diff $BASE_BRANCH --unified=0 -- '*.java' \
  | grep -E '^\+' | grep -v '^\+\+\+' \
  | awk '{print $1}' > /tmp/changed-lines.txt

# Analisar coverage das linhas modificadas
python3 scripts/analyze-diff-coverage.py \
  --coverage target/site/jacoco/jacoco.xml \
  --changed /tmp/changed-lines.txt \
  --threshold $THRESHOLD
```

**analyze-diff-coverage.py:**

```python
import xml.etree.ElementTree as ET
import sys
import argparse

def analyze_diff_coverage(coverage_file, changed_lines_file, threshold):
    tree = ET.parse(coverage_file)
    root = tree.getroot()

    total_changed = 0
    covered_changed = 0

    with open(changed_lines_file, 'r') as f:
        changed_files = {}
        for line in f:
            # Parse: src/main/java/com/example/Order.java:42
            parts = line.strip().split(':')
            if len(parts) == 2:
                file_path, line_num = parts
                if file_path not in changed_files:
                    changed_files[file_path] = []
                changed_files[file_path].append(int(line_num))

    for package in root.findall('.//package'):
        for sourcefile in package.findall('.//sourcefile'):
            file_name = sourcefile.get('name')

            for file_path, lines in changed_files.items():
                if file_name in file_path:
                    for line_elem in sourcefile.findall('.//line'):
                        line_num = int(line_elem.get('nr'))
                        if line_num in lines:
                            total_changed += 1
                            ci = int(line_elem.get('ci', 0))
                            if ci > 0:
                                covered_changed += 1

    if total_changed == 0:
        print("✅ Nenhuma linha executável modificada")
        return 0

    diff_coverage = (covered_changed / total_changed) * 100

    print(f"📊 Diff Coverage Report")
    print(f"   Linhas modificadas: {total_changed}")
    print(f"   Linhas cobertas: {covered_changed}")
    print(f"   Diff Coverage: {diff_coverage:.1f}%")
    print(f"   Threshold: {threshold}%")

    if diff_coverage < threshold:
        print(f"❌ FAILED: Diff coverage abaixo do limiar")
        return 1

    print(f"✅ PASSED")
    return 0

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--coverage', required=True)
    parser.add_argument('--changed', required=True)
    parser.add_argument('--threshold', type=float, default=80.0)

    args = parser.parse_args()
    sys.exit(analyze_diff_coverage(args.coverage, args.changed, args.threshold))
```

### 📊 Metas e Limiares

| Tipo de Mudança          | Meta  | Limiar Crítico | Exceção                         |
| ------------------------ | ----- | -------------- | ------------------------------- |
| **Novo código**          | 100%  | < 80%          | Código experimental             |
| **Refatoração**          | 100%  | < 90%          | Sem lógica nova                 |
| **Bug fix**              | 100%  | < 100%         | Deve ter teste reproduzindo bug |
| **Código legado tocado** | ≥ 50% | < 30%          | Melhorar incrementalmente       |

### 🎯 Estratégias

#### 1. Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🔍 Verificando diff coverage..."

# Staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.java$')

if [ -z "$STAGED_FILES" ]; then
    echo "✅ Nenhum arquivo Java modificado"
    exit 0
fi

# Rodar testes afetados
mvn test -Dtest="*Test"

# Analisar diff coverage
bash scripts/diff-coverage.sh HEAD 80

if [ $? -ne 0 ]; then
    echo "❌ Diff coverage insuficiente. Use 'git commit --no-verify' para forçar (não recomendado)."
    exit 1
fi

echo "✅ Diff coverage adequado"
exit 0
```

#### 2. Bot de PR

**GitHub Action:**

```yaml
- name: Comment PR with Diff Coverage
  uses: actions/github-script@v6
  with:
    script: |
      const fs = require('fs');
      const report = fs.readFileSync('diff-coverage-report.txt', 'utf8');

      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: `## 📊 Diff Coverage Report\n\n\`\`\`\n${report}\n\`\`\``
      });
```

### ⚠️ Pitfalls

1. **Código não executável**: Comentários, imports (filtrar)
2. **Testes unitários modificados**: Não contar como linhas modificadas
3. **Código gerado**: Excluir de análise
4. **Merge commits**: Analisar apenas diff do PR, não do merge

---

## 4. Flaky Rate

### 🎯 Conceito

**Flaky Test** é um teste não-determinístico que passa ou falha intermitentemente sem mudança no código. É uma das maiores fontes de frustração e erosão de confiança.

**Fórmula:**

```
Flaky Rate = (Testes Flaky / Total de Testes) × 100
```

**Critério de Flaky:**

- Teste falha e passa alternadamente em múltiplas execuções
- Sem mudança de código entre execuções
- Geralmente relacionado a timing, concorrência, estado compartilhado

### 🧪 Causas Comuns

#### 1. Dependência de Tempo

```java
// ❌ Flaky: depende de tempo de processamento
@Test
void deveProcessarEmMenosDeUmSegundo() {
    long start = System.currentTimeMillis();
    service.processLargeData();
    long duration = System.currentTimeMillis() - start;
    assertTrue(duration < 1000); // pode falhar em CI com menos recursos
}

// ✅ Não-flaky: usa timeout assertivo
@Test
@Timeout(value = 5, unit = TimeUnit.SECONDS)
void deveProcessarDentroDoTimeout() {
    service.processLargeData();
    // Se passar de 5s, JUnit falha automaticamente
}
```

#### 2. Async sem Sincronização

```java
// ❌ Flaky: verifica antes do processamento assíncrono
@Test
void deveEnviarEmailAssincrono() {
    service.sendEmailAsync(user);
    Thread.sleep(100); // race condition
    verify(emailSender).send(any());
}

// ✅ Não-flaky: usa Awaitility
@Test
void deveEnviarEmailAssincrono() {
    service.sendEmailAsync(user);

    await().atMost(Duration.ofSeconds(5))
           .untilAsserted(() -> verify(emailSender).send(any()));
}
```

#### 3. Estado Compartilhado

```java
// ❌ Flaky: testes compartilham estado
public class Flaky Test {
    private static List<String> cache = new ArrayList<>(); // compartilhado!

    @Test
    void teste1() {
        cache.add("A");
        assertEquals(1, cache.size());
    }

    @Test
    void teste2() {
        cache.add("B");
        assertEquals(1, cache.size()); // falha se teste1 rodar antes
    }
}

// ✅ Não-flaky: isolamento completo
public class NonFlakyTest {
    private List<String> cache; // instância por teste

    @BeforeEach
    void setUp() {
        cache = new ArrayList<>();
    }

    @Test
    void teste1() {
        cache.add("A");
        assertEquals(1, cache.size());
    }

    @Test
    void teste2() {
        cache.add("B");
        assertEquals(1, cache.size());
    }
}
```

#### 4. Ordem de Execução

```java
// ❌ Flaky: depende de ordem de inserção em banco
@Test
void deveBuscarPrimeiroUsuario() {
    User first = userRepository.findAll().get(0);
    assertEquals("John", first.getName()); // depende de ordem
}

// ✅ Não-flaky: busca específica
@Test
void deveBuscarUsuarioPorId() {
    User user = userRepository.findById(1L).orElseThrow();
    assertEquals("John", user.getName());
}
```

#### 5. Geração Aleatória

```java
// ❌ Flaky: usa UUID real
@Test
void deveGerarIdUnico() {
    String id = service.generateId(); // UUID.randomUUID()
    assertTrue(id.startsWith("usr-")); // pode passar ou falhar aleatoriamente
}

// ✅ Não-flaky: mocka geração
@Test
void deveGerarIdUnico() {
    when(uuidGenerator.generate()).thenReturn(UUID.fromString("123e4567-e89b-12d3-a456-426614174000"));
    String id = service.generateId();
    assertEquals("usr-123e4567-e89b-12d3-a456-426614174000", id);
}
```

### 🔧 Ferramentas de Detecção

#### 1. Maven Surefire (Rerun)

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>3.2.2</version>
    <configuration>
        <rerunFailingTestsCount>3</rerunFailingTestsCount>
        <reportsDirectory>${project.build.directory}/surefire-reports-rerun</reportsDirectory>
    </configuration>
</plugin>
```

**Análise:**

```bash
# Testes que passaram após rerun = flaky
grep -l "Flakes:" target/surefire-reports-rerun/*.xml
```

#### 2. Gradle Test Retry Plugin

```groovy
plugins {
    id 'org.gradle.test-retry' version '1.5.7'
}

test {
    retry {
        maxRetries = 3
        maxFailures = 5
        failOnPassedAfterRetry = true // marcar como falha mesmo se passar
    }
}
```

#### 3. Script de Detecção Manual

```bash
#!/bin/bash
# scripts/detect-flaky.sh

TEST_CLASS=${1:-"**/*Test.java"}
RUNS=${2:-10}

echo "🔍 Executando testes $RUNS vezes para detectar flakiness..."

for i in $(seq 1 $RUNS); do
    echo "Run $i/$RUNS..."
    mvn test -Dtest="$TEST_CLASS" > /tmp/test-run-$i.log 2>&1

    if [ $? -ne 0 ]; then
        echo "  ❌ Falhou"
        echo "$i" >> /tmp/failed-runs.txt
    else
        echo "  ✅ Passou"
        echo "$i" >> /tmp/passed-runs.txt
    fi
done

FAILURES=$(wc -l < /tmp/failed-runs.txt 2>/dev/null || echo 0)
PASSES=$(wc -l < /tmp/passed-runs.txt 2>/dev/null || echo 0)

echo ""
echo "📊 Resultado:"
echo "   Passou: $PASSES/$RUNS"
echo "   Falhou: $FAILURES/$RUNS"

if [ $FAILURES -gt 0 ] && [ $PASSES -gt 0 ]; then
    echo "   ⚠️  FLAKY DETECTADO!"
    exit 1
elif [ $FAILURES -eq $RUNS ]; then
    echo "   ❌ Teste consistentemente falhando (não flaky, bug real)"
    exit 2
else
    echo "   ✅ Teste estável"
    exit 0
fi
```

#### 4. Jenkins Flaky Test Plugin

```groovy
// Jenkinsfile
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit testResults: '**/target/surefire-reports/*.xml',
                          allowEmptyResults: true

                    // Plugin detecta flaky automaticamente
                    step([$class: 'FlakeyTestResultsPublisher'])
                }
            }
        }
    }
}
```

### 📊 Metas e Limiares

| Contexto           | Meta   | Limiar Crítico | Ação                   |
| ------------------ | ------ | -------------- | ---------------------- |
| **Suite completa** | 0%     | > 1%           | 🚨 Alerta urgente      |
| **Por módulo**     | 0%     | > 2%           | ⚠️ Investigar          |
| **Novos testes**   | 0%     | > 0%           | ❌ Bloquear merge      |
| **Testes E2E**     | < 0.5% | > 3%           | 📝 Documentar e isolar |

### 🎯 Estratégias de Mitigação

#### 1. Isolamento de Testes

```java
// Usar @DirtiesContext para Spring
@SpringBootTest
@DirtiesContext(classMode = ClassMode.AFTER_EACH_TEST_METHOD)
class IsolatedTest {
    // Cada teste recebe contexto limpo
}

// Usar TestContainers para bancos
@Testcontainers
class DatabaseTest {
    @Container
    private static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:15-alpine");

    @BeforeEach
    void cleanDatabase() {
        // Limpar entre testes
        jdbcTemplate.execute("TRUNCATE TABLE users CASCADE");
    }
}
```

#### 2. Clock Mockado

```java
// Injetar Clock
public class OrderService {
    private final Clock clock;

    public OrderService(Clock clock) {
        this.clock = clock;
    }

    public Order createOrder() {
        Order order = new Order();
        order.setCreatedAt(Instant.now(clock));
        return order;
    }
}

// Teste determinístico
@Test
void deveUsarTimestampFixo() {
    Clock fixedClock = Clock.fixed(
        Instant.parse("2025-01-15T10:00:00Z"),
        ZoneId.of("UTC")
    );

    OrderService service = new OrderService(fixedClock);
    Order order = service.createOrder();

    assertEquals(Instant.parse("2025-01-15T10:00:00Z"), order.getCreatedAt());
}
```

#### 3. Awaitility para Async

```java
@Test
void deveProcessarEventoAssincrono() {
    eventPublisher.publish(new OrderCreatedEvent(order));

    await().atMost(Duration.ofSeconds(5))
           .pollInterval(Duration.ofMillis(100))
           .untilAsserted(() -> {
               Order processed = orderRepository.findById(order.getId()).orElseThrow();
               assertEquals(OrderStatus.CONFIRMED, processed.getStatus());
           });
}
```

#### 4. Quarentena de Flaky Tests

```java
// JUnit 5: tag para isolar flaky tests
@Tag("flaky")
@Disabled("Flaky: issue #1234")
@Test
void testeComProblemaConhecido() {
    // Desabilitado até fix
}
```

**Maven profile para rodar só flaky:**

```xml
<profile>
    <id>flaky-tests</id>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <configuration>
                    <groups>flaky</groups>
                </configuration>
            </plugin>
        </plugins>
    </build>
</profile>
```

```bash
# Rodar apenas flaky tests
mvn test -Pflaky-tests
```

### 📈 Coleta Contínua

**Script de coleta semanal:**

```bash
#!/bin/bash
# scripts/weekly-flaky-report.sh

DAYS=7
RUNS_PER_TEST=5

echo "📊 Relatório de Flaky Tests (últimos $DAYS dias)"
echo "============================================="

# Obter testes modificados recentemente
RECENT_TESTS=$(git log --since="$DAYS days ago" --name-only --pretty=format: \
  | grep Test.java | sort | uniq)

for test in $RECENT_TESTS; do
    echo ""
    echo "🧪 Testando: $test"

    bash scripts/detect-flaky.sh "$test" $RUNS_PER_TEST

    if [ $? -eq 1 ]; then
        echo "   ⚠️  FLAKY - Criar issue"
        # Criar issue automaticamente
        gh issue create \
          --title "Flaky Test: $test" \
          --body "Detectado em $(date). Rodar scripts/detect-flaky.sh $test 10 para reproduzir." \
          --label "flaky-test,priority-high"
    fi
done
```

### ⚠️ Pitfalls

1. **Esconder flaky com reruns**: Apenas mascara o problema
2. **Ignorar flaky em E2E**: "É esperado" - erosão de confiança
3. **Não registrar histórico**: Perder padrões de quando ocorre
4. **Executar testes em paralelo sem isolamento**: Aumenta flakiness

---

## 5. Lead Time de Testes

### 🎯 Conceito

**Lead Time de Testes** mede o tempo desde o commit até o feedback de qualidade (testes passando/falhando).

**Fórmula:**

```
Lead Time = Tempo de Feedback - Tempo de Commit
```

**Categorias:**

- **Unit Tests**: < 1 min
- **Integration Tests**: 1-5 min
- **E2E Tests**: 5-15 min
- **Performance Tests**: 15-30 min

### 📊 Metas

| Tipo             | Meta     | Limiar Crítico | Impacto                   |
| ---------------- | -------- | -------------- | ------------------------- |
| **Unit (local)** | < 30s    | > 2 min        | Desenvolvedores não rodam |
| **Unit (CI)**    | < 2 min  | > 5 min        | Feedback lento            |
| **Integration**  | < 5 min  | > 10 min       | Merge demorado            |
| **E2E**          | < 15 min | > 30 min       | Deploy bloqueado          |

### 🔧 Otimizações

#### 1. Paralelização

```xml
<!-- Maven Surefire: rodar em paralelo -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <configuration>
        <parallel>methods</parallel>
        <threadCount>4</threadCount>
        <perCoreThreadCount>true</perCoreThreadCount>
    </configuration>
</plugin>
```

```groovy
// Gradle: paralelo por padrão
test {
    maxParallelForks = Runtime.runtime.availableProcessors().intdiv(2) ?: 1
}
```

#### 2. Test Sharding (CI)

```yaml
# GitHub Actions: dividir testes em múltiplos jobs
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - name: Run Tests (Shard ${{ matrix.shard }}/4)
        run: |
          mvn test -Dshard=${{ matrix.shard }} -DshardTotal=4
```

**Maven plugin para sharding:**

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <configuration>
        <groups>shard-${shard}</groups>
    </configuration>
</plugin>
```

#### 3. Smart Test Selection

**Apenas testes afetados por mudanças:**

```bash
#!/bin/bash
# scripts/smart-test-selection.sh

CHANGED_FILES=$(git diff --name-only origin/main...HEAD)

# Mapear arquivos mudados para testes
AFFECTED_TESTS=""

for file in $CHANGED_FILES; do
    # Exemplo simples: se Order.java mudou, rodar OrderTest.java
    if [[ $file == *"Order.java" ]]; then
        AFFECTED_TESTS="$AFFECTED_TESTS OrderTest"
    fi
done

if [ -z "$AFFECTED_TESTS" ]; then
    echo "✅ Nenhum teste afetado"
    exit 0
fi

echo "🧪 Rodando testes afetados: $AFFECTED_TESTS"
mvn test -Dtest="$AFFECTED_TESTS"
```

**Bazel (análise de dependências built-in):**

```bash
# Rodar apenas testes afetados por mudanças
bazel test --test_tag_filters=-slow //src/...
```

#### 4. Cache de Dependencies

```yaml
# GitHub Actions: cache de Maven
- name: Cache Maven packages
  uses: actions/cache@v3
  with:
    path: ~/.m2/repository
    key: ${{ runner.os }}-maven-${{ hashFiles('**/pom.xml') }}
    restore-keys: |
      ${{ runner.os }}-maven-
```

### 📈 Métricas de Acompanhamento

```python
# scripts/track-test-lead-time.py
import json
import requests
from datetime import datetime

def get_ci_duration(run_id):
    """Obter duração de CI run do GitHub Actions"""
    url = f"https://api.github.com/repos/owner/repo/actions/runs/{run_id}"
    headers = {"Authorization": f"token {GITHUB_TOKEN}"}

    response = requests.get(url, headers=headers)
    data = response.json()

    started = datetime.fromisoformat(data['run_started_at'].replace('Z', '+00:00'))
    completed = datetime.fromisoformat(data['updated_at'].replace('Z', '+00:00'))

    duration_seconds = (completed - started).total_seconds()

    return {
        'run_id': run_id,
        'duration_seconds': duration_seconds,
        'duration_minutes': duration_seconds / 60,
        'conclusion': data['conclusion']
    }

def calculate_p50_p95(durations):
    """Calcular percentis"""
    sorted_durations = sorted(durations)
    n = len(sorted_durations)

    p50_index = int(n * 0.5)
    p95_index = int(n * 0.95)

    return {
        'p50': sorted_durations[p50_index],
        'p95': sorted_durations[p95_index],
        'min': sorted_durations[0],
        'max': sorted_durations[-1],
        'mean': sum(sorted_durations) / n
    }

# Uso
durations = [get_ci_duration(run_id)['duration_minutes']
             for run_id in last_100_runs]

stats = calculate_p50_p95(durations)
print(f"📊 Lead Time Stats (últimos 100 runs):")
print(f"   P50: {stats['p50']:.1f} min")
print(f"   P95: {stats['p95']:.1f} min")
print(f"   Média: {stats['mean']:.1f} min")
```

---

## 6. Cobertura de Código

### 🎯 Conceito Expandido

Cobertura tradicional (linhas, branches) é **necessária mas não suficiente**. Complementar com:

- **Path Coverage**: Todos os caminhos possíveis
- **Condition Coverage**: Todas as condições booleanas (true/false)
- **Data Flow Coverage**: Uso de variáveis (definição → uso)

### 📊 Metas Contextuais

| Tipo de Código            | Meta Linhas | Meta Branches | Meta Mutação |
| ------------------------- | ----------- | ------------- | ------------ |
| **Domain/Business Logic** | 95%         | 90%           | 85%          |
| **Controllers/API**       | 85%         | 80%           | 70%          |
| **Repositories/DAO**      | 80%         | 75%           | 65%          |
| **Configurations**        | 60%         | 50%           | N/A          |
| **DTOs/Entities**         | 40%         | N/A           | N/A          |

### ⚠️ Armadilhas

```java
// ❌ 100% cobertura mas teste inútil
@Test
void testeComCoberturaInutil() {
    calculator.divide(10, 2); // nenhum assert!
    // Cobertura: 100% | Valor: 0%
}

// ✅ Cobertura + validação
@Test
void deveCalcularDivisao() {
    assertEquals(5.0, calculator.divide(10, 2));
}

@Test
void deveLancarExcecaoAoDividirPorZero() {
    assertThrows(ArithmeticException.class, () -> calculator.divide(10, 0));
}
```

---

## 7. Métricas de Resiliência

### 🎯 Conceito

Medir a qualidade de testes relacionados a **resiliência** (falhas, latência, indisponibilidade).

### 📊 Métricas-Chave

#### 1. Resiliência Test Coverage

```
Resiliência Coverage = (Cenários de Falha Testados / Cenários Possíveis) × 100
```

**Exemplo:**

```java
// Matriz de cenários
// [✅] Timeout de rede
// [✅] Resposta 5xx
// [✅] Resposta 4xx
// [✅] Payload corrompido
// [❌] Conexão recusada
// [❌] Circuit breaker aberto
// Resiliência Coverage: 66.7% (4/6)
```

#### 2. Chaos Test Pass Rate

```
Chaos Pass Rate = (Chaos Tests Passando / Total Chaos Tests) × 100
```

**Target**: 100% (sistema deve se recuperar de todas as falhas injetadas)

#### 3. MTTR (Mean Time To Recovery) em Testes

```java
@Test
void deveMedirTempoDeRecuperacao() {
    // Simular falha
    circuitBreaker.transitionToOpenState();

    long start = System.currentTimeMillis();

    // Aguardar recuperação
    await().atMost(Duration.ofSeconds(10))
           .until(() -> circuitBreaker.getState() == State.CLOSED);

    long recoveryTime = System.currentTimeMillis() - start;

    // MTTR deve ser < 5s
    assertThat(recoveryTime).isLessThan(5000);
}
```

---

## 8. Métricas de Performance

### 📊 Métricas-Chave

#### 1. Latência (Percentis)

```java
@Test
void deveAtenderLatenciaP95() {
    List<Long> latencies = new ArrayList<>();

    for (int i = 0; i < 100; i++) {
        long start = System.nanoTime();
        service.process();
        long duration = System.nanoTime() - start;
        latencies.add(duration / 1_000_000); // ms
    }

    Collections.sort(latencies);
    long p95 = latencies.get(94); // posição 95 de 100

    assertThat(p95).isLessThan(100); // P95 < 100ms
}
```

#### 2. Throughput

```java
@Test
void deveSuportarThroughputMinimo() {
    int requests = 1000;
    long start = System.currentTimeMillis();

    IntStream.range(0, requests).parallel()
        .forEach(i -> service.process());

    long duration = System.currentTimeMillis() - start;
    double throughput = (requests * 1000.0) / duration; // req/s

    assertThat(throughput).isGreaterThan(100); // > 100 req/s
}
```

#### 3. Resource Usage

```java
@Test
void naoDeveVazarMemoria() {
    Runtime runtime = Runtime.getRuntime();
    long before = runtime.totalMemory() - runtime.freeMemory();

    // Executar operação 1000x
    for (int i = 0; i < 1000; i++) {
        service.processLargeData();
    }

    System.gc();
    Thread.sleep(100);

    long after = runtime.totalMemory() - runtime.freeMemory();
    long growth = after - before;

    // Crescimento de memória < 10MB
    assertThat(growth).isLessThan(10 * 1024 * 1024);
}
```

---

## 9. Métricas de Negócio

### 🎯 Conceito

Testes devem validar **regras de negócio** explicitamente. Métricas de cobertura de domínio.

### 📊 Business Rule Coverage

```
Business Rule Coverage = (Regras Testadas / Regras Documentadas) × 100
```

**Exemplo:**

```java
// Regra: Desconto progressivo
// - 10 a 49 itens: 5%
// - 50 a 99 itens: 10%
// - 100+: 15%

@ParameterizedTest
@CsvSource({
    "9, 0.0",    // abaixo do limite
    "10, 0.05",  // primeira faixa
    "49, 0.05",  // boundary superior primeira faixa
    "50, 0.10",  // segunda faixa
    "99, 0.10",  // boundary superior segunda faixa
    "100, 0.15", // terceira faixa
    "1000, 0.15" // acima
})
void deveAplicarDescontoProgressivo(int quantity, double expectedDiscount) {
    assertEquals(expectedDiscount, calculator.getDiscount(quantity));
}
// Business Rule Coverage: 100% (todas as faixas testadas)
```

### 📈 Rastreabilidade

```java
// Linking testes a requisitos
@Test
@Tag("REQ-123") // requirement ID
@DisplayName("REQ-123: Cliente VIP tem frete grátis acima de R$ 100")
void clienteVipDeveTerFreteGratisAcimaDeR100() {
    // ...
}
```

**Relatório de rastreabilidade:**

```bash
# Gerar matriz de cobertura de requisitos
grep -r "@Tag(\"REQ-" src/test/ | awk -F'"' '{print $2}' | sort | uniq > /tmp/tested-reqs.txt

# Comparar com requisitos documentados
comm -23 docs/requirements.txt /tmp/tested-reqs.txt > /tmp/untested-reqs.txt

echo "📊 Requisitos sem testes:"
cat /tmp/untested-reqs.txt
```

---

## 10. Dashboard e Visualização

### 🎯 Objetivo

Consolidar métricas em dashboard único para visibilidade de time.

### 📊 Exemplo: Grafana + Prometheus

**Prometheus metrics export:**

```java
// Spring Boot Actuator + Micrometer
@Component
public class TestMetricsExporter {

    private final MeterRegistry registry;

    public TestMetricsExporter(MeterRegistry registry) {
        this.registry = registry;

        // Mutation Score
        Gauge.builder("test.mutation.score", this, TestMetricsExporter::getMutationScore)
             .description("Mutation score percentage")
             .register(registry);

        // Flaky Rate
        Gauge.builder("test.flaky.rate", this, TestMetricsExporter::getFlakyRate)
             .description("Flaky test rate percentage")
             .register(registry);

        // Lead Time
        Gauge.builder("test.lead.time.seconds", this, TestMetricsExporter::getLeadTimeSeconds)
             .description("Test lead time in seconds")
             .register(registry);
    }

    private double getMutationScore() {
        // Ler de PITest XML report
        return parsePitestReport();
    }

    private double getFlakyRate() {
        // Calcular baseado em histórico
        return calculateFlakyRate();
    }

    private double getLeadTimeSeconds() {
        // Média das últimas 10 execuções
        return averageLeadTime();
    }
}
```

**Grafana Dashboard JSON:**

```json
{
  "dashboard": {
    "title": "Test Quality Metrics",
    "panels": [
      {
        "title": "Mutation Score",
        "type": "gauge",
        "targets": [
          {
            "expr": "test_mutation_score",
            "legendFormat": "Mutation %"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "thresholds": {
              "mode": "absolute",
              "steps": [
                { "value": 0, "color": "red" },
                { "value": 60, "color": "yellow" },
                { "value": 80, "color": "green" }
              ]
            }
          }
        }
      },
      {
        "title": "Flaky Rate (7 days)",
        "type": "stat",
        "targets": [
          {
            "expr": "test_flaky_rate",
            "legendFormat": "Flaky %"
          }
        ]
      },
      {
        "title": "Lead Time Trend",
        "type": "graph",
        "targets": [
          {
            "expr": "test_lead_time_seconds",
            "legendFormat": "Lead Time (s)"
          }
        ]
      }
    ]
  }
}
```

### 📈 Template de README Metrics Badge

```markdown
# Project Name

![Mutation Score](https://img.shields.io/badge/mutation-85%25-green)
![Diff Coverage](https://img.shields.io/badge/diff%20coverage-92%25-brightgreen)
![Flaky Rate](https://img.shields.io/badge/flaky%20rate-0.2%25-green)
![Lead Time](https://img.shields.io/badge/lead%20time-3.5min-yellow)

## Quality Metrics

| Metric          | Current | Target  | Status |
| --------------- | ------- | ------- | ------ |
| Mutation Score  | 85%     | 80%     | ✅     |
| Diff Coverage   | 92%     | 85%     | ✅     |
| Flaky Rate      | 0.2%    | < 1%    | ✅     |
| Lead Time (CI)  | 3.5 min | < 5 min | ✅     |
| Branch Coverage | 88%     | 85%     | ✅     |
```

---

## 📚 Checklist de Implementação

### Fase 1: Coleta Básica

- [ ] Configurar JaCoCo ou equivalente
- [ ] Configurar PITest para mutation testing
- [ ] Configurar Codecov ou SonarQube
- [ ] Estabelecer baselines

### Fase 2: Quality Gates

- [ ] Definir thresholds para cada métrica
- [ ] Implementar checks no CI/CD
- [ ] Configurar alertas para regressões
- [ ] Documentar exceções

### Fase 3: Automação

- [ ] Scripts de coleta automatizada
- [ ] Dashboard centralizado
- [ ] Relatórios periódicos (semanal)
- [ ] Integração com ferramentas de issue tracking

### Fase 4: Cultura

- [ ] Treinar time nas métricas
- [ ] Incorporar em code reviews
- [ ] Retrospectivas baseadas em dados
- [ ] Celebrar melhorias

---

## 🎯 Próximos Passos

1. **Implementar coleta básica** (Fase 1)
2. **Estabelecer thresholds iniciais** (conservadores)
3. **Rodar por 2 semanas** para calibrar
4. **Ajustar metas** baseado em dados reais
5. **Automatizar enforcement** com quality gates

---

## 📖 Referências

- [PITest Documentation](https://pitest.org/)
- [JaCoCo Documentation](https://www.jacoco.org/jacoco/)
- [Codecov Best Practices](https://docs.codecov.com/docs)
- [Google Testing Blog - Flaky Tests](https://testing.googleblog.com/)
- [Martin Fowler - Test Coverage](https://martinfowler.com/bliki/TestCoverage.html)
