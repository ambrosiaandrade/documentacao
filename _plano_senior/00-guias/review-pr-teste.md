# Checklist de Code Review - Foco em Testes

**Objetivo:** Garantir qualidade, cobertura e efetividade dos testes em Pull Requests.

**Como usar:**

1. Revisor copia esta checklist no PR
2. Marca itens conforme revisa o código
3. Bloqueia merge se itens críticos (❌) não atendidos
4. Aprova com comentários se apenas warnings (⚠️)

---

## 🎯 Checklist Rápida (30 segundos)

Use para PRs pequenos (<200 linhas):

- [ ] **Coverage:** Código novo está testado?
- [ ] **Build:** Testes passam no CI?
- [ ] **Naming:** Nomes de testes descrevem comportamento?
- [ ] **Assertions:** Asserts validam o que prometem?
- [ ] **Flakiness:** Testes são determinísticos?

---

## 📋 Checklist Completa

### 1️⃣ Cobertura (Coverage)

#### ❌ Bloqueantes

- [ ] **Código novo possui testes**
  - Todo código de produção novo tem pelo menos 1 teste
  - Métodos públicos estão testados
  - Branches principais (if/else, switch) testados
- [ ] **Coverage mínimo atingido**
  - Line coverage ≥ 80% no diff
  - Branch coverage ≥ 70% no diff
  - CI reporta coverage e não falha
- [ ] **Código crítico tem testes**
  - Lógica de negócio crítica: coverage 100%
  - Cálculos financeiros: casos de borda testados
  - Segurança (auth, validação): cobertura completa

#### ⚠️ Warnings

- [ ] **Coverage gaps justificados**
  - Código não testado tem comentário // TODO: test
  - Métodos triviais (getters/setters) podem não ter testes
  - Código de infraestrutura (config classes) pode ter baixa coverage

**Perguntas para o Autor:**

- Qual linha não testada é a mais arriscada?
- Por que decidiu não testar X?
- Como validaria manualmente essa parte?

---

### 2️⃣ Qualidade dos Testes

#### ❌ Bloqueantes

- [ ] **Testes validam comportamento, não implementação**

  ```java
  // ❌ MAU: Testa implementação
  verify(repository, times(1)).save(any());

  // ✅ BOM: Testa comportamento
  Order result = orderService.create(request);
  assertThat(result.getStatus()).isEqualTo(CREATED);
  ```

- [ ] **Assertions significativas**

  ```java
  // ❌ MAU: Assert vazio/genérico
  assertThat(result).isNotNull();

  // ✅ BOM: Assert específico
  assertThat(result.getTotalAmount()).isEqualByComparingTo(new BigDecimal("150.00"));
  assertThat(result.getItems()).hasSize(3);
  ```

- [ ] **Casos de borda testados**

  - Lista vazia, null, zero, negativo
  - Strings vazias, muito longas, caracteres especiais
  - Datas passadas, futuras, limites
  - Exceções esperadas

- [ ] **Happy path E sad path**
  - Não apenas fluxo de sucesso
  - Validações de erro testadas
  - Exceções capturadas e validadas

#### ⚠️ Warnings

- [ ] **Nomes de testes descritivos**

  ```java
  // ❌ MAU: Nome genérico
  void testCreate()

  // ✅ BOM: Nome descritivo
  void shouldCreateOrder_whenValidRequest()
  void shouldThrowValidationException_whenItemsAreEmpty()
  ```

- [ ] **Testes pequenos e focados**

  - Um teste valida um comportamento
  - Evita testes com múltiplos asserts não relacionados
  - Arrange-Act-Assert claro

- [ ] **Test Data Builders usados**

  ```java
  // ❌ MAU: Construção manual
  Order order = new Order();
  order.setId("123");
  order.setItems(Arrays.asList(...));
  order.setCustomer(customer);

  // ✅ BOM: Builder
  Order order = OrderBuilder.anOrder()
      .withItems(3)
      .withCustomer(customerAlice())
      .build();
  ```

**Perguntas para o Autor:**

- Este teste ainda passaria se a implementação mudasse?
- O nome do teste explica o que ele valida?
- Quais casos de borda faltam?

---

### 3️⃣ Isolamento e Determinismo

#### ❌ Bloqueantes

- [ ] **Testes são isolados**

  - Não dependem de ordem de execução
  - Cada teste limpa seu próprio estado (@BeforeEach, @AfterEach)
  - Não compartilham estado mutável entre testes

