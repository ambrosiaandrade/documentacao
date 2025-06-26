# 🚦 Spring Actuator

O **Spring Boot Actuator** fornece **monitoramento e gerenciamento** da aplicação em tempo real, com endpoints que expõem métricas, saúde, informações e controle do sistema.

---

## 📚 Tabela de conteúdos

- [📦 Dependência Maven](#dependência-maven)
- [⚙️ Configuração básica para expor todos os endpoints](#configuração-básica-para-expor-todos-os-endpoints)
- [🖥️ Endpoints importantes disponíveis](#endpoints-importantes-disponíveis)
- [🔐 Segurança](#segurança)
- [📖 Referência extra](#referência-extra)

---

## 📦 Dependência Maven

Adicione no seu `pom.xml`:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

---

## ⚙️ Configuração básica para expor todos os endpoints

No arquivo `application.properties` ou `application.yml`:

```properties
management.endpoints.web.exposure.include=*
```

> Por padrão, somente alguns endpoints são expostos publicamente (ex: `health` e `info`). Essa configuração expõe todos.

---

## 🖥️ Endpoints importantes disponíveis

| Endpoint               | Descrição                                      |
| ---------------------- | ---------------------------------------------- |
| `/actuator/health`     | Estado de saúde da aplicação                   |
| `/actuator/metrics`    | Métricas detalhadas (jvm, cpu, memoria, etc.)  |
| `/actuator/info`       | Informações da aplicação (versão, build, etc.) |
| `/actuator/loggers`    | Controle dinâmico dos níveis de log            |
| `/actuator/env`        | Variáveis de ambiente e propriedades           |
| `/actuator/threaddump` | Dump das threads da JVM                        |

---

## 🔐 Segurança

Para proteger os endpoints, use o Spring Security e configure regras de acesso, pois expor todos os endpoints sem restrição pode ser um risco.

Exemplo para liberar apenas `/health` e `/info`:

```properties
management.endpoints.web.exposure.include=health,info
```

---

## 📖 Referência extra

* Blog com dicas detalhadas sobre Spring Actuator:
  [https://zup.com.br/blog/spring-actuator](https://zup.com.br/blog/spring-actuator)

---

Se quiser, posso ajudar com exemplos de configuração avançada, segurança ou integração com Prometheus/Grafana para monitoramento. Quer?
