# Apache kafka

* **[Apache Kafka](https://kafka.apache.org/quickstart)**
* https://www.confluent.io/learn/spring-boot-kafka/

<!-- TODO colocar imagens, explicar termos -->

## 📚 Tabela de conteúdos

- [Dependência e configuração](#dependencia-e-configuração)
- [Produtor](#produtor)
- [Consumidor](#consumidor)
- [Tratamento de exceção](#tratamento-de-exceção)
- [Configuração](#configuração)

## Dependência e configuração
Arquivo ``pom.xml``
```java
<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```
Arquivo ``application.properties``
```sh
# Apache Kafka
spring.kafka.bootstrap-servers=host.docker.internal:9092
spring.kafka.admin.auto-create=true

## Consumer
spring.kafka.consumer.group-id=test-group
spring.kafka.consumer.auto-offset-reset=earliest
spring.kafka.consumer.key-deserializer=org.apache.kafka.common.serialization.StringDeserializer
spring.kafka.consumer.value-deserializer=org.apache.kafka.common.serialization.StringDeserializer

## Producer
spring.kafka.producer.key-serializer=org.apache.kafka.common.serialization.StringSerializer
spring.kafka.producer.value-serializer=org.apache.kafka.common.serialization.StringSerializer
app.kafka.topic=test-topic
```

* **bootstrap-servers** especifica qual o kafka broker(s) a aplicação vai se conectar
* **key-deserializer** converte a chave da mensagem recebida de byte[] para String
* **value-deserializer** converte a mensagem recebida de byte[] para String
* **group-id** define o grupo de consumidores, Kafka usa isso para rastrear o consumo
* **key-serializer** converte a chave da mensagem que será enviada de String para byte[]
* **value-serializer** converte a mensagem que será enviada de String para byte[]

## Produtor
```java
@Autowired
private KafkaTemplate<String, String> kafkaTemplate;

@Value("${app.kafka.topic}")
private String TOPIC;

public void sendMessage(String message) {
    kafkaTemplate.send(TOPIC, message)
            .thenAccept(result -> log.info("[Kafka] Message sent successfully: {}", message))
            .exceptionally(ex -> {
                log.error("[Kafka] Failed to send message: {}", message, ex);
                return null;
            });
}
```

## Consumidor
Com tratamento de erro
```java
@KafkaListener(
        topics = "${app.kafka.topic}",
        groupId = "${spring.kafka.consumer.group-id}",
        errorHandler = "kafkaErrorHandler")
public void consume(String message) {
    try {
        if (message.contains("error")) {
            throw new RuntimeException("Failed processing message");
        }
        processMessage(message);
        log.info("[Kafka_consume] Consumed: {}", message);
    } catch (Exception e) {
        log.error("[Kafka_consume] Failed to process message: {}", message, e);
    }
}
```

Com tratamento configuração para tentar ler novamente
```java
@RetryableTopic(
        attempts = "3",
        backoff = @Backoff(delay = 2000),
        topicSuffixingStrategy = TopicSuffixingStrategy.SUFFIX_WITH_INDEX_VALUE
)
@KafkaListener(
        topics = "${app.kafka.topic}",
        groupId = "${spring.kafka.consumer.group-id}")
public void consumeWithRetry(String message) {
    try {
        if (message.contains("retry")) {
            throw new RuntimeException("Temporary failure");
        }
        processMessage(message);
        log.info("[Kafka_consumeWithRetry] Consumed: {}", message);
    } catch (Exception e) {
        log.error("[Kafka_consumeWithRetry] Failed to process message: {}", message, e);
    }
}
```

Busca mensagens do tópico
```java

@Autowired
private ConsumerFactory<String, String> consumerFactory;

public List<String> fetchMessagesFromKafka(int maxMessages) {
    List<String> fetchedMessages = new java.util.ArrayList<>();
    KafkaConsumer<String, String> consumer = null;
    try {
        consumer = (KafkaConsumer<String, String>) consumerFactory.createConsumer();
        consumer.subscribe(java.util.Collections.singletonList(TOPIC));
        consumer.poll(java.time.Duration.ZERO); // força atribuição de partições

        int count = 0;
        while (count < maxMessages) {
            ConsumerRecords<String, String> records = consumer.poll(java.time.Duration.ofSeconds(2));
            for (ConsumerRecord<String, String> record : records) {
                fetchedMessages.add(record.value());
                count++;
                if (count >= maxMessages) break;
            }
            consumer.commitSync(); // commit offsets after processing
            if (records.isEmpty()) break;
        }
    } catch (Exception e) {
        log.error("[Kafka] Error fetching messages from Kafka", e);
    } finally {
        if (consumer != null) consumer.close();
    }
    return fetchedMessages;
}
```

## Tratamento de exceção
```java
public class KafkaErrorHandler {

    @Bean
    public ConsumerAwareListenerErrorHandler kafkaErrorHandler() {
        return (message, exception, consumer) -> {
            System.err.println("Error processing message: " + message.getPayload());
            return null; // You can log, send to DLQ, or handle accordingly
        };
    }

}
```

## Configuração
```java
@Configuration
public class KafkaConsumerConfig {
    
    @Value("${spring.kafka.bootstrap-servers}")
    private String bootstrapServers;

    @Value("${spring.kafka.consumer.group-id}")
    private String groupId;

    @Bean
    public ConsumerFactory<String, String> consumerFactory() {
        Map<String, Object> props = new HashMap<>();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        return new DefaultKafkaConsumerFactory<>(props);
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, String> kafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, String> factory = new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        return factory;
    }

}
```