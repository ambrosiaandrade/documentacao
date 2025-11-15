# 🗄️ Fase 12: Banco de Dados - Plano de Estudos (Pleno → Sênior/Arquiteto)

## Visão Geral

Esta fase eleva o conhecimento de persistência do nível pleno para sênior/arquiteto, cobrindo desde fundamentos até otimizações avançadas, design de dados e estratégias de teste.

---

## Estrutura Modular

### **Módulo 1: SQL Avançado & PostgreSQL**

📁 `12.1-sql-avancado.md` (1.200+ linhas)

**Objetivos:**

- Window functions, CTEs, índices avançados
- Integridade referencial e constraints complexos
- Concorrência: deadlocks, locking strategies, MVCC
- Transações avançadas (Isolation Levels)
- Explain/Analyze e query optimization
- Particionamento e sharding

**Tópicos:**

1. Window Functions (ROW_NUMBER, RANK, LAG/LEAD)
2. CTEs Recursivas e Hierarquias
3. Constraints e Integridade Referencial
4. Concorrência e Locking (Pessimistic, Optimistic)
5. Transações Avançadas (Isolation Levels, MVCC)
6. Performance e Otimização (EXPLAIN, pg_stat_statements)
7. Particionamento (Range, List, Hash)
8. Ferramentas Open Source (pgAdmin, DBeaver)

**Artefatos:**

- ✅ 15+ exemplos práticos SQL avançado
- ✅ Tabela de Isolation Levels
- ✅ Diagrama de MVCC
- ✅ Scripts de diagnóstico deadlock
- ✅ Métricas: tempo query, deadlock rate, table bloat

**Nota:** Testes de banco estão em `docs/03-avancado/03.5-banco-dados.md`

---

### **Módulo 2: JPA & Hibernate Profundo**

📁 `12.2-jpa-hibernate.md` (1.400+ linhas)

**Objetivos:**

- Dominar anotações JPA/Hibernate
- Entity lifecycle e estados
- Relacionamentos complexos (OneToMany, ManyToMany)
- @Transactional em profundidade
- Lazy vs Eager loading
- N+1 queries e soluções
- Cache de primeiro e segundo nível
- Listeners e Callbacks

**Tópicos:**

1. Anotações Fundamentais (Tabela Completa)
2. Entity Lifecycle
3. Relacionamentos (@OneToMany, @ManyToMany, @JoinColumn, @JoinTable)
4. @Transactional Profundo (Propagation, Isolation, Rollback)
5. Fetch Strategies
6. Query Optimization (EntityGraph, Batch Fetch)
7. Caching (L1, L2, Query Cache)
8. Auditing e Callbacks
9. Testes com @DataJpaTest

**Artefatos:**

- ✅ Tabela de 50+ anotações JPA
- ✅ Diagrama de Entity States
- ✅ 20+ exemplos práticos
- ✅ Tabela Propagation behaviors
- ✅ Anti-patterns e soluções
- ✅ Métricas: queries/request, cache hit rate

---

### **Módulo 3: Spring Data & Repositories**

📁 `12.3-spring-data-repositories.md` (1.000+ linhas)

**Objetivos:**

- Repository patterns
- Query methods e @Query
- Specifications e Criteria API
- Paginação e Sorting
- Projections e DTOs
- Auditing automático
- Custom repositories

**Tópicos:**

1. Repository Hierarchy
2. Query Methods (naming conventions)
3. @Query (JPQL, Native SQL)
4. Specifications (type-safe queries)
5. Pageable e Sort
6. Projections (Interface-based, Class-based, Dynamic)
7. @CreatedDate, @LastModifiedDate
8. Custom Repository Implementation
9. Testing Strategies

**Artefatos:**

- ✅ Tabela de Query Keywords
- ✅ 15+ exemplos paginação
- ✅ Specifications avançadas
- ✅ Testes parametrizados
- ✅ Métricas: tempo paginação, memory usage

---

### **Módulo 4: NoSQL - MongoDB**

📁 `12.4-mongodb.md` (800+ linhas)

**Objetivos:**

