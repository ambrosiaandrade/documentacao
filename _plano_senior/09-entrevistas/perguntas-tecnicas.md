# 🧠 Perguntas Técnicas - Entrevistas de Testes de Software

## Índice

1. [Objetivo](#1-objetivo)
2. [Como Usar Este Documento](#2-como-usar-este-documento)
3. [Fundamentos de Testes](#3-fundamentos-de-testes)
4. [Qualidade e Métricas](#4-qualidade-e-métricas)
5. [Resiliência e Confiabilidade](#5-resiliência-e-confiabilidade)
6. [Performance e Escalabilidade](#6-performance-e-escalabilidade)
7. [Observabilidade](#7-observabilidade)
8. [Segurança](#8-segurança)
9. [Arquitetura e Design](#9-arquitetura-e-design)
10. [Processos e Cultura](#10-processos-e-cultura)
11. [Trade-offs e Decisões](#11-trade-offs-e-decisões)

---

## 1. Objetivo

Este documento contém **50+ perguntas reflexivas** para:

- **Entrevistas técnicas** (pleno a sênior)
- **Autoavaliação** de conhecimento
- **Discussões de time** sobre práticas de teste
- **Preparação para promoção** a níveis seniores

**Características das perguntas:**

- ✅ Abertas (não há resposta única "certa")
- ✅ Avaliam raciocínio crítico
- ✅ Exploram trade-offs e contexto
- ✅ Conectam teoria e prática
- ✅ Focam em ferramentas open source

---

## 2. Como Usar Este Documento

### Para Entrevistadores

**Estrutura da Entrevista:**

1. Escolher 3-5 perguntas de diferentes categorias
2. Dar 5-10 minutos para resposta inicial
3. Fazer perguntas de aprofundamento
4. Avaliar usando rubrica (docs/09-entrevistas/rubrica-avaliacao.md)

**Perguntas de Follow-up:**

- "Pode dar um exemplo real onde isso aconteceu?"
- "Quais foram os trade-offs dessa decisão?"
- "Como você mediria o sucesso dessa abordagem?"
- "E se o contexto fosse [X] em vez de [Y]?"

### Para Candidatos

**Como Estruturar Respostas:**

1. **Contexto**: Descrever cenário real
2. **Problema**: Qual desafio enfrentou
3. **Solução**: Como resolveu (ferramentas, técnicas)
4. **Resultado**: Métricas de impacto
5. **Aprendizado**: O que faria diferente

**Red Flags a Evitar:**

- ❌ Respostas dogmáticas ("sempre use X")
- ❌ Sem considerar contexto
- ❌ Focar apenas em teoria sem prática
- ❌ Não mencionar trade-offs
- ❌ Ignorar métricas/evidências

---

## 3. Fundamentos de Testes

### 🎯 Nível: Pleno → Sênior

#### P1: Unit Tests vs Integration Tests

**Pergunta:**

> Você está revisando um PR onde um colega escreveu testes de integração para toda a lógica de negócio, argumentando que "testes de integração são mais confiáveis porque testam o fluxo completo". Como você responderia? Quando integration tests são preferíveis a unit tests?

**O que avaliar:**

- Entendimento da pirâmide de testes
- Trade-offs (velocidade vs confiança)
- Capacidade de dar feedback construtivo
- Conhecimento de quando cada tipo é apropriado

---

#### P2: Test Doubles - Mock vs Stub vs Fake

**Pergunta:**

> Explique a diferença entre Mock, Stub e Fake. Dê um exemplo real onde você escolheu um tipo específico de test double e por quê. Que problemas você encontraria se usasse o tipo errado?

**O que avaliar:**

- Precisão conceitual (não confundir os tipos)
- Experiência prática com bibliotecas (Mockito, etc.)
- Entendimento de trade-offs
- Capacidade de identificar anti-patterns (over-mocking)

---

#### P3: Flaky Tests

**Pergunta:**

> Seu time tem 5% de taxa de flakiness. Os testes passam localmente mas falham na CI 1 em cada 20 execuções. Como você investigaria e resolveria isso? Que estratégias preventivas implementaria?

**O que avaliar:**

- Conhecimento de causas comuns (timing, state, randomness)
- Uso de ferramentas (rerun policies, detectores de flaky)
- Abordagem sistemática de debug
- Visão de longo prazo (prevenção, cultura)

---

#### P4: Test Data Management

**Pergunta:**

> Você precisa testar um fluxo complexo envolvendo 5 entidades relacionadas (User, Order, Payment, Product, Shipping). Como você gerenciaria a criação desses dados de teste? Que padrões usaria?

**O que avaliar:**

- Conhecimento de Test Data Builders / Object Mother
- Capacidade de manter testes legíveis
- Trade-off entre reutilização e clareza
- Ferramentas práticas (fixtures, factories)

---

#### P5: AAA vs Given-When-Then

**Pergunta:**

> Seu time debate entre usar AAA (Arrange-Act-Assert) ou Given-When-Then. Há alguma diferença real? Em que contextos cada abordagem é mais apropriada?

**O que avaliar:**

- Entendimento de que são equivalentes estruturalmente
- Contexto importa (BDD → GWT, unit tests → AAA)
- Consistência dentro do projeto
- Pragmatismo vs dogmatismo

---

## 4. Qualidade e Métricas

### 🎯 Nível: Pleno → Sênior

#### P6: Code Coverage

**Pergunta:**

> Seu gerente quer aumentar a cobertura de código de 60% para 90%. Você concorda? Por que sim ou não? Que métricas alternativas ou complementares você proporia?

**O que avaliar:**

- Entendimento de limitações de coverage
- Conhecimento de métricas melhores (mutation score, diff coverage)
- Capacidade de negociar com stakeholders
- Visão holística de qualidade

---

#### P7: Mutation Testing

**Pergunta:**

> Você implementou mutation testing (PITest, Stryker) e descobriu que apesar de 85% de cobertura, o mutation score é apenas 45%. O que isso significa? Como você melhoraria?

**O que avaliar:**

- Compreensão profunda de mutation testing
- Identificação de testes superficiais
- Estratégia de melhoria (priorização)
- Experiência com ferramentas open source (PITest)

---

#### P8: Diff Coverage

**Pergunta:**

> Seu time debate implementar diff coverage obrigatório (80% para código novo). Quais os benefícios e riscos? Como você implementaria isso tecnicamente?

**O que avaliar:**

- Conhecimento de ferramentas (Codecov, Coveralls)
- Trade-offs (encorajar qualidade vs overhead)
- Integração com CI/CD
- Exceções e pragmatismo

---

#### P9: Quality Gates

**Pergunta:**

> Projete um sistema de quality gates para um projeto Java/Spring Boot. Quais verificações você incluiria em cada estágio (pre-commit, PR, staging, production)?

**O que avaliar:**

- Conhecimento de múltiplas métricas
- Estratégia em camadas (shift-left)
- Ferramentas open source (SonarQube, etc.)
- Balanceamento velocidade vs qualidade

---

#### P10: Test Pyramid

**Pergunta:**

> Você herdou um projeto com a proporção inversa da pirâmide de testes: 10% unit, 20% integration, 70% E2E. Qual estratégia você usaria para inverter isso? Por onde começar?

**O que avaliar:**

- Abordagem incremental e pragmática
- Priorização (risco vs esforço)
- Refatoração segura
- Métricas para medir progresso

---

## 5. Resiliência e Confiabilidade

### 🎯 Nível: Sênior

#### P11: Circuit Breaker

**Pergunta:**

> Você implementou um Circuit Breaker (Resilience4j) para chamadas a um serviço de pagamento. Como você testaria os 3 estados (Closed, Open, Half-Open)? Que métricas você monitoraria em produção?

**O que avaliar:**

- Entendimento profundo do padrão
- Testes de diferentes estados
- Observabilidade (métricas, alertas)
- Experiência com Resilience4j

---

#### P12: Retry com Exponential Backoff

**Pergunta:**

> Quando retry é apropriado e quando é perigoso? Dê exemplos de operações que devem e não devem ter retry. Como você testaria uma política de retry exponencial?

**O que avaliar:**

- Conhecimento de idempotência
- Casos de uso (transient failures)
- Anti-patterns (retry storm)
- Testes determinísticos (Clock mockado)

---

#### P13: Idempotência

**Pergunta:**

> Explique por que idempotência é crítica para resiliência. Como você garantiria que um endpoint de pagamento seja idempotente? Como testaria isso?

**O que avaliar:**

- Compreensão profunda de idempotência
- Técnicas (idempotency keys, deduplicação)
- Testes de retry/duplicação
- Implicações arquiteturais

---

#### P14: Chaos Engineering

**Pergunta:**

> Seu time quer começar com Chaos Engineering. Por onde você começaria? Que experimentos iniciais proporia? Quais ferramentas open source usaria?

**O que avaliar:**

- Conhecimento de Chaos Toolkit, Pumba, Toxiproxy
- Abordagem progressiva (game days → automação)
- Hipóteses testáveis
- Cultura de aprendizado (blameless postmortems)

---

#### P15: Timeout Strategies

**Pergunta:**

> Como você determinaria o timeout apropriado para chamadas HTTP entre serviços? Que dados você coletaria? Como testaria diferentes cenários de timeout?

**O que avaliar:**

- Análise de percentis (p95, p99)
- Testes de latência/timeout
- Trade-offs (user experience vs resiliência)
- Ferramentas (Wiremock para simular delays)

---

## 6. Performance e Escalabilidade

### 🎯 Nível: Sênior

#### P16: Load vs Stress vs Spike Testing

**Pergunta:**

> Explique a diferença entre Load, Stress e Spike testing. Para um e-commerce esperando Black Friday, qual tipo você priorizaria e por quê?

**O que avaliar:**

- Clareza conceitual
- Contexto de negócio
- Ferramentas (JMeter, Gatling, k6)
- Métricas relevantes (throughput, latency, error rate)

---

#### P17: Performance Budgets

**Pergunta:**

> Você precisa definir performance budgets para uma API REST. Quais métricas usaria? Como testaria continuamente que os budgets não são violados?

**O que avaliar:**

- Métricas (p95 latency, throughput, error rate)
- Integração com CI/CD
- Ferramentas (k6 thresholds, Gatling assertions)
- Quality gates de performance

---

#### P18: N+1 Query Problem

**Pergunta:**

> Como você detectaria e testaria N+1 query problems? Que ferramentas usaria? Como preveniria regressões?

**O que avaliar:**

- Conhecimento de ORM (JPA, Hibernate)
- Ferramentas (Hibernate statistics, query logs)
- Testes de performance
- Code review practices

---

#### P19: Cache Testing

**Pergunta:**

> Você implementou cache (Redis) para reduzir latência. Como testaria: 1) TTL correto, 2) cache invalidation, 3) consistência com DB? Que métricas monitoraria?

**O que avaliar:**

- Estratégias de teste (Testcontainers Redis)
- Edge cases (expiration, eviction)
- Métricas (hit rate, miss rate)
- Trade-offs (consistência eventual)

---

#### P20: Database Performance

**Pergunta:**

> Seu teste de carga revela que o banco de dados é o gargalo. Como você investigaria? Que otimizações consideraria? Como validaria o impacto?

**O que avaliar:**

- Análise de query plans
- Índices, particionamento, connection pool
- A/B testing de otimizações
- Ferramentas (pg_stat_statements, EXPLAIN ANALYZE)

---

## 7. Observabilidade

### 🎯 Nível: Sênior

#### P21: Logs, Métricas, Traces

**Pergunta:**

> Explique a diferença entre logs, métricas e traces. Para debugar um problema de latência intermitente, qual você usaria primeiro e por quê?

**O que avaliar:**

- Clareza conceitual (3 pilares)
- Casos de uso apropriados
- Ferramentas open source (Prometheus, Jaeger, ELK)
- Estratégia de troubleshooting

---

#### P22: Distributed Tracing

**Pergunta:**

> Como você testaria que distributed tracing (OpenTelemetry, Jaeger) está funcionando corretamente em um sistema com 5 microserviços?

**O que avaliar:**

- Propagação de trace context
- Testes end-to-end
- Validação de spans
- Ferramentas (Jaeger UI, assertions)

---

#### P23: Correlation IDs

**Pergunta:**

> Por que correlation IDs são importantes? Como você garantiria que eles são propagados corretamente entre serviços? Como testaria isso?

**O que avaliar:**

- Entendimento de debugging distribuído
- Implementação (headers, MDC/ThreadLocal)
- Testes de propagação
- Integração com logging

---

#### P24: Métricas de Negócio

**Pergunta:**

> Além de métricas técnicas (latency, error rate), que métricas de negócio você instrumentaria em um sistema de checkout? Como testaria a coleta dessas métricas?

**O que avaliar:**

- Visão além de métricas técnicas
- Exemplos concretos (conversion rate, cart abandonment)
- Testes de instrumentação
- Ferramentas (Prometheus custom metrics)

---

#### P25: Health Checks

**Pergunta:**

> Projete um health check endpoint robusto. O que ele deve verificar? Como evitar que o health check cause mais problemas (ex: DDoS no banco)? Como testaria?

**O que avaliar:**

- Verificações essenciais (DB, dependencies)
- Trade-offs (profundidade vs latência)
- Testes de falha
- Práticas (liveness vs readiness)

---

## 8. Segurança

### 🎯 Nível: Sênior

#### P26: Security Testing

**Pergunta:**

> Que tipos de testes de segurança você incluiria em um pipeline CI/CD? Quais ferramentas open source usaria? Como balancearia segurança e velocidade?

**O que avaliar:**

- SAST, DAST, dependency scanning
- Ferramentas (OWASP ZAP, Snyk, Trivy)
- Integração no pipeline
- Shift-left security

---

#### P27: SQL Injection Testing

**Pergunta:**

> Como você testaria que sua aplicação está protegida contra SQL injection? Que técnicas de prevenção validaria nos testes?

**O que avaliar:**

- Conhecimento de ataque e defesa
- Testes com payloads maliciosos
- Prepared statements, ORM
- Ferramentas (SQLMap para testes)

---

#### P28: Authentication & Authorization

**Pergunta:**

> Como você testaria regras de autorização complexas (RBAC, ABAC)? Que estratégias usaria para garantir cobertura completa?

**O que avaliar:**

- Matriz de permissões
- Testes parametrizados
- Edge cases (privilege escalation)
- Ferramentas (Spring Security Test)

---

#### P29: Secrets Management

**Pergunta:**

> Como você garantiria que secrets não vazam em logs ou mensagens de erro? Como testaria isso? Que práticas implementaria no time?

**O que avaliar:**

- Estratégias (masking, secret managers)
- Testes automatizados (grep logs)
- Code review practices
- Ferramentas (git-secrets, TruffleHog)

---

#### P30: Supply Chain Security

**Pergunta:**

> Como você garantiria a segurança de dependências third-party? Que verificações automatizadas implementaria? Como responderia a uma CVE crítica?

**O que avaliar:**

- SBOM, vulnerability scanning
- Ferramentas (Dependabot, Snyk, OWASP Dependency-Check)
- Processo de response
- Testes de regressão pós-update

---

## 9. Arquitetura e Design

### 🎯 Nível: Sênior

#### P31: Testabilidade no Design

**Pergunta:**

> Você está revisando o design de um novo serviço. Quais características arquiteturais você buscaria para garantir alta testabilidade? Dê exemplos de decisões que facilitam ou dificultam testes.

**O que avaliar:**

- Dependency injection, interfaces
- Separação de concerns
- Código testável vs acoplado
- Refatoração para testabilidade

---

#### P32: Contract Testing

**Pergunta:**

> Quando contract testing (Pact) é mais apropriado que integration testing? Como você implementaria contract tests entre 3 serviços (frontend, BFF, backend)?

**O que avaliar:**

- Entendimento de consumer-driven contracts
- Pact workflow (consumer → provider)
- Trade-offs vs E2E
- Ferramentas (Pact, Spring Cloud Contract)

---

#### P33: Event-Driven Testing

**Pergunta:**

> Como você testaria um sistema event-driven (Kafka, RabbitMQ)? Que desafios você anteciparia? Quais estratégias usaria?

**O que avaliar:**

- Testes de produção/consumo
- Idempotência, ordering, duplicação
- Testcontainers para Kafka
- Testes de falha (broker down)

---

#### P34: Database Migration Testing

**Pergunta:**

> Como você testaria migrações de banco de dados (Flyway, Liquibase)? Como garantiria rollback seguro? Que cenários de falha testaria?

**O que avaliar:**

- Testes de migração up/down
- Dados existentes (backward compatibility)
- Performance de migrações
- CI/CD integration

---

#### P35: Hexagonal Architecture

**Pergunta:**

> Como a arquitetura hexagonal (ports & adapters) facilita testes? Dê um exemplo de como você testaria a mesma lógica de negócio com diferentes adapters (HTTP vs message queue).

**O que avaliar:**

- Entendimento de hexagonal architecture
- Separação de concerns
- Testes de ports sem adapters
- Substituição de adapters

---

## 10. Processos e Cultura

### 🎯 Nível: Sênior

#### P36: TDD Adoption

**Pergunta:**

> Seu time debate adotar TDD. Você é a favor ou contra? Em que contextos TDD agrega mais valor? Como você introduziria TDD gradualmente?

**O que avaliar:**

- Entendimento de TDD (Red-Green-Refactor)
- Pragmatismo (não dogmatismo)
- Estratégia de adoção
- Benefícios e custos

---

#### P37: Code Review para Testes

**Pergunta:**

> Que aspectos você priorizaria ao revisar testes em um PR? Dê 5 pontos de atenção críticos.

**O que avaliar:**

- Nomenclatura, clareza
- Cobertura de edge cases
- Flakiness potencial
- Performance
- Mutação de conceitos críticos

---

#### P38: Test Ownership

**Pergunta:**

> "QA deveria escrever todos os testes" vs "Desenvolvedores devem testar tudo". Qual modelo você prefere? Por quê? Como você dividiria responsabilidades?

**O que avaliar:**

- Shift-left mindset
- Colaboração dev-QA
- Pirâmide de testes
- Expertise apropriada

---

#### P39: Flaky Test Policy

**Pergunta:**

> Seu time discute a política: "Testes flaky devem ser desabilitados até serem corrigidos" vs "Testes flaky devem bloquear merges até serem corrigidos". Qual você escolheria?

**O que avaliar:**

- Trade-offs (velocidade vs qualidade)
- Contexto importa
- Estratégias intermediárias
- Cultura de propriedade

---

#### P40: Testing Budget

**Pergunta:**

> Você tem 2 semanas de capacidade para melhorar testes. Como priorizaria: aumentar cobertura, reduzir flakiness, adicionar mutation testing, ou implementar performance tests?

**O que avaliar:**

- Análise de risco
- ROI de diferentes abordagens
- Contexto do projeto
- Métricas para decisão

---

## 11. Trade-offs e Decisões

### 🎯 Nível: Sênior

#### P41: Test Speed vs Confidence

**Pergunta:**

> Seus testes de integração levam 30 minutos. O time quer velocidade. Você consideraria: paralelização, reduzir testes, ou substituir por mocks? Como decidiria?

**O que avaliar:**

- Análise de múltiplas opções
- Métricas (tempo, confiança, custo)
- Implementação técnica
- Trade-offs de cada abordagem

---

#### P42: Production Testing

**Pergunta:**

> "Testing in production" é boa prática ou negligência? Quando é apropriado? Que técnicas você usaria (canary, feature flags, synthetic monitoring)?

**O que avaliar:**

- Entendimento de testes em produção
- Técnicas apropriadas
- Riscos e mitigações
- Ferramentas (LaunchDarkly, canary deployments)

---

#### P43: Test Data em Produção

**Pergunta:**

> Você precisa testar em produção mas não quer afetar dados reais. Que estratégias consideraria? Como garantiria isolamento?

**O que avaliar:**

- Shadow mode, synthetic users
- Separação lógica (flags, tagging)
- Limpeza de dados
- Compliance e privacidade

---

#### P44: Monorepo vs Multirepo Testing

**Pergunta:**

> Como a estratégia de testes muda entre monorepo e multirepo? Que desafios únicos cada abordagem apresenta?

**O que avaliar:**

- Testes cross-service
- CI/CD implications
- Dependency management
- Ferramentas (Nx, Bazel, etc.)

---

#### P45: Economic Trade-offs

**Pergunta:**

> Calcule o custo de: 1) Escrever mais testes (tempo dev), 2) Bugs em produção (downtime), 3) CI/CD infrastructure. Como você otimizaria esse balanço?

**O que avaliar:**

- Visão econômica (não apenas técnica)
- Quantificação de riscos
- Dados para decisão
- Métricas DORA, SLA/SLO

---

#### P46: Legacy Code Testing

**Pergunta:**

> Você herdou 100k linhas de código sem testes. Qual sua estratégia? Por onde começar? Como medir progresso?

**O que avaliar:**

- Characterization tests
- Refatoração segura
- Priorização por risco
- Working Effectively with Legacy Code (Feathers)

---

#### P47: Test Frameworks Selection

**Pergunta:**

> Você está iniciando um novo projeto Python. Como decidiria entre pytest, unittest, nose? Que critérios usaria?

**O que avaliar:**

- Conhecimento de ferramentas
- Critérios objetivos (features, comunidade)
- Contexto do time
- Open source ecosystem

---

#### P48: AI-Generated Tests

**Pergunta:**

> Ferramentas de IA (Copilot, ChatGPT) podem gerar testes. Quando você confiaria neles? Quando revisaria criticamente? Que riscos anteciparia?

**O que avaliar:**

- Pragmatismo com novas tecnologias
- Entendimento de limitações
- Revisão crítica
- Complemento, não substituição

---

#### P49: Observability vs Testing

**Pergunta:**

> "Observabilidade suficiente elimina necessidade de testes extensivos". Concorda ou discorda? Como eles se complementam?

**O que avaliar:**

- Entendimento de diferenças
- Complementaridade
- Shift-left (testes) vs shift-right (observability)
- Balanced approach

---

#### P50: Open Source Contribution

**Pergunta:**

> Você encontrou um bug em uma biblioteca open source (ex: Mockito). Como decidiria entre: workaround, fork, ou contribuir fix upstream? Como testaria o fix?

**O que avaliar:**

- Visão de comunidade
- Pragmatismo vs idealismo
- Contribuição para ecosystem
- Processo de OSS contribution

---

## 📊 Matriz de Classificação das Perguntas

| Categoria           | Nível Pleno        | Nível Sênior                                     | Total  |
| ------------------- | ------------------ | ------------------------------------------------ | ------ |
| **Fundamentos**     | P1, P2, P3, P4, P5 | -                                                | 5      |
| **Qualidade**       | P6, P7, P8         | P9, P10                                          | 5      |
| **Resiliência**     | -                  | P11, P12, P13, P14, P15                          | 5      |
| **Performance**     | -                  | P16, P17, P18, P19, P20                          | 5      |
| **Observabilidade** | -                  | P21, P22, P23, P24, P25                          | 5      |
| **Segurança**       | -                  | P26, P27, P28, P29, P30                          | 5      |
| **Arquitetura**     | -                  | P31, P32, P33, P34, P35                          | 5      |
| **Processos**       | -                  | P36, P37, P38, P39, P40                          | 5      |
| **Trade-offs**      | -                  | P41, P42, P43, P44, P45, P46, P47, P48, P49, P50 | 10     |
| **TOTAL**           | **13**             | **37**                                           | **50** |

---

## 🎯 Guia de Seleção de Perguntas

### Para Nível Pleno

**Foco:** Fundamentos, ferramentas, práticas básicas

**Sugestão de Combo (45 min):**

1. P2 (Test Doubles) - 10 min
2. P3 (Flaky Tests) - 10 min
3. P6 (Code Coverage) - 10 min
4. P36 (TDD) - 10 min
5. Mini-caso prático - 5 min

### Para Nível Sênior

**Foco:** Arquitetura, trade-offs, visão sistêmica

**Sugestão de Combo (60 min):**

1. P11 (Circuit Breaker) - 12 min
2. P21 (Logs/Métricas/Traces) - 12 min
3. P31 (Testabilidade no Design) - 12 min
4. P41 (Speed vs Confidence) - 12 min
5. P45 (Economic Trade-offs) - 12 min

### Para Arquiteto/Principal

**Foco:** Visão estratégica, influência, decisões de longo prazo

**Sugestão de Combo (90 min):**

1. P9 (Quality Gates) - 15 min
2. P14 (Chaos Engineering) - 15 min
3. P32 (Contract Testing) - 15 min
4. P40 (Testing Budget) - 15 min
5. P45 (Economic Trade-offs) - 15 min
6. Mini-caso de arquitetura - 15 min

---

## 🔍 Exemplo de Resposta Completa

### Pergunta: P11 (Circuit Breaker)

**Resposta Exemplo (Nível Sênior):**

**Contexto:**
"No último projeto, implementei Circuit Breaker para chamadas ao serviço de pagamento PagSeguro, que tinha SLA de 99.5% mas sofria picos de latência."

**Problema:**
"Quando o PagSeguro ficava lento (>5s), nossa API também travava, causando timeout em cascata. Precisávamos isolar essa falha."

**Solução:**
"Usei Resilience4j com configuração:

- Threshold: 50% de falhas em 10 chamadas
- Timeout: 2s por chamada
- Wait duration: 30s no estado Open
- Half-open: testar com 3 chamadas

Para testes:

1. **Unit test (estados):** Mockei o serviço para retornar falhas e validei transição Closed→Open→Half-Open→Closed
2. **Integration test:** Usei WireMock com delays para simular latência e validar timeout
3. **Chaos test:** Toxiproxy para simular falha total do PagSeguro

Métricas monitoradas:

- `resilience4j.circuitbreaker.state` (gauge: 0=closed, 1=open, 2=half-open)
- `resilience4j.circuitbreaker.calls` (counter por resultado: success/failure/fallback)
- Alertas no Grafana quando estado = Open por >5min"

**Resultado:**
"Reduzimos timeout em cascata de 45% para <5%. P99 latency melhorou de 8s para 2.5s mesmo durante incidentes do PagSeguro."

**Aprendizado:**
"Inicialmente configurei threshold muito agressivo (20%), causando circuit aberto desnecessário. Ajustei para 50% após análise de métricas. Também aprendi a importância de fallback: retornar erro 503 com retry-after header vs 500 genérico."

---

## ✅ Checklist para Autoavaliação

Use este checklist para medir sua preparação:

### Fundamentos (Pleno)

- [ ] Consigo explicar diferença entre unit/integration/E2E com exemplos
- [ ] Sei usar Mockito (mock, spy, stub, verify, ArgumentCaptor)
- [ ] Identifico e corrijo flaky tests
- [ ] Uso Test Data Builders para cenários complexos
- [ ] Sigo estrutura AAA/Given-When-Then consistentemente

### Qualidade (Pleno → Sênior)

- [ ] Entendo limitações de code coverage
- [ ] Implementei mutation testing (PITest/Stryker)
- [ ] Configurei diff coverage no CI/CD
- [ ] Projetei quality gates em múltiplas camadas
- [ ] Sei balancear pirâmide de testes

### Resiliência (Sênior)

- [ ] Implementei Circuit Breaker em produção
- [ ] Testei políticas de Retry com exponential backoff
- [ ] Garanti idempotência em operações críticas
- [ ] Realizei experimentos de Chaos Engineering
- [ ] Defini e testei timeout strategies

### Performance (Sênior)

- [ ] Realizei load/stress/spike tests (JMeter/k6)
- [ ] Defini performance budgets mensuráveis
- [ ] Identifiquei e resolvi N+1 queries
- [ ] Testei cache (TTL, invalidation, hit rate)
- [ ] Otimizei queries com EXPLAIN ANALYZE

### Observabilidade (Sênior)

- [ ] Implementei distributed tracing (Jaeger/OpenTelemetry)
- [ ] Testei propagação de correlation IDs
- [ ] Instrumentei métricas de negócio
- [ ] Projetei health checks robustos
- [ ] Uso logs/métricas/traces apropriadamente

### Segurança (Sênior)

- [ ] Integrei security testing no CI/CD (SAST/DAST)
- [ ] Testei proteções contra SQL injection
- [ ] Validei regras de autorização complexas
- [ ] Implementei secret masking em logs
- [ ] Monitoro vulnerabilidades (SBOM, CVEs)

### Arquitetura (Sênior)

- [ ] Projeto código pensando em testabilidade
- [ ] Implementei contract testing (Pact)
- [ ] Testei sistemas event-driven (Kafka)
- [ ] Validei database migrations (up/down)
- [ ] Aplico hexagonal architecture

### Processos (Sênior)

- [ ] Pratico TDD quando apropriado
- [ ] Reviso testes em PRs com critérios claros
- [ ] Defendo cultura de qualidade no time
- [ ] Tenho política para flaky tests
- [ ] Sei priorizar investimento em testes

### Trade-offs (Sênior)

- [ ] Balanço speed vs confidence baseado em contexto
- [ ] Uso testing in production apropriadamente
- [ ] Considero trade-offs econômicos
- [ ] Tenho estratégia para legacy code
- [ ] Avalio ferramentas com critérios objetivos

**Pontuação:**

- 40-45 ✅: Pronto para sênior
- 30-39 🔶: Caminho certo, focar em gaps
- 20-29 📚: Estudo aprofundado necessário
- <20 🎯: Consolidar fundamentos primeiro

---

## 📚 Recursos Complementares

### Livros

- **Growing Object-Oriented Software, Guided by Tests** (Freeman, Pryce)
- **Working Effectively with Legacy Code** (Feathers)
- **Release It!** (Nygard) - Patterns de resiliência
- **Building Microservices** (Newman) - Testing distribuído

### Ferramentas Open Source

- **Testes:** JUnit 5, pytest, Jest, TestNG
- **Mocking:** Mockito, unittest.mock, Sinon
- **Mutation:** PITest, Stryker, mutmut
- **Coverage:** JaCoCo, Coverage.py, Istanbul
- **Performance:** JMeter, Gatling, k6, Locust
- **Chaos:** Chaos Toolkit, Pumba, Toxiproxy
- **Contract:** Pact, Spring Cloud Contract
- **Containers:** Testcontainers
- **Observability:** Prometheus, Grafana, Jaeger

### Referências

- [Martin Fowler - Testing](https://martinfowler.com/testing/)
- [Google Testing Blog](https://testing.googleblog.com/)
- [Microsoft - Testing Pyramid](https://docs.microsoft.com/en-us/azure/devops/learn/devops-at-microsoft/shift-left-make-testing-fast-reliable)

---

**Próximo passo:** Praticar com [mini-casos](mini-casos.md) e avaliar usando [rubrica](rubrica-avaliacao.md).
