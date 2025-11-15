# 🔄 Patterns Transversais (Cross-Cutting Concerns)

> Coleção de **patterns transversais** que se aplicam a toda aplicação, independente da arquitetura ou camada específica.

---

## 📚 O Que São Patterns Transversais?

**Patterns transversais** (ou **cross-cutting concerns**) são aspectos da aplicação que atravessam múltiplas camadas e contextos, afetando toda a base de código de forma uniforme.

### Diferença para Design Patterns (04-patterns)

| Aspecto         | Design Patterns (04-patterns)  | Transversais (05-transversal)           |
| --------------- | ------------------------------ | --------------------------------------- |
| **Escopo**      | Problema específico            | Toda a aplicação                        |
| **Localização** | Classe, módulo, camada         | Múltiplas camadas                       |
| **Propósito**   | Resolver problema de design    | Comportamento consistente global        |
| **Exemplos**    | Circuit Breaker, Factory, Saga | Exception Handling, Logging, Validation |
| **Acoplamento** | Baixo (isolado)                | Alto (cross-cutting)                    |

---

## 📖 Índice de Patterns

### 🛡️ Qualidade e Robustez

| #    | Pattern                                          | Descrição                                                     | Nível            |
| ---- | ------------------------------------------------ | ------------------------------------------------------------- | ---------------- |
| 05.5 | [Exception Handling](05.5-exception-handling.md) | Tratamento global de exceções (REST, Async, Mensageria, etc.) | 🟡 Intermediário |
| 05.6 | [Logging](05.6-logging.md)                       | Logging estruturado com MDC, trace IDs, ELK Stack             | 🟡 Intermediário |
| 05.7 | [Validation](05.7-validation.md)                 | Bean Validation, validadores customizados, grupos             | 🟡 Intermediário |
| 05.8 | [Configuration](05.8-configuration.md)           | Gerenciamento de propriedades, profiles, Config Server        | 🟡 Intermediário |

### 📐 Princípios e Práticas

| #     | Pattern                                                             | Descrição                                              | Nível            |
| ----- | ------------------------------------------------------------------- | ------------------------------------------------------ | ---------------- |
| 05.9  | [Princípios de Desenvolvimento](05.9-principios-desenvolvimento.md) | SOLID, DRY, KISS, YAGNI com exemplos Java/Spring       | 🟡 Intermediário |
| 05.10 | [Clean Code](05.10-clean-code.md)                                   | Nomenclatura, funções, comentários, formatação, testes | 🟡 Intermediário |

---

## 🎯 Quando Usar Patterns Transversais?

### ✅ Use quando precisar de:

- **Comportamento consistente** em toda aplicação (ex: formato de erro)
- **Rastreabilidade** completa (logs com trace IDs)
- **Configuração centralizada** (externalized properties)
- **Validação uniforme** (Bean Validation em todas camadas)
- **Tratamento de erros global** (mesma estrutura de erro)

### ❌ Evite quando:

- Comportamento pode ser localizado em uma única classe
- Adiciona complexidade desnecessária
- Pode ser resolvido com design pattern específico

---

## 🔍 Detalhamento dos Patterns

### 05.5 Exception Handling ⚠️

**Tratamento global de exceções** para garantir respostas consistentes em todos os contextos.

#### Contextos Cobertos:

- ✅ **REST APIs** (@RestControllerAdvice)
- ✅ **Métodos Async** (AsyncUncaughtExceptionHandler)
- ✅ **Mensageria** (RabbitMQ ErrorHandler, DLQ)
- ✅ **Scheduled Tasks** (@Aspect)
- ✅ **WebSocket** (@MessageExceptionHandler)
- ✅ **GraphQL** (DataFetcherExceptionHandler)

#### Principais Features:

- Custom exceptions hierárquicas (ResourceNotFoundException, BusinessException, etc.)
- ErrorResponse padronizado com trace ID
- Integração com logging (MDC)
- Dead Letter Queue para mensagens falhadas
- Estratégias de retry específicas por contexto