- Schema design para documentos
- Testes com Embedded MongoDB
- Consistência eventual
- Indexação e performance
- Aggregation pipeline
- Transactions (desde 4.0)

**Tópicos:**

1. Document Design Patterns
2. Spring Data MongoDB
3. Testing (Flapdoodle Embedded MongoDB)
4. Indexes (Single, Compound, Text)
5. Aggregation Framework
6. Transactions Multi-Document
7. Change Streams
8. Performance Tuning

**Artefatos:**

- ✅ Comparação SQL vs NoSQL
- ✅ Padrões de schema design
- ✅ 10+ exemplos agregação
- ✅ Testes com TestContainers MongoDB
- ✅ Métricas: index usage, query patterns

---

### **Módulo 5: Redis - Cache & Pub/Sub**

📁 `12.5-redis.md` (700+ linhas)

**Objetivos:**

- Cache strategies (Cache-Aside, Write-Through, Read-Through)
- TTL e expiração
- Pub/Sub messaging
- Testes com Embedded Redis
- Observabilidade (hit rate, evictions)

**Tópicos:**

1. Spring Cache Abstraction
2. Cache Strategies
3. @Cacheable, @CacheEvict, @CachePut
4. Redis Data Structures (String, Hash, List, Set, ZSet)
5. TTL e Eviction Policies
6. RedisTemplate vs ReactiveRedisTemplate
7. Pub/Sub Pattern
8. Testing (Testcontainers Redis)
9. Monitoring & Metrics

**Artefatos:**

- ✅ Tabela de cache strategies
- ✅ Comparação Redis vs Caffeine
- ✅ 12+ exemplos práticos
- ✅ Testes de TTL e expiração
- ✅ Métricas: hit rate, miss rate, evictions

---

### **Módulo 6: Database Migrations**

📁 `12.6-migrations.md` (600+ linhas)

**Objetivos:**

- Flyway vs Liquibase (comparação)
- Versionamento de schema
- Rollback strategies
- Zero-downtime migrations
- Testing migrations

**Tópicos:**

1. Flyway Setup e Convenções
2. Liquibase Setup (XML, YAML, JSON)
3. Migration Best Practices
4. Rollback Strategies
5. Blue-Green Deployments
6. Backward Compatibility
7. Testing Migrations
8. CI/CD Integration

**Artefatos:**

- ✅ Comparação Flyway vs Liquibase
- ✅ 10+ exemplos de migrations
- ✅ Checklist de zero-downtime
- ✅ Scripts de validação
- ✅ Métricas: migration time, rollback success rate

---

### **Módulo 7: Triggers & Stored Procedures**

📁 `12.7-triggers-procedures.md` (500+ linhas)

**Objetivos:**

- Quando usar (e quando NÃO usar) triggers
- Stored procedures em PostgreSQL
- Testing database logic
- Alternatives (Domain Events)

**Tópicos:**

1. Triggers: BEFORE/AFTER, Row/Statement
2. Stored Procedures (PL/pgSQL)
3. Functions vs Procedures
4. Testing Database Logic
5. Observability (logging, metrics)
6. Alternatives: Application Layer Logic
7. Domain Events Pattern
8. Trade-offs e Anti-patterns

**Artefatos:**

- ✅ Matriz de decisão (trigger vs app logic)
- ✅ 8+ exemplos PostgreSQL
- ✅ Testes de triggers
- ✅ Comparação com Domain Events
- ✅ Métricas: trigger execution time

---

### **Módulo 8: Connection Pooling & Performance**

📁 `12.8-connection-pooling.md` (700+ linhas)

**Objetivos:**

- HikariCP tuning
- Connection pool sizing
- Prepared statements
- Batch processing
- Query performance monitoring

**Tópicos:**

1. HikariCP Configuration
2. Pool Sizing Formula
3. Connection Leak Detection
4. Prepared Statements Best Practices
5. Batch Insert/Update
6. Connection Timeout Strategies
7. Monitoring & Alerting
8. Troubleshooting Common Issues

**Artefatos:**

