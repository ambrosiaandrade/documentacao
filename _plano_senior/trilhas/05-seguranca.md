# Trilha de Segurança - Exercícios Práticos

**Objetivo:** Dominar técnicas de **testes de segurança** para identificar e prevenir vulnerabilidades como **SQL Injection**, **autenticação fraca**, **exposição de secrets** e **dependências vulneráveis**.

**Nível:** Avançado → Senior  
**Tempo Estimado:** 8-10 horas  
**Pré-requisitos:** Spring Security, OAuth2, JWT, conhecimento de OWASP Top 10

---

## 🛡️ Exercício 1: Prevenção de SQL Injection

### 🎯 Objetivo

Identificar e corrigir vulnerabilidades de **SQL Injection** usando **PreparedStatement** e **testes de segurança**.

### 📖 Contexto

Atacante pode manipular queries SQL para extrair dados sensíveis, deletar dados ou executar comandos arbitrários.

### 🛠️ Passos

#### 1. Reproduzir SQL Injection

```java
// ❌ VULNERÁVEL: String concatenation
@RestController
public class UserController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/users/search")
    public List<User> searchUsers(@RequestParam String name) {
        // SQL Injection vulnerability
        String sql = "SELECT * FROM users WHERE name = '" + name + "'";
        return jdbcTemplate.query(sql, new UserRowMapper());
    }
}
```

**Ataque:**

```bash
# Ataque 1: Bypass authentication
curl "http://localhost:8080/users/search?name=' OR '1'='1"

# Query executada:
# SELECT * FROM users WHERE name = '' OR '1'='1'
# Retorna TODOS os usuários

# Ataque 2: Union-based injection
curl "http://localhost:8080/users/search?name=' UNION SELECT id, username, password FROM admin_users --"

# Ataque 3: Time-based blind injection
curl "http://localhost:8080/users/search?name=' OR SLEEP(5) --"
```

#### 2. Corrigir com PreparedStatement

```java
// ✅ SEGURO: PreparedStatement
@RestController
public class UserController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/users/search")
    public List<User> searchUsers(@RequestParam String name) {
        // Usar ? placeholder (parametrização)
        String sql = "SELECT * FROM users WHERE name = ?";
        return jdbcTemplate.query(sql, new UserRowMapper(), name);
    }
}
```

#### 3. Usar JPA com Query Methods

```java
// ✅ SEGURO: Spring Data JPA
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    // Query derivada (segura)
    List<User> findByNameContaining(String name);

    // @Query com parâmetros nomeados (segura)
    @Query("SELECT u FROM User u WHERE u.name = :name")
    List<User> findByName(@Param("name") String name);

    // ❌ VULNERÁVEL: Query nativa sem parâmetros
    @Query(value = "SELECT * FROM users WHERE name = '" + "?1" + "'", nativeQuery = true)
    List<User> findByNameUnsafe(String name);

    // ✅ SEGURO: Query nativa com parâmetros
    @Query(value = "SELECT * FROM users WHERE name = ?1", nativeQuery = true)
    List<User> findByNameSafe(String name);
}
```

#### 4. Testar SQL Injection

```java
@SpringBootTest
@AutoConfigureMockMvc
class SqlInjectionTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
        userRepository.save(new User("Alice", "alice@example.com"));
        userRepository.save(new User("Bob", "bob@example.com"));
    }

    @Test
    void shouldPreventSqlInjection_withOrClause() throws Exception {
        // Arrange - Ataque: ' OR '1'='1
        String maliciousInput = "' OR '1'='1";

        // Act
        MvcResult result = mockMvc.perform(get("/users/search")
                .param("name", maliciousInput))
            .andExpect(status().isOk())
            .andReturn();

        // Assert - Não deve retornar TODOS os usuários
        String response = result.getResponse().getContentAsString();
        List<User> users = objectMapper.readValue(response, new TypeReference<>() {});

        // Com PreparedStatement, busca literal "' OR '1'='1" (sem match)
        assertThat(users).isEmpty();
    }

    @Test
    void shouldPreventSqlInjection_withUnionAttack() throws Exception {
        // Arrange - Ataque: ' UNION SELECT * FROM admin_users --
        String maliciousInput = "' UNION SELECT id, username, password FROM admin_users --";

        // Act
        MvcResult result = mockMvc.perform(get("/users/search")
                .param("name", maliciousInput))
            .andExpect(status().isOk())
            .andReturn();

        // Assert - Não deve executar UNION
        String response = result.getResponse().getContentAsString();
        assertThat(response).doesNotContain("admin_users");
    }

    @Test
    void shouldSanitizeInput_beforeQuery() {
        // Arrange
        String input = "<script>alert('xss')</script>"; // XSS attempt

        // Act
        String sanitized = HtmlUtils.htmlEscape(input);

        // Assert
        assertThat(sanitized).isEqualTo("&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;");
    }

    @Test
    void shouldValidateInput_withPattern() {
        // Arrange
        String validName = "Alice123";
        String invalidName = "'; DROP TABLE users; --";

        // Pattern: apenas letras e números
        Pattern pattern = Pattern.compile("^[a-zA-Z0-9]+$");

        // Assert
        assertThat(pattern.matcher(validName).matches()).isTrue();
        assertThat(pattern.matcher(invalidName).matches()).isFalse();
    }
}
```

