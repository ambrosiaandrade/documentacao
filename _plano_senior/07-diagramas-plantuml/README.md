# Diagramas PlantUML - Patterns de Engenharia de Software

Esta pasta contém diagramas de sequência detalhados dos principais padrões de resiliência, arquitetura e design (GoF) utilizados em sistemas modernos.

## 📋 Índice de Diagramas

### 🛡️ Padrões de Resiliência

| #   | Diagrama                                                             | Descrição                                                                                                    | Linhas |
| --- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ------ |
| 01  | [Circuit Breaker](./01-circuit-breaker.puml)                         | Máquina de estados: CLOSED → OPEN → HALF_OPEN. Failure tracking, timer transitions, métricas.                | ~150   |
| 02  | [Retry with Backoff](./02-retry-backoff.puml)                        | Exponential backoff com jitter. 5 tentativas, delays calculados (0.95s → 8.48s). Comparação de estratégias.  | ~180   |
| 03  | [Saga Orchestration](./03-saga-orchestration.puml)                   | Saga orchestrada: Payment → Inventory → Shipping. Compensation flows, Saga Log, idempotency.                 | ~280   |
| 04  | [Bulkhead Isolation](./04-bulkhead-isolation.puml)                   | Thread pools isolados (Critical/Normal/Batch). Saturação, database connection pools, métricas.               | ~200   |
| 05  | [Rate Limiting (Token Bucket)](./05-rate-limiting-token-bucket.puml) | Token bucket algorithm. Burst capacity, refill automático, Redis Lua script, multi-tier (Free → Enterprise). | ~250   |

### 🏗️ Padrões de Arquitetura

| #   | Diagrama                                                   | Descrição                                                                                                              | Linhas |
| --- | ---------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ------ |
| 06  | [Hexagonal Architecture](./06-hexagonal-architecture.puml) | Ports & Adapters. Core Domain isolado, Primary/Secondary Ports, múltiplos adapters (REST, GraphQL, JPA, Stripe).       | ~320   |
| 07  | [CQRS](./07-cqrs-pattern.puml)                             | Command/Query Segregation. Write model (PostgreSQL) + Read model (MongoDB), eventual consistency, múltiplas projeções. | ~350   |
| 08  | [Event Sourcing](./08-event-sourcing.puml)                 | Event Store como source of truth. Event replay, aggregate rehydration, snapshots, time travel queries.                 | ~380   |
| 14  | [Pub/Sub Architecture](./14-pubsub-architecture.puml)      | Kafka-based messaging. Topics, partitions, consumer groups, offset management, fan-out, delivery guarantees.           | ~350   |

### 🎨 Padrões de Design (GoF)

| #   | Diagrama                                         | Descrição                                                                                             | Linhas |
| --- | ------------------------------------------------ | ----------------------------------------------------------------------------------------------------- | ------ |
| 09  | [Factory Method](./09-factory-method.puml)       | Payment factories (CreditCard, PayPal, Pix). Runtime selection, dependency injection, extensibility.  | ~270   |
| 10  | [Builder Pattern](./10-builder-pattern.puml)     | Fluent API para construção de objetos complexos. Nested builders, Object Mother, test data builders.  | ~320   |
| 11  | [Strategy Pattern](./11-strategy-pattern.puml)   | Discount strategies (NoDiscount, Percentage, Fixed, VIPTiered). Runtime algorithm selection, DI.      | ~290   |
| 12  | [Observer Pattern](./12-observer-pattern.puml)   | Event notification system. Multiple observers (Email, SMS, Push, Analytics), Spring ApplicationEvent. | ~340   |
| 13  | [Decorator Pattern](./13-decorator-pattern.puml) | Dynamic behavior addition. Logging, Caching, Validation decorators. Spring AOP, Java I/O streams.     | ~360   |

### 🔐 Padrões de Segurança & Autenticação