- ✅ Tabela configurações HikariCP
- ✅ Formula pool sizing
- ✅ 10+ exemplos batch processing
- ✅ Scripts de monitoring
- ✅ Métricas: active connections, wait time, usage %

---

### **Módulo 9: Multi-Tenancy**

📁 `12.9-multi-tenancy.md` (600+ linhas)

**Objetivos:**

- Database per tenant
- Schema per tenant
- Row-level security
- Testing multi-tenant apps

**Tópicos:**

1. Multi-Tenancy Strategies
2. Database per Tenant (Pros/Cons)
3. Schema per Tenant
4. Discriminator Column (Row-Level)
5. Dynamic DataSource Routing
6. Hibernate Multi-Tenancy
7. Testing Strategies
8. Security Considerations

**Artefatos:**

- ✅ Comparação de estratégias
- ✅ 8+ exemplos práticos
- ✅ Testes de isolamento
- ✅ Security checklist
- ✅ Métricas: tenant isolation, query performance

---

### **Módulo 10: Database Design & Modeling**

📁 `12.10-database-design.md` (900+ linhas)

**Objetivos:**

- Normalização (1NF, 2NF, 3NF, BCNF)
- Denormalização e trade-offs
- Schema design patterns
- Data modeling para performance
- Event Sourcing e CQRS
- Time-series data modeling

**Tópicos:**

1. Formas Normais (1NF → BCNF)
2. Quando Denormalizar
3. Schema Design Patterns
4. Modeling para Diferentes Casos de Uso
5. Event Sourcing Pattern
6. CQRS (Command Query Responsibility Segregation)
7. Time-Series Data (TimescaleDB)
8. Document vs Relational Trade-offs

**Artefatos:**

- ✅ Tabela de formas normais
- ✅ 15+ exemplos de schema design
- ✅ Comparação patterns
- ✅ Diagramas ER avançados
- ✅ Métricas: query complexity, join cost

**Nota:** Testes de banco estão em `docs/03-avancado/03.5-banco-dados.md`

---

## Critérios de Conclusão da Fase 12

| Módulo | Artefatos           | Exemplos | Métricas | Status      |
| ------ | ------------------- | -------- | -------- | ----------- |
| 12.1   | SQL Avançado        | 15+      | 5+       | ⏳ Pendente |
| 12.2   | JPA/Hibernate       | 20+      | 6+       | ⏳ Pendente |
| 12.3   | Spring Data         | 15+      | 4+       | ⏳ Pendente |
| 12.4   | MongoDB             | 10+      | 3+       | ⏳ Pendente |
| 12.5   | Redis               | 12+      | 4+       | ⏳ Pendente |
| 12.6   | Migrations          | 10+      | 3+       | ⏳ Pendente |
| 12.7   | Triggers/Procedures | 8+       | 2+       | ⏳ Pendente |
| 12.8   | Connection Pooling  | 10+      | 4+       | ⏳ Pendente |
| 12.9   | Multi-Tenancy       | 8+       | 3+       | ⏳ Pendente |
| 12.10  | Testing Strategies  | 20+      | 5+       | ⏳ Pendente |

**Total Estimado:** ~8.500 linhas de conteúdo técnico de alta qualidade

---

## Roadmap de Execução

### Semana 1: Fundamentos

- Módulo 12.1 (SQL Avançado)
- Módulo 12.2 (JPA/Hibernate)

### Semana 2: Spring Data & NoSQL

- Módulo 12.3 (Spring Data)
- Módulo 12.4 (MongoDB)
- Módulo 12.5 (Redis)

### Semana 3: Operações & Avançado

- Módulo 12.6 (Migrations)
- Módulo 12.7 (Triggers/Procedures)
- Módulo 12.8 (Connection Pooling)

### Semana 4: Arquitetura & Testing

- Módulo 12.9 (Multi-Tenancy)
- Módulo 12.10 (Testing Strategies)
- Revisão e integração

---

## Ferramentas Open Source (Referência Rápida)