#### 5. Usar OWASP Java Encoder

```xml
<dependency>
    <groupId>org.owasp.encoder</groupId>
    <artifactId>encoder</artifactId>
    <version>1.2.3</version>
</dependency>
```

```java
import org.owasp.encoder.Encode;

@Service
public class SafeQueryService {

    public String buildSafeQuery(String userInput) {
        // Escapar para contexto SQL
        String safe = Encode.forSql(userInput);

        // Usar PreparedStatement é sempre preferível
        String sql = "SELECT * FROM users WHERE name = ?";
        return jdbcTemplate.query(sql, new UserRowMapper(), safe);
    }
}
```

### ✅ Critério de Sucesso

- ✅ Todas as queries usam PreparedStatement ou JPA
- ✅ Nenhuma concatenação de strings em SQL
- ✅ Input validation com regex/pattern
- ✅ Testes automatizados para SQL injection
- ✅ Code review checklist para SQL injection

### ⚠️ Pitfalls

- ❌ **Escapar manualmente:** Usar PreparedStatement, não regex
- ❌ **Native queries sem parâmetros:** Vulnerável
- ❌ **Confiar no input do usuário:** Sempre validar
- ❌ **Esquecer ORDER BY/LIMIT:** Também podem ser injetados

### 🚀 Extensão

1. **OWASP ZAP:** Scan automatizado de vulnerabilidades
2. **SQLMap:** Ferramenta de penetration testing
3. **Database permissions:** Limitar permissões do user da aplicação

---

## 🔐 Exercício 2: Testes de Autenticação JWT/OAuth2

### 🎯 Objetivo

Implementar e testar **autenticação segura** com **JWT** e **OAuth2**, validando tokens, expiração e autorização.

### 📖 Contexto

API REST expõe endpoints sensíveis. Você precisa garantir que apenas usuários autenticados com permissões corretas acessem recursos.

### 🛠️ Passos

#### 1. Configurar Spring Security com JWT

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .requestMatchers("/api/orders/**").hasAnyRole("USER", "ADMIN")
                .anyRequest().authenticated()
            )
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .addFilterBefore(jwtAuthenticationFilter(),
                UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter();
    }
}
```

#### 2. Criar JWT Token Service

```java
@Service
public class JwtTokenService {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration:3600000}") // 1 hora
    private long expiration;

    public String generateToken(Authentication authentication) {
        UserDetails user = (UserDetails) authentication.getPrincipal();

        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);

        return Jwts.builder()
            .setSubject(user.getUsername())
            .claim("roles", user.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .collect(Collectors.toList()))
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(SignatureAlgorithm.HS512, secret)
            .compact();
    }

    public String getUsernameFromToken(String token) {
        Claims claims = Jwts.parser()
            .setSigningKey(secret)
            .parseClaimsJws(token)
            .getBody();

        return claims.getSubject();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().setSigningKey(secret).parseClaimsJws(token);
            return true;
        } catch (SignatureException e) {
            log.error("Invalid JWT signature");
        } catch (ExpiredJwtException e) {
            log.error("Expired JWT token");
        } catch (Exception e) {
            log.error("Invalid JWT token");
        }
        return false;
    }
}
```

#### 3. Implementar JWT Filter

```java
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtTokenService tokenService;

    @Autowired
    private UserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        try {
            String token = extractToken(request);

            if (token != null && tokenService.validateToken(token)) {
                String username = tokenService.getUsernameFromToken(token);
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.getAuthorities()
                    );

                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            log.error("Cannot set user authentication", e);
        }

        filterChain.doFilter(request, response);
    }

    private String extractToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