| #   | Diagrama                                                            | Descrição                                                                                                                       | Linhas |
| --- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 15  | [OAuth 2.0 Authorization Code](./15-oauth2-authorization-code.puml) | OAuth 2.0 flow completo com PKCE. Authorization Code Grant, token exchange, refresh token rotation, revocation.                 | ~650   |
| 16  | [JWT Lifecycle](./16-jwt-lifecycle.puml)                            | JWT creation, validation, claims, signature verification, JWKS endpoint, blacklist, expiration handling.                        | ~580   |
| 17  | [JWE Encryption](./17-jwe-encryption.puml)                          | JSON Web Encryption. RSA-OAEP + AES-GCM, hybrid cryptography, CEK encryption, nested JWT (sign then encrypt).                   | ~620   |
| 18  | [Facial Recognition](./18-facial-recognition.puml)                  | Biometric authentication. OpenCV preprocessing, face_recognition (dlib), DeepFace (FaceNet), liveness detection, anti-spoofing. | ~700   |

### 📊 Diagramas Alternativos (Diferentes Perspectivas)

| #   | Diagrama                                                                             | Descrição                                                                                          | Linhas |
| --- | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- | ------ |
| 19  | [Circuit Breaker - State Diagram](./19-circuit-breaker-state-diagram.puml)           | State machine view do Circuit Breaker. Transições de estado, condições, configuração Resilience4j. | ~120   |
| 20  | [CQRS - Component Diagram](./20-cqrs-component-diagram.puml)                         | Component architecture view. Command API, Query API, Write/Read DBs, Event Bus, Projectors.        | ~180   |
| 21  | [Saga - Choreography vs Orchestration](./21-saga-choreography-vs-orchestration.puml) | Comparação lado a lado. Event-driven choreography vs central orchestrator, compensation flows.     | ~250   |

**Total:** 21 diagramas | ~8.030 linhas de PlantUML

## 🚀 Como Usar

### Pré-requisitos

#### Opção 1: VS Code (Recomendado)

1. **Instalar PlantUML Extension:**

   ```bash
   code --install-extension jebbs.plantuml
   ```

2. **Instalar Java Runtime (se não tiver):**

   ```bash
   # Windows (com Chocolatey)
   choco install openjdk11

   # macOS (com Homebrew)
   brew install openjdk@11

   # Linux (Ubuntu/Debian)
   sudo apt-get install openjdk-11-jre
   ```

3. **Instalar Graphviz:**

   ```bash
   # Windows
   choco install graphviz

   # macOS
   brew install graphviz

   # Linux
   sudo apt-get install graphviz
   ```

4. **Abrir diagrama e pressionar:** `Alt + D` (preview)

#### Opção 2: PlantUML Online

