# Guia Completo de Testes com JUnit 5 [MÉDIO-EXPERT]

> **Objetivo:** Material estruturado sobre testes em Java, cobrindo desde fundamentos até patterns avançados, preparando desenvolvedores para o nível Sênior.

---

## 📚 Estrutura do Material

Este material está organizado em **5 níveis progressivos**, permitindo aprendizado incremental ou consulta pontual conforme a necessidade.

### 🎯 Como Usar Este Material

**Para Iniciantes:**  
→ Comece por `01-fundamentos` e siga a ordem sequencial.

**Para Intermediários:**  
→ Revise `01-fundamentos` rapidamente e foque em `02-intermediario` e `03-avancado`.

**Para Avançados:**  
→ Vá direto para `03-avancado`, `04-patterns` e estude casos específicos.

**Para Consulta Pontual:**  
→ Use o índice abaixo para encontrar o tópico desejado.

---

## 📖 Índice de Conteúdo

### [01. Fundamentos](docs/01-fundamentos/) `[BÁSICO]`

Base essencial de testes com JUnit 5.

- [1.1 Introdução ao JUnit 5](docs/01-fundamentos/01.1-intro-junit5.md) - Arquitetura, vantagens, setup
- [1.2 Assertions e Estrutura Básica](docs/01-fundamentos/01.2-assertions.md) - `@Test`, assertEquals, assertTrue, assertThrows
- [1.3 Ciclo de Vida dos Testes](docs/01-fundamentos/01.3-ciclo-vida.md) - @BeforeEach, @AfterEach, @BeforeAll, @AfterAll
- [1.4 Testes Parametrizados](docs/01-fundamentos/01.4-testes-parametrizados.md) - @ValueSource, @CsvSource, @MethodSource

---

### [02. Intermediário](docs/02-intermediario/) `[MÉDIO]`

Técnicas avançadas de parametrização e mocking.

- [2.1 Testes Parametrizados Avançados](docs/02-intermediario/02.1-parametrizados-avancado.md) - @CsvFileSource, @EnumSource, Aggregators
- [2.2 Testes Dinâmicos](docs/02-intermediario/02.2-testes-dinamicos.md) - @TestFactory, DynamicTest, DynamicContainer
- [2.3 Integração com Mockito](docs/02-intermediario/02.3-mockito.md) - Mocks, stubs, spies, ArgumentCaptor
- [2.4 Boas Práticas de Nomeação](docs/02-intermediario/02.4-nomeacao-testes.md) - Padrões PT-BR e EN

---

### [03. Avançado](docs/03-avancado/) `[ALTO]`

Testes de integração, infraestrutura e cenários complexos.

- [3.1 Spring Context Testing](docs/03-avancado/03.1-spring-context.md) - @SpringBootTest, @WebMvcTest, @DataJpaTest
- [3.2 Testcontainers](docs/03-avancado/03.2-testcontainers.md) - PostgreSQL, MongoDB, Kafka, Redis
- [3.3 Mensageria](docs/03-avancado/03.3-mensageria.md) - Kafka, @EmbeddedKafka, DLQ, idempotência
- [3.4 LDAP Testing](docs/03-avancado/03.4-ldap.md) - UnboundID InMemory, operações CRUD, autenticação
- [3.5 Banco de Dados](docs/03-avancado/03.5-banco-dados.md) - JPA, Flyway, MongoDB, Redis, Elasticsearch
- [3.6 Controller Testing](docs/03-avancado/03.6-controller.md) - MockMvc, REST CRUD, validações, segurança
- [3.7 XML/JSON Testing](docs/03-avancado/03.7-xml-json.md) - JSONAssert, JsonPath, XMLUnit, Schema validation
- [3.8 Performance e Carga](docs/03-avancado/03.8-performance.md) - JMeter, Gatling, JMH

---

### [04. Patterns](docs/04-patterns/) `[EXPERT]`

