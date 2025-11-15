# 📚 Catálogo de Design Patterns - Java Spring Boot

> Coleção completa de **49 design patterns** implementados em Java/Spring Boot, organizados por categoria com exemplos práticos, testes e boas práticas.

---

## 📖 Índice por Categoria

### 🛡️ Padrões de Resiliência (6 patterns)

Patterns para proteger aplicações contra falhas.

| #     | Pattern                                    | Nível            | Descrição                                      |
| ----- | ------------------------------------------ | ---------------- | ---------------------------------------------- |
| 04.1  | [Circuit Breaker](04.1-circuit-breaker.md) | 🔴 Avançado      | Proteção contra falhas em cascata              |
| 04.2  | [Retry](04.2-retry.md)                     | 🟡 Intermediário | Tentativas automáticas com backoff exponential |
| 04.3  | [Fallback](04.3-fallback.md)               | 🟡 Intermediário | Resposta alternativa quando falha              |
| 04.4  | [Timeout](04.4-timeout.md)                 | 🟡 Intermediário | Limites de tempo para operações                |
| 04.5  | [Bulkhead](04.5-bulkhead.md)               | 🔴 Avançado      | Isolamento de recursos críticos                |
| 04.15 | [Rate Limiting](04.15-rate-limiting.md)    | 🔴 Avançado      | Controle de taxa de requisições                |

---

### 📨 Padrões de Mensageria e Eventos (6 patterns)

Patterns para comunicação assíncrona e event-driven.

| #     | Pattern                                              | Nível            | Descrição                                  |
| ----- | ---------------------------------------------------- | ---------------- | ------------------------------------------ |
| 04.6  | [Saga](04.6-saga-pattern.md)                         | 🔴 Avançado      | Transações distribuídas com compensação    |
| 04.7  | [Event Sourcing](04.7-event-sourcing.md)             | 🔴 Avançado      | Armazenar estado como sequência de eventos |
| 04.8  | [CQRS](04.8-cqrs.md)                                 | 🔴 Avançado      | Separação de leitura e escrita             |
| 04.9  | [Publisher-Subscriber](04.9-publisher-subscriber.md) | 🟡 Intermediário | Pub-Sub com desacoplamento                 |
| 04.10 | [Dead Letter Queue](04.10-dead-letter-queue.md)      | 🟡 Intermediário | Tratamento de mensagens falhadas           |
| 04.11 | [Idempotência](04.11-idempotencia.md)                | 🔴 Avançado      | Garantir processamento único               |

---

### 💾 Padrões de Cache e Dados (3 patterns)

Patterns para otimização de dados.

| #     | Pattern                                           | Nível            | Descrição                          |
| ----- | ------------------------------------------------- | ---------------- | ---------------------------------- |
| 04.12 | [Cache Aside](04.12-cache-aside.md)               | 🟡 Intermediário | Cache sob demanda (lazy loading)   |
| 04.13 | [Read/Write Through](04.13-read-write-through.md) | 🟡 Intermediário | Cache sincronizado automaticamente |
| 04.14 | [Token Refresh](04.14-token-refresh.md)           | 🟡 Intermediário | Renovação automática de tokens     |

---

### 🔍 Padrões de Observabilidade (1 pattern)

Patterns para monitoramento e diagnóstico de sistemas distribuídos.

| #     | Pattern                                             | Nível       | Descrição                                  |
| ----- | --------------------------------------------------- | ----------- | ------------------------------------------ |
| 04.50 | [Distributed Tracing](04.50-distributed-tracing.md) | 🔴 Avançado | Rastreamento de requisições entre serviços |

---

### 🎨 GoF - Padrões de Criação (3 patterns)

Patterns para criação de objetos.

| #     | Pattern                                   | Nível     | Descrição                        | Uso Principal           |
| ----- | ----------------------------------------- | --------- | -------------------------------- | ----------------------- |
| 04.16 | [Factory Method](04.16-factory-method.md) | 🟢 Básico | Criação de objetos por interface | Notificadores, parsers  |
| 04.17 | [Builder](04.17-builder.md)               | 🟢 Básico | Construção fluente de objetos    | DTOs complexos, queries |
| 04.27 | [Singleton](04.27-singleton.md)           | 🟢 Básico | Instância única                  | Configurações, pools    |

---

### 🎨 GoF - Padrões Estruturais (6 patterns)

Patterns para composição de classes e objetos.

