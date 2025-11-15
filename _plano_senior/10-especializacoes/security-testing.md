# 🔒 Security Testing - Especializações Avançadas

## Índice

1. [Introdução](#1-introdução)
2. [SAST - Static Application Security Testing](#2-sast---static-application-security-testing)
3. [DAST - Dynamic Application Security Testing](#3-dast---dynamic-application-security-testing)
4. [Dependency Scanning](#4-dependency-scanning)
5. [Secrets Detection](#5-secrets-detection)
6. [OWASP Top 10](#6-owasp-top-10)
7. [Container Security](#7-container-security)
8. [Métricas](#8-métricas)

---

## 1. Introdução

### O que é Security Testing?

**Definição:** Processo contínuo de identificar vulnerabilidades, riscos e conformidade de segurança através de análise automatizada e manual.

**Shift Left Security:** Detectar vulnerabilidades o mais cedo possível no ciclo de desenvolvimento.

```
Design → Code → Build → Test → Deploy → Monitor
   ↓       ↓       ↓      ↓       ↓        ↓
  TM    SAST+   Dep.   DAST   Runtime  Pen.
        IDE    Scan   Auto   Security  Test
```

### Por que Security Testing?

- ✅ Prevenir data breaches (custo médio: $4.35M)
- ✅ Conformidade (LGPD, GDPR, PCI-DSS)
- ✅ Reputação da marca
- ✅ ROI: 10x mais barato corrigir em desenvolvimento

---

## 2. SAST - Static Application Security Testing

### 2.1 Conceito

**Análise estática** de código-fonte para identificar vulnerabilidades sem executar a aplicação.

**O que detecta:**

- SQL Injection
- Cross-Site Scripting (XSS)
- Path Traversal
- Hardcoded secrets
- Insecure cryptography
- Null pointer dereferences

### 2.2 SonarQube (Open Source)

**Docker Compose:**

```yaml
version: "3.8"
services:
  sonarqube:
    image: sonarqube:10.3-community
    ports:
      - "9000:9000"
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs

volumes:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
```

**Maven Integration:**

```xml
<plugin>
    <groupId>org.sonarsource.scanner.maven</groupId>
    <artifactId>sonar-maven-plugin</artifactId>
    <version>3.10.0.2594</version>
</plugin>
```

**Execução:**

```bash
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=my-project \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<token>
```

**Quality Gate:**

```yaml
# sonar-project.properties
sonar.qualitygate.wait=true
sonar.qualitygate.timeout=300

# Limites
sonar.coverage.minimum=80
sonar.security_rating=A
sonar.vulnerabilities.max=0
sonar.security_hotspots.max=0
```

### 2.3 SpotBugs + FindSecBugs

**Maven:**

```xml
<plugin>
    <groupId>com.github.spotbugs</groupId>
    <artifactId>spotbugs-maven-plugin</artifactId>
    <version>4.8.1.0</version>
    <dependencies>
        <dependency>
            <groupId>com.h3xstream.findsecbugs</groupId>
            <artifactId>findsecbugs-plugin</artifactId>
            <version>1.12.0</version>
        </dependency>
    </dependencies>
    <configuration>
        <effort>Max</effort>
        <threshold>Low</threshold>
        <plugins>
            <plugin>
                <groupId>com.h3xstream.findsecbugs</groupId>
                <artifactId>findsecbugs-plugin</artifactId>
                <version>1.12.0</version>
            </plugin>
        </plugins>
    </configuration>
</plugin>
```

**Exemplo de Detecção (Java 17+):**

```java
// ❌ VULNERÁVEL - SQL Injection
public User findUser(String username) {
    var sql = "SELECT * FROM users WHERE username = '" + username + "'";
    return jdbcTemplate.queryForObject(sql, userRowMapper);
}

// ✅ SEGURO - Prepared Statement (Java 17+)
public User findUser(String username) {
    var sql = "SELECT * FROM users WHERE username = ?";
    return jdbcTemplate.queryForObject(sql, userRowMapper, username);
}

// ✅ AINDA MELHOR - Text Block (Java 15+)
public List<User> findUsersByRole(String role) {
    var sql = """
        SELECT u.id, u.name, u.email
        FROM users u
        WHERE u.role = ?
        AND u.active = true
        """;
    return jdbcTemplate.query(sql, userRowMapper, role);
}
```

**SpotBugs detecta:**

```
[SECURITY] SQL Injection vulnerability
Pattern: SQL_INJECTION_JDBC
File: UserRepository.java:42
Message: Possible SQL injection. Use prepared statements.
```

---

## 3. DAST - Dynamic Application Security Testing

### 3.1 Conceito

**Análise dinâmica** da aplicação em execução, simulando ataques reais.

**O que detecta:**

- Autenticação fraca
- Session management issues
- CSRF vulnerabilities
- Security misconfigurations
- Exposed sensitive data

### 3.2 OWASP ZAP (Zed Attack Proxy)

**Docker:**

```bash
docker run -u zap -p 8080:8080 \
  -v $(pwd)/reports:/zap/reports \
  owasp/zap2docker-stable \
  zap-baseline.py -t http://host.docker.internal:8081 \
  -r zap-report.html
```

**Automated Scan (CI/CD):**

```yaml
# .github/workflows/security-scan.yml
name: Security Scan

on:
  pull_request:
    branches: [main]

jobs:
  zap_scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Start application
        run: |
          docker-compose up -d app
          sleep 30

      - name: ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.7.0
        with:
          target: "http://localhost:8080"
          rules_file_name: ".zap/rules.tsv"
          cmd_options: "-a"

      - name: Upload ZAP Report
        uses: actions/upload-artifact@v3
        with:
          name: zap-report
          path: report_html.html
```

**Rules Configuration (.zap/rules.tsv):**

```tsv
10023	IGNORE	(Path Traversal)
10096	IGNORE	(Timestamp Disclosure)
10202	WARN	(Absence of Anti-CSRF Tokens)
40012	FAIL	(SQL Injection)
40014	FAIL	(Cross Site Scripting)
```

### 3.3 Nuclei (Fast Scanner)

**Instalação:**

```bash
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
```

**Scan:**

```bash
nuclei -u http://localhost:8080 \
  -t exposures/ -t cves/ -t misconfiguration/ \
  -severity critical,high \
  -json -o nuclei-results.json
```

**Custom Template:**

```yaml
# custom-sql-injection.yaml
id: custom-sql-injection

info:
  name: SQL Injection Test
  severity: critical

requests:
  - method: GET
    path:
      - "{{BaseURL}}/api/users?id=1' OR '1'='1"

    matchers:
      - type: word
        words:
          - "SQL syntax"
          - "ORA-00933"
          - "MySQL Error"
```

---

## 4. Dependency Scanning

### 4.1 OWASP Dependency-Check

**Maven:**

```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>9.0.7</version>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
        <suppressionFiles>
            <suppressionFile>dependency-check-suppressions.xml</suppressionFile>
        </suppressionFiles>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

**Suppression File:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    <!-- False positive: CVE-2022-12345 não afeta nosso uso -->
    <suppress>
        <packageUrl regex="true">^pkg:maven/com\.example/library@.*$</packageUrl>
        <cve>CVE-2022-12345</cve>
    </suppress>
</suppressions>
```

### 4.2 Trivy (Container + Dependencies)

**Scan de Imagem:**

```bash
trivy image --severity HIGH,CRITICAL \
  --exit-code 1 \
  myapp:latest
```

**Scan de Filesystem:**

```bash
trivy fs --scanners vuln,secret,misconfig \
  --severity CRITICAL,HIGH \
  --exit-code 1 \
  .
```

**CI/CD Integration:**

```yaml
# .github/workflows/trivy.yml
- name: Run Trivy scanner
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: "fs"
    scan-ref: "."
    format: "sarif"
    output: "trivy-results.sarif"
    severity: "CRITICAL,HIGH"

- name: Upload to GitHub Security
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: "trivy-results.sarif"
```

### 4.3 Snyk (Alternative)

```bash
# Instalar
npm install -g snyk

# Autenticar
snyk auth

# Scan
snyk test --severity-threshold=high

# Monitor
snyk monitor
```

---

## 5. Secrets Detection

### 5.1 Gitleaks

**Instalação:**

```bash
# Linux/macOS
brew install gitleaks

# Docker
docker pull zricethezav/gitleaks:latest
```

**Scan Local:**

```bash
gitleaks detect --source . --verbose --report-path gitleaks-report.json
```

**Pre-commit Hook:**

```bash
#!/bin/bash
# .git/hooks/pre-commit

gitleaks protect --staged --verbose
if [ $? -ne 0 ]; then
    echo "❌ Secrets detectados! Commit bloqueado."
    exit 1
fi
```

**Custom Rules (.gitleaks.toml):**

```toml
title = "Custom Gitleaks Config"

[[rules]]
id = "aws-access-key"
description = "AWS Access Key"
regex = '''AKIA[0-9A-Z]{16}'''
tags = ["aws", "credentials"]

[[rules]]
id = "private-key"
description = "Private Key"
regex = '''-----BEGIN (RSA|OPENSSH|DSA|EC) PRIVATE KEY-----'''
tags = ["key", "secret"]

[[rules]]
id = "custom-api-key"
description = "Custom API Key Pattern"
regex = '''api[_-]?key[_-]?=\s*['"]?[a-zA-Z0-9]{32,}['"]?'''
tags = ["api-key"]
```

### 5.2 TruffleHog

**Scan Repository:**

```bash
docker run --rm -v $(pwd):/repo \
  trufflesecurity/trufflehog:latest \
  filesystem /repo \
  --only-verified \
  --json > trufflehog-results.json
```

**GitHub Scan:**

```bash
trufflehog github --org=mycompany \
  --only-verified \
  --json
```

---

## 6. OWASP Top 10

### 6.1 A01:2021 - Broken Access Control

**Vulnerabilidade:**

```java
// ❌ INSEGURO - Sem validação de autorização
@GetMapping("/users/{id}")
public User getUser(@PathVariable Long id) {
    return userService.findById(id);
}
```

**Teste (Java 17+):**

```java
@Test
void naoDevePermitir_AcessoUsuarioAlheio() {
    // Arrange - User 1 autenticado
    var token = login("user1@example.com");

    // Act - Tentar acessar dados de User 2
    var response = restTemplate.exchange(
        "/users/2",
        HttpMethod.GET,
        new HttpEntity<>(headers(token)),
        User.class
    );

    // Assert
    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
}
```

**Correção:**

````java
@GetMapping("/users/{id}")
@PreAuthorize("@authService.canAccessUser(#id, authentication)")
public User getUser(@PathVariable Long id) {
    return userService.findById(id);
}
```### 6.2 A02:2021 - Cryptographic Failures

**Vulnerabilidade:**

```java
// ❌ INSEGURO - MD5 é quebrado
var hash = DigestUtils.md5Hex(password);
````

**Teste (Java 17+):**

```java
@Test
void deveCriptografar_SenhasFortes_ComBcrypt() {
    var plainPassword = "MySecureP@ssw0rd!";
    var hash = passwordEncoder.encode(plainPassword);

    // Validar formato BCrypt
    assertThat(hash).startsWith("$2a$");
    assertThat(hash).hasSize(60);

    // Validar não reversível
    assertThat(passwordEncoder.matches(plainPassword, hash)).isTrue();
    assertThat(passwordEncoder.matches("wrong", hash)).isFalse();
}
```

**Correção:**

````java
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder(12); // Cost factor 12
}
```### 6.3 A03:2021 - Injection

**SQL Injection Test (Java 17+):**

```java
@Test
void deveBloquear_SQLInjection_NoParametroUsername() {
    var maliciousInput = "admin' OR '1'='1' --";

    assertThrows(BadRequestException.class, () ->
        userService.findByUsername(maliciousInput)
    );
}
````

**Command Injection Test (Java 17+):**

````java
@Test
void deveBloquear_CommandInjection_NoNomeArquivo() {
    var maliciousFilename = "file.txt; rm -rf /";

    assertThrows(SecurityException.class, () ->
        fileService.process(maliciousFilename)
    );
}
```### 6.4 A05:2021 - Security Misconfiguration

**Test Security Headers (Java 17+):**

```java
@Test
void deveConfigurar_SecurityHeaders_Corretamente() {
    var response = restTemplate.getForEntity("/", String.class);
    var headers = response.getHeaders();

    // Content Security Policy
    assertThat(headers.getFirst("Content-Security-Policy"))
        .contains("default-src 'self'");

    // X-Frame-Options
    assertThat(headers.getFirst("X-Frame-Options"))
        .isEqualTo("DENY");

    // X-Content-Type-Options
    assertThat(headers.getFirst("X-Content-Type-Options"))
        .isEqualTo("nosniff");

    // Strict-Transport-Security
    assertThat(headers.getFirst("Strict-Transport-Security"))
        .contains("max-age=31536000");
}
```### 6.5 A07:2021 - Identification and Authentication Failures

**Brute Force Test (Java 17+):**

```java
@Test
void deveBloquear_AposMultiplasTentativasFalhas() {
    var username = "user@example.com";
    var wrongPassword = "wrongPassword";

    // 5 tentativas falhadas
    for (int i = 0; i < 5; i++) {
        loginService.login(username, wrongPassword);
    }

    // 6ª tentativa deve ser bloqueada
    assertThrows(AccountLockedException.class, () ->
        loginService.login(username, wrongPassword)
    );

    // Validar que até senha correta falha
    assertThrows(AccountLockedException.class, () ->
        loginService.login(username, "correctPassword")
    );
}
```---

## 7. Container Security

### 7.1 Dockerfile Best Practices

**Inseguro:**

```dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y python3
COPY . /app
WORKDIR /app
USER root
CMD ["python3", "app.py"]
````

**Seguro:**

```dockerfile
# 1. Imagem base específica e minimal
FROM python:3.11-slim-bookworm

# 2. Non-root user
RUN useradd -m -u 1000 appuser

# 3. Dependências primeiro (cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Código da aplicação
COPY --chown=appuser:appuser . /app
WORKDIR /app

# 5. Remover ferramentas desnecessárias
RUN apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*

# 6. Mudar para non-root
USER appuser

# 7. Health check
HEALTHCHECK CMD curl --fail http://localhost:8080/health || exit 1

# 8. Startup
CMD ["python3", "app.py"]
```

### 7.2 Docker Bench Security

```bash
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
  -v /var/lib:/var/lib \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc:/etc \
  --label docker_bench_security \
  docker/docker-bench-security
```

---

## 8. Métricas

### 8.1 Métricas-Chave

**Vulnerabilities by Severity:**

```
Critical: 0 (blocker)
High: ≤ 5 (ação imediata)
Medium: ≤ 20 (próximo sprint)
Low: tracked (backlog)
```

**Mean Time to Remediate (MTTR):**

```
MTTR = Soma(Data Correção - Data Detecção) / Total Vulnerabilidades

Meta:
- Critical: ≤ 24h
- High: ≤ 7 dias
- Medium: ≤ 30 dias
```

**Security Debt:**

```
Security Debt = Vulnerabilidades Conhecidas × Custo Médio Correção

Alerta: > $50k ou > 90 dias sem redução
```

### 8.2 Dashboard Grafana

**Prometheus Metrics:**

```yaml
# application.yml
management:
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: ${spring.application.name}
```

**Custom Metrics (Java 17+):**

````java
@Component
public final class SecurityMetrics {

    private final MeterRegistry registry;

    public SecurityMetrics(MeterRegistry registry) {
        this.registry = registry;
    }

    public void recordVulnerability(String severity) {
        registry.counter("security.vulnerabilities",
            "severity", severity
        ).increment();
    }

    public void recordScanDuration(String tool, long durationMs) {
        registry.timer("security.scan.duration",
            "tool", tool
        ).record(durationMs, TimeUnit.MILLISECONDS);
    }
}
```---

## 📊 Resumo de Ferramentas

| Tipo             | Ferramenta      | Uso                       |
| ---------------- | --------------- | ------------------------- |
| **SAST**         | SonarQube       | Análise estática completa |
|                  | SpotBugs        | Bugs + segurança Java     |
| **DAST**         | OWASP ZAP       | Scan dinâmico web apps    |
|                  | Nuclei          | Fast scan + templates     |
| **Dependencies** | Trivy           | Container + FS + secrets  |
|                  | OWASP Dep-Check | Java dependencies         |
| **Secrets**      | Gitleaks        | Git history scan          |
|                  | TruffleHog      | Deep secrets detection    |
| **Container**    | Trivy           | Vulnerabilidades          |
|                  | Docker Bench    | CIS compliance            |

---

## 🎯 Checklist

- [ ] SAST configurado (SonarQube/SpotBugs)
- [ ] DAST automatizado (ZAP/Nuclei)
- [ ] Dependency scanning (Trivy/OWASP)
- [ ] Secrets detection (Gitleaks)
- [ ] Quality gates definidos
- [ ] Pre-commit hooks instalados
- [ ] Security headers configurados
- [ ] Container scanning no CI/CD
- [ ] MTTR tracking
- [ ] Security training para equipe
````