Padrões de resiliência, arquitetura e boas práticas.

#### 🔄 Resilience Patterns

- [Circuit Breaker](docs/04-patterns/circuit-breaker.md) - Interrompe chamadas em caso de falhas
- [Retry](docs/04-patterns/retry.md) - Tentativas com backoff exponencial
- [Fallback](docs/04-patterns/fallback.md) - Retorno padrão em falhas
- [Timeout](docs/04-patterns/timeout.md) - Limites de tempo de execução
- [Bulkhead](docs/04-patterns/bulkhead.md) - Isolamento de recursos

#### 🏗 Architectural Patterns

- [Saga Pattern](docs/04-patterns/saga.md) - Consistência distribuída
- [Event Sourcing](docs/04-patterns/event-sourcing.md) - Persistência de eventos
- [CQRS](docs/04-patterns/cqrs.md) - Separação comando/consulta

#### 📬 Messaging Patterns

- [Publisher/Subscriber](docs/04-patterns/pubsub.md) - Entrega e assinaturas
- [Dead Letter Queue](docs/04-patterns/dlq.md) - Mensagens não processadas
- [Idempotência](docs/04-patterns/idempotencia.md) - Proteção contra duplicatas

#### 💾 Cache Patterns

- [Cache Aside](docs/04-patterns/cache-aside.md) - Invalidação e atualização
- [Read/Write Through](docs/04-patterns/cache-through.md) - Sincronização com DB

#### 🔒 Security Patterns

- [Token Refresh](docs/04-patterns/token-refresh.md) - Expiração e renovação
- [Rate Limiting](docs/04-patterns/rate-limiting.md) - Controle de requisições

---

### [05. Transversal](docs/05-transversal/) `[TODOS OS NÍVEIS]`

Conceitos aplicáveis a todos os níveis.

- [Princípios de Testes](docs/05-transversal/principios-testes.md) - AAA, Determinismo, Isolamento, Clock
- [Boas Práticas](docs/05-transversal/boas-praticas.md) - Consolidado de todas as seções
- [Anti-Patterns](docs/05-transversal/anti-patterns.md) - O que evitar
- [Glossário](docs/05-transversal/glossario.md) - Termos técnicos unificados

---

## 🎓 Trilhas de Aprendizado

### Trilha 1: Qualidade de Código `[8h]`

1. 01.1 Intro JUnit 5
2. 01.2 Assertions
3. 01.4 Testes Parametrizados
4. 02.3 Mockito
5. 05-transversal/principios-testes.md
6. 05-transversal/boas-praticas.md

### Trilha 2: Resiliência `[12h]`

1. 03.3 Mensageria
2. 04-patterns/circuit-breaker.md
3. 04-patterns/retry.md
4. 04-patterns/fallback.md
5. 04-patterns/timeout.md
6. 04-patterns/bulkhead.md

### Trilha 3: Integração e Infraestrutura `[16h]`

1. 03.1 Spring Context
2. 03.2 Testcontainers
3. 03.5 Banco de Dados
4. 03.6 Controller
5. 03.3 Mensageria

### Trilha 4: Arquitetura Distribuída `[20h]`

1. 04-patterns/saga.md
2. 04-patterns/event-sourcing.md
3. 04-patterns/cqrs.md
4. 04-patterns/pubsub.md
5. 04-patterns/idempotencia.md
6. 03.3 Mensageria
7. 03.8 Performance

---

## 🔧 Ferramentas e Dependências

### Essenciais

```xml
<!-- JUnit 5 -->
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter</artifactId>
    <version>5.10.1</version>
    <scope>test</scope>
</dependency>

<!-- Mockito -->
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-junit-jupiter</artifactId>
    <version>5.7.0</version>
    <scope>test</scope>
</dependency>

<!-- AssertJ -->
<dependency>
    <groupId>org.assertj</groupId>
    <artifactId>assertj-core</artifactId>
    <version>3.24.2</version>
    <scope>test</scope>
</dependency>
```

