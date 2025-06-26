# Maven e Gradle

* **[Maven](https://maven.apache.org/)**
* **[Gradle](https://docs.gradle.org/current/userguide/userguide.html)**

## 📚 Tabela de conteúdos

- [📦 Maven build e plugins](#maven-build-e-plugins)
  - [Plugin Spring Boot para construir JARs executáveis](#plugin-spring-boot-para-construir-jars-executáveis)
  - [Plugin do compilador Maven com processadores de anotação para Lombok e MapStruct](#plugin-do-compilador-maven-com-processadores-de-anotação-para-lombok-e-mapstruct)
  - [Carrega propriedades de dependência](#carrega-propriedades-de-dependência-podem-ser-removidas-se-não-forem-utilizadas)
  - [Executa testes unitários e configura o agente Java Mockito](#executa-testes-unitários-e-configura-o-agente-java-mockito-se-necessário)
  - [Plugin JaCoCo para medir a cobertura de código, mínimo de 80%](#plugin-jacoco-para-medir-a-cobertura-de-código-mínimo-de-80)
  - [Copia o relatório JaCoCo gerado para a pasta de recursos estáticos para acesso frontend](#copia-o-relatório-jacoco-gerado-para-a-pasta-de-recursos-estáticos-para-acesso-frontend)

## 📦 Maven build e plugins

A ordem apresentada a seguir é importante, especialmente na configuração do plugin que envolve Lombok e MapStruct.

### Plugin Spring Boot para construir JARs executáveis

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <version>${spring.boot.maven.plugin}</version>
    <executions>
        <execution>
            <goals>
                <goal>repackage</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### Plugin do compilador Maven com processadores de anotação para Lombok e MapStruct
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <configuration>
        <source>${java.version}</source>
        <target>${java.version}</target>
        <generatedSourcesDirectory>${project.build.directory}/generated-sources/annotations
        </generatedSourcesDirectory>
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
```

### Carrega propriedades de dependência (podem ser removidas se não forem utilizadas)
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-dependency-plugin</artifactId>
    <executions>
        <execution>
            <goals>
                <goal>properties</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```
### Executa testes unitários e configura o agente Java Mockito (se necessário)
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <configuration>
        <argLine>
            -javaagent:${settings.localRepository}/org/mockito/mockito-core/${mockito.version}/mockito-core-${mockito.version}.jar
        </argLine>
    </configuration>
</plugin>
```

### Plugin JaCoCo para medir a cobertura de código, mínimo de 80%
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>${jacoco.version}</version>
    <executions>
        <!-- Prepares the JaCoCo agent before running tests -->
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
            <configuration>
                <excludes>
                    <exclude>org/jcp/xml/**</exclude>
                    <exclude>com/sun/**</exclude>
                    <exclude>sun/*</exclude>
                    <exclude>java/*</exclude>
                    <exclude>jdk/*</exclude>
                    <exclude>javax/*</exclude>
                    <exclude>**/*Application.class</exclude>
                    <exclude>**/*$HibernateInstantiator.class</exclude>
                    <exclude>**/*$Proxy*.class</exclude>
                    <exclude>**/*$HibernateProxy*.class</exclude>
                    <exclude>**/*$EnhancerBySpringCGLIB*.class</exclude>
                </excludes>
            </configuration>
        </execution>

        <!-- Generates HTML report after running tests -->
        <execution>
            <id>report</id>
            <phase>verify</phase>
            <goals>
                <goal>report</goal>
            </goals>
            <configuration>
                <excludes>
                    <exclude>**/models/**</exclude>
                    <exclude>**/entities/**</exclude>
                    <exclude>**/enums/**</exclude>
                    <exclude>**/exceptions/**</exclude>
                    <exclude>**/interfaces/**</exclude>
                    <exclude>**/*Application.class</exclude>
                </excludes>
            </configuration>
        </execution>

        <!-- Enforces a minimum coverage threshold during build -->
        <execution>
            <id>check</id>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <rules>
                    <rule>
                        <element>BUNDLE</element>
                        <limits>
                            <limit>
                                <counter>INSTRUCTION</counter>
                                <value>COVEREDRATIO</value>
                                <minimum>0.80</minimum>
                            </limit>
                        </limits>
                    </rule>
                </rules>
                <excludes>
                    <exclude>**/models/**</exclude>
                    <exclude>**/entities/**</exclude>
                    <exclude>**/enums/**</exclude>
                    <exclude>**/exceptions/**</exclude>
                    <exclude>**/interfaces/**</exclude>
                    <exclude>**/*Application.class</exclude>
                </excludes>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### Copia o relatório JaCoCo gerado para a pasta de recursos estáticos para acesso frontend
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-resources-plugin</artifactId>
    <version>${maven.resources.plugin.version}</version>
    <executions>
        <execution>
            <id>copy-jacoco-report</id>
            <phase>prepare-package</phase>
            <goals>
                <goal>copy-resources</goal>
            </goals>
            <configuration>
                <outputDirectory>${project.basedir}/src/main/resources/static/jacoco</outputDirectory>
                <resources>
                    <resource>
                        <directory>${project.build.directory}/site/jacoco</directory>
                        <filtering>false</filtering>
                    </resource>
                </resources>
            </configuration>
        </execution>
    </executions>
</plugin>
```