```

#### 4. Testar Autenticação JWT

```java
@SpringBootTest
@AutoConfigureMockMvc
class JwtAuthenticationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtTokenService tokenService;

    @Test
    void shouldRejectRequest_withoutToken() throws Exception {
        // Act & Assert
        mockMvc.perform(get("/api/orders"))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void shouldAcceptRequest_withValidToken() throws Exception {
        // Arrange
        String token = createTokenForUser("alice", "USER");

        // Act & Assert
        mockMvc.perform(get("/api/orders")
                .header("Authorization", "Bearer " + token))
            .andExpect(status().isOk());
    }

    @Test
    void shouldRejectRequest_withExpiredToken() throws Exception {
        // Arrange - Token expirado
        String expiredToken = createExpiredToken("alice");

        // Act & Assert
        mockMvc.perform(get("/api/orders")
                .header("Authorization", "Bearer " + expiredToken))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void shouldRejectRequest_withInvalidSignature() throws Exception {
        // Arrange - Token com signature inválida
        String token = createTokenForUser("alice", "USER");
        String tamperedToken = token + "tampered";

        // Act & Assert
        mockMvc.perform(get("/api/orders")
                .header("Authorization", "Bearer " + tamperedToken))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void shouldEnforceRoleBasedAccess() throws Exception {
        // Arrange
        String userToken = createTokenForUser("alice", "USER");
        String adminToken = createTokenForUser("admin", "ADMIN");

        // Act & Assert - USER não pode acessar /api/admin
        mockMvc.perform(get("/api/admin/users")
                .header("Authorization", "Bearer " + userToken))
            .andExpect(status().isForbidden());

        // ADMIN pode acessar
        mockMvc.perform(get("/api/admin/users")
                .header("Authorization", "Bearer " + adminToken))
            .andExpect(status().isOk());
    }

    @Test
    void shouldPreventTokenReplay_afterLogout() {
        // Arrange
        String token = createTokenForUser("alice", "USER");

        // Act - Logout (invalidar token)
        tokenBlacklist.add(token);

        // Assert - Token não deve mais funcionar
        boolean valid = tokenService.validateToken(token) && !tokenBlacklist.contains(token);
        assertThat(valid).isFalse();
    }

    private String createTokenForUser(String username, String... roles) {
        List<GrantedAuthority> authorities = Arrays.stream(roles)
            .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
            .collect(Collectors.toList());

        Authentication auth = new UsernamePasswordAuthenticationToken(
            new User(username, "password", authorities),
            null,
            authorities
        );

        return tokenService.generateToken(auth);
    }

    private String createExpiredToken(String username) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() - 1000); // Expirou há 1s

        return Jwts.builder()
            .setSubject(username)
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(SignatureAlgorithm.HS512, "test-secret")
            .compact();
    }
}
```

#### 5. Testar OAuth2 Integration

```java
@SpringBootTest
class OAuth2Test {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockUser(username = "alice", roles = {"USER"})
    void shouldAccessProtectedResource_withOAuth2() throws Exception {
        mockMvc.perform(get("/api/orders"))
            .andExpect(status().isOk());
    }

    @Test
    void shouldRedirectToLogin_whenUnauthenticated() throws Exception {
        mockMvc.perform(get("/api/orders"))
            .andExpect(status().is3xxRedirection())
            .andExpect(redirectedUrlPattern("**/oauth2/authorization/**"));
    }
}
```

### ✅ Critério de Sucesso

- ✅ JWT gerado com expiration time
- ✅ Token validado em cada requisição
- ✅ Tokens expirados rejeitados
- ✅ Signature inválida detectada
- ✅ Role-based access control funciona
- ✅ Logout invalida token (blacklist)

### ⚠️ Pitfalls

- ❌ **Secret hardcoded:** Usar variáveis de ambiente
- ❌ **Token sem expiration:** Tokens nunca expiram
- ❌ **Algoritmo fraco:** Usar HS512 ou RS256
- ❌ **Não validar claims:** Aceitar qualquer token

### 🚀 Extensão

1. **Refresh tokens:** Renovar token sem reautenticar
2. **Token rotation:** Trocar secret periodicamente
3. **Multi-factor authentication (MFA):** TOTP com Google Authenticator

---

## 🔑 Exercício 3: Secrets Management com Vault

### 🎯 Objetivo

Gerenciar **secrets** (senhas, API keys, tokens) de forma segura usando **HashiCorp Vault** ou **Spring Cloud Config**.

### 📖 Contexto

Secrets hardcoded no código ou properties são facilmente expostos em repositórios Git.

### 🛠️ Passos

#### 1. Configurar Vault com Docker

```yaml
# docker-compose.yml
version: "3.8"
services:
  vault:
    image: vault:1.15
    ports:
      - "8200:8200"
    environment:
      VAULT_DEV_ROOT_TOKEN_ID: root-token
      VAULT_DEV_LISTEN_ADDRESS: 0.0.0.0:8200
    cap_add:
      - IPC_LOCK
