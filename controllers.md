# 🚀 Controllers

-----

## 📚 Tabela de conteúdos

- [O que é REST?](#o-que-é-rest)
  - [Princípios do REST](#princípios-do-rest)
  - [Exemplo de API RESTful](#exemplo-de-api-restful)
  - [Vantagens do REST](#vantagens-do-rest)
- [📌 Diferença entre @Controller e @RestController](#diferença-entre-controller-e-restcontroller)
- [@Controller](#controller)
- [@RestController](#restcontroller)
- [❗ Tratamento Global de Exceções](#tratamento-global-de-exceções)
- [RESTful vs RESTless](#restful-vs-restless)
  - [RESTful](#restful)
  - [RESTless](#restless)
- [Boas Práticas no Design de Endpoints REST](#boas-práticas-no-design-de-endpoints-rest)
  - [✅ 1. Use substantivos, não verbos, nos endpoints](#1-use-substantivos-não-verbos-nos-endpoints)
  - [✅ 2. Use plural para recursos](#2-use-plural-para-recursos)
  - [✅ 3. Hierarquia nos recursos](#3-hierarquia-nos-recursos)
  - [✅ 4. Use corretamente os métodos HTTP](#4-use-corretamente-os-métodos-http)
  - [✅ 5. Utilize os códigos HTTP corretos](#5-utilize-os-códigos-http-corretos)
  - [✅ 6. Suporte para paginação, filtro e ordenação](#6-suporte-para-paginação-filtro-e-ordenação)
  - [✅ 7. Documente sua API](#7-documente-sua-api)

-----

## O que é REST?

REST (Representational State Transfer) é um estilo arquitetural para construção de APIs baseadas em recursos. Ele define um conjunto de princípios para comunicação entre sistemas, geralmente via HTTP.

### Princípios do REST

1. **Recursos bem definidos**

   * Cada "coisa" do sistema é tratada como um recurso: usuários, produtos, pedidos etc.
   * Representado por **URLs únicas** (ex: `/api/usuarios/1`).

2. **Operações baseadas em HTTP**

   * A manipulação dos recursos é feita com os métodos HTTP:

     | Método | Ação      | Exemplo           |
     | ------ | --------- | ----------------- |
     | GET    | Buscar    | `/api/usuarios`   |
     | POST   | Criar     | `/api/usuarios`   |
     | PUT    | Atualizar | `/api/usuarios/1` |
     | DELETE | Remover   | `/api/usuarios/1` |

3. **Sem estado (stateless)**

   * Cada requisição deve conter **todas as informações necessárias** para ser processada.
   * O servidor **não armazena o estado do cliente** entre requisições.

4. **Uso de representações**

   * Os dados dos recursos são enviados como representações (geralmente **JSON**, mas pode ser XML, YAML etc).

5. **Comunicação via HTTP padrão**

   * Usa cabeçalhos, códigos de status (`200 OK`, `404 Not Found`, etc.) e métodos conforme especificação HTTP.

### Exemplo de API RESTful

Suponha um sistema de cadastro de animais:

| Método | Endpoint          | Ação                      |
| ------ | ----------------- | ------------------------- |
| GET    | `/api/animais`    | Lista todos os animais    |
| GET    | `/api/animais/10` | Busca animal com ID 10    |
| POST   | `/api/animais`    | Cria novo animal          |
| PUT    | `/api/animais/10` | Atualiza animal com ID 10 |
| DELETE | `/api/animais/10` | Remove animal com ID 10   |

---

### Vantagens do REST

* **Simplicidade**: baseado em HTTP puro.
* **Escalabilidade**: comunicação stateless facilita balanceamento.
* **Integração fácil**: sistemas diversos podem consumir a API com qualquer linguagem.
* **Caching e performance**: uso inteligente de cabeçalhos HTTP.

## 📌 Diferença entre @Controller e @RestController

| Anotação          | Retorno Esperado    | Uso Comum                          |
| ----------------- | ------------------- | ---------------------------------- |
| `@Controller`     | HTML / páginas      | MVC tradicional (Thymeleaf, JSP)   |
| `@RestController` | JSON / dados (REST) | APIs RESTful (React, Angular etc.) |

* **@RestController = @Controller + @ResponseBody**: toda resposta é serializada como JSON (ou outro formato definido pelo Content-Type).
* **@Controller** é usado com ViewResolvers para retornar páginas HTML renderizadas.


## @Controller

````java
@Controller
public class PaginaController {

    @GetMapping("/home")
    public String home(Model model) {
        model.addAttribute("mensagem", "Bem-vindo!");
        return "home"; // mapeado para /templates/home.html (ex: Thymeleaf)
    }
}
````
💡 Esse tipo de controller depende de um motor de template (como Thymeleaf).


## @RestController

```java
@RestController
@RequestMapping("/api")
public class MyController {

    @PostMapping
    public ResponseEntity<String> create(@RequestBody Object o) {
        // lógica para salvar objeto
        return ResponseEntity.status(201).body("Criado com sucesso");
    }

    @GetMapping
    public ResponseEntity<List<String>> readAll() {
        List<String> dados = List.of("Item 1", "Item 2");
        return ResponseEntity.ok(dados);
    }

    @GetMapping("/{id}")
    public ResponseEntity<String> read(@PathVariable int id) {
        return ResponseEntity.ok("Item com id: " + id);
    }

    @PutMapping("/{id}")
    public ResponseEntity<String> update(@RequestBody Object o, @PathVariable int id) {
        return ResponseEntity.ok("Atualizado com id: " + id);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> delete(@PathVariable int id) {
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/buscar")
    public ResponseEntity<String> buscarPorNome(@RequestParam String nome) {
        return ResponseEntity.ok("Nome buscado: " + nome);
    }
}
```
* **@RequestBody** transforma JSON da requisição em objeto Java.
* **@PathVariable** pega valores da URL.
* **@RequestParam** extrair parâmetros da query string da URL (ex: ?nome=João&idade=30) ou de formulários enviados via x-www-form-urlencoded

| Anotação        | Origem                    | Exemplo de uso         |
| --------------- | ------------------------- | ---------------------- |
| `@RequestParam` | Query string / formulário | `/usuarios?ativo=true` |
| `@PathVariable` | Parte da rota da URL      | `/usuarios/{id}`       |

```java
@GetMapping("/filtros")
public ResponseEntity<List<String>> filtrar(
    @RequestParam List<String> tags
) {
    return ResponseEntity.ok(tags);
}
```
Chamada:
``GET /api/filtros?tags=java&tags=spring&tags=lombok``

Resultado:
``["java", "spring", "lombok"]``

```java
@GetMapping("/busca")
public ResponseEntity<String> buscarComParametros(@RequestParam Map<String, String> params) {
    return ResponseEntity.ok("Parâmetros recebidos: " + params.toString());
}
```
Requisição:
``GET /api/busca?nome=João&idade=30&ativo=true``

Resposta:
``Parâmetros recebidos: {nome=João, idade=30, ativo=true}``

String nome = params.get("nome");

## ❗ Tratamento Global de Exceções

```java
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;

import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalHandler {

    /**
     * Erros de validação com @Valid (ex: campos obrigatórios ausentes, formatos inválidos etc).
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Object> handleValidationException(MethodArgumentNotValidException ex) {
        Map<String, String> erros = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String campo = ((FieldError) error).getField();
            String mensagem = error.getDefaultMessage();
            erros.put(campo, mensagem);
        });

        return ResponseEntity.badRequest().body(erros);
    }

    /**
     * Parâmetros obrigatórios ausentes na URL (ex: @RequestParam sem valor).
     */
    @ExceptionHandler(MissingServletRequestParameterException.class)
    public ResponseEntity<String> handleMissingParams(MissingServletRequestParameterException ex) {
        String nomeParametro = ex.getParameterName();
        return ResponseEntity
                .badRequest()
                .body("Parâmetro obrigatório ausente: " + nomeParametro);
    }

    /**
     * Argumentos inválidos (ex: @PathVariable com valor fora do esperado).
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<String> handleIllegalArgument(IllegalArgumentException e) {
        return ResponseEntity
                .badRequest()
                .body("Argumento inválido: " + e.getMessage());
    }

    /**
     * Exceções de acesso negado ou falta de autenticação/autorização.
     * (Opcional: requer configuração de segurança Spring Security).
     */
    // @ExceptionHandler(AccessDeniedException.class)
    // public ResponseEntity<String> handleAccessDenied(AccessDeniedException ex) {
    //     return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Acesso negado.");
    // }

    /**
     * Fallback genérico para exceções não tratadas.
     * Deve ser o último, para capturar qualquer erro inesperado.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGenericException(Exception e) {
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Erro interno: " + e.getMessage());
    }
}
```

## RESTful vs RESTless

### RESTful

Uma API é considerada **RESTful** quando **segue os princípios do REST** de forma consistente:

* Endpoints representam recursos.
* Métodos HTTP têm significado semântico (GET = buscar, POST = criar, etc).
* Stateless (sem estado entre requisições).
* Usa status HTTP corretos (`200 OK`, `404 Not Found`, etc).
* URLs claras e orientadas a recursos.

**Exemplo RESTful:**

```
GET     /api/usuarios/1        → retorna o usuário com ID 1  
POST    /api/usuarios          → cria um novo usuário  
PUT     /api/usuarios/1        → atualiza o usuário com ID 1  
DELETE  /api/usuarios/1        → remove o usuário com ID 1  
```

---

### RESTless

Uma API é **RESTless** (ou "não RESTful") quando **viola os princípios do REST**, por exemplo:

* Endpoints com verbos (`/getUsuario`, `/createUsuario`) em vez de representar recursos.
* Métodos HTTP usados incorretamente (ex: usando apenas `POST` para tudo).
* Design inconsistente ou com semântica misturada.

**Exemplo RESTless (❌ não recomendado):**

```
POST /api/getUsuario?id=1  
POST /api/createUsuario  
POST /api/updateUsuario  
POST /api/deleteUsuario?id=1
```

🔴 Isso ignora os verbos HTTP e transforma tudo em chamadas genéricas — o que vai contra o espírito REST.

---

## Boas Práticas no Design de Endpoints REST

### ✅ 1. Use substantivos, não verbos, nos endpoints

* **👍 Correto**: `/api/clientes`
* **👎 Errado**: `/api/getClientes`

> O método HTTP já define a ação: **GET** significa buscar, **POST** significa criar.

---

### ✅ 2. Use plural para recursos

* **👍** `/api/produtos`
* **👎** `/api/produto`

Consistência facilita o entendimento da API.

---

### ✅ 3. Hierarquia nos recursos

* **Exemplo**:
  `/api/clientes/123/pedidos/456` → pedido 456 do cliente 123

---

### ✅ 4. Use corretamente os métodos HTTP

| Método | Ação              | Descrição                         |
| ------ | ----------------- | --------------------------------- |
| GET    | Buscar            | Não modifica dados (idempotente)  |
| POST   | Criar             | Cria novo recurso                 |
| PUT    | Atualizar         | Atualiza completamente um recurso |
| PATCH  | Atualizar parcial | Atualiza parte de um recurso      |
| DELETE | Remover           | Remove um recurso                 |

---

### ✅ 5. Utilize os códigos HTTP corretos

| Código | Significado            |
| ------ | ---------------------- |
| 200    | OK                     |
| 201    | Created                |
| 204    | No Content (sem corpo) |
| 400    | Bad Request            |
| 401    | Unauthorized           |
| 404    | Not Found              |
| 500    | Internal Server Error  |

---

### ✅ 6. Suporte para paginação, filtro e ordenação

```http
GET /api/produtos?page=1&size=10&sort=preco,desc&categoria=eletronicos
```

* `page`, `size`: paginação
* `sort`: ordenação (campo,direção)
* parâmetros adicionais: filtros

---

### ✅ 7. Documente sua API

Use ferramentas como:

* **Swagger/OpenAPI** (`springdoc-openapi`, `springfox`)
* **Postman collections**
* **Redoc**, **Stoplight**