| #     | Pattern                         | Nível            | Descrição                             | Uso Principal              |
| ----- | ------------------------------- | ---------------- | ------------------------------------- | -------------------------- |
| 04.21 | [Adapter](04.21-adapter.md)     | 🟡 Intermediário | Compatibilidade de interfaces         | Integrar APIs legadas      |
| 04.22 | [Decorator](04.22-decorator.md) | 🟡 Intermediário | Adicionar comportamento dinamicamente | Logging, cache, validation |
| 04.24 | [Proxy](04.24-proxy.md)         | 🟡 Intermediário | Controle de acesso a objetos          | Lazy loading, security     |
| 04.28 | [Facade](04.28-facade.md)       | 🟢 Básico        | Interface simplificada                | Simplificar subsistemas    |
| 04.29 | [Composite](04.29-composite.md) | 🟡 Intermediário | Estruturas hierárquicas               | Árvores, menus             |
| 04.30 | [DAO](04.30-dao.md)             | 🟢 Básico        | Data Access Object                    | Acesso a dados             |

---

### 🎨 GoF - Padrões Comportamentais (6 patterns)

Patterns para interação entre objetos.

| #     | Pattern                                                     | Nível            | Descrição                  | Uso Principal          |
| ----- | ----------------------------------------------------------- | ---------------- | -------------------------- | ---------------------- |
| 04.18 | [Strategy](04.18-strategy.md)                               | 🟢 Básico        | Algoritmos intercambiáveis | Cálculos, pagamentos   |
| 04.19 | [Observer](04.19-observer.md)                               | 🟡 Intermediário | Notificação de mudanças    | Eventos, listeners     |
| 04.20 | [Template Method](04.20-template-method.md)                 | 🟢 Básico        | Esqueleto de algoritmo     | Processamento de dados |
| 04.23 | [Command](04.23-command.md)                                 | 🟡 Intermediário | Encapsular requisições     | Undo/redo, filas       |
| 04.25 | [State](04.25-state.md)                                     | 🟡 Intermediário | Comportamento por estado   | Workflows, pedidos     |
| 04.26 | [Chain of Responsibility](04.26-chain-of-responsibility.md) | 🟡 Intermediário | Cadeia de processadores    | Filtros, validações    |

---

### 🏛️ Padrões Arquiteturais (13 patterns)

Patterns para organização da arquitetura da aplicação.

| #     | Pattern                                               | Nível            | Descrição                     | Característica Principal            |
| ----- | ----------------------------------------------------- | ---------------- | ----------------------------- | ----------------------------------- |
| 04.31 | [Layers](04.31-layers-architecture.md)                | 🟢 Básico        | Organização em camadas        | Controller → Service → Repository   |
| 04.32 | [MVC](04.32-mvc-architecture.md)                      | 🟢 Básico        | Model-View-Controller         | Separação de responsabilidades      |
| 04.33 | [Hexagonal](04.33-hexagonal-architecture.md)          | 🔴 Avançado      | Ports & Adapters              | Domain isolado de infraestrutura    |
| 04.34 | [Microservices](04.34-microservices-architecture.md)  | 🔴 Avançado      | Serviços independentes        | Deploy independente, escalabilidade |
| 04.35 | [Client-Server](04.35-client-server-architecture.md)  | 🟡 Intermediário | Separação cliente/servidor    | REST APIs, web apps                 |
| 04.36 | [Event-Driven](04.36-event-driven-architecture.md)    | 🔴 Avançado      | Comunicação por eventos       | Desacoplamento, assíncrono          |
| 04.37 | [Gateway Arquitetural](04.37-gateway-arquitetural.md) | 🔴 Avançado      | API Gateway pattern           | Routing, auth, rate limiting        |
| 04.38 | [Gateway Integração](04.38-gateway-integracao.md)     | 🔴 Avançado      | Integration Gateway           | Protocol translation, aggregation   |
| 04.39 | [Monolithic](04.39-monolithic-architecture.md)        | 🟢 Básico        | Aplicação única               | Single artifact, modular            |
| 04.40 | [N-Tier](04.40-n-tier-architecture.md)                | 🟡 Intermediário | Camadas físicas separadas     | Presentation/Application/Data tiers |
| 04.41 | [Mediator](04.41-mediator-pattern.md)                 | 🟡 Intermediário | Comunicação centralizada      | Event/Command/Pipeline mediators    |
| 04.48 | [SOA](04.48-soa-architecture.md)                      | 🔴 Avançado      | Service-Oriented Architecture | SOAP, WSDL, ESB                     |
| 04.49 | [Orchestrator](04.49-orchestrator-pattern.md)         | 🔴 Avançado      | Orquestração de workflows     | Saga, compensation, state machine   |