### Spring Boot Testing

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

### Testcontainers

```xml
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>testcontainers</artifactId>
    <version>1.19.3</version>
    <scope>test</scope>
</dependency>
```

---

## 📊 Convenções do Material

### Tags de Dificuldade

- `[BÁSICO]` - Conceitos essenciais, sem pré-requisitos complexos
- `[MÉDIO]` - Integração de conceitos, múltiplas bibliotecas
- `[ALTO]` - Arquitetura, trade-offs, múltiplos componentes
- `[EXPERT]` - Sistemas distribuídos, performance, segurança avançada

### Emojis Semânticos

- 🧪 Código/Testes/Laboratórios
- 🎯 Objetivo/Propósito
- ⚠ Pitfalls/Riscos/Anti-patterns
- 📊 Métricas/Fórmulas
- 🧠 Reflexões/Perguntas
- 🔍 Estudos de Caso
- ✅ Checklists

### Estrutura Padrão de Arquivo

```markdown
# Título [NÍVEL]

🎯 **Objetivo:** Descrição clara (1-2 linhas)

## Contexto

Introdução breve...

## 🧪 Exemplos Práticos

Código executável...

## ⚠ Pitfalls Comuns

Lista de erros frequentes...

## 📊 Métricas

Fórmulas e limiares...

## ✅ Checklist

Critérios de pronto...

## 🧠 Perguntas Reflexivas

Questões para aprofundamento...
```

---

## 🚀 Início Rápido

### 1. Clone o Repositório

```bash
git clone [repo-url]
cd plano_senior
```

### 2. Valide a Estrutura

```bash
python scripts/check_duplicate_headings.py
```

### 3. Escolha Sua Trilha

Consulte [🎓 Trilhas de Aprendizado](#-trilhas-de-aprendizado) e comece!

---

## 📝 Contribuindo

### Guia de Estilo

Leia [docs/STYLEGUIDE.md](docs/STYLEGUIDE.md) antes de contribuir.

### Scripts de Validação

- `scripts/check_duplicate_headings.py` - Detecta headings duplicados
- `scripts/generate_toc.py` - Gera índices automaticamente (futuro)

### Processo de Contribuição

1. Verifique se o conteúdo pertence a uma das 5 categorias
2. Aplique tags de dificuldade e emojis semânticos
3. Execute script de validação
4. Abra PR com descrição clara

---

## 📈 Roadmap

- [x] **Fase 1:** Higienização inicial (concluída)
- [x] **Fase 2:** Modularização do conteúdo (em andamento)
- [ ] **Fase 3:** Matriz de Patterns
- [ ] **Fase 4:** Princípios Transversais consolidados
- [ ] **Fase 5:** Trilhas de Exercícios interativos
- [ ] **Fase 6:** Checklists & Autoavaliação
- [ ] **Fase 7:** Estudos de Caso com Diagramas
- [ ] **Fase 8:** Métricas & Automação
- [ ] **Fase 9:** Perguntas de Entrevista Técnica
- [ ] **Fase 10:** Revisão Editorial & Taxonomia
- [ ] **Fase 11:** Especializações Avançadas

---

## 📚 Referências

- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://javadoc.io/doc/org.mockito/mockito-core/latest/org/mockito/Mockito.html)
- [Testcontainers Documentation](https://www.testcontainers.org/)
- [Spring Boot Testing](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.testing)
- [AssertJ Documentation](https://assertj.github.io/doc/)

---

## 📞 Suporte

- **Documentação:** [docs/](docs/)
- **Issues:** Use GitHub Issues para reportar problemas
- **Discussões:** Use GitHub Discussions para perguntas

---

**Licença:** MIT  
**Manutenção:** Material vivo, atualizado continuamente  
**Última Atualização:** 2025-11-14 (Fase 2 iniciada)