- [ ] **Testes são determinísticos**

  ```java
  // ❌ MAU: Não determinístico
  LocalDateTime now = LocalDateTime.now();
  Thread.sleep(1000);

  // ✅ BOM: Determinístico
  Clock clock = Clock.fixed(Instant.parse("2025-01-15T10:00:00Z"), ZoneId.of("UTC"));
  ```

- [ ] **Dependências externas mockadas**

  - APIs externas: WireMock, MockServer
  - Banco de dados: Testcontainers, H2
  - Filesystem: JUnit TempDirectory
  - Clock: Clock.fixed()
  - Random: seed fixo

- [ ] **Sem Thread.sleep()**

  ```java
  // ❌ MAU: Sleep
  Thread.sleep(5000);
  assertThat(result).isNotNull();

  // ✅ BOM: Awaitility
  await().atMost(Duration.ofSeconds(5))
      .untilAsserted(() -> assertThat(result).isNotNull());
  ```

#### ⚠️ Warnings

- [ ] **@BeforeEach limpa estado**

  - Repositories limpos
  - Caches invalidados
  - Mocks resetados

- [ ] **Sem variáveis estáticas mutáveis**
  - Statics podem vazar entre testes
  - Preferir injeção de dependência

**Perguntas para o Autor:**

- Estes testes passam se executados em ordem aleatória?
- Há algum estado compartilhado entre testes?
- Como garantir que o tempo/random é fixo?

---

### 4️⃣ Performance dos Testes

#### ❌ Bloqueantes

- [ ] **Testes unitários são rápidos**

  - Unitários: < 100ms por teste
  - Suite inteira de unitários: < 30s
  - Sem I/O real (disco, rede, banco)

- [ ] **Testes de integração têm timeout**

  ```java
  @Test
  @Timeout(value = 5, unit = TimeUnit.SECONDS)
  void shouldProcessOrder_withinTimeout() {
      // ...
  }
  ```

- [ ] **Sem sleeps desnecessários**
  - Usar Awaitility com timeout mínimo
  - Não esperar tempo fixo se não necessário

#### ⚠️ Warnings

- [ ] **Tests paralelos quando possível**

  ```xml
  <!-- Maven Surefire -->
  <parallel>classes</parallel>
  <threadCount>4</threadCount>
  ```

- [ ] **Testcontainers reusable**

  ```java
  @Container
  static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>()
      .withReuse(true);
  ```

- [ ] **Banco em memória para unitários**
  - H2 para testes rápidos
  - Testcontainers apenas para integração

**Perguntas para o Autor:**

- Quanto tempo leva para executar todos os testes?
- Algum teste demora mais de 1s? Por quê?
- Há I/O que pode ser mockado?

---

### 5️⃣ Mocks e Test Doubles

#### ❌ Bloqueantes

- [ ] **Mocks justificados**

  - Não mockar DTOs ou value objects
  - Mockar apenas dependências externas ou complexas
  - Preferir objetos reais quando simples

- [ ] **Mocks não sobre-especificados**

  ```java
  // ❌ MAU: Mock frágil
  when(repository.findById(eq("123"))).thenReturn(Optional.of(order));
  verify(repository, times(1)).findById(eq("123"));

  // ✅ BOM: Mock flexível
  when(repository.findById(anyString())).thenReturn(Optional.of(order));
  // Não verificar se não crítico
  ```

- [ ] **Stubs preferidos para queries**

  ```java
  // ✅ Stub para query (apenas retorno)
  when(orderRepository.findById("123")).thenReturn(Optional.of(order));

  // ✅ Mock para command (verificar chamada)
  verify(paymentService).processPayment(any());
  ```

#### ⚠️ Warnings

- [ ] **Usar ArgumentCaptor com cautela**

  ```java
  // ⚠️ Captor pode ser sinal de teste frágil
  ArgumentCaptor<Order> captor = ArgumentCaptor.forClass(Order.class);
  verify(repository).save(captor.capture());
  assertThat(captor.getValue().getStatus()).isEqualTo(CREATED);

  // ✅ Melhor: Testar resultado, não parâmetro interno
  Order result = orderService.create(request);
  assertThat(result.getStatus()).isEqualTo(CREATED);
  ```

- [ ] **Mock vs Spy**
  - Preferir Mock (comportamento totalmente definido)
  - Spy apenas quando necessário (mistura real + mock)

**Perguntas para o Autor:**

- Por que mockar X ao invés de usar objeto real?
- Essa verificação de mock é realmente necessária?
- O teste continua válido se a implementação mudar?

---

### 6️⃣ Flakiness (Testes Instáveis)

#### ❌ Bloqueantes

- [ ] **Sem dependências de tempo real**

  - Clock injetado e fixo
  - Não usar System.currentTimeMillis() em testes
  - Datas/timestamps mockadas