---

### 🌐 Padrões de Comunicação (6 patterns)

Patterns para integração e comunicação entre sistemas.

| #     | Pattern                                                   | Nível            | Descrição                | Protocolo/Tecnologia                  |
| ----- | --------------------------------------------------------- | ---------------- | ------------------------ | ------------------------------------- |
| 04.42 | [REST Architecture](04.42-rest-architecture.md)           | 🟡 Intermediário | APIs HTTP/JSON           | GET/POST/PUT/DELETE, status codes     |
| 04.43 | [GraphQL Architecture](04.43-graphql-architecture.md)     | 🔴 Avançado      | Query language flexível  | Schema, resolvers, subscriptions      |
| 04.44 | [gRPC Architecture](04.44-grpc-architecture.md)           | 🔴 Avançado      | RPC de alta performance  | Protocol Buffers, HTTP/2, streaming   |
| 04.45 | [WebSocket Architecture](04.45-websocket-architecture.md) | 🔴 Avançado      | Comunicação bidirecional | Full-duplex, STOMP, real-time         |
| 04.46 | [Webhook Architecture](04.46-webhook-architecture.md)     | 🔴 Avançado      | HTTP callbacks           | Push notifications, signatures, retry |
| 04.47 | [SOAP Architecture](04.47-soap-architecture.md)           | 🔴 Avançado      | Web Services enterprise  | WSDL, WS-Security, XML                |

---

## 🎯 Guia Rápido de Seleção

### Por Problema

| Problema                          | Pattern Recomendado              | Nível |
| --------------------------------- | -------------------------------- | ----- |
| Proteger contra falhas            | Circuit Breaker, Retry, Fallback | 🔴🟡  |
| Criar objetos complexos           | Builder, Factory Method          | 🟢    |
| Comunicação assíncrona            | Saga, Event Sourcing, Pub-Sub    | 🔴    |
| Cache de dados                    | Cache Aside, Read/Write Through  | 🟡    |
| Transações distribuídas           | Saga Pattern                     | 🔴    |
| API pública                       | REST Architecture                | 🟡    |
| Real-time bidirecional            | WebSocket                        | 🔴    |
| Integrações event-driven          | Webhook, Event-Driven            | 🔴    |
| Alta performance RPC              | gRPC                             | 🔴    |
| Mensagens falhadas                | Dead Letter Queue                | 🟡    |
| Processamento único               | Idempotência                     | 🔴    |
| Controlar taxa de requisições     | Rate Limiting                    | 🔴    |
| Rastrear requisições distribuídas | Distributed Tracing              | 🔴    |
| Debug de microsserviços           | Distributed Tracing              | 🔴    |

**Nota:** Para tratamento de exceções, veja **[05-transversal/05.5-exception-handling.md](../05-transversal/05.5-exception-handling.md)**.

### Por Nível de Experiência

#### 🟢 Iniciante (10 patterns)

Comece por aqui se você está aprendendo:

- Factory Method, Builder, Singleton
- Facade, Strategy, Template Method, DAO
- Layers, MVC, Monolithic

#### 🟡 Intermediário (20 patterns)

Para desenvolvedores com experiência:

- Retry, Fallback, Timeout
- Cache Aside, Read/Write Through, Token Refresh
- Pub-Sub, Dead Letter Queue
- Adapter, Decorator, Proxy, Composite
- Observer, Command, State, Chain of Responsibility
- REST Architecture, Client-Server, N-Tier, Mediator

#### 🔴 Avançado (20 patterns)

Para arquitetos e seniors:

- Circuit Breaker, Bulkhead, Rate Limiting
- Saga, Event Sourcing, CQRS, Idempotência
- Distributed Tracing
- Hexagonal, Microservices, Event-Driven, SOA, Orchestrator
- GraphQL, gRPC, WebSocket, Webhook, SOAP

---

## 📊 Estatísticas da Coleção

- **Total de Patterns**: 50
- **Linhas de Código**: ~42.000 (média 840 linhas/pattern)
- **Testes Incluídos**: ~250 (média 5 testes/pattern)
- **Categorias**: 8

