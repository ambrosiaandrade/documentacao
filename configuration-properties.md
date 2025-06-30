## ConfigurationProperties

A anotação `@ConfigurationProperties(prefix = "app.kafka")` é usada em Spring Boot para criar uma **classe de configuração "tipada"**, que mapeia valores do `application.yml` ou `application.properties` para campos Java.

### ✅ Objetivo:

👉 Evitar vários `@Value` espalhados e agrupar propriedades relacionadas em um só lugar — com **autocompletar**, **validação**, e **manutenção muito mais fácil**.

---

## 🧱 Explicação linha a linha

```java
@ConfigurationProperties(prefix = "app.kafka")
public class KafkaRetryProperties {
    private int retries;
    private int retryBackoffMs;
    private String retryPolicy;

    // Getters e setters obrigatórios (ou usar Lombok)
}
```

Essa classe mapeia propriedades como:

```yaml
app:
  kafka:
    retries: 3
    retry-backoff-ms: 1000
    retry-policy: exponential
```

🔁 Cada valor do `YAML` ou `properties` será injetado no campo correspondente da classe, **automaticamente pelo Spring**.

---

## ⚙️ Como usar no projeto?

### 1. Habilitar o binding

Adicione a anotação `@EnableConfigurationProperties` na sua `@Configuration`, ou simplesmente registre a classe como `@Component`.

#### Opção 1 — mais explícita:

```java
@Configuration
@EnableConfigurationProperties(KafkaRetryProperties.class)
public class KafkaConfig {
    // aqui você pode usar a KafkaRetryProperties
}
```

#### Opção 2 — anotando direto na classe:

```java
@Component
@ConfigurationProperties(prefix = "app.kafka")
public class KafkaRetryProperties {
    // ...
}
```

### 2. Usar a classe no seu bean de retry

```java
@Configuration
public class KafkaRetryConfig {

    private final KafkaRetryProperties properties;

    public KafkaRetryConfig(KafkaRetryProperties properties) {
        this.properties = properties;
    }

    @Bean
    public RetryTemplate retryTemplate() {
        RetryTemplate template = new RetryTemplate();

        SimpleRetryPolicy retryPolicy = new SimpleRetryPolicy();
        retryPolicy.setMaxAttempts(properties.getRetries());

        BackOffPolicy backOffPolicy = "exponential".equalsIgnoreCase(properties.getRetryPolicy())
                ? getExponentialBackOffPolicy()
                : getFixedBackOffPolicy();

        template.setRetryPolicy(retryPolicy);
        template.setBackOffPolicy(backOffPolicy);

        return template;
    }

    private FixedBackOffPolicy getFixedBackOffPolicy() {
        var policy = new FixedBackOffPolicy();
        policy.setBackOffPeriod(properties.getRetryBackoffMs());
        return policy;
    }

    private ExponentialBackOffPolicy getExponentialBackOffPolicy() {
        var policy = new ExponentialBackOffPolicy();
        policy.setInitialInterval(1000);
        policy.setMultiplier(2.0);
        policy.setMaxInterval(5000);
        return policy;
    }
}
```

---

## 💡 Vantagens de usar `@ConfigurationProperties`

| Vantagem               | Explicação                                                                    |
| ---------------------- | ----------------------------------------------------------------------------- |
| ✅ Organização          | Agrupa propriedades relacionadas                                              |
| ✅ Evita repetição      | Substitui múltiplos `@Value`                                                  |
| ✅ Mais robusto         | Suporta validação com `@Validated`                                            |
| ✅ Mais fácil de testar | Pode ser instanciado e usado em testes isolados                               |
| ✅ IntelliSense         | IDEs como IntelliJ reconhecem os campos no `application.yml` com autocomplete |

---

## 🧪 Bônus: Usar validação

```java
@Component
@ConfigurationProperties(prefix = "app.kafka")
@Validated
public class KafkaRetryProperties {
    
    @Min(1)
    private int retries;

    @Min(0)
    private int retryBackoffMs;

    @NotBlank
    private String retryPolicy;

    // getters/setters
}
```

> Agora o Spring vai falhar ao iniciar se alguma propriedade estiver inválida (muito útil em produção).

---

## ✅ Conclusão

Usar `@ConfigurationProperties`:

* ✅ É a forma **mais limpa, segura e escalável** de configurar beans com propriedades externas.
* ✅ Permite organizar configurações relacionadas como objetos.
* ✅ Melhora a legibilidade, manutenção e testabilidade do código.

Se quiser, posso te mostrar como escrever **testes unitários para essa classe de configuração** ou como gerar **autocomplete para o `application.yml`** com o `spring-boot-configuration-processor`. Deseja isso?
