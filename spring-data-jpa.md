# Spring Data JPA 

## 📚 Tabela de conteúdos

- [Visão Geral](#visão-geral)
- [🔗 Links Oficiais](#links-oficiais)
- [⚙️ Dependências Maven](#dependências-maven)
- [🛠️ Configurações no `application.properties`](#configurações-no-applicationproperties)
- [🧪 Exemplo de Entidade e Repositório](#exemplo-de-entidade-e-repositório)
- [📦 Interfaces de Repositórios no Spring Data](#interfaces-de-repositórios-no-spring-data)
  - [Pacote: `org.springframework.data.repository`](#pacote-orgspringframeworkdatarepository)
  - [Pacote: `org.springframework.data.jpa.repository`](#pacote-orgspringframeworkdatajparepository)
- [📝 Consultas Personalizadas](#consultas-personalizadas)
- [🔄 Operações com Paging e Sorting](#operações-com-paging-e-sorting)
- [✅ Boas Práticas](#boas-práticas)
- [🔗 Relacionamentos no JPA](#relacionamentos-no-jpa)
  - [📘 `@ManyToOne` e `@OneToMany`](#manytoone-e-onetomany)
    - [Exemplo:](#exemplo)
  - [📘 `@OneToOne`](#onetoone)
  - [📘 `@ManyToMany`](#manytomany)
- [🔢 Estratégias de Geração de ID](#estratégias-de-geração-de-id)
  - [Tipos:](#tipos)
  - [Recomendado:](#recomendado)
- [⚡ EAGER vs LAZY](#eager-vs-lazy)
    - [Exemplo de diferença:](#exemplo-de-diferença)
- [🗃️ Inicialização com `schema.sql` / `data.sql`](#inicialização-com-schemasql-datasql)
  - [Exemplo: `schema.sql`](#exemplo-schemasql)
  - [Exemplo: `data.sql`](#exemplo-datasql)
  - [Importante:](#importante)
- [⏱️ Auditing com `@CreatedDate`, `@LastModifiedDate`](#auditing-com-createddate-lastmodifieddate)
  - [1. Habilite auditoria no seu projeto:](#1-habilite-auditoria-no-seu-projeto)
  - [2. Use as anotações nas entidades:](#2-use-as-anotações-nas-entidades)
  - [3. Configure o tipo de auditoria no Spring Boot:](#3-configure-o-tipo-de-auditoria-no-spring-boot)
  - [4. (Opcional) Usar auditoria de usuário:](#4-opcional-usar-auditoria-de-usuário)
- [✅ Resumo das Boas Práticas](#resumo-das-boas-práticas)

## Visão Geral

Spring Data JPA é um módulo do Spring Data que simplifica o acesso a dados usando o JPA (Java Persistence API). Ele abstrai e automatiza grande parte do trabalho necessário para criar repositórios de persistência, facilitando o desenvolvimento de aplicações baseadas em dados.

---

## 🔗 Links Oficiais

* **[Spring Data JPA](https://docs.spring.io/spring-data/jpa/reference/jpa/getting-started.html)**
* **[H2 Database](https://h2database.com/html/main.html)**
* **[Hibernate](https://hibernate.org/)**

---

## ⚙️ Dependências Maven

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>
```

---

## 🛠️ Configurações no `application.properties`

```properties
# H2 Console
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
spring.h2.console.settings.web-allow-others=true

# DataSource
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=sa

# JPA / Hibernate
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# Inicialização do SQL
spring.jpa.defer-datasource-initialization=true
spring.sql.init.mode=always
```

---

## 🧪 Exemplo de Entidade e Repositório

```java
import jakarta.persistence.*;

@Entity
public class Person {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private String name;

    // Getters e Setters
}
```

```java
import org.springframework.data.repository.CrudRepository;

public interface PersonRepository extends CrudRepository<Person, Long> {
    List<Person> findByName(String name);
}
```

---

## 📦 Interfaces de Repositórios no Spring Data

### Pacote: `org.springframework.data.repository`

```java
public interface CrudRepository<T, ID> extends Repository<T, ID>
```

> Fornece métodos básicos como `save`, `findById`, `findAll`, `deleteById`.

```java
public interface ListCrudRepository<T, ID> extends CrudRepository<T, ID>
```

> Versão moderna com suporte a `List<T>` ao invés de `Iterable<T>`.

```java
public interface PagingAndSortingRepository<T, ID> extends Repository<T, ID>
```

> Suporte a paginação (`Pageable`) e ordenação (`Sort`).

```java
public interface ListPagingAndSortingRepository<T, ID> extends PagingAndSortingRepository<T, ID>
```

> Combina paginação com retorno em `List<T>`.

---

### Pacote: `org.springframework.data.jpa.repository`

```java
public interface JpaRepository<T, ID> extends
    ListCrudRepository<T, ID>,
    ListPagingAndSortingRepository<T, ID>,
    QueryByExampleExecutor<T>
```

> Interface mais completa com suporte a:

* Paginação e ordenação
* Consultas por exemplo (`Query by Example`)
* Suporte à `flush`, `saveAllAndFlush`, `deleteInBatch`, etc.

---

## 📝 Consultas Personalizadas

Você pode definir consultas personalizadas por **convenção de nomes** ou usando a anotação `@Query`.

```java
List<Person> findByNameContainingIgnoreCase(String name);

@Query("SELECT p FROM Person p WHERE p.name = :name")
List<Person> buscarPorNome(@Param("name") String name);
```

---

## 🔄 Operações com Paging e Sorting

```java
Page<Person> findAll(Pageable pageable);
List<Person> findAll(Sort sort);
```

Exemplo de uso:

```java
PageRequest.of(0, 10, Sort.by("name").ascending());
```

---

## ✅ Boas Práticas

* Prefira `JpaRepository` por oferecer mais funcionalidades.
* Use `@Transactional` para métodos de escrita complexos.
* Habilite `show-sql` apenas em ambientes de desenvolvimento.
* Utilize `Pageable` e `Sort` para lidar com grandes volumes de dados.

## 🔗 Relacionamentos no JPA

O JPA permite mapear relações entre entidades para refletir a estrutura do banco de dados relacional. Aqui estão os tipos mais comuns:

---

### 📘 `@ManyToOne` e `@OneToMany`

Relacionamento **muitos-para-um** (muitos filhos para um pai) e **um-para-muitos** (um pai para muitos filhos).

#### Exemplo:

```java
@Entity
public class Department {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @OneToMany(mappedBy = "department", cascade = CascadeType.ALL)
    private List<Employee> employees = new ArrayList<>();
}
```

```java
@Entity
public class Employee {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "department_id")
    private Department department;
}
```

* `mappedBy`: indica o lado **não proprietário** da relação.
* `cascade`: define como operações em `Department` afetam `Employee`.
* `fetch`: define o tipo de carregamento (veremos abaixo).

---

### 📘 `@OneToOne`

Relacionamento **um-para-um** entre duas entidades.

```java
@Entity
public class User {

    @Id
    @GeneratedValue
    private Long id;

    private String username;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "profile_id", referencedColumnName = "id")
    private UserProfile profile;
}

@Entity
public class UserProfile {

    @Id
    @GeneratedValue
    private Long id;

    private String address;
}
```

---

### 📘 `@ManyToMany`

Relacionamento **muitos-para-muitos**, normalmente com uma tabela intermediária.

```java
@Entity
public class Student {

    @Id
    @GeneratedValue
    private Long id;

    private String name;

    @ManyToMany
    @JoinTable(
        name = "student_course",
        joinColumns = @JoinColumn(name = "student_id"),
        inverseJoinColumns = @JoinColumn(name = "course_id")
    )
    private Set<Course> courses = new HashSet<>();
}

@Entity
public class Course {

    @Id
    @GeneratedValue
    private Long id;

    private String title;

    @ManyToMany(mappedBy = "courses")
    private Set<Student> students = new HashSet<>();
}
```

---

## 🔢 Estratégias de Geração de ID

A anotação `@GeneratedValue` controla como o valor da chave primária é gerado:

```java
@Id
@GeneratedValue(strategy = GenerationType.AUTO)
private Long id;
```

### Tipos:

* `AUTO`: o provedor JPA escolhe a melhor estratégia com base no banco.
* `IDENTITY`: usa autoincremento do banco (ex: `AUTO_INCREMENT` no MySQL).
* `SEQUENCE`: usa sequência do banco, ideal para PostgreSQL.
* `TABLE`: usa uma tabela para gerar valores únicos.

### Recomendado:

* Use `IDENTITY` com bancos que suportam autoincremento.
* Use `SEQUENCE` com bancos como PostgreSQL para melhor performance.

---

## ⚡ EAGER vs LAZY

`fetch = FetchType.LAZY` (Padrão para coleções)

* Os dados relacionados **só são carregados quando acessados**.
* Mais performático; evita queries desnecessárias.
* Requer atenção para evitar `LazyInitializationException` fora do contexto da transação.

`fetch = FetchType.EAGER` (Padrão para @ManyToOne, @OneToOne)

* Os dados relacionados são **carregados imediatamente** com a entidade principal.
* Simples, mas pode gerar **N+1 queries** e performance ruim.

#### Exemplo de diferença:

```java
// LAZY (recomendado para coleções)
@OneToMany(mappedBy = "department", fetch = FetchType.LAZY)
private List<Employee> employees;

// EAGER
@ManyToOne(fetch = FetchType.EAGER)
private Department department;
```


---

## 🗃️ Inicialização com `schema.sql` / `data.sql`

O Spring Boot detecta automaticamente os arquivos:

* `schema.sql`: script de **criação** do schema.
* `data.sql`: script de **inserção de dados**.

Eles devem estar na raiz de `src/main/resources` ou `src/test/resources`.

### Exemplo: `schema.sql`

```sql
CREATE TABLE person (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100)
);
```

### Exemplo: `data.sql`

```sql
INSERT INTO person (name) VALUES ('João');
INSERT INTO person (name) VALUES ('Ana');
```

### Importante:

* Para garantir a execução, configure no `application.properties`:

```properties
spring.sql.init.mode=always
spring.jpa.defer-datasource-initialization=true
```

---

## ⏱️ Auditing com `@CreatedDate`, `@LastModifiedDate`

O Spring Data JPA permite o uso de anotações de auditoria para preencher automaticamente campos como data de criação e modificação.

### 1. Habilite auditoria no seu projeto:

```java
@Configuration
@EnableJpaAuditing
public class JpaConfig {}
```

### 2. Use as anotações nas entidades:

```java
@Entity
@EntityListeners(AuditingEntityListener.class)
public class Person {

    @Id
    @GeneratedValue
    private Long id;

    private String name;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;
}
```

### 3. Configure o tipo de auditoria no Spring Boot:

```properties
spring.jpa.properties.hibernate.jdbc.time_zone=UTC
```

### 4. (Opcional) Usar auditoria de usuário:

Você pode criar um `AuditorAware` para registrar quem criou ou atualizou (por login, token, etc):

```java
@Bean
public AuditorAware<String> auditorProvider() {
    return () -> Optional.of("admin"); // ou capturar do contexto de segurança
}
```

---

## ✅ Resumo das Boas Práticas

| Funcionalidade                      | Recomendação                                  |
| ----------------------------------- | --------------------------------------------- |
| `@DataJpaTest`                      | Para testes isolados de repositórios          |
| `data.sql`, `schema.sql`            | Boa forma de carregar dados para testes e dev |
| `@CreatedDate`, `@LastModifiedDate` | Auditar entidades automaticamente             |
| `@EnableJpaAuditing`                | Necessário para ativar auditoria no projeto   |
| `AuditorAware`                      | Customizar o responsável por alterações       |

