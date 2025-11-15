# 📊 Rubrica de Avaliação - Entrevistas Técnicas de Testes

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Escala de Níveis](#2-escala-de-níveis)
3. [Dimensões de Avaliação](#3-dimensões-de-avaliação)
4. [Rubricas por Competência](#4-rubricas-por-competência)
5. [Rubrica Consolidada](#5-rubrica-consolidada)
6. [Como Usar Esta Rubrica](#6-como-usar-esta-rubrica)
7. [Exemplos de Avaliação](#7-exemplos-de-avaliação)

---

## 1. Visão Geral

### Objetivo

Esta rubrica fornece critérios objetivos para avaliar candidatos em entrevistas técnicas focadas em testes de software, adequada para níveis:

- **Júnior** (0-2 anos)
- **Pleno** (2-5 anos)
- **Sênior** (5-8 anos)
- **Staff/Principal** (8+ anos)

### Princípios

✅ **Objetividade**: Critérios mensuráveis e observáveis
✅ **Consistência**: Mesma escala para todos os candidatos
✅ **Contextualização**: Considerar experiência e senioridade
✅ **Foco em Raciocínio**: Valorizar processo sobre resposta "correta"

---

## 2. Escala de Níveis

### Escala Numérica (1-5)

| Nota  | Nível        | Descrição                        | Decisão                            |
| ----- | ------------ | -------------------------------- | ---------------------------------- |
| **5** | Excepcional  | Supera expectativas para o nível | Contratação fortemente recomendada |
| **4** | Forte        | Atende plenamente expectativas   | Contratação recomendada            |
| **3** | Adequado     | Atende requisitos mínimos        | Contratação com ressalvas          |
| **2** | Abaixo       | Não atende requisitos mínimos    | Não recomendado para o nível       |
| **1** | Insuficiente | Lacunas críticas                 | Não recomendado                    |

### Conversão para Níveis de Senioridade

| Pontuação Média | Júnior          | Pleno           | Sênior               | Staff                |
| --------------- | --------------- | --------------- | -------------------- | -------------------- |
| **4.5 - 5.0**   | Excepcional     | Excepcional     | Contratação imediata | Contratação imediata |
| **3.5 - 4.4**   | Forte           | Forte           | Adequado             | Abaixo               |
| **2.5 - 3.4**   | Adequado        | Adequado        | Abaixo               | Não recomendado      |
| **1.5 - 2.4**   | Abaixo          | Abaixo          | Não recomendado      | Não recomendado      |
| **< 1.5**       | Não recomendado | Não recomendado | Não recomendado      | Não recomendado      |

---

## 3. Dimensões de Avaliação

### 3.1 Conhecimento Técnico (25%)

- Domínio de frameworks, ferramentas e conceitos
- Atualização com práticas modernas
- Conhecimento de open source ecosystem

### 3.2 Raciocínio e Análise (30%)

- Capacidade de identificar causa raiz
- Pensamento estruturado
- Consideração de múltiplas perspectivas

### 3.3 Experiência Prática (20%)

- Exemplos concretos de projetos
- Profundidade técnica
- Lições aprendidas

### 3.4 Comunicação (15%)

- Clareza na explicação
- Capacidade de justificar decisões
- Escuta ativa

### 3.5 Trade-offs e Contexto (10%)

- Balanceamento de prós e contras
- Adaptação ao contexto
- Visão sistêmica

---

## 4. Rubricas por Competência

### 4.1 Fundamentos de Testes

#### Unit Tests vs Integration Tests

| Nível           | 1 (Insuf.)               | 2 (Abaixo)                 | 3 (Adequado)                     | 4 (Forte)                       | 5 (Excepcional)                                        |
| --------------- | ------------------------ | -------------------------- | -------------------------------- | ------------------------------- | ------------------------------------------------------ |
| **Definição**   | Confunde os conceitos    | Define vagamente           | Define corretamente              | Define com precisão e exemplos  | Define com nuances (contract, component tests)         |
| **Quando usar** | Não sabe escolher        | Escolha baseada em feeling | Escolha com justificativa básica | Escolha considerando trade-offs | Escolha considerando contexto completo (pirâmide, ROI) |
| **Exemplos**    | Não dá exemplos          | Exemplos incorretos        | Exemplos corretos simples        | Exemplos de projetos reais      | Exemplos com análise de decisão                        |
| **Ferramentas** | Não menciona ferramentas | Menciona JUnit ou similar  | Menciona JUnit + Mockito         | Menciona ecosystem completo     | Compara frameworks (JUnit 5 vs TestNG)                 |

**Perguntas para avaliar:**

- "Explique a diferença entre unit test e integration test"
- "Quando você escolheria um sobre o outro?"
- "Dê um exemplo de cada do seu último projeto"

---

#### Test Doubles (Mock, Stub, Spy, Fake)

| Nível           | 1 (Insuf.)              | 2 (Abaixo)              | 3 (Adequado)                  | 4 (Forte)                          | 5 (Excepcional)                               |
| --------------- | ----------------------- | ----------------------- | ----------------------------- | ---------------------------------- | --------------------------------------------- |
| **Conceitos**   | Chama tudo de "mock"    | Conhece mock e stub     | Conhece os 5 tipos            | Explica diferenças com clareza     | Explica casos de uso específicos              |
| **Uso prático** | Não usou na prática     | Usa Mockito basicamente | Usa mock/stub apropriadamente | Usa todos os tipos contextualmente | Sabe quando evitar (over-mocking)             |
| **Frameworks**  | Não conhece ferramentas | Conhece Mockito         | Conhece Mockito + verify      | Conhece ArgumentCaptor, InOrder    | Compara Mockito vs WireMock vs TestContainers |

**Perguntas para avaliar:**

- "Qual a diferença entre mock e stub?"
- "Quando você usaria spy em vez de mock?"
- "Dê um exemplo de quando fake é melhor que mock"

---

#### Flaky Tests

| Nível             | 1 (Insuf.)       | 2 (Abaixo)        | 3 (Adequado)              | 4 (Forte)                     | 5 (Excepcional)                                 |
| ----------------- | ---------------- | ----------------- | ------------------------- | ----------------------------- | ----------------------------------------------- |
| **Identificação** | Não sabe o que é | Define vagamente  | Define e dá causas comuns | Identifica causas específicas | Classifica por tipo (timing, state, randomness) |
| **Resolução**     | "Reexecutar"     | "Remover o teste" | Corrige causa específica  | Abordagem sistemática         | Estratégia preventiva + ferramentas             |
| **Prevenção**     | Não menciona     | "Testar melhor"   | Menciona determinismo     | Clock mockado, fixtures       | Política de time + CI/CD enforcement            |
| **Ferramentas**   | Não conhece      | Menciona rerun    | Surefire rerun plugin     | Detectores automáticos        | Métricas (flaky rate) + alertas                 |

**Perguntas para avaliar:**

- "Seu time tem 5% de flaky tests. Como você resolveria?"
- "Que causas de flakiness você já encontrou?"
- "Como você previne flaky tests?"

---

### 4.2 Qualidade e Métricas

#### Code Coverage

| Nível            | 1 (Insuf.)                  | 2 (Abaixo)                | 3 (Adequado)               | 4 (Forte)                      | 5 (Excepcional)                       |
| ---------------- | --------------------------- | ------------------------- | -------------------------- | ------------------------------ | ------------------------------------- |
| **Compreensão**  | Acha que 100% = qualidade   | Sabe calcular %           | Entende limitações         | Explica line vs branch vs path | Contexto (legacy vs greenfield)       |
| **Uso adequado** | Meta é sempre 100%          | "Quanto maior melhor"     | Target baseado em contexto | Diff coverage para código novo | ROI de cobertura (custo vs benefício) |
| **Alternativas** | Não conhece outras métricas | Menciona mutation testing | Propõe mutation testing    | Propõe múltiplas métricas      | Sistema de quality gates em camadas   |
| **Ferramentas**  | Não conhece ferramentas     | Conhece JaCoCo            | JaCoCo + Codecov           | JaCoCo + PITest + SonarQube    | Integração CI/CD com enforcement      |

**Perguntas para avaliar:**

- "Seu gerente quer 90% de cobertura. Você concorda?"
- "85% de cobertura mas 45% mutation score. O que isso significa?"
- "Como você mediria qualidade de testes além de coverage?"

---

#### Mutation Testing

| Nível             | 1 (Insuf.)           | 2 (Abaixo)       | 3 (Adequado)             | 4 (Forte)                          | 5 (Excepcional)                              |
| ----------------- | -------------------- | ---------------- | ------------------------ | ---------------------------------- | -------------------------------------------- |
| **Conceito**      | Não conhece          | Ouviu falar      | Explica o conceito       | Explica com exemplos de mutantes   | Explica operators (conditionals, math, etc.) |
| **Prática**       | Nunca usou           | Experimentou     | Usou em projeto          | Implementou no CI/CD               | Otimizou performance (incremental)           |
| **Interpretação** | Não sabe interpretar | "Maior = melhor" | Identifica testes fracos | Prioriza gaps críticos             | Análise de custo-benefício                   |
| **Ferramentas**   | Não conhece          | Conhece PITest   | Configurou PITest        | PITest + Stryker (multi-linguagem) | Comparação de ferramentas                    |

**Perguntas para avaliar:**

- "O que é mutation testing?"
- "Mutation score de 45% indica o quê?"
- "Como você implementaria mutation testing em CI/CD?"

---

### 4.3 Resiliência e Confiabilidade

#### Circuit Breaker

| Nível             | 1 (Insuf.)        | 2 (Abaixo)       | 3 (Adequado)        | 4 (Forte)                       | 5 (Excepcional)                                 |
| ----------------- | ----------------- | ---------------- | ------------------- | ------------------------------- | ----------------------------------------------- |
| **Conceito**      | Não conhece       | Definição vaga   | Define 3 estados    | Explica transições e thresholds | Compara com outros patterns (bulkhead, timeout) |
| **Implementação** | Nunca implementou | Copiou config    | Implementou com lib | Ajustou config para contexto    | A/B test de configs                             |
| **Testes**        | Não sabe testar   | Unit test básico | Testa estados       | Testa transições + fallback     | Chaos test + observabilidade                    |
| **Ferramentas**   | Não conhece       | Hystrix          | Resilience4j        | Resilience4j + métricas         | Comparação Hystrix vs Resilience4j              |

**Perguntas para avaliar:**

- "Explique Circuit Breaker"
- "Como você testaria os 3 estados?"
- "Que métricas monitoraria em produção?"

---

#### Idempotência

| Nível             | 1 (Insuf.)                 | 2 (Abaixo)             | 3 (Adequado)        | 4 (Forte)                         | 5 (Excepcional)                         |
| ----------------- | -------------------------- | ---------------------- | ------------------- | --------------------------------- | --------------------------------------- |
| **Conceito**      | Não conhece                | Define vagamente       | Define corretamente | Explica com exemplos HTTP         | Diferença idempotente vs determinístico |
| **Implementação** | Não sabe implementar       | Idempotency key básico | Lock + deduplicação | Distributed lock + atomicidade    | Considera edge cases (timeout, retry)   |
| **Testes**        | Não sabe testar            | Testa retry simples    | Testa duplicação    | Testa concorrência                | Chaos test (network partition)          |
| **Casos de uso**  | Não identifica quando usar | "Sempre necessário"    | APIs de mutação     | Diferencia GET vs POST/PUT/DELETE | Trade-offs (performance vs segurança)   |

**Perguntas para avaliar:**

- "O que é idempotência?"
- "Como implementaria em endpoint de pagamento?"
- "Como testaria idempotência sob concorrência?"

---

### 4.4 Performance e Escalabilidade

#### Load Testing

| Nível           | 1 (Insuf.)                       | 2 (Abaixo)        | 3 (Adequado)                 | 4 (Forte)                         | 5 (Excepcional)                    |
| --------------- | -------------------------------- | ----------------- | ---------------------------- | --------------------------------- | ---------------------------------- |
| **Tipos**       | Não diferencia load/stress/spike | Conhece load test | Diferencia load/stress/spike | Explica quando usar cada          | Contexto de negócio (Black Friday) |
| **Ferramentas** | Não conhece                      | JMeter            | JMeter ou k6                 | k6 + scripting                    | Comparação JMeter vs Gatling vs k6 |
| **Métricas**    | "Teste passou/falhou"            | Throughput        | Throughput + latency p95     | Throughput + latency + error rate | SLI/SLO com error budget           |
| **Integração**  | Testes manuais                   | Script isolado    | Script versionado            | CI/CD integration                 | Quality gate com thresholds        |

**Perguntas para avaliar:**

- "Diferença entre load test e stress test?"
- "Que métricas você coletaria?"
- "Como integraria no CI/CD?"

---

### 4.5 Observabilidade

#### Logs, Métricas, Traces

| Nível           | 1 (Insuf.)                | 2 (Abaixo)              | 3 (Adequado)              | 4 (Forte)                     | 5 (Excepcional)                 |
| --------------- | ------------------------- | ----------------------- | ------------------------- | ----------------------------- | ------------------------------- |
| **Conceitos**   | Confunde os 3 pilares     | Define logs             | Define logs e métricas    | Define os 3 pilares           | Explica quando usar cada        |
| **Uso prático** | Só usa logs               | Logs + métricas básicas | Logs + métricas + traces  | Estratégia de troubleshooting | Correlation entre os 3          |
| **Ferramentas** | Não conhece               | ELK                     | ELK ou Prometheus/Grafana | Prometheus + Jaeger + ELK     | OpenTelemetry + vendor-agnostic |
| **Testes**      | Não testa observabilidade | Valida logs existem     | Valida métricas           | Valida propagação de traces   | Chaos test de observabilidade   |

**Perguntas para avaliar:**

- "Diferença entre logs, métricas e traces?"
- "Para debugar latência intermitente, qual você usa?"
- "Como testaria distributed tracing?"

---

### 4.6 Segurança

#### Security Testing

| Nível           | 1 (Insuf.)     | 2 (Abaixo)            | 3 (Adequado)      | 4 (Forte)                     | 5 (Excepcional)                       |
| --------------- | -------------- | --------------------- | ----------------- | ----------------------------- | ------------------------------------- |
| **Tipos**       | Não conhece    | Menciona SAST ou DAST | SAST + DAST       | SAST + DAST + dependency scan | Shift-left security + threat modeling |
| **Ferramentas** | Não conhece    | Ouviu falar de OWASP  | Conhece OWASP ZAP | OWASP ZAP + Snyk + Trivy      | Comparação de ferramentas open source |
| **Integração**  | Testes manuais | Script isolado        | CI/CD integration | Quality gate com CVE blocking | Pipeline seguro (secrets, SBOM)       |
| **Práticas**    | Não menciona   | SQL injection         | Top 10 OWASP      | Auth/authz testing            | Threat modeling + attack surface      |

**Perguntas para avaliar:**

- "Que tipos de security testing você incluiria no CI/CD?"
- "Como testaria proteção contra SQL injection?"
- "Ferramentas open source que você usaria?"

---

### 4.7 Arquitetura e Design

#### Testabilidade no Design

| Nível           | 1 (Insuf.)                  | 2 (Abaixo)           | 3 (Adequado)                  | 4 (Forte)                     | 5 (Excepcional)                             |
| --------------- | --------------------------- | -------------------- | ----------------------------- | ----------------------------- | ------------------------------------------- |
| **Princípios**  | Não considera testabilidade | Dependency injection | DI + interfaces               | SOLID + testabilidade         | Hexagonal architecture                      |
| **Refatoração** | Não sabe refatorar          | Extract method       | Extract + inject dependencies | Seams (Feathers)              | Characterization tests + refatoração segura |
| **Code review** | Não avalia testabilidade    | "Adicione testes"    | Aponta código não testável    | Sugere refatoração específica | Balanceia pragmatismo vs ideal              |
| **Exemplos**    | Não dá exemplos             | Exemplo genérico     | Exemplo de projeto            | Antes/depois com métricas     | Trade-offs de cada approach                 |

**Perguntas para avaliar:**

- "Que características você busca em código testável?"
- "Como você refatoraria código legado para testabilidade?"
- "Exemplo de decisão arquitetural que facilitou testes"

---

#### Contract Testing

| Nível             | 1 (Insuf.)        | 2 (Abaixo)     | 3 (Adequado)                     | 4 (Forte)                              | 5 (Excepcional)                           |
| ----------------- | ----------------- | -------------- | -------------------------------- | -------------------------------------- | ----------------------------------------- |
| **Conceito**      | Não conhece       | Ouviu falar    | Define consumer-driven contracts | Explica workflow (consumer → provider) | Comparação contract vs E2E vs integration |
| **Implementação** | Nunca implementou | Copiou exemplo | Implementou com Pact             | Implementou CI/CD completo             | Múltiplos consumers + versioning          |
| **Ferramentas**   | Não conhece       | Pact           | Pact + Pact Broker               | Pact + Spring Cloud Contract           | Comparação de ferramentas                 |
| **Quando usar**   | Não sabe          | "Sempre"       | Microservices                    | Trade-off E2E vs contract              | Considera maturidade do time              |

**Perguntas para avaliar:**

- "O que é contract testing?"
- "Quando é melhor que E2E tests?"
- "Como implementaria entre frontend, BFF e backend?"

---

### 4.8 Processos e Cultura

#### TDD (Test-Driven Development)

| Nível           | 1 (Insuf.)     | 2 (Abaixo)          | 3 (Adequado)           | 4 (Forte)                   | 5 (Excepcional)                 |
| --------------- | -------------- | ------------------- | ---------------------- | --------------------------- | ------------------------------- |
| **Conceito**    | Não conhece    | Define vagamente    | Red-Green-Refactor     | Explica benefícios e custos | Contextos onde TDD agrega valor |
| **Prática**     | Nunca praticou | Tentou mas parou    | Pratica ocasionalmente | Pratica regularmente        | Ensina para o time              |
| **Quando usar** | Não sabe       | "Sempre" ou "Nunca" | Lógica complexa        | Trade-off por contexto      | Pragmatismo (não dogmatismo)    |
| **Impacto**     | Não mensura    | "Código melhor"     | Design emergente       | Métricas (cobertura, bugs)  | ROI (tempo vs qualidade)        |

**Perguntas para avaliar:**

- "Você pratica TDD? Por que sim/não?"
- "Quando TDD agrega mais valor?"
- "Como você introduziria TDD em um time resistente?"

---

#### Code Review para Testes

| Nível           | 1 (Insuf.)        | 2 (Abaixo)             | 3 (Adequado)                       | 4 (Forte)                         | 5 (Excepcional)                         |
| --------------- | ----------------- | ---------------------- | ---------------------------------- | --------------------------------- | --------------------------------------- |
| **Critérios**   | Não revisa testes | "Teste está presente"  | Nomenclatura + AAA                 | Nomenclatura + cobertura de edges | Checklist completo (mutação, flakiness) |
| **Feedback**    | Não dá feedback   | "Adicione mais testes" | Feedback específico                | Feedback construtivo + exemplos   | Ensina princípios                       |
| **Priorização** | Aprova sempre     | Bloqueia tudo          | Diferencia crítico vs nice-to-have | Risk-based review                 | Balanceia velocidade vs qualidade       |

**Perguntas para avaliar:**

- "5 pontos que você verifica ao revisar testes"
- "Exemplo de feedback construtivo que você deu"
- "Como você balanceia velocidade e qualidade em reviews?"

---

### 4.9 Trade-offs e Decisões

#### Speed vs Confidence

| Nível        | 1 (Insuf.)              | 2 (Abaixo)             | 3 (Adequado)           | 4 (Forte)                        | 5 (Excepcional)               |
| ------------ | ----------------------- | ---------------------- | ---------------------- | -------------------------------- | ----------------------------- |
| **Análise**  | Não reconhece trade-off | "Testes são lentos"    | Identifica o trade-off | Quantifica (tempo vs bugs)       | ROI analysis                  |
| **Soluções** | Remover testes          | Paralelização básica   | Múltiplas estratégias  | Priorização por risco            | Dados para decisão (métricas) |
| **Contexto** | Resposta única          | "Depende" sem elaborar | Adapta ao contexto     | Exemplos de contextos diferentes | Framework de decisão          |

**Perguntas para avaliar:**

- "Seus integration tests levam 30min. O que você faria?"
- "Como você decidiria entre velocidade e confiança?"
- "Exemplo de quando você priorizou velocidade sobre testes completos"

---

#### Testing in Production

| Nível           | 1 (Insuf.)        | 2 (Abaixo)            | 3 (Adequado)                     | 4 (Forte)                   | 5 (Excepcional)                         |
| --------------- | ----------------- | --------------------- | -------------------------------- | --------------------------- | --------------------------------------- |
| **Conceito**    | "Péssima prática" | Ouviu falar           | Conhece técnicas (canary, flags) | Implementou canary ou flags | Estratégia completa (synthetic, shadow) |
| **Quando usar** | Nunca             | "Sempre testar antes" | Casos específicos                | Trade-off pre-prod vs prod  | ROI (custo infra vs insights)           |
| **Ferramentas** | Não conhece       | Feature flags         | LaunchDarkly ou similar          | Canary + flags + monitoring | Comparação de abordagens                |
| **Riscos**      | Não considera     | "É arriscado"         | Mitigações básicas               | Rollback + alertas          | Incident response plan                  |

**Perguntas para avaliar:**

- "Testing in production é boa prática?"
- "Quando você testaria em produção?"
- "Como você mitigaria riscos?"

---

## 5. Rubrica Consolidada

### Scorecard Resumido

| Competência             | Peso     | Nota (1-5) | Ponderada          |
| ----------------------- | -------- | ---------- | ------------------ |
| **Fundamentos**         |          |            |                    |
| - Unit vs Integration   | 5%       |            |                    |
| - Test Doubles          | 5%       |            |                    |
| - Flaky Tests           | 5%       |            |                    |
| **Qualidade**           |          |            |                    |
| - Code Coverage         | 5%       |            |                    |
| - Mutation Testing      | 5%       |            |                    |
| **Resiliência**         |          |            |                    |
| - Circuit Breaker       | 5%       |            |                    |
| - Idempotência          | 5%       |            |                    |
| **Performance**         |          |            |                    |
| - Load Testing          | 5%       |            |                    |
| **Observabilidade**     |          |            |                    |
| - Logs/Métricas/Traces  | 10%      |            |                    |
| **Segurança**           |          |            |                    |
| - Security Testing      | 5%       |            |                    |
| **Arquitetura**         |          |            |                    |
| - Testabilidade         | 10%      |            |                    |
| - Contract Testing      | 5%       |            |                    |
| **Processos**           |          |            |                    |
| - TDD                   | 5%       |            |                    |
| - Code Review           | 5%       |            |                    |
| **Trade-offs**          |          |            |                    |
| - Speed vs Confidence   | 10%      |            |                    |
| - Testing in Production | 5%       |            |                    |
| **TOTAL**               | **100%** |            | **\_\_\_\_ / 5.0** |

---

## 6. Como Usar Esta Rubrica

### Para Entrevistadores

**Antes da Entrevista:**

1. Selecionar 5-7 competências relevantes para a posição
2. Preparar perguntas específicas de cada competência
3. Revisar rubricas das competências selecionadas

**Durante a Entrevista:**

1. Tomar notas de evidências concretas (exemplos, explicações)
2. Fazer follow-ups para aprofundar
3. Não julgar antes de explorar completamente

**Após a Entrevista:**

1. Avaliar cada competência usando a rubrica (1-5)
2. Calcular nota ponderada
3. Escrever justificativa para cada nota
4. Comparar com threshold do nível

### Para Candidatos

**Preparação:**

1. Auto-avaliar em cada competência
2. Preparar exemplos concretos de projetos
3. Praticar articulação de trade-offs
4. Estudar gaps identificados

**Durante a Entrevista:**

1. Usar framework: Contexto → Problema → Solução → Resultado
2. Mencionar trade-offs e alternativas consideradas
3. Quantificar impacto quando possível
4. Admitir quando não sabe (não inventar)

---

## 7. Exemplos de Avaliação

### Exemplo 1: Candidato Pleno - Nota 4.2/5.0

**Perfil:** 4 anos de experiência, e-commerce

**Destaques:**

- ✅ Explicou Circuit Breaker com exemplo real de integração com gateway de pagamento
- ✅ Mencionou Resilience4j, configurou thresholds baseado em dados
- ✅ Propôs métricas de monitoramento (state, call duration)
- ✅ Testou transições de estado com WireMock

**Áreas de melhoria:**

- 🔶 Não mencionou fallback strategy
- 🔶 Mutation testing: conhece o conceito mas nunca implementou
- 🔶 Contract testing: não tem experiência prática

**Avaliação por Competência:**

- Resiliência (Circuit Breaker): **5/5** - Excepcional
- Qualidade (Mutation Testing): **3/5** - Adequado
- Arquitetura (Contract Testing): **2/5** - Abaixo
- Performance (Load Testing): **4/5** - Forte
- Observabilidade: **4/5** - Forte

**Decisão:** ✅ **APROVADO para Pleno** - Forte em resiliência e observabilidade, pode crescer em qualidade avançada

---

### Exemplo 2: Candidato Sênior - Nota 3.8/5.0

**Perfil:** 6 anos de experiência, fintech

**Destaques:**

- ✅ Conhecimento teórico sólido de múltiplas áreas
- ✅ Articulou trade-offs claramente
- ✅ Mencionou ferramentas open source apropriadas
- ✅ Demonstrou pragmatismo (não dogmatismo)

**Áreas de melhoria:**

- 🔶 Exemplos práticos superficiais (faltou profundidade)
- 🔶 Não quantificou impacto de decisões
- 🔶 Chaos Engineering: conceito claro mas nunca praticou
- 🔶 Mutation testing: não implementou em CI/CD

**Avaliação por Competência:**

- Fundamentos: **4/5** - Forte
- Qualidade: **3/5** - Adequado
- Resiliência: **4/5** - Forte
- Trade-offs: **5/5** - Excepcional
- Experiência prática: **3/5** - Adequado (falta profundidade)

**Decisão:** 🔶 **APROVADO COM RESSALVAS para Sênior** - Precisa de mais experiência hands-on em qualidade avançada e chaos engineering

---

### Exemplo 3: Candidato Sênior - Nota 4.8/5.0

**Perfil:** 7 anos de experiência, SaaS B2B

**Destaques:**

- ✅ Implementou mutation testing no CI/CD (PITest) com 75% threshold
- ✅ Projetou quality gates em 4 camadas (pre-commit, PR, staging, prod)
- ✅ Chaos Engineering: realizou game days mensais, automatizou com Chaos Toolkit
- ✅ Exemplos concretos com métricas de impacto (redução de 40% em bugs produção)
- ✅ Articulou trade-offs econômicos (custo infra vs qualidade)
- ✅ Influenciou cultura de qualidade no time

**Áreas de melhoria:**

- 🔶 Contract testing: implementou mas não escalonou para múltiplos times

**Avaliação por Competência:**

- Qualidade: **5/5** - Excepcional
- Resiliência: **5/5** - Excepcional
- Arquitetura: **4/5** - Forte
- Processos: **5/5** - Excepcional (influência cultural)
- Trade-offs: **5/5** - Excepcional

**Decisão:** ✅ **CONTRATAÇÃO FORTEMENTE RECOMENDADA para Sênior** - Candidato excepcional, considerar Staff track

---

## 📚 Recursos Complementares

### Calibração de Entrevistadores

**Shadow Interviews:**

- Novos entrevistadores acompanham 5 entrevistas
- Preenchem rubrica independentemente
- Discutem diferenças com entrevistador sênior

**Reuniões de Calibração:**

- Mensalmente, time de entrevistadores revisa decisões
- Discute casos limítrofes
- Atualiza rubrica baseado em aprendizados

### Documentação de Decisões

**Template de Feedback:**

```markdown
# Avaliação: [Nome do Candidato]

**Posição:** [Nível]
**Data:** [DD/MM/AAAA]
**Entrevistador:** [Nome]

## Nota Final: X.X / 5.0

**Decisão:** [APROVADO / APROVADO COM RESSALVAS / NÃO APROVADO]

## Destaques

- [Ponto forte 1 com exemplo concreto]
- [Ponto forte 2 com exemplo concreto]
- [Ponto forte 3 com exemplo concreto]

## Áreas de Melhoria

- [Gap 1 com contexto]
- [Gap 2 com contexto]

## Avaliação Detalhada

| Competência     | Nota | Justificativa |
| --------------- | ---- | ------------- |
| [Competência 1] | X/5  | [Evidências]  |
| [Competência 2] | X/5  | [Evidências]  |

## Recomendação

[Justificativa final da decisão considerando nível, contexto do time, etc.]
```

---

## ✅ Checklist Final

### Para Entrevistadores

- [ ] Selecionei competências relevantes para o nível
- [ ] Preparei perguntas específicas de cada competência
- [ ] Revisei rubricas antes da entrevista
- [ ] Tomei notas de evidências concretas
- [ ] Avaliei objetivamente usando a rubrica
- [ ] Documentei justificativas para cada nota
- [ ] Considerei contexto (nível, experiência, área)
- [ ] Revisei decisão com calibração do time

### Para Candidatos

- [ ] Auto-avaliei em cada competência
- [ ] Preparei 5-7 exemplos concretos de projetos
- [ ] Pratiquei articulação de trade-offs
- [ ] Estudei ferramentas open source mencionadas
- [ ] Revisei conceitos fundamentais
- [ ] Preparei perguntas para o entrevistador
- [ ] Estruturei respostas: Contexto → Problema → Solução → Resultado

---

**Próximos passos:**

- Praticar com [perguntas técnicas](perguntas-tecnicas.md)
- Resolver [mini-casos](mini-casos.md)
- Consultar [glossário técnico](../12-taxonomia/glossario.md)