```

```bash
# Inicializar Vault
docker-compose up -d vault

# Autenticar
export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN='root-token'

# Armazenar secrets
vault kv put secret/order-service \
    database.password=my-secret-password \
    api.key=sk-1234567890abcdef
```

#### 2. Integrar Spring Boot com Vault

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-vault-config</artifactId>
</dependency>
```

```yaml
# bootstrap.yml
spring:
  application:
    name: order-service
  cloud:
    vault:
      uri: http://localhost:8200
      token: root-token
      kv:
        enabled: true
        backend: secret
```

```java
@Configuration
@ConfigurationProperties(prefix = "database")
public class DatabaseConfig {

    private String password; // Injetado do Vault

    @Bean
    public DataSource dataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:postgresql://localhost:5432/orders");
        config.setUsername("postgres");
        config.setPassword(password); // Secret do Vault
        return new HikariDataSource(config);
    }
}
```

#### 3. Evitar Secrets em Código

```java
// ❌ ERRADO: Hardcoded
@Service
public class PaymentService {
    private static final String API_KEY = "sk-1234567890abcdef";

    public void processPayment() {
        restTemplate.getForObject(
            "https://api.payment.com/charge?api_key=" + API_KEY,
            String.class
        );
    }
}

// ✅ CORRETO: Injetar do Vault
@Service
public class PaymentService {

    @Value("${api.key}")
    private String apiKey;

    public void processPayment() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + apiKey);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        restTemplate.exchange(
            "https://api.payment.com/charge",
            HttpMethod.POST,
            entity,
            String.class
        );
    }
}
```

#### 4. Usar Environment Variables

```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST:localhost}:5432/orders
    username: ${DB_USER:postgres}
    password: ${DB_PASSWORD} # OBRIGATÓRIO via env var
```

```bash
# Executar com env vars
export DB_PASSWORD=my-secret-password
java -jar order-service.jar

# Ou via Docker
docker run -e DB_PASSWORD=my-secret-password order-service
```

#### 5. Testar Secrets Management

```java
@SpringBootTest
class SecretsTest {

    @Value("${database.password}")
    private String databasePassword;

    @Test
    void shouldLoadSecretFromVault() {
        // Assert - Secret carregado do Vault
        assertThat(databasePassword).isNotNull();
        assertThat(databasePassword).isNotEmpty();
        assertThat(databasePassword).isNotEqualTo("changeme");
    }

    @Test
    void shouldNotLogSecrets() {
        // Arrange
        Logger logger = (Logger) LoggerFactory.getLogger(PaymentService.class);
        ListAppender<ILoggingEvent> listAppender = new ListAppender<>();
        listAppender.start();
        logger.addAppender(listAppender);

        // Act
        paymentService.processPayment();

        // Assert - Secret não deve aparecer nos logs
        List<ILoggingEvent> logs = listAppender.list;
        logs.forEach(log -> {
            assertThat(log.getFormattedMessage()).doesNotContain("sk-1234567890abcdef");
        });
    }

    @Test
    void shouldRotateSecrets() {
        // Arrange
        String oldPassword = databasePassword;

        // Act - Rotacionar secret no Vault
        vaultTemplate.write("secret/order-service",
            Map.of("database.password", "new-rotated-password"));

        // Refresh context
        context.refresh();

        // Assert
        assertThat(databasePassword).isNotEqualTo(oldPassword);
    }
}
```

#### 6. Encrypted Properties (Alternativa ao Vault)

```xml
<dependency>
    <groupId>com.github.ulisesbocchio</groupId>
    <artifactId>jasypt-spring-boot-starter</artifactId>
    <version>3.0.5</version>
</dependency>
```