Acesse: [http://www.plantuml.com/plantuml/uml/](http://www.plantuml.com/plantuml/uml/)

1. Copie o conteúdo de qualquer arquivo `.puml`
2. Cole no editor online
3. Diagrama renderizado automaticamente

#### Opção 3: CLI Local

```bash
# Baixar plantuml.jar
wget https://sourceforge.net/projects/plantuml/files/plantuml.jar/download -O plantuml.jar

# Gerar imagem PNG
java -jar plantuml.jar 01-circuit-breaker.puml

# Gerar SVG (vetorial)
java -jar plantuml.jar -tsvg 01-circuit-breaker.puml

# Processar todos os diagramas
java -jar plantuml.jar *.puml
```

### Renderização em Batch

```bash
# Gerar todos os diagramas como PNG
cd docs/07-diagramas-plantuml
java -jar plantuml.jar -o ./output *.puml

# Gerar SVG (melhor qualidade para zoom)
java -jar plantuml.jar -tsvg -o ./output *.puml
```

## 📖 Estrutura dos Diagramas

Cada diagrama segue uma estrutura consistente:

### 1. **Título e Configuração**

```plantuml
@startuml Nome do Pattern
!theme plain
skinparam sequenceMessageAlign center

title Pattern Name - Description
```

### 2. **Participantes**

- Atores (Cliente, Sistema)
- Serviços (OrderService, PaymentService)
- Componentes (Circuit Breaker, Cache)
- Infraestrutura (Database, Queue, Kafka)

### 3. **Cenários Detalhados**

#### Happy Path

- Fluxo normal de execução
- Todos os steps bem-sucedidos
- Resultado esperado

#### Error Path

- Falhas e exceções
- Mecanismos de recuperação
- Fallbacks e compensações

#### Edge Cases

- Casos especiais
- Saturação
- Timeouts

### 4. **Notas Técnicas**

#### Código de Exemplo

```java
// Configuração Resilience4j
CircuitBreakerConfig config = CircuitBreakerConfig.custom()
  .failureRateThreshold(50)
  .waitDurationInOpenState(Duration.ofSeconds(60))
  .build();
```

#### Métricas

- `circuit.breaker.state`
- `calls.total`, `calls.failed`
- `state.transitions`

#### Benefits vs Trade-offs

- ✅ Benefícios (loose coupling, scalability)
- ⚠️ Trade-offs (complexity, eventual consistency)

### 5. **Use Cases**

- Quando usar
- Quando NÃO usar
- Casos de uso reais

## 🔗 Integração com Documentação Existente

Estes diagramas complementam a documentação detalhada dos patterns na pasta `04-patterns/`:

| Diagrama        | Documentação Relacionada                            |
| --------------- | --------------------------------------------------- |
| Circuit Breaker | `04-patterns/resiliencia/circuit-breaker.md`        |
| Retry           | `04-patterns/resiliencia/retry-backoff.md`          |
| Saga            | `04-patterns/resiliencia/saga.md`                   |
| Bulkhead        | `04-patterns/resiliencia/bulkhead.md`               |
| Rate Limiting   | `04-patterns/resiliencia/rate-limiting.md`          |
| Hexagonal       | `04-patterns/arquitetura/hexagonal-architecture.md` |
| CQRS            | `04-patterns/arquitetura/cqrs.md`                   |
| Event Sourcing  | `04-patterns/arquitetura/event-sourcing.md`         |
| Factory Method  | `04-patterns/gof/criacionais/factory-method.md`     |
| Builder         | `04-patterns/gof/criacionais/builder.md`            |
| Strategy        | `04-patterns/gof/comportamentais/strategy.md`       |
| Observer        | `04-patterns/gof/comportamentais/observer.md`       |
| Decorator       | `04-patterns/gof/estruturais/decorator.md`          |

**Recomendação:** Leia a documentação em `04-patterns/` primeiro para entender conceitos, depois visualize os diagramas para ver sequências de execução.

## 🎯 Casos de Uso

### 1. **Estudo Visual**

- Ver fluxos de execução passo a passo
- Entender interações entre componentes
- Visualizar estados e transições

### 2. **Design de Sistema**

- Planejar implementações
- Comunicar decisões arquiteturais
- Onboarding de novos membros

### 3. **Code Review**

- Validar implementações contra patterns
- Identificar desvios
- Sugerir melhorias

### 4. **Troubleshooting**

- Entender fluxo durante debugging
- Identificar pontos de falha
- Analisar race conditions

### 5. **Documentação de ADRs**

- Incluir diagramas em Architecture Decision Records
- Ilustrar trade-offs
- Comparar alternativas

## 🛠️ Tecnologias Referenciadas

Os diagramas incluem exemplos de código e configuração para:

### Frameworks

- **Spring Boot** (DI, @EventListener, @Async, @Cacheable)
- **Resilience4j** (Circuit Breaker, Retry, Bulkhead, Rate Limiter)
- **Kafka** (Producer, Consumer, Streams)

### Bancos de Dados

- **PostgreSQL** (Write model, transações)
- **MongoDB** (Read model, agregações)
- **Redis** (Cache, rate limiting)
- **ClickHouse** (Analytics)

### Testing

- **JUnit 5** (Unit tests)
- **Mockito** (Mocking)
- **Testcontainers** (Integration tests)
- **WireMock** (HTTP mocking)

### Observability

- **Prometheus** (Métricas)
- **Grafana** (Dashboards)
- **OpenTelemetry** (Distributed tracing)
- **ELK Stack** (Logging)

## 📊 Métricas e Observabilidade

Cada diagrama de resiliência inclui seção de métricas:

### Circuit Breaker

```java
registry.counter("circuit.breaker.calls.total", "state", "closed").increment();
registry.gauge("circuit.breaker.failure.rate", failureRate);
registry.counter("circuit.breaker.state.transitions", "to", "open").increment();
```

### Rate Limiting

```java
registry.counter("rate.limiter.requests.total", "result", "allowed").increment();
registry.counter("rate.limiter.requests.rejected").increment();
registry.gauge("rate.limiter.tokens.available", tokensAvailable);
```

### Saga

```java
registry.counter("saga.executions.total", "status", "completed").increment();
registry.timer("saga.execution.duration").record(duration);
registry.counter("saga.compensations.total").increment();
```

## 🔄 Comparações de Patterns

Alguns diagramas incluem comparações:

### Decorator vs Inheritance

- **Decorator:** Composição, runtime, flexível
- **Inheritance:** Herança, compile-time, rígido

### Observer vs Pub/Sub

- **Observer:** In-memory, single process, síncrono
- **Pub/Sub:** Broker-based, distributed, assíncrono

### Retry Strategies

- Fixed Delay vs Linear vs Exponential vs Exponential+Jitter
- Trade-offs de cada abordagem

## 📚 Referências

### PlantUML

- [PlantUML Official Documentation](https://plantuml.com/)
- [Sequence Diagram Guide](https://plantuml.com/sequence-diagram)
- [PlantUML Cheatsheet](https://plantuml.com/guide)

### Patterns

- **Martin Fowler:** [Patterns of Enterprise Application Architecture](https://martinfowler.com/eaaCatalog/)
- **Gang of Four:** Design Patterns: Elements of Reusable Object-Oriented Software
- **Chris Richardson:** [Microservices Patterns](https://microservices.io/patterns/index.html)
- **Sam Newman:** Building Microservices

### Resilience

- **Release It!** by Michael Nygard
- **Resilience4j Documentation:** [resilience4j.readme.io](https://resilience4j.readme.io/)
- **Netflix OSS:** Hystrix (precursor do Resilience4j)

### Event-Driven

- **Kafka Documentation:** [kafka.apache.org](https://kafka.apache.org/documentation/)
- **Designing Event-Driven Systems** by Ben Stopford
- **Building Event-Driven Microservices** by Adam Bellemare

## 🤝 Contribuindo

Para adicionar novos diagramas ou melhorar existentes:

1. **Mantenha Consistência:**

   - Use `!theme plain`
   - Sequência: setup → happy path → error path → metrics → benefits/trade-offs
   - Notas com código de exemplo

2. **Inclua Documentação:**

   - Notas explicativas com `note right/left/over`
   - Código Java com syntax highlighting
   - Métricas Prometheus
   - Benefits e Trade-offs

3. **Teste Renderização:**

   ```bash
   java -jar plantuml.jar -checkonly novo-diagrama.puml
   java -jar plantuml.jar novo-diagrama.puml
   ```

4. **Atualize README:**
   - Adicione linha na tabela de índice
   - Incremente contagem total de linhas
   - Adicione referências cruzadas

## 📝 Changelog

### 2025-11-15 - Fase 7 do Plano de Refatoração

- ✅ Criados 14 diagramas PlantUML (~4.040 linhas)
- ✅ 5 padrões de resiliência
- ✅ 4 padrões de arquitetura
- ✅ 5 padrões de design (GoF)
- ✅ Integração com documentação existente (pasta 04-patterns)
- ✅ README com instruções de uso e referências

### Próximos Passos (Fase 8+)

- Adicionar diagramas de componentes (C4 Model)
- Diagramas de deployment (Kubernetes)
- Sequence diagrams para fluxos de testes
- Diagramas de trace distribuído (OpenTelemetry)

---

**Nota:** Estes diagramas fazem parte do **Plano de Refatoração do Material de Testes** - Fase 7. Para contexto completo, consulte `Plano-Refatoracao-Material-Testes.md` na raiz do projeto.