### Distribuição por Nível

- 🟢 **Básico**: 10 patterns (20%)
- 🟡 **Intermediário**: 20 patterns (40%)
- 🔴 **Avançado**: 20 patterns (40%)

### Distribuição por Categoria

- **Resiliência**: 6 patterns (12%)
- **Mensageria/Eventos**: 6 patterns (12%)
- **Cache/Dados**: 3 patterns (6%)
- **Observabilidade**: 1 pattern (2%)
- **GoF Criação**: 3 patterns (6%)
- **GoF Estruturais**: 6 patterns (12%)
- **GoF Comportamentais**: 6 patterns (12%)
- **Arquiteturais**: 13 patterns (26%)
- **Comunicação**: 6 patterns (12%)

---

## 🚀 Como Usar Este Catálogo

### 1️⃣ Explorando por Necessidade

Use o **Guia Rápido de Seleção** acima para encontrar o pattern que resolve seu problema específico.

### 2️⃣ Aprendendo Progressivamente

Siga a ordem por nível:

1. **Básicos do GoF** (Factory Method, Builder, Singleton, Strategy, Template Method, DAO, Facade)
2. **Resiliência Básica** (Retry, Fallback, Timeout)
3. **Cache e Dados** (Cache Aside, Read/Write Through)
4. **Arquiteturas Fundamentais** (Layers, MVC, Monolithic)
5. **Patterns Estruturais** (Adapter, Decorator, Proxy, Composite)
6. **Patterns Comportamentais** (Observer, Command, State, Chain of Responsibility)
7. **Resiliência Avançada** (Circuit Breaker, Bulkhead, Rate Limiting)
8. **Event-Driven** (Saga, Event Sourcing, CQRS, Pub-Sub, DLQ, Idempotência)
9. **Arquiteturas Avançadas** (Hexagonal, Microservices, Event-Driven, SOA, Orchestrator, N-Tier, Mediator)
10. **Comunicação** (REST, GraphQL, gRPC, WebSocket, Webhook, SOAP)

### 3️⃣ Estrutura de Cada Pattern

Todos os patterns seguem a mesma estrutura:

```markdown
# Pattern Name [NÍVEL]

## 🎯 Objetivo

O que o pattern faz

## 📚 O Que É?

Definição e analogia

## ❌ Problema que Resolve

Exemplo ANTES (problema) vs DEPOIS (solução)

## 🔧 Implementação Completa

Código completo e funcional (6+ seções)

## 🧪 Como Testar

5+ testes (unitários, integração, E2E)

## 📊 Boas Práticas

Checklist de recomendações

## 🔗 Comparação

Tabela comparativa com alternativas

## ✅ Vantagens vs ⚠️ Desvantagens

Prós e contras

## 🔍 Quando Usar vs Não Usar

Guia de decisão
```

---

## 💡 Dicas de Estudo

### Para Iniciantes

1. Não tente aprender todos de uma vez
2. Implemente cada pattern em um projeto pequeno
3. Foque nos patterns **🟢 Básicos** primeiro
4. Use as analogias para entender os conceitos

### Para Intermediários

1. Compare patterns similares (ex: Adapter vs Bridge)
2. Combine patterns (ex: Factory + Strategy)
3. Estude os trade-offs de cada abordagem
4. Implemente os patterns **🟡 Intermediários** em projetos reais

### Para Avançados

1. Entenda quando NÃO usar cada pattern
2. Avalie o custo/benefício de patterns complexos
3. Combine múltiplos patterns arquiteturais
4. Documente decisões arquiteturais (ADRs)

---

## 🔍 Busca Rápida

### Por Tecnologia

- **Spring Boot**: Todos os patterns
- **Resilience4j**: Circuit Breaker, Retry, Bulkhead, Rate Limiting
- **JPA/Hibernate**: DAO
- **REST**: REST Architecture
- **RabbitMQ/Kafka**: Saga, Event Sourcing, Pub-Sub, DLQ, Idempotência
- **Cache**: Cache Aside, Read/Write Through (Redis, Caffeine)
- **GraphQL**: GraphQL Architecture
- **gRPC**: gRPC Architecture (Protocol Buffers)
- **WebSocket**: WebSocket Architecture (STOMP)
- **SOAP**: SOAP Architecture (WS-Security, WSDL)
- **Observabilidade**: Distributed Tracing (OpenTelemetry, Zipkin, Jaeger, Sleuth)
- **Testing**: MockMvc, @WebMvcTest, @SpringBootTest, @GraphQlTest

