# Testes unitários

## 📚 Tabela de conteúdos
- [WebMvcTest com MockMvc](#webmvctest-com-mockmvc)
- [🧠 Service e Teste Unitário](#service-e-teste-unitário)
  - [🧱 Exemplo de Service](#exemplo-de-service)
  - [✅ Teste Unitário](#teste-unitário)
  - [Async](#async)
    - [Serviço async](#serviço-async)
    - [Teste async](#teste-async)
  - [Kafka](#kafka)
    - [Serviço kafka](#serviço-kafka)
    - [Teste kafka](#teste-kafka)
- [DataJpaTest](#datajpatest)
  - [Exemplo básico:](#exemplo-básico)
  - [Dicas:](#dicas)
- [🔬 `@DataJpaTest` vs `@Mock` de `Repository`](#datajpatest-vs-mock-de-repository)
- [🧪 Exemplos](#exemplos)
  - [1. Usando `@DataJpaTest` (teste real do repositório)](#1-usando-datajpatest-teste-real-do-repositório)
  - [2. Usando `@Mock` em um serviço que depende do repositório](#2-usando-mock-em-um-serviço-que-depende-do-repositório)
- [🧠 Qual escolher?](#qual-escolher)
  
-----

## WebMvcTest com MockMvc

```java
@WebMvcTest(MyController.class)
class MyControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private MyService service;

    @Test
    void addAnimal() throws Exception {
        when(service.saveAnimal(any())).thenReturn(new Animal());

        mockMvc.perform(
            MockMvcRequestBuilders.post("/animal")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "name": "Findus",
                        "birthday": "2020-01-01",
                        "animalType": "CAT"
                    }
                """)
        ).andExpect(status().isCreated());

        verify(service).saveAnimal(any());
    }

    @Test
    void getAnimalByType_shouldReturnAnimalListAndOkStatus() throws Exception {
        List<Animal> list = List.of(MockAnimal.generateAnimal(CAT));

        when(animalService.getAnimalsByType(CAT.name())).thenReturn(list);

        mockMvc.perform(
                        MockMvcRequestBuilders.get("/animal/q")
                                .param("type", "CAT")
                )
                .andDo(print())
                .andExpect(status().isOk());

        verify(animalService).getAnimalsByType(CAT.name());
    }

    @Test
    void deleteAnimalById_shouldNoContentStatus() throws Exception {
        doNothing().when(animalService).deleteAnimal(anyInt());

        mockMvc.perform(
                        MockMvcRequestBuilders.delete("/animal/{id}", 1)
                )
                .andDo(print())
                .andExpect(status().isNoContent());

        verify(animalService).deleteAnimal(anyInt());
    }
}
```

## 🧠 Service e Teste Unitário


### 🧱 Exemplo de Service

```java
@Service
@Slf4j
public class AnimalService {

    private final AnimalRepository animalRepository;
    private final IAnimalMapper animalMapper;

    public AnimalService(AnimalRepository animalRepository, IAnimalMapper mapper) {
        this.animalRepository = animalRepository;
        this.animalMapper = mapper;
    }

    public Animal saveAnimal(Animal animal) {
        try {
            handleEmptyFields(animal);
            AnimalEntity entity = animalMapper.toEntity(animal);
            var savedAnimal = animalRepository.save(entity);
            return animalMapper.toModel(savedAnimal);
        } catch (DataAccessException e) {
            throw new BaseException(e.getMessage(), 500);
        }
    }

    public void deleteAnimal(int id) {
        try {
            animalRepository.deleteById(id);
        } catch (DataAccessException e) {
            throw new BaseException(e.getMessage(), 500);
        }
    }
}
```

---

### ✅ Teste Unitário

```java
@ExtendWith(MockitoExtension.class)
class AnimalServiceTest {

    @Mock
    private AnimalRepository animalRepository;

    private IAnimalMapper mapper;

    @InjectMocks
    private AnimalService animalService;

    @BeforeEach
    void setUp() {
        mapper = Mappers.getMapper(IAnimalMapper.class);
        MockitoAnnotations.openMocks(this);
        animalService = new AnimalService(animalRepository, mapper);
    }

    @Test
    void saveAnimal_success() {
        var animals = MockAnimal.generateAnimals();

        for (Animal animal : animals) {
            AnimalEntity entity = mapper.toEntity(animal);
            entity.setId(1);
            when(animalRepository.save(entity)).thenReturn(entity);
            animal = mapper.toModel(entity);
            Animal result = animalService.saveAnimal(animal);
            assertNotNull(result);
            assertNotNull(result.getName());
            verify(animalRepository).save(entity);
        }
    }

    @Test
    void saveAnimal_dataAccessException() {
        Animal animal = MockAnimal.generateAnimal(DOG);
        AnimalEntity entity = mapper.toEntity(animal);

        when(animalRepository.save(entity)).thenThrow(new DataAccessException("DB error") {});
        assertThrows(BaseException.class, () -> animalService.saveAnimal(animal));
    }

    @Nested
    class DeleteAnimal {
        @Test
        @DisplayName("Delete animal - success")
        void deleteAnimal_success() {
            animalService.deleteAnimal(1);
            verify(animalRepository).deleteById(1);
        }

        @Test
        @DisplayName("Delete animal - error dataAccessException")
        void deleteAnimal_dataAccessException() {
            doThrow(new DataAccessException("Error") {})
                .when(animalRepository).deleteById(anyInt());

            assertThrows(BaseException.class, () -> animalService.deleteAnimal(1));
            verify(animalRepository).deleteById(1);
        }
    }
}
```
* `@Test`
    * Marca um método que será executado como um caso de teste.
    * Deve estar em uma classe de teste.
    * O método pode (e deve) ter asserções (assertEquals, assertThrows, etc.) para verificar o comportamento esperado.
* `@Nested`
    * Permite organizar testes relacionados em grupos internos (classes internas).
    * Facilita leitura e manutenção dos testes.
    * Útil para separar testes por cenários como: Create, Delete, Update, Error handling, etc.
* `@DisplayName`
    * Define um nome descritivo para o teste, exibido no relatório do JUnit.
    * Substitui o nome do método por uma descrição legível.
    * Torna o teste mais claro para quem lê os logs ou usa ferramentas de análise.

---

### Async

#### Serviço async
* Necessário usar `@EnableAsync` no Application.java

```java
@Service
public class AsyncService {
    
    @Async
    public CompletableFuture<String> success() {
        try {
            // Simulates a long task
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return CompletableFuture.failedFuture(e);
        }

        log.info("[runAsyncTask] Executed in thread: " + Thread.currentThread().getName());
        return CompletableFuture.completedFuture("Finished task!");
    }

    @Async
    public CompletableFuture<String> error() {
        return CompletableFuture.failedFuture(new RuntimeException("Async error!"));
    }

}
```

#### Teste async

```java
@ExtendWith(MockitoExtension.class)
class AsyncServiceTest {

    private final AsyncService asyncService = new AsyncService();

    @Test
    void runAsyncTask() throws Exception {
        CompletableFuture<String> future = asyncService.success();
        String result = future.get(); // Waits for completion
        assertEquals("Finished task!", result);
    }

    @Test
    void testThreadInterrupted() throws Exception {
        Thread.currentThread().interrupt(); // Force interruption

        CompletableFuture<String> future = asyncService.success();

        // Wait and assert
        ExecutionException thrown = assertThrows(ExecutionException.class, future::get);
        assertTrue(thrown.getCause() instanceof InterruptedException);

        // Reset the interrupt status so it doesn't affect other tests
        Thread.interrupted();
    }

    @Test
    void runAsyncTaskError() {
        CompletableFuture<String> future = asyncService.error();
        Exception exception = assertThrows(Exception.class, future::get);
        assertTrue(exception.getCause() instanceof RuntimeException);
        assertEquals("Async error!", exception.getCause().getMessage());
    }

    @Test
    void successCompletesSuccessfully() throws Exception {
        CompletableFuture<String> future = asyncService.success();
        assertTrue(future.isDone() || future.complete("Finished task!"));
        assertEquals("Finished task!", future.get());
    }

    @Test
    void errorCompletesExceptionally() {
        CompletableFuture<String> future = asyncService.error();
        assertTrue(future.isCompletedExceptionally());
    }

}
```

### Kafka
* Necessário usar `@EnableKafka` no Application.java

#### Serviço kafka
```java
@Slf4j
@Service
public class KafkaMessageService {

    private final KafkaTemplate<String, String> kafkaTemplate;

    @Value("${app.kafka.topic}")
    private String topic;

    public KafkaMessageService(KafkaTemplate<String, String> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendMessage(String message) {
        kafkaTemplate.send(topic, message);
        log.info("Mensagem enviada: {}", message);
    }

    @KafkaListener(topics = "${app.kafka.topic}", groupId = "grupo1")
    public void consume(String message) {
        log.info("Mensagem consumida: {}", message);
    }

    @RetryableTopic(
        attempts = "3",
        backoff = @Backoff(delay = 2000),
        topicSuffixingStrategy = TopicSuffixingStrategy.SUFFIX_WITH_INDEX_VALUE
    )
    @KafkaListener(topics = "${app.kafka.topic}", groupId = "grupo-retry")
    public void consumeWithRetry(String message) {
        log.info("[Kafka] Recebido: {}", message);

        if (message.contains("erro")) {
            throw new RuntimeException("Erro intencional para retry");
        }

        processMessage(message);
    }
}

```

#### Teste kafka
```java
@ExtendWith(MockitoExtension.class)
class KafkaMessageServiceTest {

    @Mock
    private KafkaTemplate<String, String> kafkaTemplate;

    @InjectMocks
    private KafkaMessageService kafkaMessageService;

    private static final String TOPIC = "test-topic";

    @BeforeEach
    void setup() throws Exception {
        Field topicField = KafkaMessageService.class.getDeclaredField("topic");
        topicField.setAccessible(true);
        topicField.set(kafkaMessageService, TOPIC);
    }

    @Test
    void testSendMessage_shouldCallKafkaTemplate() {
        String mensagem = "mensagem de teste";

        kafkaMessageService.sendMessage(mensagem);

        verify(kafkaTemplate).send(TOPIC, mensagem);
    }

    @Test
    void testConsume_shouldLogMessage() {
        // Como é void e só loga, pode testar se não lança exceções
        assertDoesNotThrow(() -> kafkaMessageService.consume("mensagem"));
    }

    @Test
    void testConsumeWithRetry_successfulMessage() {
        assertDoesNotThrow(() -> kafkaRetryService.consumeWithRetry("mensagem válida"));
    }

    @Test
    void testConsumeWithRetry_shouldThrowAndBeCaughtByKafka() {
        KafkaRetryService spyService = spy(kafkaRetryService);

        doThrow(new RuntimeException("falha intencional"))
            .when(spyService).processMessage("erro");

        assertThrows(RuntimeException.class, () -> spyService.consumeWithRetry("erro"));
    }
}

```

## DataJpaTest

`@DataJpaTest` é uma anotação fornecida pelo Spring Boot para facilitar testes com JPA. Ele configura apenas os componentes de persistência (repositories, datasource, JPA, etc), usando um banco em memória como H2.

### Exemplo básico:

```java
@DataJpaTest
class PersonRepositoryTest {

    @Autowired
    private PersonRepository personRepository;

    @Test
    void testSaveAndFind() {
        Person person = new Person();
        person.setName("Maria");

        personRepository.save(person);

        Optional<Person> found = personRepository.findById(person.getId());
        assertTrue(found.isPresent());
        assertEquals("Maria", found.get().getName());
    }
}
```

### Dicas:

* O Spring Boot automaticamente usa um banco H2 em memória para o teste.
* Use `@AutoConfigureTestDatabase(replace = NONE)` se quiser usar o banco real (não recomendado em testes unitários).
* `@TestEntityManager` pode ser injetado para interações mais diretas com o EntityManager (útil para verificar estados persistidos).
---

## 🔬 `@DataJpaTest` vs `@Mock` de `Repository`

A diferença entre usar `@DataJpaTest` e `@Mock` (ou `@MockBean`) para testar repositórios está no **nível de teste** e **objetivo** de cada abordagem.

| Característica                       | `@DataJpaTest`                                                                             | `@Mock` (`@MockBean`, `Mockito.mock()`)                                  |
| ------------------------------------ | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| Tipo de teste                        | **Teste de integração** com o banco de dados real (geralmente H2 em memória)               | **Teste unitário** sem interação com o banco de dados                    |
| Dependência de JPA                   | Sim, JPA/Hibernate são carregados                                                          | Não, é apenas um mock (simulado)                                         |
| Objetivo principal                   | Verificar o funcionamento **real** do repositório (queries, relacionamentos, persistência) | Verificar **interações** com o repositório (ex: se o método foi chamado) |
| Velocidade                           | Mais lento (acesso real ao banco em memória)                                               | Muito rápido (sem I/O, puro Java)                                        |
| Quando usar                          | Para testar regras de persistência, JPQL, joins, etc.                                      | Para testar serviços que **dependem** do repositório                     |
| Exemplo de framework                 | Usa Spring Boot Test, Spring Data JPA, H2                                                  | Usa Mockito ou Spring Boot Test com `@MockBean`                          |
| Garante integração correta com banco | ✅ Sim                                                                                      | ❌ Não, apenas simula chamadas                                            |

---

## 🧪 Exemplos

### 1. Usando `@DataJpaTest` (teste real do repositório)

```java
@DataJpaTest
class PersonRepositoryTest {

    @Autowired
    private PersonRepository repository;

    @Test
    void shouldSaveAndFindByName() {
        repository.save(new Person(null, "Alice"));
        List<Person> people = repository.findByName("Alice");
        assertEquals(1, people.size());
    }
}
```

✅ Testa a persistência real no banco (incluindo SQL gerado, mapeamentos e integridade de dados).

---

### 2. Usando `@Mock` em um serviço que depende do repositório

```java
@ExtendWith(MockitoExtension.class)
class PersonServiceTest {

    @Mock
    private PersonRepository repository;

    @InjectMocks
    private PersonService service;

    @Test
    void shouldReturnPeopleByName() {
        when(repository.findByName("Bob"))
            .thenReturn(List.of(new Person(1L, "Bob")));

        List<Person> result = service.findPeople("Bob");

        assertEquals(1, result.size());
        verify(repository).findByName("Bob");
    }
}
```

✅ Testa apenas a **lógica de negócio** do `PersonService`, sem interagir com o banco.

---

## 🧠 Qual escolher?

| Cenário                                                                                           | Recomendo usar...      |
| ------------------------------------------------------------------------------------------------- | ---------------------- |
| Você está desenvolvendo e quer garantir que o repositório está funcionando com a JPA corretamente | `@DataJpaTest`         |
| Você quer testar um `@Service` e isolar o comportamento sem precisar do banco de dados            | `@Mock` ou `@MockBean` |
| Quer validar se `@Query` funciona ou se relacionamentos estão configurados corretamente           | `@DataJpaTest`         |
| Quer simular exceções ou controlar o retorno de um repositório                                    | `@Mock`                |