#### Quando Usar:

- ✅ Aplicações com múltiplos pontos de entrada (REST, messaging, async)
- ✅ Necessidade de respostas de erro consistentes
- ✅ Integração com sistemas de monitoramento

[📄 Ver documentação completa →](05.5-exception-handling.md)

---

### 05.6 Logging 📊

**Logging estruturado e contextual** com rastreamento de requisições e integração com ferramentas de análise.

#### Principais Features:

- **MDC (Mapped Diagnostic Context)** para trace IDs
- Logging estruturado (JSON) com Logback/Logstash
- Propagação de contexto em threads assíncronas
- Mascaramento de dados sensíveis (LGPD/GDPR)
- Integração com ELK Stack/Splunk
- Async appenders para performance

#### Contextos Cobertos:

- ✅ REST APIs (request/response logging)
- ✅ Async methods (thread context propagation)
- ✅ Mensageria (message tracking)
- ✅ Scheduled tasks (execution context)

#### Quando Usar:

- ✅ Aplicações distribuídas (rastreamento entre serviços)
- ✅ Necessidade de debugging em produção
- ✅ Auditoria e compliance
- ✅ Monitoramento de performance

[📄 Ver documentação completa →](05.6-logging.md)

---

### 05.7 Validation ✔️

**Validação robusta** usando Bean Validation (JSR-380) com validadores customizados e grupos.

#### Principais Features:

- **Bean Validation** (@NotNull, @NotBlank, @Size, @Email, etc.)
- Validadores customizados (@ValidCPF, @ValidEnum, etc.)
- Grupos de validação (Create.class, Update.class)
- Validação cross-field (@ValidDateRange)
- Exception handling integrado (MethodArgumentNotValidException)
- Internacionalização (ValidationMessages.properties)

#### Camadas Cobertas:

- ✅ Controller (@Valid @RequestBody)
- ✅ Service (@Validated)
- ✅ Entity (JPA constraints)

#### Quando Usar:

- ✅ Validação de entrada de APIs
- ✅ Regras de negócio simples (formato, range)
- ✅ Validação em múltiplas camadas (defesa em profundidade)
- ✅ Necessidade de mensagens de erro consistentes

[📄 Ver documentação completa →](05.7-validation.md)

---

### 05.8 Configuration ⚙️

**Gerenciamento centralizado de configurações** com externalization, profiles e recarregamento dinâmico.

#### Principais Features:

- **@ConfigurationProperties** (type-safe properties)
- **Profiles** (dev, prod, test)
- Externalization (environment variables, Config Server)
- **@RefreshScope** (dynamic reload)
- Encryption (Jasypt)
- Validation de properties (@Min, @NotNull, etc.)
- Feature flags

#### Tecnologias Suportadas:

- ✅ application.yml/properties
- ✅ Spring Cloud Config Server
- ✅ Consul
- ✅ Environment variables
- ✅ Command-line arguments

#### Quando Usar:

- ✅ Múltiplos ambientes (dev, staging, prod)
- ✅ Segredos sensíveis (API keys, passwords)
- ✅ Configuração centralizada (microservices)
- ✅ Recarregamento sem restart

[📄 Ver documentação completa →](05.8-configuration.md)

---

### 05.9 Princípios de Desenvolvimento 📐

**Princípios fundamentais** para escrever código de qualidade, manutenível e escalável.

#### Princípios Cobertos:

- ✅ **SOLID**
  - **S**ingle Responsibility Principle (SRP)
  - **O**pen/Closed Principle (OCP)
  - **L**iskov Substitution Principle (LSP)
  - **I**nterface Segregation Principle (ISP)
  - **D**ependency Inversion Principle (DIP)
