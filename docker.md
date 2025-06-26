# 🐳 Docker & Docker Compose

Este documento descreve como containerizar uma aplicação Spring Boot usando Docker, além de como utilizar Docker Compose para orquestrar múltiplos serviços, como banco de dados e Apache Kafka (em modo KRaft, sem Zookeeper).

---

## 📚 Tabela de conteúdos

- [📦 Requisitos](#requisitos)
- [🛠️ 1. Gerando o `.jar` da aplicação](#1-gerando-o-jar-da-aplicação)
- [🧾 2. Criando o `Dockerfile`](#2-criando-o-dockerfile)
- [▶️ 3. Construindo e executando com Docker](#3-construindo-e-executando-com-docker)
- [📄 4. Orquestração com Docker Compose](#4-orquestração-com-docker-compose)
  - [📂 Exemplo com Spring Boot + PostgreSQL](#exemplo-com-spring-boot-postgresql)
  - [📂 Exemplo com Kafka (modo KRaft) + Kafka UI](#exemplo-com-kafka-modo-kraft-kafka-ui)
- [▶️ 5. Rodando os containers](#5-rodando-os-containers)
  - [Aplicação + PostgreSQL:](#aplicação-postgresql)
  - [Kafka (modo KRaft):](#kafka-modo-kraft)
- [🧪 Testando a aplicação](#testando-a-aplicação)
- [🧪 Testando Kafka com CLI](#testando-kafka-com-cli)
  - [Produzir mensagem:](#produzir-mensagem)
  - [Consumir mensagens:](#consumir-mensagens)
- [🧹 Parando e limpando](#parando-e-limpando)
- [📌 Dicas úteis](#dicas-úteis)

----

## 📦 Requisitos

* [Docker](https://docs.docker.com/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/)
  (geralmente já incluído nas versões modernas do Docker Desktop)
* Projeto Spring Boot empacotado como `.jar`

---

## 🛠️ 1. Gerando o `.jar` da aplicação

Execute no terminal:

```bash
./mvnw clean package
```

O arquivo será gerado em:
`target/nome-da-aplicacao.jar`

---

## 🧾 2. Criando o `Dockerfile`

Crie um arquivo chamado `Dockerfile` na raiz do projeto com o conteúdo:

```dockerfile
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

> 💡 Altere a imagem base (`eclipse-temurin:17-jdk-alpine`) conforme a versão do Java usada no projeto.

---

## ▶️ 3. Construindo e executando com Docker

```bash
# Build da imagem
docker build -t minha-app .

# Executar container
docker run -p 8080:8080 minha-app
```

Acesse: `http://localhost:8080`

---

## 📄 4. Orquestração com Docker Compose

### 📂 Exemplo com Spring Boot + PostgreSQL

`docker-compose.yml`

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - db
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/meubanco
      SPRING_DATASOURCE_USERNAME: postgres
      SPRING_DATASOURCE_PASSWORD: postgres
      SPRING_JPA_HIBERNATE_DDL_AUTO: update

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: meubanco
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

---

### 📂 Exemplo com Kafka (modo KRaft) + Kafka UI

`docker-compose.kafka.yml`

```yaml
version: '3.8'

services:
  kafka:
    image: confluentinc/cp-kafka:latest
    container_name: kafka
    hostname: kafka
    ports:
      - "9092:9092"
      - "9093:9093"
    environment:
      KAFKA_KRAFT_MODE: "true"
      KAFKA_PROCESS_ROLES: "broker,controller"
      KAFKA_NODE_ID: 1
      KAFKA_CONTROLLER_QUORUM_VOTERS: "1@kafka:9093"
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:29092,PLAINTEXT_HOST://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT,CONTROLLER:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_CONTROLLER_LISTENER_NAMES: CONTROLLER
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://host.docker.internal:9092
      KAFKA_LOG_DIRS: /var/lib/kafka/data
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_LOG_RETENTION_HOURS: 168
      KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
      CLUSTER_ID: "Mk3OEYBSD34fcwNTJENDM2Qk"
    volumes:
      - kafka-data:/var/lib/kafka/data
    networks:
      - kafka-net

  kafbat-ui:
    image: ghcr.io/kafbat/kafka-ui:latest
    container_name: kafbat-ui
    ports:
      - "8081:8080"
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:29092
      KAFKA_CLUSTERS_0_PROPERTIES_SECURITY_PROTOCOL: PLAINTEXT
    networks:
      - kafka-net

volumes:
  kafka-data:

networks:
  kafka-net:
    driver: bridge
```

---

## ▶️ 5. Rodando os containers

### Aplicação + PostgreSQL:

```bash
docker-compose up --build
```

### Kafka (modo KRaft):

```bash
docker-compose -f docker-compose.kafka.yml up --build
```

---

## 🧪 Testando a aplicação

Se estiver usando Springdoc (Swagger):

```
http://localhost:8080/swagger-ui.html
```

---

## 🧪 Testando Kafka com CLI

### Produzir mensagem:

```bash
docker exec -it kafka kafka-console-producer \
  --bootstrap-server kafka:29092 \
  --topic meu-topico
```

### Consumir mensagens:

```bash
docker exec -it kafka kafka-console-consumer \
  --bootstrap-server kafka:29092 \
  --topic meu-topico \
  --from-beginning
```

---

## 🧹 Parando e limpando

```bash
docker-compose down --volumes
docker image rm minha-app
docker-compose -f docker-compose.kafka.yml down --volumes
```

---

## 📌 Dicas úteis

* Acesse o Kafka UI em: `http://localhost:8081`
* Configuração Kafka no Spring Boot (`application.properties`):

```properties
spring.kafka.bootstrap-servers=localhost:9092
spring.kafka.consumer.group-id=app-group
spring.kafka.consumer.auto-offset-reset=earliest
```

* Arquivo `.dockerignore`:

```dockerignore
target/
.git
.idea
*.iml
Dockerfile
docker-compose*.yml
```

* Logs em tempo real:

```bash
docker-compose logs -f app
```

* Acessar o PostgreSQL via terminal:

```bash
docker exec -it <nome_do_container_db> psql -U postgres -d meubanco
```