- [ ] **Sem dependências de ordem**

  - Listas ordenadas explicitamente se necessário
  - Não assumir ordem de HashMap/Set

- [ ] **Sem race conditions**

  - Sincronização adequada em testes assíncronos
  - Awaitility para validar estados eventuais
  - CountDownLatch quando necessário

- [ ] **Sem dependências de ambiente**
  - Não ler arquivos de diretórios fixos
  - Usar @TempDir para arquivos temporários
  - Portas dinâmicas (não hardcoded)

#### ⚠️ Warnings

- [ ] **Retry apenas se justificado**

  - @RepeatedTest(10) para testes estatísticos
  - Não usar retry para esconder flakiness
  - Preferir corrigir causa raiz

- [ ] **Logs adequados em falhas**
  - Erros com contexto suficiente para debug
  - Não apenas "expected X but was Y"

**Perguntas para o Autor:**

- Este teste já falhou aleatoriamente alguma vez?
- Há alguma dependência de tempo/ordem/ambiente?
- Como debugaria se este teste ficasse flaky?

---

### 7️⃣ Mutation Testing

#### ⚠️ Warnings (Recomendado para código crítico)

- [ ] **Mutation score considerado**

  - Código crítico: mutation score ≥ 80%
  - Testes matam mutantes principais:
    - Condicionais invertidos (> virou >=)
    - Retornos trocados (true virou false)
    - Matemática alterada (+ virou -)

- [ ] **Mutantes sobreviventes justificados**
  - Logging geralmente não precisa matar mutantes
  - Código defensivo pode ter mutantes "allowed"

**Perguntas para o Autor:**

- Este teste detectaria se a lógica fosse invertida?
- E se o return fosse trocado de true para false?

---

### 8️⃣ Testes de Integração

#### ❌ Bloqueantes

- [ ] **Testcontainers configurado**

  - Banco real (Postgres, MySQL) via container
  - Não usar banco compartilhado para testes
  - @Transactional com rollback automático

- [ ] **Contratos validados**

  - APIs externas: contrato testado (Pact, Spring Cloud Contract)
  - Não assumir comportamento de API sem teste

- [ ] **Resiliência testada**
  - Timeout configurado e testado
  - Retry testado com WireMock scenarios
  - Circuit breaker testado (aberto/fechado/half-open)

#### ⚠️ Warnings

- [ ] **Não duplicar testes**

  - Integração complementa unitário, não duplica
  - Unitário: lógica isolada
  - Integração: comunicação entre componentes

- [ ] **Dados de teste gerenciados**
  - Scripts SQL versionados
  - Flyway/Liquibase para migrações de teste
  - Test Data Builders para criar fixtures

**Perguntas para o Autor:**

- Este teste de integração testa algo não coberto por unitários?
- Como os dados de teste são gerenciados?
- Há rollback automático entre testes?

---

### 9️⃣ Segurança nos Testes

#### ❌ Bloqueantes

- [ ] **Sem secrets hardcoded**

  ```java
  // ❌ MAU: Secret hardcoded
  String apiKey = "sk-1234567890abcdef";

  // ✅ BOM: Secret de teste
  String apiKey = "test-key-not-real";
  ```

- [ ] **SQL Injection testado**

  ```java
  @Test
  void shouldPreventSqlInjection() {
      String maliciousInput = "'; DROP TABLE users; --";
      assertThatThrownBy(() -> userService.search(maliciousInput))
          .isInstanceOf(ValidationException.class);
  }
  ```

- [ ] **Autenticação/Autorização testada**
  - Testes com @WithMockUser
  - Validar roles/permissions
  - Testar acesso negado (403/401)

#### ⚠️ Warnings

- [ ] **OWASP Top 10 considerado**
  - SQL Injection, XSS, CSRF testados quando aplicável
  - Validação de inputs testada
  - Encoding de outputs testado

**Perguntas para o Autor:**

- Há validação de segurança neste código?
- Como garantir que SQL injection não ocorre?
- Autenticação/Autorização estão testadas?

---

### 🔟 Documentação e Manutenibilidade

#### ⚠️ Warnings

- [ ] **Testes auto-documentadores**

  - Nome do teste explica cenário
  - Given-When-Then claro
  - Não precisa de comentários para entender

- [ ] **Javadoc apenas se necessário**

  - Testes são auto-explicativos
  - Javadoc para testes complexos ou algoritmos

- [ ] **Código de teste limpo**
  - DRY: extrair setup comum
  - Helper methods para criar fixtures
  - Não copiar/colar testes

