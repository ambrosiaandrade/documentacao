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