- ✅ **DRY** (Don't Repeat Yourself)
- ✅ **KISS** (Keep It Simple, Stupid)
- ✅ **YAGNI** (You Aren't Gonna Need It)

#### Principais Features:

- Exemplos práticos com Java/Spring Boot
- Código "antes" e "depois" refatorado
- PedidoService refatorado para SRP
- Strategy pattern para OCP (desconto extensível)
- Composição vs herança para LSP
- Interfaces segregadas para ISP (pagamentos)
- Dependency Injection para DIP
- Bean Validation para eliminar DRY
- Código simples vs over-engineering (KISS)
- Evitar features especulativas (YAGNI)

#### Quando Usar:

- ✅ **Sempre** - Princípios aplicáveis a qualquer projeto
- ✅ Código com alta complexidade (precisa refatoração)
- ✅ Código difícil de testar (muitas dependências)
- ✅ Código duplicado (violação DRY)
- ✅ Over-engineering (violação KISS/YAGNI)

[📄 Ver documentação completa →](05.9-principios-desenvolvimento.md)

---

### 05.10 Clean Code 🧹

**Práticas de código limpo** para garantir legibilidade, manutenibilidade e qualidade.

#### Principais Features:

- **Nomenclatura**: Revela intenção, pronunciável, buscável
- **Funções**: Pequenas (<20 linhas), responsabilidade única, max 3 parâmetros
- **Comentários**: Código auto-explicativo, mínimo de comentários
- **Formatação**: Organização vertical, linhas ≤120 caracteres
- **Tratamento de erros**: Exceptions vs códigos de erro, @RestControllerAdvice centralizado
- **Classes**: Alta coesão, baixo acoplamento, organização estruturada
- **Testes**: AAA pattern (Arrange-Act-Assert), um conceito por teste

#### Exemplos Práticos:

```java
// ❌ Nome ruim
int d; // dias

// ✅ Nome bom
int diasAteVencimento;

// ❌ Função grande
public void processarPedido(Pedido pedido) {
    // 50 linhas de código...
}

// ✅ Função pequena (SRP)
public void processarPedido(Pedido pedido) {
    validarPedido(pedido);
    calcularTotal(pedido);
    salvarPedido(pedido);
    enviarEmail(pedido);
}
```

#### Quando Usar:

- ✅ **Sempre** - Clean Code é essencial
- ✅ Code review (verificar práticas)
- ✅ Refatoração (melhorar qualidade)
- ✅ Onboarding de novos desenvolvedores
- ✅ Código difícil de entender (precisa simplificar)

[📄 Ver documentação completa →](05.10-clean-code.md)

---

## 🔗 Integração entre Patterns

Os patterns transversais frequentemente trabalham juntos:

```
Requisição HTTP
  ↓
1. Configuration (carrega properties)
  ↓
2. Logging (registra trace ID via MDC)
  ↓
3. Validation (valida entrada)
  ↓
4. Business Logic
  ↓
5. Exception Handling (captura erros)
  ↓
6. Logging (registra erro com trace ID)
  ↓
Resposta HTTP (ErrorResponse ou Success)
```

### Exemplo Combinado:

```java
@RestController
@RequestMapping("/api/pedidos")
@RequiredArgsConstructor
class PedidoController {

    private final PedidoService service;
    private final ConfigProperties config; // 05.8 Configuration

    @PostMapping
    public ResponseEntity<PedidoDTO> criar(@Valid @RequestBody PedidoRequest request) {
        // 05.6 Logging - Trace ID automaticamente via MDC
        log.info("Criando pedido: clienteId={}", request.getClienteId());

        // 05.7 Validation - @Valid valida automaticamente

        // Business logic
        PedidoDTO pedido = service.criar(request);

        log.info("Pedido criado: id={}", pedido.getId());

        return ResponseEntity.ok(pedido);
    }
}

// 05.5 Exception Handling - Captura erros globalmente
@RestControllerAdvice
class GlobalExceptionHandler {

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidation(ValidationException ex) {
        // Usa MDC para trace ID (05.6 Logging)
        String traceId = MDC.get("traceId");

        ErrorResponse error = ErrorResponse.builder()
                .timestamp(LocalDateTime.now())
                .traceId(traceId)
                .message(ex.getMessage())
                .build();

        log.warn("Validation error: traceId={}, error={}", traceId, ex.getMessage());

        return ResponseEntity.badRequest().body(error);
    }
}
```

---

## 📊 Comparação com Design Patterns

| Pattern            | Tipo        | Escopo                | Exemplo                      |
| ------------------ | ----------- | --------------------- | ---------------------------- |
| Circuit Breaker    | Design      | Chamada específica    | Proteger API externa         |
| Exception Handling | Transversal | Toda aplicação        | Qualquer erro capturado      |
| Factory Method     | Design      | Criação de objetos    | NotificationFactory          |
| Configuration      | Transversal | Toda aplicação        | Qualquer property            |
| Saga               | Design      | Transação distribuída | Pedido → Pagamento → Estoque |
| Logging            | Transversal | Toda aplicação        | Qualquer operação            |
| Adapter            | Design      | Integração            | LegacyPaymentAdapter         |
| Validation         | Transversal | Qualquer entrada      | DTO, Entity, Service param   |

---

## 🎓 Ordem de Aprendizado Recomendada

### 1️⃣ Fundamentos (comece por aqui)

1. **Princípios de Desenvolvimento** (05.9) - Base teórica (SOLID, DRY, KISS, YAGNI)
2. **Clean Code** (05.10) - Práticas de código limpo
3. **Configuration** (05.8) - Base para todos os outros patterns técnicos
4. **Logging** (05.6) - Essencial para debugging
5. **Validation** (05.7) - Proteção de entrada
6. **Exception Handling** (05.5) - Tratamento de erros

### 2️⃣ Progressão Sugerida

```
Princípios (SOLID, DRY, KISS, YAGNI)
  ↓ (base teórica)
Clean Code (nomenclatura, funções)
  ↓ (práticas de escrita)
Configuration
  ↓ (usa properties)
Logging
  ↓ (registra eventos)
Validation
  ↓ (valida entrada)
Exception Handling
  ↓ (captura erros de validação)
[Implementa Business Logic com 04-patterns]
```

---

## 🧪 Testando Patterns Transversais

### Exception Handling

```java
@WebMvcTest(PedidoController.class)
class ExceptionHandlingTest {
    @Test
    void deveria_retornar_400_quando_validation_falha() throws Exception {
        mockMvc.perform(post("/api/pedidos")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.violations").exists());
    }
}
```

### Logging

```java
@SpringBootTest
class LoggingTest {
    @Test
    void deveria_propagar_trace_id() {
        MDC.put("traceId", "test-123");

        service.execute();

        // Verifica logs capturados
        assertThat(logAppender.list)
                .extracting("mdcPropertyMap")
                .extracting("traceId")
                .contains("test-123");
    }
}
```

### Validation

```java
class ValidationTest {
    private Validator validator;

    @Test
    void deveria_falhar_quando_cpf_invalido() {
        ClienteRequest request = new ClienteRequest();
        request.setCpf("123.456.789-00"); // Inválido

        Set<ConstraintViolation<ClienteRequest>> violations = validator.validate(request);

        assertThat(violations).hasSize(1);
        assertThat(violations).extracting("message").contains("CPF inválido");
    }
}
```

### Configuration

```java
@SpringBootTest
@TestPropertySource(properties = {
        "app.email.enabled=true",
        "app.email.smtp.host=smtp.test.com"
})
class ConfigurationTest {
    @Autowired
    private EmailProperties emailProperties;

    @Test
    void deveria_carregar_properties() {
        assertThat(emailProperties.getEnabled()).isTrue();
        assertThat(emailProperties.getSmtp().getHost()).isEqualTo("smtp.test.com");
    }
}
```

---

## 📋 Checklist de Implementação

### Para uma Nova Aplicação

- [ ] **Princípios de Desenvolvimento** (05.9)

  - [ ] Aplicar SOLID (SRP, OCP, LSP, ISP, DIP) no design
  - [ ] Evitar código duplicado (DRY)
  - [ ] Manter simplicidade (KISS)
  - [ ] Não adicionar features desnecessárias (YAGNI)

- [ ] **Clean Code** (05.10)

  - [ ] Nomes revelam intenção
  - [ ] Funções pequenas (<20 linhas)
  - [ ] Comentários mínimos (código auto-explicativo)
  - [ ] Formatação consistente
  - [ ] Testes com AAA pattern

- [ ] **Configuration** (05.8)

  - [ ] application.yml com profiles (dev, prod)
  - [ ] @ConfigurationProperties classes
  - [ ] Externalization de secrets (env vars)
  - [ ] Jasypt para encryption (opcional)

- [ ] **Logging** (05.6)

  - [ ] logback-spring.xml configurado
  - [ ] MDC filter para trace IDs
  - [ ] Async appenders
  - [ ] Integração com ELK/Splunk (opcional)

- [ ] **Validation** (05.7)

  - [ ] Dependência spring-boot-starter-validation
  - [ ] DTOs com anotações (@NotNull, @Size, etc.)
  - [ ] Validadores customizados (CPF, enum, etc.)
  - [ ] Exception handler para MethodArgumentNotValidException

- [ ] **Exception Handling** (05.5)
  - [ ] @RestControllerAdvice com handlers
  - [ ] Custom exceptions (ResourceNotFoundException, etc.)
  - [ ] ErrorResponse padronizado
  - [ ] Handlers para async, messaging, websocket (conforme necessário)

---

## 🔗 Recursos Adicionais

### Documentação Spring

- [Spring Boot Externalized Configuration](https://docs.spring.io/spring-boot/reference/features/external-config.html)
- [Spring Validation](https://docs.spring.io/spring-framework/reference/core/validation/beanvalidation.html)
- [Spring Logging](https://docs.spring.io/spring-boot/reference/features/logging.html)

### Bibliotecas

- **Logback** - [https://logback.qos.ch/](https://logback.qos.ch/)
- **SLF4J** - [https://www.slf4j.org/](https://www.slf4j.org/)
- **Hibernate Validator** - [https://hibernate.org/validator/](https://hibernate.org/validator/)
- **Jasypt** - [https://github.com/ulisesbocchio/jasypt-spring-boot](https://github.com/ulisesbocchio/jasypt-spring-boot)

### Ferramentas

- **ELK Stack** - [https://www.elastic.co/elastic-stack](https://www.elastic.co/elastic-stack)
- **Splunk** - [https://www.splunk.com/](https://www.splunk.com/)
- **Spring Cloud Config** - [https://spring.io/projects/spring-cloud-config](https://spring.io/projects/spring-cloud-config)
- **Consul** - [https://www.consul.io/](https://www.consul.io/)

---

## 📝 Changelog

### v1.1 (2025-11)

- ✅ **6 patterns transversais** documentados
- ✅ Exception Handling (REST, Async, Mensageria, Scheduled, WebSocket, GraphQL)
- ✅ Logging (MDC, trace IDs, ELK integration)
- ✅ Validation (Bean Validation, custom validators)
- ✅ Configuration (profiles, Config Server, encryption)
- ✅ Princípios de Desenvolvimento (SOLID, DRY, KISS, YAGNI)
- ✅ Clean Code (nomenclatura, funções, formatação, testes)
- ✅ Separação clara entre design patterns (04-patterns) e transversais (05-transversal)

---

## 🤝 Relação com Outros Padrões

### Complementa 04-patterns:

- **Circuit Breaker + Logging**: Registra falhas de circuit breaker
- **Saga + Exception Handling**: Compensa transações quando erro ocorre
- **REST Architecture + Validation**: Valida requests REST
- **Event Sourcing + Logging**: Auditoria completa de eventos

### Usado por 04-patterns:

Todo pattern em **04-patterns** potencialmente usa:

- **Logging** para rastreamento
- **Exception Handling** para erros
- **Validation** para entrada
- **Configuration** para properties

---

**Happy Coding!** 🚀

Desenvolvido com ❤️ para a comunidade Java/Spring Boot
