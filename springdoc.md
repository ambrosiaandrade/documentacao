# Springdoc OpenAPI – Documentação da API

[Springdoc OpenAPI](https://springdoc.org/) é a integração moderna de **Swagger/OpenAPI 3** com aplicações Spring Boot. Ele gera automaticamente a documentação dos endpoints REST expostos pela aplicação.

## 📚 Tabela de conteúdos

- [📌 Endpoints Padrão](#-endpoints-padrão)
- [⚙️ Dependência Maven](#-dependência-maven)
- [🛠️ Configuração Básica (`application.properties`)](#-configuração-básica-applicationproperties)
- [🖋️ Anotações](#-anotações)
  - [No Controller](#no-controller)
  - [No Método](#no-método)
- [🧪 Anotando os modelos (DTOs ou entidades)](#-anotando-os-modelos-dtos-ou-entidades)
- [📦 Suporte para Versionamento de API](#-suporte-para-versionamento-de-api)
- [🧠 Boas Práticas](#-boas-práticas)
- [🔖 Ordenação de Controllers no Swagger UI](#-ordenação-de-controllers-no-swagger-ui)
- [🧱 Integração com Spring Security](#-integração-com-spring-security)

---

## 📌 Endpoints Padrão

| Recurso                       | URL padrão                                                          |
| ----------------------------- | ------------------------------------------------------------------- |
| Swagger UI (interface visual) | `http://localhost:8080/swagger-ui.html` ou `/swagger-ui/index.html` |
| OpenAPI JSON                  | `http://localhost:8080/v3/api-docs`                                 |
| OpenAPI YAML                  | `http://localhost:8080/v3/api-docs.yaml`                            |
| Actuator + Swagger            | Requer `springdoc.show-actuator=true`                               |

> Substitua `localhost:8080` pelo host, porta e contexto corretos da sua aplicação.

---

## ⚙️ Dependência Maven

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>${springdoc.version}</version>
</dependency>
```

🔁 Versão recomendada: `2.x` para Spring Boot 3+
(Ex: `2.3.0` ou superior)

---

## 🛠️ Configuração Básica (`application.properties`)

```properties
# Swagger + Actuator
springdoc.show-actuator=true

# (opcional) Personalizar URL base do Swagger UI
springdoc.swagger-ui.path=/swagger-ui.html
springdoc.api-docs.path=/v3/api-docs
```

---

## 🖋️ Anotações

### No Controller

```java
@RestController
@RequestMapping("/animals")
@Tag(name = "1. Animal", description = "Operações relacionadas a animais")
public class AnimalController {}
```

### No Método

```java
@Operation(
    summary = "Cadastrar um novo animal",
    description = "Cria e retorna o animal cadastrado."
)
@ApiResponses({
    @ApiResponse(responseCode = "201", description = "Criado com sucesso",
        content = @Content(mediaType = "application/json", schema = @Schema(implementation = Animal.class))),
    @ApiResponse(responseCode = "400", description = "Requisição inválida"),
    @ApiResponse(responseCode = "500", description = "Erro interno do servidor")
})
@PostMapping
public ResponseEntity<Animal> addAnimal(@RequestBody Animal animal) {
    // lógica...
}
```

---

## 🧪 Anotando os modelos (DTOs ou entidades)

```java
@Schema(description = "Representa um animal no sistema")
public class Animal {

    @Schema(description = "ID do animal", example = "1")
    private Long id;

    @Schema(description = "Nome do animal", example = "Leão")
    private String name;

    // getters e setters
}
```

---

## 📦 Suporte para Versionamento de API

Springdoc suporta múltiplas versões de API com agrupamento automático ou manual:

```properties
springdoc.group-configs[0].group=api-v1
springdoc.group-configs[0].paths-to-match=/v1/**
```

---

## 🧠 Boas Práticas

| Prática                            | Descrição                                                                 |
| ---------------------------------- | ------------------------------------------------------------------------- |
| ❌ Evite expor tudo automaticamente | Use `@Tag` e `@Operation` para documentação clara e controlada            |
| ✅ Documente os erros esperados     | `@ApiResponse` com código de erro e modelo de erro padronizado            |
| ✅ Mantenha consistência nos grupos | Útil para projetos com versionamento ou microserviços                     |
| ✅ Utilize `example = ""`           | Facilita testes e entendimento da API no Swagger UI                       |
| ✅ Combine com Bean Validation      | Springdoc detecta automaticamente anotações como `@NotNull`, `@Size`, etc |

---

## 🔖 Ordenação de Controllers no Swagger UI

```java
@Tag(name = "1. MyController")
public class MyController {}
```

**application.properties**:

```properties
springdoc.swagger-ui.enabled=true
springdoc.swagger-ui.tagsSorter=alpha
```

## 🧱 Integração com Spring Security

Se estiver usando autenticação, adicione suporte à segurança no Swagger:

```java
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Animais")
@RestController
public class AnimalController {
    // ...
}
```

E configure no bean principal:

```java
@Bean
public OpenAPI customOpenAPI() {
    return new OpenAPI()
        .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
        .components(new Components().addSecuritySchemes("bearerAuth",
            new SecurityScheme()
                .name("bearerAuth")
                .type(SecurityScheme.Type.HTTP)
                .scheme("bearer")
                .bearerFormat("JWT")
        ));
}
```