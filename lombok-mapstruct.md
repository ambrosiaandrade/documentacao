# Lombok e MapStruct

* **[Lombok](https://projectlombok.org/)**: Elimina boilerplate como getters, setters, constructors etc.
* **[MapStruct](https://mapstruct.org/)**: Facilita o mapeamento entre objetos (ex: DTO ↔ Entity)

---

## 📚 Tabela de conteúdos

- [Configuração](#configuração)
- [Lombok](#lombok)
- [Mapper](#mapper)

---

## Configuração 
No arquivo `pom.xml`

```xml
<properties>
    <lombok.version>1.18.30</lombok.version>
    <mapstruct.version>1.5.5.Final</mapstruct.version>
</properties>

<dependencies>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>${lombok.version}</version>
    </dependency>
    <dependency>
        <groupId>org.mapstruct</groupId>
        <artifactId>mapstruct</artifactId>
        <version>${mapstruct.version}</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <source>${java.version}</source>
                <target>${java.version}</target>
                <annotationProcessorPaths>
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                        <version>${lombok.version}</version>
                    </path>
                    <path>
                        <groupId>org.mapstruct</groupId>
                        <artifactId>mapstruct-processor</artifactId>
                        <version>${mapstruct.version}</version>
                    </path>
                </annotationProcessorPaths>
            </configuration>
        </plugin>
    </plugins>
</build>
```

---

## Lombok

```java
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Animal {
    private Long id;
    private String nome;
    private String especie;
}
```
* **@Data**: Gera getters, setters, equals(), hashCode() e toString().
* **@Builder**: Permite usar o padrão Builder.
* **@NoArgsConstructor / @AllArgsConstructor**: Gera construtores sem argumentos e com todos os argumentos.

```java
@Entity
@Getter
@Setter
public class AnimalEntity {
    @Id
    private Long id;
    private String nome;
    private String especie;
}
```
Cautela ao usar Lombok junto com JPA — evite @Data em entidades para não ter problemas com equals() e hashCode() em coleções ou proxys do Hibernate.

## Mapper

```java
@Mapper(componentModel = "spring")
public interface IAnimalMapper {

    IAnimalMapper INSTANCE = Mappers.getMapper(IAnimalMapper.class);

    AnimalEntity toEntity(Animal animal);
    Animal toModel(AnimalEntity animalEntity);
}
```
* **@Mapper(componentModel = "spring")** Vai garantir que a classe gerada vai ser tratada como um bean do Spring, possibilitando que o String faça a injeção de dependência em outros componentes, como serviço ou controller, usando por exemplo o `@Autowired`.
* **@Mapping** para campos com nomes diferentes.
```java
@Mapping(source = "nomeCompleto", target = "nome")
UsuarioEntity toEntity(Usuario usuario);

@Mapping(source = "nome", target = "nomeCompleto")
Usuario toModel(UsuarioEntity usuarioEntity);
```
* **@MapperConfig** é uma anotação usada para definir configurações globais de mapeamento. Pode conter:
    * Estratégias de naming,
    * Estratégias de mapeamento de coleções ou nulls,
    * Classes auxiliares (como conversores),
    * Qualquer configuração que você repetiria em vários mappers.
```java
import org.mapstruct.MapperConfig;
import org.mapstruct.ReportingPolicy;
import org.mapstruct.NullValueMappingStrategy;

@MapperConfig(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueMappingStrategy = NullValueMappingStrategy.RETURN_DEFAULT
)
public interface CentralMapperConfig {
}
```
* **componentModel** = "spring": todos os mappers que usarem esse config serão beans do Spring.
* **unmappedTargetPolicy** = ReportingPolicy.IGNORE: ignora warnings de campos não mapeados.
* **nullValueMappingStrategy** = RETURN_DEFAULT: em vez de retornar null, retorna um valor padrão (ex: lista vazia).

Agora configuraria o mapper com essa configuração personalizada
```java
@Mapper(config = CentralMapperConfig.class)
public interface IAnimalMapper {

    AnimalEntity toEntity(Animal animal);
    Animal toModel(AnimalEntity entity);
}
```
----

## 🧠 Por que `INSTANCE = Mappers.getMapper(...)` conflita com `@Mapper(componentModel = "spring")`?

### ✅ O que `@Mapper(componentModel = "spring")` faz?

Essa anotação diz ao **MapStruct** para gerar um **bean gerenciado pelo Spring** da sua interface mapper.

Ou seja, ele vai gerar uma classe `IAnimalMapperImpl` e anotá-la com `@Component`, permitindo que você injete ela com Spring, assim:

```java
@Autowired
private IAnimalMapper mapper;
```

ou via construtor, como você fez (o ideal).

---

### ⚠️ O que o `INSTANCE = Mappers.getMapper(IAnimalMapper.class)` faz?

Essa linha é usada **quando você NÃO está usando Spring**.

```java
IAnimalMapper mapper = Mappers.getMapper(IAnimalMapper.class);
```

O `Mappers.getMapper()` é um **mecanismo de fallback** do MapStruct que **instancia o mapper diretamente**, fora do controle do Spring (sem injeção de dependência, sem AOP, sem ciclo de vida do Spring).

---

### ⚠️ Por que é um conflito?

Porque são **duas formas diferentes e excludentes de obter o mapper**:

| Forma                                | Quem controla a instância? | Injeção via `@Autowired`? |
| ------------------------------------ | -------------------------- | ------------------------- |
| `Mappers.getMapper()`                | MapStruct (manual)         | ❌ Não                     |
| `@Mapper(componentModel = "spring")` | Spring                     | ✅ Sim                     |

Quando você declara isso na interface:

```java
@Mapper(componentModel = "spring")
public interface IAnimalMapper {
    IAnimalMapper INSTANCE = Mappers.getMapper(IAnimalMapper.class);
}
```

Você está, na prática, **misturando os dois mundos**:

* Dizendo ao Spring: "gere um bean para mim".
* Mas também dizendo ao MapStruct: "me dá uma instância manual agora".

⚠️ Isso pode causar:

* Ambiguidade.
* O Spring **não consegue injetar** o bean (porque `INSTANCE` é estático e direto).
* Em testes ou contextos paralelos, pode criar bugs difíceis de rastrear.

---

### ✅ Conclusão: escolha **uma abordagem só**

* Se você **usa Spring** (e está usando), **não use o `INSTANCE = Mappers.getMapper(...)`**.
* Apenas injete o mapper normalmente via `@Autowired` ou construtor.

---

### Exemplo final e correto:

```java
@Mapper(componentModel = "spring")
public interface IAnimalMapper {
    AnimalEntity toEntity(Animal animal);
    Animal toModel(AnimalEntity animalEntity);
}
```

E no service:

```java
@Service
public class AnimalService {
    private final AnimalRepository animalRepository;
    private final IAnimalMapper animalMapper;

    public AnimalService(AnimalRepository repo, IAnimalMapper mapper) {
        this.animalRepository = repo;
        this.animalMapper = mapper;
    }
}
```

Tudo controlado 100% pelo Spring. Simples, limpo, profissional. ✅