```yaml
# application.yml
spring:
  datasource:
    password: ENC(encrypted-value-here)

jasypt:
  encryptor:
    password: ${JASYPT_ENCRYPTOR_PASSWORD}
```

```bash
# Encriptar valor
java -cp jasypt-1.9.3.jar org.jasypt.intf.cli.JasyptPBEStringEncryptionCLI \
    input="my-secret-password" \
    password="master-key" \
    algorithm=PBEWithMD5AndDES

# Output: ENC(5F4DCC3B5AA765D61D8327DEB882CF99)
```

### ✅ Critério de Sucesso

- ✅ Nenhum secret hardcoded no código
- ✅ Secrets carregados de Vault ou env vars
- ✅ Secrets não aparecem em logs
- ✅ Rotation de secrets testada
- ✅ Git history sem secrets expostos

### ⚠️ Pitfalls

- ❌ **Secrets no Git:** Usar .gitignore para application-local.yml
- ❌ **Secrets em logs:** Não logar variáveis sensíveis
- ❌ **Secrets em exception messages:** Filtrar stack traces
- ❌ **Sem rotation:** Secrets nunca são trocados

### 🚀 Extensão

1. **AWS Secrets Manager:** Alternativa ao Vault na AWS
2. **Sealed Secrets:** Para Kubernetes
3. **Secret scanning:** Usar GitGuardian ou TruffleHog

---

## 🔍 Exercício 4: OWASP Top 10 Testing

### 🎯 Objetivo

Testar aplicação contra as **OWASP Top 10 vulnerabilidades** mais críticas.

### 📖 Contexto

OWASP Top 10 lista as vulnerabilidades web mais comuns e perigosas.

### 🛠️ Passos

#### 1. OWASP Top 10 (2021)

| #   | Vulnerabilidade              | Descrição                            | Teste                        |
| --- | ---------------------------- | ------------------------------------ | ---------------------------- |
| A01 | Broken Access Control        | Usuário acessa recurso sem permissão | Testar bypass de autorização |
| A02 | Cryptographic Failures       | Dados sensíveis não encriptados      | Verificar HTTPS, bcrypt      |
| A03 | Injection                    | SQL/Command/LDAP injection           | Testar inputs maliciosos     |
| A04 | Insecure Design              | Falta de controles de segurança      | Code review                  |
| A05 | Security Misconfiguration    | Configs default inseguras            | Scan com OWASP ZAP           |
| A06 | Vulnerable Components        | Dependências desatualizadas          | Dependency-Check             |
| A07 | Identification/Auth Failures | Autenticação fraca                   | Testar brute force           |
| A08 | Software/Data Integrity      | Falta de validação de integridade    | Testar deserialization       |
| A09 | Logging/Monitoring Failures  | Logs insuficientes                   | Verificar auditoria          |
| A10 | Server-Side Request Forgery  | SSRF attacks                         | Testar URL injection         |

#### 2. Testar A01: Broken Access Control

```java
@Test
void shouldPreventHorizontalPrivilegeEscalation() throws Exception {
    // Arrange
    String aliceToken = createTokenForUser("alice");
    String bobOrderId = "ORDER-BOB-123";

    // Act & Assert - Alice não pode acessar pedido do Bob
    mockMvc.perform(get("/api/orders/" + bobOrderId)
            .header("Authorization", "Bearer " + aliceToken))
        .andExpect(status().isForbidden());
}

@Test
void shouldPreventVerticalPrivilegeEscalation() throws Exception {
    // Arrange
    String userToken = createTokenForUser("alice", "USER");

    // Act & Assert - USER não pode acessar endpoint de ADMIN
    mockMvc.perform(delete("/api/admin/users/123")
            .header("Authorization", "Bearer " + userToken))
        .andExpect(status().isForbidden());
}

// ✅ Implementar verificação
@GetMapping("/api/orders/{orderId}")
public Order getOrder(@PathVariable String orderId, Authentication auth) {
    Order order = orderRepository.findById(orderId).orElseThrow();

    // Verificar ownership
    String username = auth.getName();
    if (!order.getCustomer().getUsername().equals(username)) {
        throw new AccessDeniedException("Not your order");
    }

    return order;
}
```

#### 3. Testar A02: Cryptographic Failures