**Perguntas para o Autor:**

- Um desenvolvedor novo entenderia este teste em 1 minuto?
- Há duplicação que pode ser extraída?

---

## 🚨 Red Flags (Revisar com Atenção)

### 🔴 Bloqueio Imediato

- ❌ **Sem testes:** Código novo sem nenhum teste
- ❌ **Testes desabilitados:** @Disabled, @Ignore sem justificativa
- ❌ **Testes comentados:** Código de teste comentado
- ❌ **Testes falhando:** CI vermelho
- ❌ **Coverage caiu:** Diff coverage < 50%

### 🟡 Atenção Redobrada

- ⚠️ **Muitos mocks:** > 5 mocks em um teste
- ⚠️ **Teste gigante:** > 50 linhas (Arrange muito grande)
- ⚠️ **AssertTrue/False genérico:** Não diz o que valida
- ⚠️ **Sleeps:** Thread.sleep() presente
- ⚠️ **Prints:** System.out.println() em testes

---

## 📊 Métricas para Acompanhar

### Por PR

- Coverage do diff (linha e branch)
- Número de testes adicionados
- Tempo de execução dos testes
- Flaky tests (se houver histórico)

### Por Time (Sprint)

- Coverage geral do projeto
- Mutation score (código crítico)
- Flaky rate (% testes instáveis)
- Test execution time (tendência)

---

## 🎯 Exemplos de Feedback Construtivo

### ❌ Feedback Ruim

> "Faltam testes aqui."

### ✅ Feedback Bom

> "O método `calculateDiscount()` não está testado. Sugiro adicionar testes para:
>
> - Desconto de 10% para clientes VIP
> - Zero desconto para não-VIP
> - Edge case: desconto não pode ser > 50%"

---

### ❌ Feedback Ruim

> "Esse teste está errado."

### ✅ Feedback Bom

> "Este teste valida a chamada do mock (`verify`), mas não valida o resultado retornado ao usuário. Sugiro adicionar:
>
> ````java
> Order result = orderService.create(request);
> assertThat(result.getStatus()).isEqualTo(CREATED);
> ```"
> ````

---

### ❌ Feedback Ruim

> "Muito mock."

### ✅ Feedback Bom

> "Este teste mocka 7 dependências. Considere:
>
> 1. Usar objetos reais para DTOs (Customer, OrderItem)
> 2. Mockar apenas PaymentService (dependência externa)
> 3. Isso tornará o teste mais simples e menos frágil."

---

## 📋 Template de Comentário para PR

```markdown
## ✅ Code Review - Testes

### Coverage

- [ ] Código novo testado: SIM / NÃO
- [ ] Coverage diff: \_\_\_%
- [ ] Casos de borda testados: LISTA

### Qualidade

- [ ] Nomes descritivos: OK / MELHORAR
- [ ] Assertions significativas: OK / MELHORAR
- [ ] Isolamento: OK / PROBLEMAS

### Performance

- [ ] Testes rápidos (< 100ms): SIM / NÃO
- [ ] Sem sleeps: OK / TEM SLEEPS

### Flakiness

- [ ] Determinísticos: SIM / RISCO
- [ ] Sem dependências externas: OK / DEPENDE DE X

### Comentários

[Seus comentários aqui]

### Veredito

- [ ] ✅ APPROVED
- [ ] 💬 APPROVED COM SUGESTÕES
- [ ] 🔄 REQUEST CHANGES
```

---

## 🎓 Para o Autor do PR

### Antes de Abrir o PR

- [ ] Executei todos os testes localmente
- [ ] Verifiquei coverage do meu código
- [ ] Testei casos de borda
- [ ] Nomes de testes são descritivos
- [ ] Testes são determinísticos (executei 10x)
- [ ] Sem sleeps ou dependencies de tempo
- [ ] Código de teste está limpo (DRY)

### Ao Receber Feedback

- [ ] Agradeça o feedback
- [ ] Aplique sugestões ou explique por que não
- [ ] Re-execute testes após mudanças
- [ ] Atualize descrição do PR se necessário

---

## 📚 Referências

- **Livro:** _Effective Software Testing_ - Maurício Aniche
- **Livro:** _Growing Object-Oriented Software, Guided by Tests_ - Freeman/Pryce
- **Livro:** _xUnit Test Patterns_ - Gerard Meszaros
- **Site:** [Test Desiderata](https://kentbeck.github.io/TestDesiderata/) - Kent Beck

---

**Última Atualização:** 2025-11-15  
**Versão:** 1.0  
**Criado em:** Fase 6 - Checklists & Autoavaliação