### Por Caso de Uso

- **E-commerce**: Saga, CQRS, Event Sourcing, Cache Aside, Webhook, Distributed Tracing
- **Banking**: SOAP, Circuit Breaker, Saga, Idempotência, Distributed Tracing
- **Social Media**: WebSocket, Event-Driven, Pub-Sub, Distributed Tracing
- **API Pública**: REST, GraphQL, Rate Limiting
- **Microservices**: Circuit Breaker, Saga, Event-Driven, gRPC, Orchestrator, Distributed Tracing
- **Real-time**: WebSocket, GraphQL Subscriptions
- **Payment Gateway**: Webhook, Circuit Breaker, Idempotência, Distributed Tracing
- **Notification System**: Pub-Sub, Dead Letter Queue, Retry
- **Debug/Observabilidade**: Distributed Tracing, Logging (05-transversal)

---

## 🔗 Recursos Relacionados

### Patterns Transversais

Para patterns que se aplicam a toda aplicação (cross-cutting concerns), veja a pasta **[05-transversal](../05-transversal/)**:

- **[05.5 Exception Handling](../05-transversal/05.5-exception-handling.md)** - Tratamento global de exceções (REST, Async, Mensageria, Scheduled, WebSocket, GraphQL)
- **[05.6 Logging](../05-transversal/05.6-logging.md)** - Logging estruturado com MDC, trace IDs, ELK Stack
- **[05.7 Validation](../05-transversal/05.7-validation.md)** - Bean Validation, validadores customizados, grupos
- **[05.8 Configuration](../05-transversal/05.8-configuration.md)** - Gerenciamento de propriedades, profiles, Config Server

### Leitura Recomendada

- **Design Patterns** (Gang of Four)
- **Patterns of Enterprise Application Architecture** (Martin Fowler)
- **Microservices Patterns** (Chris Richardson)
- **Building Microservices** (Sam Newman)

### Referências Online

- [Refactoring.Guru](https://refactoring.guru/design-patterns)
- [Spring Documentation](https://spring.io/guides)
- [Martin Fowler's Blog](https://martinfowler.com/)
- [Microsoft Architecture Patterns](https://learn.microsoft.com/en-us/azure/architecture/patterns/)

---

## 📝 Changelog

### v1.2 (2025-11)

- ✅ Reorganização: **47 patterns** em 04-patterns + **4 transversais** em 05-transversal
- ✅ **Exception Handling** movido para 05-transversal (05.5)
- ✅ **Novos patterns transversais**: Logging (05.6), Validation (05.7), Configuration (05.8)
- ✅ Separação clara entre design patterns e cross-cutting concerns
- ✅ Atualização de referências cruzadas

### v1.1 (2025-11)

- ✅ **48 patterns** documentados
- ✅ **Exception Handling completo**: REST, Async, Mensageria, Scheduled, WebSocket, GraphQL
- ✅ Reorganização por categoria funcional

### v1.0 (2024-01)

- ✅ 47 patterns documentados
- ✅ Exemplos completos com Spring Boot
- ✅ Testes unitários e integração
- ✅ Analogias e comparações
- ✅ Guias de quando usar/não usar

---

## 🔥 Destaques

### Patterns Mais Usados

1. **Circuit Breaker** - Proteção contra falhas em cascata
2. **REST Architecture** - APIs HTTP/JSON padrão
3. **Saga Pattern** - Transações distribuídas
4. **Cache Aside** - Cache otimizado
5. **Event Sourcing** - Auditoria completa de eventos

### Combinações Poderosas

- **Resiliência Completa**: Circuit Breaker + Retry + Fallback + Timeout + Bulkhead
- **Event-Driven**: Event Sourcing + CQRS + Saga + Pub-Sub + DLQ
- **Microservices**: Hexagonal + Event-Driven + Saga + gRPC + Circuit Breaker + Distributed Tracing
- **API Robusta**: REST + Rate Limiting + Cache Aside + (05-transversal: Exception Handling + Validation)
- **Observabilidade Full**: Distributed Tracing + (05-transversal: Logging + Metrics)

---

**Happy Coding!** 🚀

Desenvolvido com ❤️ para a comunidade Java/Spring Boot