```java
@Test
void shouldHashPasswords_withBcrypt() {
    // Arrange
    String plainPassword = "myPassword123";

    // Act
    String hashed = passwordEncoder.encode(plainPassword);

    // Assert
    assertThat(hashed).isNotEqualTo(plainPassword);
    assertThat(hashed).startsWith("$2a$"); // BCrypt prefix
    assertThat(passwordEncoder.matches(plainPassword, hashed)).isTrue();
}

@Test
void shouldEnforceHttps_inProduction() {
    // Assert
    assertThat(environment.getProperty("server.ssl.enabled")).isEqualTo("true");
    assertThat(environment.getProperty("security.require-ssl")).isEqualTo("true");
}

// ✅ Configurar HTTPS
@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.requiresChannel(channel ->
            channel.anyRequest().requiresSecure()
        );
        return http.build();
    }
}
```

#### 4. Testar A06: Vulnerable Components

```bash
# OWASP Dependency-Check
mvn org.owasp:dependency-check-maven:check

# Gera relatório: target/dependency-check-report.html
```

```xml
<!-- pom.xml -->
<build>
    <plugins>
        <plugin>
            <groupId>org.owasp</groupId>
            <artifactId>dependency-check-maven</artifactId>
            <version>8.4.0</version>
            <configuration>
                <failBuildOnCVSS>7</failBuildOnCVSS> <!-- Falha se CVSS >= 7 -->
            </configuration>
            <executions>
                <execution>
                    <goals>
                        <goal>check</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

#### 5. Testar A08: Insecure Deserialization

```java
// ❌ VULNERÁVEL: Deserialization de input não confiável
@PostMapping("/import")
public void importData(@RequestBody byte[] data) throws Exception {
    ObjectInputStream ois = new ObjectInputStream(new ByteInputStream(data));
    Object obj = ois.readObject(); // PERIGOSO!
}

// ✅ SEGURO: Usar JSON
@PostMapping("/import")
public void importData(@RequestBody ImportRequest request) {
    // Jackson deserializa apenas classes esperadas
    processImport(request);
}

@Test
void shouldRejectMaliciousDeserialization() {
    // Arrange - Payload malicioso
    byte[] malicious = createGadgetChainPayload();

    // Act & Assert
    assertThatThrownBy(() -> objectInputStream.readObject(malicious))
        .isInstanceOf(InvalidClassException.class);
}
```

#### 6. Scan Automatizado com OWASP ZAP

```bash
# Docker ZAP
docker run -t owasp/zap2docker-stable zap-baseline.py \
    -t http://localhost:8080 \
    -r zap-report.html

# Analisa relatório para vulnerabilidades
```

### ✅ Critério de Sucesso

- ✅ Testes para A01 (Access Control)
- ✅ Passwords hasheados com bcrypt
- ✅ HTTPS enforçado
- ✅ Dependency-Check no CI/CD
- ✅ Nenhuma CVE crítica (CVSS >= 7)
- ✅ ZAP scan sem alertas High/Medium

### ⚠️ Pitfalls

- ❌ **Testar apenas happy path:** Testar edge cases maliciosos
- ❌ **Ignorar warnings de dependências:** Atualizar sempre
- ❌ **Não testar em staging:** Prod não é lugar de teste
- ❌ **Security como afterthought:** Integrar no SDLC

### 🚀 Extensão

1. **SAST:** Static Application Security Testing (SonarQube)
2. **DAST:** Dynamic Application Security Testing (Burp Suite)
3. **Penetration Testing:** Contratar pentester profissional

---

## 🔎 Exercício 5: Dependency Scanning Automatizado

### 🎯 Objetivo

Automatizar **scanning de vulnerabilidades** em dependências usando **OWASP Dependency-Check**, **Snyk** e **GitHub Dependabot**.

### 📖 Contexto

80% das vulnerabilidades vêm de dependências de terceiros. Você precisa detectar e corrigir CVEs rapidamente.

### 🛠️ Passos

#### 1. OWASP Dependency-Check (Maven)

```xml
<!-- pom.xml -->
<build>
    <plugins>
        <plugin>
            <groupId>org.owasp</groupId>
            <artifactId>dependency-check-maven</artifactId>
            <version>8.4.0</version>
            <configuration>
                <format>ALL</format>
                <failBuildOnCVSS>7</failBuildOnCVSS>
                <suppressionFile>dependency-check-suppression.xml</suppressionFile>
            </configuration>
        </plugin>
    </plugins>
</build>
```

```bash
# Executar scan
mvn dependency-check:check