| Categoria           | Ferramenta            | Uso                         |
| ------------------- | --------------------- | --------------------------- |
| **Database**        | PostgreSQL            | RDBMS principal             |
|                     | H2                    | In-memory testing           |
|                     | MongoDB               | NoSQL document store        |
|                     | Redis                 | Cache & pub/sub             |
| **ORM**             | Hibernate             | JPA implementation          |
|                     | Spring Data JPA       | Repository abstraction      |
| **Migrations**      | Flyway                | SQL-based migrations        |
|                     | Liquibase             | XML/YAML migrations         |
| **Testing**         | TestContainers        | Docker containers for tests |
|                     | DbUnit                | Database fixtures           |
|                     | Testcontainers-Spring | Spring Boot integration     |
| **Connection Pool** | HikariCP              | Fast connection pooling     |
| **Monitoring**      | pg_stat_statements    | PostgreSQL query stats      |
|                     | Micrometer            | Metrics collection          |
|                     | Spring Boot Actuator  | Database health checks      |

---

## Padrão de Qualidade por Módulo

Cada módulo deve incluir:

1. **Introdução** (O que é, por que é importante)
2. **Conceitos Fundamentais** (Tabelas, diagramas)
3. **Exemplos Práticos** (Java 17+, código completo)
4. **Ferramentas Open Source** (Setup, configuração)
5. **Testes** (Estratégias, exemplos)
6. **Métricas** (O que medir, como medir)
7. **Boas Práticas** (DO/DON'T)
8. **Anti-Patterns** (O que evitar)
9. **Troubleshooting** (Problemas comuns)
10. **Checklist** (Validação de conhecimento)

---

## Convenções de Código

- ✅ **Java 17+** obrigatório (var, records, text blocks, sealed classes)
- ✅ **Spring Boot 3.x** (Jakarta EE, não javax)
- ✅ **JUnit 5** (não JUnit 4)
- ✅ **AssertJ** para assertions
- ✅ **TestContainers** para testes de integração
- ✅ **HikariCP** como connection pool
- ✅ **SLF4J + Logback** para logging

---

## Métricas Transversais

Cada módulo deve definir métricas específicas, mas algumas são universais:

1. **Query Performance**: Tempo médio de execução (ms)
2. **Connection Usage**: % de conexões ativas
3. **Cache Hit Rate**: % de hits no cache
4. **Error Rate**: % de queries com erro
5. **Transaction Duration**: Tempo médio de transação
6. **Deadlock Rate**: Deadlocks por hora
7. **Migration Success**: % de migrations bem-sucedidas
8. **Test Coverage**: % de código testado

---

## Prompt Modelo para Criação de Módulos

```
Contexto: Fase 12 - Banco de Dados (Módulo X)
Objetivo: Criar guia completo de [tópico] elevando de pleno para sênior/arquiteto
Formato Saída: Markdown com estrutura padronizada
Critérios Qualidade:
  - Exemplos práticos em Java 17+
  - Ferramentas open source
  - Tabelas comparativas e explicativas
  - Métricas mensuráveis
  - Testes com TestContainers
  - DO/DON'T claros
  - Checklist de validação
Restrições:
  - Mínimo 600 linhas por módulo
  - Máximo 1.500 linhas por módulo
  - 100% dos exemplos em Java 17+
  - Evitar jargão sem explicação
Ação: Produzir módulo completo
```

---

## Próximos Passos

1. **Iniciar Módulo 12.1** (SQL Avançado & PostgreSQL)
2. Seguir sequência do roadmap
3. Validar critérios de conclusão de cada módulo
4. Integrar com outras fases do plano

---

## Referências

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Hibernate User Guide](https://docs.jboss.org/hibernate/orm/current/userguide/html_single/Hibernate_User_Guide.html)
- [Spring Data JPA Reference](https://docs.spring.io/spring-data/jpa/docs/current/reference/html/)
- [Flyway Documentation](https://flywaydb.org/documentation/)
- [TestContainers](https://www.testcontainers.org/)
- [HikariCP GitHub](https://github.com/brettwooldridge/HikariCP)

---

**Nota:** Este plano está alinhado com o padrão de qualidade das Fases 8, 10 e 11 já concluídas, garantindo consistência e profundidade técnica.
