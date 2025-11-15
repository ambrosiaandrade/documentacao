# 🌐 Terminologia Unificada - Testes de Software

## Índice

1. [Objetivo](#1-objetivo)
2. [Português ↔ Inglês](#2-português--inglês)
3. [Equivalências entre Frameworks](#3-equivalências-entre-frameworks)
4. [Migração de Termos Legados](#4-migração-de-termos-legados)
5. [Sinônimos a Evitar](#5-sinônimos-a-evitar)
6. [Decisões de Nomenclatura](#6-decisões-de-nomenclatura)
7. [Glossário Rápido](#7-glossário-rápido)

---

## 1. Objetivo

Este documento padroniza a terminologia usada em:

- **Documentação técnica** (português e inglês)
- **Código-fonte** (comentários, nomes de classes/métodos)
- **Comunicação entre times** (reuniões, issues, PRs)
- **Treinamentos e materiais educacionais**

### Princípios

1. **Consistência**: Usar sempre o mesmo termo para o mesmo conceito
2. **Clareza**: Evitar ambiguidades e sinônimos desnecessários
3. **Padrão de Mercado**: Seguir nomenclatura amplamente adotada
4. **Open Source First**: Priorizar terminologia de ferramentas open source

---

## 2. Português ↔ Inglês

### 2.1 Tipos de Testes

| Português               | Inglês                | ⚠️ Evitar            | Contexto                         |
| ----------------------- | --------------------- | -------------------- | -------------------------------- |
| **Teste de Unidade**    | Unit Test             | Teste Unitário       | JUnit, pytest, Jest              |
| **Teste de Integração** | Integration Test      | Teste Integrado      | Spring Boot Test, TestContainers |
| **Teste de Contrato**   | Contract Test         | Teste Contratual     | Pact, Spring Cloud Contract      |
| **Teste Ponta a Ponta** | End-to-End Test (E2E) | Teste E2E            | Selenium, Cypress, Playwright    |
| **Teste de Fumaça**     | Smoke Test            | Teste Smoke          | Verificação básica pós-deploy    |
| **Teste de Sanidade**   | Sanity Test           | Teste Sanity         | Subset de smoke tests            |
| **Teste de Regressão**  | Regression Test       | Teste Regressivo     | Validação pós-mudança            |
| **Teste de Aceitação**  | Acceptance Test       | Teste de Aceite      | Critérios de negócio             |
| **Teste Exploratório**  | Exploratory Test      | -                    | Manual, ad-hoc                   |
| **Teste de Carga**      | Load Test             | Teste de Performance | JMeter, Gatling, k6              |
| **Teste de Estresse**   | Stress Test           | -                    | Limites do sistema               |
| **Teste de Caos**       | Chaos Test            | Teste Caótico        | Chaos Toolkit, LitmusChaos       |

### 2.2 Padrões e Técnicas

| Português                         | Inglês                      | ⚠️ Evitar                                | Frameworks             |
| --------------------------------- | --------------------------- | ---------------------------------------- | ---------------------- |
| **Dublê de Teste**                | Test Double                 | Mock (genérico)                          | Mockito, unittest.mock |
| **Simulacro**                     | Mock                        | -                                        | Mockito, Sinon         |
| **Esboço**                        | Stub                        | -                                        | WireMock, Sinon        |
| **Espião**                        | Spy                         | -                                        | Mockito Spy, Sinon Spy |
| **Falsificação**                  | Fake                        | -                                        | Fake Repository        |
| **Manequim**                      | Dummy                       | -                                        | Parâmetro não usado    |
| **AAA**                           | Arrange-Act-Assert          | Setup-Execute-Verify                     | Padrão universal       |
| **TDD**                           | Test-Driven Development     | Desenvolvimento Guiado por Testes        | Red-Green-Refactor     |
| **BDD**                           | Behavior-Driven Development | Desenvolvimento Guiado por Comportamento | Cucumber, SpecFlow     |
| **Teste de Mutação**              | Mutation Testing            | -                                        | PITest, Stryker        |
| **Teste Baseado em Propriedades** | Property-Based Testing      | -                                        | Hypothesis, QuickCheck |
| **Test Data Builder**             | Test Data Builder           | Builder Pattern                          | Padrão criacional      |

### 2.3 Métricas e Qualidade

| Português                 | Inglês          | ⚠️ Evitar            | Ferramentas            |
| ------------------------- | --------------- | -------------------- | ---------------------- |
| **Cobertura de Código**   | Code Coverage   | Cobertura de Testes  | JaCoCo, Coverage.py    |
| **Cobertura de Linha**    | Line Coverage   | -                    | JaCoCo                 |
| **Cobertura de Ramo**     | Branch Coverage | Cobertura de Decisão | JaCoCo                 |
| **Cobertura Diferencial** | Diff Coverage   | Delta Coverage       | Codecov, Coveralls     |
| **Escore de Mutação**     | Mutation Score  | Taxa de Mutação      | PITest, Stryker        |
| **Teste Intermitente**    | Flaky Test      | Teste Flaky          | Surefire Rerun         |
| **Taxa de Intermitência** | Flaky Rate      | Flakiness            | Histórico de execuções |
| **Tempo de Execução**     | Execution Time  | Duração              | CI/CD metrics          |
| **Lead Time**             | Lead Time       | Tempo de Entrega     | DORA metrics           |
| **Quality Gate**          | Quality Gate    | Portão de Qualidade  | SonarQube, CI/CD       |

### 2.4 Arquitetura e Resiliência

| Português                  | Inglês              | ⚠️ Evitar            | Bibliotecas           |
| -------------------------- | ------------------- | -------------------- | --------------------- |
| **Disjuntor**              | Circuit Breaker     | -                    | Resilience4j, Hystrix |
| **Tentativa**              | Retry               | Retry Policy         | Resilience4j          |
| **Retrocesso Exponencial** | Exponential Backoff | -                    | Spring Retry          |
| **Bulkhead**               | Bulkhead            | Isolamento           | Resilience4j          |
| **Limitação de Taxa**      | Rate Limiting       | Throttling           | Bucket4j, Guava       |
| **Timeout**                | Timeout             | Tempo Limite         | Resilience4j          |
| **Fallback**               | Fallback            | Plano B              | Resilience4j          |
| **Health Check**           | Health Check        | Verificação de Saúde | Spring Actuator       |

### 2.5 CI/CD e Automação

| Português               | Inglês                      | ⚠️ Evitar           | Ferramentas         |
| ----------------------- | --------------------------- | ------------------- | ------------------- |
| **Integração Contínua** | Continuous Integration (CI) | -                   | Jenkins, GitLab CI  |
| **Entrega Contínua**    | Continuous Delivery (CD)    | -                   | GitHub Actions      |
| **Deploy Contínuo**     | Continuous Deployment       | -                   | ArgoCD, Flux        |
| **Pipeline**            | Pipeline                    | Esteira             | CI/CD pipelines     |
| **Stage**               | Stage                       | Estágio, Fase       | Build, Test, Deploy |
| **Artefato**            | Artifact                    | -                   | JAR, Docker image   |
| **Quality Gate**        | Quality Gate                | Portão de Qualidade | SonarQube           |

---

## 3. Equivalências entre Frameworks

### 3.1 Anotações de Teste

#### Lifecycle Hooks

| Conceito           | JUnit 5 (Java) | pytest (Python)                              | Jest (JavaScript) | Mocha (JavaScript) |
| ------------------ | -------------- | -------------------------------------------- | ----------------- | ------------------ |
| **Antes de todos** | `@BeforeAll`   | `@pytest.fixture(scope="session")`           | `beforeAll()`     | `before()`         |
| **Antes de cada**  | `@BeforeEach`  | `@pytest.fixture(scope="function")`          | `beforeEach()`    | `beforeEach()`     |
| **Após cada**      | `@AfterEach`   | `yield` (fixture)                            | `afterEach()`     | `afterEach()`      |
| **Após todos**     | `@AfterAll`    | `@pytest.fixture(scope="session")` + `yield` | `afterAll()`      | `after()`          |

#### Marcação e Organização

| Conceito          | JUnit 5          | pytest              | Jest               | NUnit (.NET)    |
| ----------------- | ---------------- | ------------------- | ------------------ | --------------- |
| **Marcar teste**  | `@Test`          | `def test_*()`      | `test()` ou `it()` | `[Test]`        |
| **Nome legível**  | `@DisplayName()` | `pytest -v`         | `describe()/it()`  | `[TestCase()]`  |
| **Agrupar**       | `@Nested`        | `class Test*`       | `describe()`       | `[TestFixture]` |
| **Desabilitar**   | `@Disabled`      | `@pytest.mark.skip` | `test.skip()`      | `[Ignore]`      |
| **Tag/Categoria** | `@Tag()`         | `@pytest.mark.*`    | `test.only()`      | `[Category()]`  |

#### Asserções

| Conceito       | JUnit 5                        | pytest             | Jest                        | Chai (JS)                    |
| -------------- | ------------------------------ | ------------------ | --------------------------- | ---------------------------- |
| **Igualdade**  | `assertEquals(a, b)`           | `assert a == b`    | `expect(a).toBe(b)`         | `expect(a).to.equal(b)`      |
| **Verdadeiro** | `assertTrue(x)`                | `assert x`         | `expect(x).toBeTruthy()`    | `expect(x).to.be.true`       |
| **Nulo**       | `assertNull(x)`                | `assert x is None` | `expect(x).toBeNull()`      | `expect(x).to.be.null`       |
| **Exceção**    | `assertThrows(E, ...)`         | `pytest.raises(E)` | `expect().toThrow(E)`       | `expect().to.throw(E)`       |
| **Contém**     | `assertThat(list).contains(x)` | `assert x in list` | `expect(list).toContain(x)` | `expect(list).to.include(x)` |

### 3.2 Mocking

| Conceito               | Mockito (Java)                | unittest.mock (Python)       | Sinon (JS)                      | Moq (.NET)                   |
| ---------------------- | ----------------------------- | ---------------------------- | ------------------------------- | ---------------------------- |
| **Criar mock**         | `mock(Class.class)`           | `Mock()`                     | `sinon.mock()`                  | `new Mock<T>()`              |
| **Stub retorno**       | `when(m.foo()).thenReturn(x)` | `m.foo.return_value = x`     | `stub.returns(x)`               | `mock.Setup(...).Returns(x)` |
| **Verificar chamada**  | `verify(m).foo()`             | `m.foo.assert_called_once()` | `sinon.assert.calledOnce(stub)` | `mock.Verify(...)`           |
| **Capturar argumento** | `ArgumentCaptor<T>`           | `call_args`                  | `stub.getCall(0).args`          | `Capture<T>()`               |
| **Spy**                | `spy(obj)`                    | `wraps=real_obj`             | `sinon.spy(obj)`                | `mock.CallBase = true`       |

### 3.3 Test Containers

| Conceito               | Testcontainers (Java)             | testcontainers-python | node-testcontainers         |
| ---------------------- | --------------------------------- | --------------------- | --------------------------- |
| **Container genérico** | `new GenericContainer<>()`        | `GenericContainer()`  | `new GenericContainer()`    |
| **PostgreSQL**         | `new PostgreSQLContainer<>()`     | `PostgresContainer()` | `new PostgreSqlContainer()` |
| **MySQL**              | `new MySQLContainer<>()`          | `MySqlContainer()`    | `new MySqlContainer()`      |
| **MongoDB**            | `new MongoDBContainer()`          | `MongoDbContainer()`  | `new MongoDBContainer()`    |
| **Redis**              | `new GenericContainer<>("redis")` | `RedisContainer()`    | `new RedisContainer()`      |

### 3.4 Performance Testing

| Conceito        | JMeter       | Gatling                   | k6                          | Locust       |
| --------------- | ------------ | ------------------------- | --------------------------- | ------------ |
| **Thread/User** | Thread Group | `setUp(users)`            | `vus: 10`                   | `users`      |
| **Duração**     | Duration     | `during(30 seconds)`      | `duration: '30s'`           | `run_time`   |
| **Taxa**        | Throughput   | `constantUsersPerSec(10)` | `rate: 10`                  | `spawn_rate` |
| **Cenário**     | Test Plan    | `scenario()`              | `export default function()` | `@task`      |
| **Asserção**    | Assertion    | `check()`                 | `check()`                   | N/A          |

---

## 4. Migração de Termos Legados

### 4.1 Termos Descontinuados

| ❌ Termo Legado                 | ✅ Termo Moderno                                    | Motivo da Mudança       |
| ------------------------------- | --------------------------------------------------- | ----------------------- |
| **Teste Caixa Branca**          | Teste de Unidade                                    | Mais específico e claro |
| **Teste Caixa Preta**           | Teste de Sistema/E2E                                | Mais específico e claro |
| **Teste de Integração** (amplo) | Teste de Integração (backend) ou E2E                | Evitar ambiguidade      |
| **Mock** (genérico)             | Test Double (categoria), Mock/Stub/Spy (específico) | Precisão técnica        |
| **Coverage** (genérico)         | Line Coverage / Branch Coverage                     | Especificar tipo        |
| **Teste Funcional**             | Teste de Aceitação ou E2E                           | Evitar ambiguidade      |
| **Teste de Performance**        | Load Test / Stress Test / Performance Test          | Especificar tipo        |
| **Teste de Regressão**          | Regression Suite (automática)                       | Automatização implícita |
| **Teste de Sanidade**           | Smoke Test                                          | Termo mais comum        |

### 4.2 Frameworks Legados

| ❌ Framework Descontinuado       | ✅ Alternativa Open Source               | Motivo                          |
| -------------------------------- | ---------------------------------------- | ------------------------------- |
| **JUnit 4**                      | **JUnit 5** (Jupiter)                    | Arquitetura modular, extensível |
| **TestNG** (para novos projetos) | **JUnit 5**                              | Maior adoção e suporte          |
| **Hystrix**                      | **Resilience4j**                         | Netflix descontinuou Hystrix    |
| **PowerMock**                    | **Mockito + refatoração**                | PowerMock dificulta debugging   |
| **Selenium (standalone)**        | **Selenium + Selenide/WebDriverManager** | Melhores abstrações             |
| **Protractor**                   | **Playwright / Cypress**                 | Google descontinuou Protractor  |
| **Karma**                        | **Jest / Vitest**                        | Jest mais moderno e rápido      |

### 4.3 Práticas Legadas

| ❌ Prática Antiga                          | ✅ Prática Moderna                        | Benefício          |
| ------------------------------------------ | ----------------------------------------- | ------------------ |
| **try-catch manual para exceções**         | `assertThrows()` / `assertThatThrownBy()` | Mais expressivo    |
| **assertTrue(list.contains(x))**           | `assertThat(list).contains(x)`            | Mensagens melhores |
| **@RunWith(SpringRunner.class)** (JUnit 4) | `@SpringBootTest` (JUnit 5)               | Simplificação      |
| **@Mock + MockitoAnnotations.initMocks()** | `@ExtendWith(MockitoExtension.class)`     | Automação          |
| **Thread.sleep()**                         | `Awaitility.await()`                      | Não-flaky          |
| **Random sem seed**                        | `Random(seed)` ou `@RandomizedTest`       | Reprodutibilidade  |

---

## 5. Sinônimos a Evitar

### 5.1 Ambiguidades Comuns

#### "Mock" - USE COM CUIDADO

```java
// ❌ AMBÍGUO - "mock" pode significar várias coisas
UserRepository mock = mock(UserRepository.class);

// ✅ CLARO - Especificar tipo de test double
UserRepository userRepositoryStub = mock(UserRepository.class);
when(userRepositoryStub.findById(1L)).thenReturn(user); // Stub (retorno fixo)

UserRepository userRepositorySpy = spy(realRepository); // Spy (objeto real parcialmente mockado)

UserRepository userRepositoryMock = mock(UserRepository.class);
verify(userRepositoryMock).save(any()); // Mock (verificação de comportamento)
```

**Nomenclatura recomendada:**

- **Stub**: Quando retorna dados fixos
- **Spy**: Quando observa objeto real
- **Mock**: Quando verifica comportamento
- **Fake**: Quando tem implementação simplificada

#### "Teste de Integração" - ESPECIFICAR ESCOPO

```java
// ❌ AMBÍGUO - Qual tipo de integração?
class UserIntegrationTest { }

// ✅ CLARO - Especificar camadas
class UserRepositoryIntegrationTest { } // Repository + DB real
class UserServiceIntegrationTest { }    // Service + Repository mockado
class UserApiIntegrationTest { }        // API + Service real (sem DB real)
class UserE2ETest { }                    // UI + Backend + DB real
```

#### "Teste de Performance" - ESPECIFICAR TIPO

```java
// ❌ AMBÍGUO
class PerformanceTest { }

// ✅ CLARO
class OrderServiceLoadTest { }       // Carga normal esperada
class OrderServiceStressTest { }     // Além dos limites
class OrderServiceSpikeTest { }      // Picos súbitos
class OrderServiceSoakTest { }       // Longa duração
class OrderServiceScalabilityTest { } // Crescimento gradual
```

### 5.2 Termos Equivalentes - ESCOLHER UM

| Conceito                     | ✅ Termo Preferido | ⚠️ Sinônimos Aceitos | ❌ Evitar                       |
| ---------------------------- | ------------------ | -------------------- | ------------------------------- |
| **Teste falho intermitente** | Flaky Test         | Teste Intermitente   | Teste Instável, Teste Quebrado  |
| **Dados de teste**           | Test Data          | Test Fixtures        | Test Payload (muito específico) |
| **Preparação do teste**      | Arrange / Given    | Setup                | Initialize                      |
| **Execução do teste**        | Act / When         | Execute              | Run                             |
| **Validação do teste**       | Assert / Then      | Verify               | Check                           |
| **Pirâmide de testes**       | Test Pyramid       | Testing Pyramid      | -                               |
| **Dublê de teste**           | Test Double        | Test Substitute      | Test Mock (muito amplo)         |

---

## 6. Decisões de Nomenclatura

### 6.1 Código-fonte (Inglês ou Português?)

#### ✅ Recomendação: **INGLÊS** para código, **PORTUGUÊS** para documentação

**Motivo:**

- APIs e frameworks são em inglês
- Facilita onboarding internacional
- Evita mistura de idiomas

```java
// ✅ BOM - Tudo em inglês
@Test
void shouldCalculateDiscountWhenQuantityGreaterThan10() {
    // Arrange
    DiscountCalculator calculator = new DiscountCalculator();

    // Act
    double discount = calculator.getDiscount(50);

    // Assert
    assertEquals(0.10, discount);
}

// 🔶 ACEITÁVEL - Tudo em português (se time preferir)
@Test
void deveCalcularDescontoQuandoQuantidadeMaiorQue10() {
    // Arrange
    CalculadoraDesconto calculadora = new CalculadoraDesconto();

    // Act
    double desconto = calculadora.obterDesconto(50);

    // Assert
    assertEquals(0.10, desconto);
}

// ❌ RUIM - Mistura de idiomas
@Test
void shouldCalculateDescontoWhenQuantityMaiorQue10() {
    DiscountCalculator calculadora = new DiscountCalculator();
    double desconto = calculadora.getDiscount(50);
    assertEquals(0.10, desconto);
}
```

### 6.2 Acrônimos e Siglas

**Regra: Manter acrônimos conhecidos, expandir os demais**

| Situação                  | ✅ Usar                           | ❌ Evitar                             |
| ------------------------- | --------------------------------- | ------------------------------------- |
| **Amplamente conhecido**  | TDD, BDD, CI/CD, API, REST, HTTP  | Test Driven Development (por extenso) |
| **Específico do domínio** | SLA, SLO, SLI (se equipe conhece) | Service Level Agreement (por extenso) |
| **Ambíguo**               | Integration Test                  | IT (pode ser Information Technology)  |
| **Novo/Customizado**      | CustomerRelationshipScore         | CRS (sem contexto)                    |

```java
// ✅ BOM - Acrônimos conhecidos
class OrderApiE2ETest { }
class UserTDDExample { }
class PaymentSLAValidator { }

// ❌ RUIM - Acrônimos obscuros
class OrdAPIITest { }  // O que é "I"?
class UsrTDDEx { }     // Abreviação desnecessária
class PmtSLAV { }      // Muito abreviado
```

### 6.3 Prefixos e Sufixos

**Convenção de sufixos:**

| Sufixo             | Significado           | Exemplo                          |
| ------------------ | --------------------- | -------------------------------- |
| `*Test`            | Unit test (padrão)    | `OrderServiceTest`               |
| `*IntegrationTest` | Integration test      | `OrderRepositoryIntegrationTest` |
| `*E2ETest`         | End-to-end test       | `CheckoutE2ETest`                |
| `*AcceptanceTest`  | Acceptance test (BDD) | `OrderAcceptanceTest`            |
| `*PerformanceTest` | Performance test      | `OrderServiceLoadTest`           |
| `*ContractTest`    | Contract test         | `OrderPaymentContractTest`       |
| `*Builder`         | Test data builder     | `OrderBuilder`                   |
| `*Mother`          | Object mother         | `OrderMother`                    |
| `*Fixture`         | Test fixture          | `OrderFixture`                   |

**Evitar prefixos:**

```java
// ❌ RUIM - Prefixo redundante
class TestOrderService { }

// ✅ BOM - Sufixo
class OrderServiceTest { }
```

---

## 7. Glossário Rápido

### 7.1 Termos Essenciais (A-Z)

| Termo                      | Definição                                                | Termo Relacionado                |
| -------------------------- | -------------------------------------------------------- | -------------------------------- |
| **AAA**                    | Arrange-Act-Assert (estrutura de teste)                  | Given-When-Then (BDD)            |
| **Assertion**              | Validação de resultado esperado                          | Assert, Verify                   |
| **BDD**                    | Behavior-Driven Development                              | TDD, Gherkin                     |
| **Branch Coverage**        | % de ramos condicionais testados                         | Line Coverage                    |
| **CI/CD**                  | Continuous Integration/Delivery                          | Pipeline, Automation             |
| **Circuit Breaker**        | Padrão de resiliência que interrompe chamadas falhando   | Resilience4j                     |
| **Code Coverage**          | % de código executado pelos testes                       | JaCoCo, Coverage.py              |
| **Contract Test**          | Valida contrato entre serviços                           | Pact, Spring Cloud Contract      |
| **Diff Coverage**          | Cobertura apenas de código alterado                      | Codecov, Incremental Coverage    |
| **Dummy**                  | Test double que não é usado (preenche assinatura)        | Test Double                      |
| **E2E Test**               | Teste completo do fluxo (UI → Backend → DB)              | End-to-End, Selenium             |
| **Fake**                   | Test double com implementação simplificada               | In-Memory DB, Fake Repository    |
| **Flaky Test**             | Teste com resultado não-determinístico                   | Intermittent Failure             |
| **Integration Test**       | Testa interação entre componentes                        | TestContainers, Spring Boot Test |
| **Load Test**              | Testa comportamento sob carga esperada                   | JMeter, Gatling, k6              |
| **Mock**                   | Test double que verifica comportamento                   | Mockito, Sinon                   |
| **Mutation Testing**       | Injeta bugs para validar qualidade dos testes            | PITest, Stryker                  |
| **Property-Based Testing** | Testa com dados gerados automaticamente                  | Hypothesis, QuickCheck           |
| **Regression Test**        | Valida que mudanças não quebraram funcionalidades        | Regression Suite                 |
| **Smoke Test**             | Testes básicos para verificar se sistema está funcional  | Sanity Test                      |
| **Spy**                    | Test double que observa objeto real                      | Mockito Spy, Partial Mock        |
| **Stress Test**            | Testa sistema além dos limites                           | Load Test, Performance Test      |
| **Stub**                   | Test double que retorna dados fixos                      | WireMock, Sinon                  |
| **TDD**                    | Test-Driven Development                                  | Red-Green-Refactor               |
| **Test Double**            | Objeto substituto para teste (categoria)                 | Mock, Stub, Spy, Fake, Dummy     |
| **Test Pyramid**           | Modelo de proporção de testes (Unit > Integration > E2E) | Testing Strategy                 |
| **Unit Test**              | Testa unidade isolada (classe/método)                    | JUnit, pytest, Jest              |

### 7.2 Verbos Comuns em Testes

| Português     | Inglês    | Uso                       | Exemplo                            |
| ------------- | --------- | ------------------------- | ---------------------------------- |
| **deve**      | should    | Início de nome de teste   | `deveCalcularDesconto()`           |
| **quando**    | when      | Condição do cenário       | `quandoQuantidadeMaior10()`        |
| **dado que**  | given     | Contexto inicial (BDD)    | `dadoUsuarioAutenticado()`         |
| **então**     | then      | Resultado esperado (BDD)  | `entaoRetornaDesconto10Porcento()` |
| **validar**   | validate  | Validação de regra        | `validarPedidoCompleto()`          |
| **verificar** | verify    | Checagem de comportamento | `verificarChamadaAoGateway()`      |
| **retornar**  | return    | Expectativa de retorno    | `deveRetornarVazio()`              |
| **lançar**    | throw     | Expectativa de exceção    | `deveLancarExcecao()`              |
| **criar**     | create    | Criação de entidade       | `deveCriarPedido()`                |
| **atualizar** | update    | Atualização de entidade   | `deveAtualizarStatus()`            |
| **remover**   | delete    | Remoção de entidade       | `deveRemoverPedido()`              |
| **buscar**    | fetch/get | Consulta de dados         | `deveBuscarPorId()`                |
| **processar** | process   | Execução de lógica        | `deveProcessarPagamento()`         |

### 7.3 Decisão Rápida: Qual Termo Usar?

#### Cenário 1: "Preciso substituir uma dependência no teste"

```
Você precisa de um... TEST DOUBLE

├─ Só preenche parâmetro (não é usado)?
│  └─ DUMMY
│
├─ Retorna dados fixos?
│  └─ STUB
│
├─ Observa objeto real?
│  └─ SPY
│
├─ Verifica comportamento (chamadas)?
│  └─ MOCK
│
└─ Tem implementação simplificada funcional?
   └─ FAKE
```

#### Cenário 2: "Qual tipo de teste devo escrever?"

```
Qual é o escopo?

├─ Uma classe/método isolado?
│  └─ UNIT TEST (JUnit, pytest, Jest)
│
├─ Componente + dependência real (DB, API)?
│  └─ INTEGRATION TEST (TestContainers)
│
├─ Contrato entre serviços?
│  └─ CONTRACT TEST (Pact)
│
├─ Fluxo completo (UI → Backend → DB)?
│  └─ E2E TEST (Selenium, Cypress)
│
├─ Verificação básica pós-deploy?
│  └─ SMOKE TEST
│
├─ Comportamento sob carga?
│  └─ LOAD TEST (JMeter, k6)
│
└─ Resiliência a falhas?
   └─ CHAOS TEST (Chaos Toolkit)
```

#### Cenário 3: "Qual métrica de cobertura usar?"

```
Qual é o contexto?

├─ Cobertura geral do projeto?
│  └─ CODE COVERAGE (Line + Branch)
│
├─ Cobertura apenas do código novo/alterado?
│  └─ DIFF COVERAGE
│
├─ Qualidade dos testes (detectam bugs)?
│  └─ MUTATION SCORE
│
└─ Testes instáveis?
   └─ FLAKY RATE
```

---

## 📚 Referências

### Glossários Oficiais

- [ISTQB Glossary](https://glossary.istqb.org/) - Terminologia padrão de testes
- [Martin Fowler's Bliki](https://martinfowler.com/bliki/) - Test Doubles, Mocks, Stubs
- [Google Testing Blog](https://testing.googleblog.com/) - Terminologia do Google

### Frameworks

- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [pytest Documentation](https://docs.pytest.org/)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)

### Padrões

- [xUnit Test Patterns](http://xunitpatterns.com/) - Gerard Meszaros
- [Growing Object-Oriented Software, Guided by Tests](http://www.growing-object-oriented-software.com/)

---

## ✅ Checklist de Uso

Ao escrever testes ou documentação:

- [ ] Usei termos do [Glossário Rápido](#71-termos-essenciais-a-z)?
- [ ] Evitei [Sinônimos Ambíguos](#51-ambiguidades-comuns)?
- [ ] Segui [Nomenclatura de Código](#61-código-fonte-inglês-ou-português) (inglês ou português consistente)?
- [ ] Usei sufixos corretos (`*Test`, `*IntegrationTest`, etc.)?
- [ ] Especifiquei tipo quando termo é genérico (ex: "Mock" → "Stub")?
- [ ] Referenciei glossário técnico quando necessário?
- [ ] Padronizei entre frameworks (ex: JUnit → pytest equivalência)?

---

**Convenção adotada neste projeto:**

- ✅ **Código em INGLÊS** (classes, métodos, variáveis)
- ✅ **Documentação em PORTUGUÊS** (markdown, comentários de alto nível)
- ✅ **Ferramentas OPEN SOURCE** (prioridade absoluta)
- ✅ **Termos do glossário técnico** (docs/12-taxonomia/glossario.md)