# Relatório: target/dependency-check-report.html
```

#### 2. Suprimir Falsos Positivos

```xml
<!-- dependency-check-suppression.xml -->
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    <suppress>
        <notes>False positive - não afeta nossa aplicação</notes>
        <cve>CVE-2023-12345</cve>
    </suppress>
</suppressions>
```

#### 3. Snyk Integration

```bash
# Instalar Snyk CLI
npm install -g snyk

# Autenticar
snyk auth

# Scan projeto
snyk test

# Monitor projeto (alertas automáticos)
snyk monitor
```

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  snyk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Snyk
        uses: snyk/actions/maven@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
```

#### 4. GitHub Dependabot

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "maven"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "security-team"
    labels:
      - "dependencies"
      - "security"
```

**Dependabot automaticamente:**

- Detecta CVEs em dependências
- Abre PRs com updates
- Testa build com nova versão

#### 5. Testar Dependency Updates

```java
@SpringBootTest
class DependencyTest {

    @Test
    void shouldHaveNoKnownVulnerabilities() throws Exception {
        // Executar Dependency-Check programaticamente
        Engine engine = new Engine();
        engine.scan(new File("pom.xml"));
        engine.analyzeDependencies();

        // Assert - Nenhuma CVE crítica
        long criticalCount = engine.getDependencies().stream()
            .flatMap(dep -> dep.getVulnerabilities().stream())
            .filter(vuln -> vuln.getCvssV3().getBaseScore() >= 9.0)
            .count();

        assertThat(criticalCount)
            .as("Critical vulnerabilities found")
            .isEqualTo(0);
    }

    @Test
    void shouldUseLatestSecurityPatches() {
        // Assert - Verificar versões específicas
        String springBootVersion = SpringBootVersion.getVersion();
        assertThat(springBootVersion).isGreaterThanOrEqualTo("3.1.5");
    }
}
```

#### 6. CI/CD Pipeline

```yaml
# .github/workflows/ci.yml
name: CI

on: [push]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: "17"

      - name: OWASP Dependency-Check
        run: mvn dependency-check:check

      - name: Upload Report
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: dependency-check-report
          path: target/dependency-check-report.html

      - name: Fail on High Severity
        run: |
          if grep -q "severity=\"HIGH\"" target/dependency-check-report.xml; then
            echo "High severity vulnerabilities found!"
            exit 1
          fi
```

### ✅ Critério de Sucesso

- ✅ Dependency-Check no CI/CD
- ✅ Build falha com CVE >= 7 (CVSS)
- ✅ Dependabot habilitado
- ✅ Snyk monitora projeto
- ✅ PRs automáticos para updates
- ✅ SLA de correção: CVE crítico < 7 dias

### ⚠️ Pitfalls

- ❌ **Ignorar falsos positivos:** Documentar supressões
- ❌ **Não atualizar dependências:** Dívida técnica cresce
- ❌ **Scanning apenas em prod:** Esquerda no shift-left
- ❌ **Não testar updates:** PR automático pode quebrar build

### 🚀 Extensão

1. **Software Bill of Materials (SBOM):** Gerar SBOM com CycloneDX
2. **License compliance:** Verificar licenças de dependências
3. **Container scanning:** Trivy para imagens Docker

---

## 📊 Checkpoint: Autoavaliação da Trilha Segurança

### Nível Intermediário (41-70%)

- ⬜ PreparedStatement para prevenir SQL injection
- ⬜ Passwords hasheados com bcrypt
- ⬜ JWT básico implementado
- ⬜ Secrets em env vars (não hardcoded)

### Nível Avançado (71-90%)

- ⬜ Testes automatizados para SQL injection
- ⬜ JWT com expiration e validation
- ⬜ Role-based access control
- ⬜ Vault ou Secrets Manager integrado
- ⬜ Dependency-Check no CI/CD
- ⬜ OWASP Top 10 testado

### Nível Senior (91-100%)

- ⬜ OWASP ZAP scan automatizado
- ⬜ Snyk + Dependabot integrados
- ⬜ Refresh tokens implementados
- ⬜ MFA (Multi-Factor Authentication)
- ⬜ Secret rotation automatizada
- ⬜ Security champions no time
- ⬜ Penetration testing regular
- ⬜ SAST + DAST no pipeline

---

**Criado em:** 2025-11-15  
**Tempo Estimado:** 8-10 horas  
**Material Completo:** Todas as 5 trilhas finalizadas! 🎉
