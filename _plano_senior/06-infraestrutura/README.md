# 06 - Infraestrutura 🏗️

## 🎯 O Que São Padrões de Infraestrutura?

**Padrões de Infraestrutura** são práticas e tecnologias para **containerizar**, **orquestrar** e **automatizar** o deploy de aplicações.

Diferentemente de padrões de código (05-transversal), infraestrutura foca em:

- **Containers**: Docker para empacotar aplicações
- **Orquestração**: Kubernetes para gerenciar containers
- **Automação**: CI/CD para build e deploy automatizados

---

## 🔄 Diferença: Código vs Infraestrutura

| Aspecto             | Código (05-transversal)      | Infraestrutura (06)              |
| ------------------- | ---------------------------- | -------------------------------- |
| **Foco**            | Lógica da aplicação          | Deploy e operação                |
| **Onde aplica?**    | Dentro do código Java/Spring | Fora da aplicação (Docker/K8s)   |
| **Responsável**     | Desenvolvedor                | DevOps (mas devs precisam saber) |
| **Exemplo**         | Exception Handling, Logging  | Docker, Kubernetes, CI/CD        |
| **Quando executa?** | Runtime da aplicação         | Build e deploy                   |

---

## 📚 Índice de Padrões

| ID   | Nome                    | Descrição                                                             | Nível    |
| ---- | ----------------------- | --------------------------------------------------------------------- | -------- |
| 06.1 | Docker                  | Containerização de aplicações Spring Boot                             | Avançado |
| 06.2 | Kubernetes              | Orquestração de containers em produção                                | Avançado |
| 06.3 | CI/CD                   | Automação de build, test e deploy (GitHub Actions, GitLab CI)         | Avançado |
| 06.4 | Princípios Cloud        | Well-Architected Framework (AWS, Azure, GCP) + visão de negócio       | Avançado |
| 06.5 | Secrets Management      | HashiCorp Vault, Sealed Secrets, SOPS (alternativas open source)      | Avançado |
| 06.6 | Key Vault Detalhado     | Implementação completa: Azure Key Vault, AWS Secrets Manager, GCP     | Avançado |
| 06.7 | Ferramentas Open Source | Alternativas open source: Podman, Keycloak, OpenLDAP, Prometheus, Zsh | Avançado |
| 06.8 | Jenkins Detalhado       | CI/CD com Jenkins: Pipelines, Docker agents, plugins, Blue Ocean      | Avançado |

---

## 🎯 Quando Usar Cada Tecnologia?

### Docker

**Use quando:**

- ✅ Precisa isolar aplicação e dependências
- ✅ Quer ambiente consistente (dev = prod)
- ✅ Tem microservices que precisam rodar juntos

**Evite quando:**

- ❌ Aplicação muito simples (1 arquivo)
- ❌ Overhead não justifica benefício

### Kubernetes

**Use quando:**

- ✅ Precisa escalar automaticamente
- ✅ Alta disponibilidade é crítica
- ✅ Tem 5+ microservices
- ✅ Deploy em multi-cloud

**Evite quando:**

- ❌ Monolito simples com pouco tráfego
- ❌ Time pequeno sem conhecimento K8s
- ❌ Custo operacional alto demais

### CI/CD

**Use quando:**

- ✅ Deploy frequente (>1x por semana)
- ✅ Múltiplos desenvolvedores no time
- ✅ Quer feedback rápido (testes automatizados)
- ✅ Reduzir erro humano no deploy

**Evite quando:**

- ❌ Projeto pessoal com deploy raro
- ❌ Sem testes automatizados

**Ferramentas:**

- ☁️ **Cloud**: GitHub Actions, GitLab CI, Azure DevOps
- 🔓 **Open Source**: Jenkins, Drone CI, Tekton (K8s), Woodpecker CI

### Princípios Cloud

**Use quando:**

- ✅ Arquitetar aplicação cloud-native
- ✅ Otimizar custos (Reserved Instances, autoscaling)
- ✅ Garantir segurança (IAM, encryption)
- ✅ Alta disponibilidade (Multi-AZ)

**Evite quando:**

- ❌ Aplicação on-premise (sem cloud)

### Secrets Management

**Use quando:**

- ✅ Precisa gerenciar senhas, API keys, certificados
- ✅ Rotação automática de secrets
- ✅ Auditoria de acesso
- ✅ Compliance (LGPD, PCI-DSS)

**Evite quando:**

- ❌ Aplicação sem dados sensíveis (raro)

**Ferramentas:**

- ☁️ **Cloud**: AWS Secrets Manager, Azure Key Vault, GCP Secret Manager
- 🔓 **Open Source**: HashiCorp Vault, Sealed Secrets (K8s), SOPS

### Key Vault Detalhado

**Use quando:**

- ✅ Precisa implementação completa com Terraform + Spring Boot
- ✅ Rotação automática de secrets (Lambda, Azure Function)
- ✅ Encryption de dados com keys criptográficas
- ✅ Certificados SSL/TLS gerenciados

**Cobre:**

- Azure Key Vault (access policies, Managed Identity)
- AWS Secrets Manager (rotation, JDBC driver)
- GCP Secret Manager (IAM, versioning)
- Encryption Service com keys do vault

### Ferramentas Open Source

**Use quando:**

- ✅ Quer alternativas sem vendor lock-in
- ✅ Budget limitado (sem custo de licença)
- ✅ Precisa flexibilidade/customização máxima
- ✅ Aprender ferramentas modernas da comunidade

**Cobre:**

- **Containers**: Podman (rootless), Buildah, Skopeo
- **K8s**: K3s, MicroK8s, Minikube, Helm
- **CI/CD**: Jenkins (overview), Drone, Tekton, Woodpecker
- **Monitoramento**: Prometheus, Grafana, Loki, Jaeger
- **Autenticação**: Keycloak (SSO/OAuth2), OpenLDAP
- **Terminais**: Zsh + Oh My Zsh, Tmux
- **IaC**: Terraform, Pulumi

### Jenkins Detalhado

**Use quando:**

- ✅ Precisa CI/CD 100% open source e auto-hospedado
- ✅ Pipeline as Code (Jenkinsfile no Git)
- ✅ Integração completa: Docker, K8s, SonarQube, Slack
- ✅ Multibranch pipelines (dev/staging/prod)

**Cobre:**

- **Instalação**: Docker, Docker Compose, Kubernetes
- **Plugins essenciais**: Git, Docker, K8s, SonarQube, Slack
- **Jenkinsfile completo**: Build, test, quality gate, security scan, deploy
- **Pipeline Declarativo vs Scripted**
- **Multibranch pipeline**: Estratégia por branch/tag
- **Docker agents**: Agents dinâmicos em containers
- **Segurança**: RBAC, HashiCorp Vault integration
- **Blue Ocean**: UI moderna para visualização
- **Notificações**: Slack, Email, Teams

---

## 🔗 Integração entre Tecnologias

```
┌──────────────────────────────────────────────┐
│                  CI/CD                       │
│  (GitHub Actions, GitLab CI, Jenkins)        │
└──────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│                 Docker                       │
│  (Empacota aplicação em imagem)              │
└──────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│               Kubernetes                     │
│  (Orquestra containers, autoscaling)         │
└──────────────────────────────────────────────┘
```

**Fluxo típico:**

1. **Desenvolvedor** faz push no Git
2. **CI/CD** roda testes e build Maven
3. **Docker** cria imagem da aplicação
4. **CI/CD** envia imagem para registry
5. **Kubernetes** faz deploy da nova versão
6. **Kubernetes** monitora saúde (liveness/readiness)
7. **Kubernetes** escala automaticamente se necessário

---

## 📋 Checklist Infraestrutura

### Docker

- [ ] Dockerfile usa multi-stage build?
- [ ] Imagem Alpine (menor tamanho)?
- [ ] Usuário não-root?
- [ ] Health check configurado?
- [ ] .dockerignore otimizado?

### Kubernetes

- [ ] Deployment com rolling update?
- [ ] Resource limits definidos?
- [ ] Liveness e readiness probes?
- [ ] ConfigMaps para configurações?
- [ ] Secrets para dados sensíveis?
- [ ] HPA (autoscaling) configurado?

### CI/CD

- [ ] Testes automatizados (unit + integration)?
- [ ] Quality gate (SonarQube)?
- [ ] Build com cache (rápido)?
- [ ] Deploy automatizado?
- [ ] Rollback automático em caso de falha?
- [ ] Notificações (Slack/Email)?

### Secrets Management

- [ ] Secrets no vault (não no código)?
- [ ] Rotação automática habilitada?
- [ ] Managed Identity configurada?
- [ ] Network ACL (bloqueia acesso público)?
- [ ] Auditoria habilitada?
- [ ] Soft delete + purge protection?

### Ferramentas Open Source

- [ ] Considera alternativas open source (Podman, Jenkins)?
- [ ] Keycloak para SSO/OAuth2?
- [ ] Prometheus + Grafana para monitoramento?
- [ ] Helm para gerenciar apps K8s?
- [ ] Terraform/Pulumi para IaC?

### Jenkins

- [ ] Pipeline as Code (Jenkinsfile no Git)?
- [ ] Stages paralelos (unit + integration tests)?
- [ ] Quality gate (SonarQube) configurado?
- [ ] Docker agents para builds isolados?
- [ ] Multibranch pipeline (dev/staging/prod)?
- [ ] Notificações (Slack/Email)?
- [ ] Credentials via Vault/Credentials Plugin?
- [ ] Build discarder (economiza espaço)?

---

## 🎓 Progressão de Aprendizado

### Iniciante → Intermediário

1. **Docker básico**: Dockerfile, docker-compose
2. **CI básico**: GitHub Actions com build + test
3. **Deploy manual**: docker run em VM

### Intermediário → Avançado

1. **Docker otimizado**: Multi-stage, Alpine, layers
2. **Kubernetes básico**: Deployment, Service, Ingress
3. **CI/CD completo**: Build + Test + Docker + Deploy K8s

### Avançado → Expert

1. **Kubernetes avançado**: HPA, StatefulSets, Helm
2. **Observabilidade**: Prometheus, Grafana, Loki
3. **Estratégias de deploy**: Blue-Green, Canary
4. **Service Mesh**: Istio para microservices

---

## 🔗 Relação com 05-transversal

**Infraestrutura** complementa **Padrões Transversais**:

| Transversal (05)        | Infraestrutura (06)             |
| ----------------------- | ------------------------------- |
| Exception Handling      | K8s liveness probe detecta erro |
| Logging                 | ELK Stack centraliza logs       |
| Configuration           | ConfigMaps/Secrets no K8s       |
| Princípios (SOLID, DRY) | Apply no código antes de deploy |
| Clean Code              | Facilita manutenção no pipeline |

**Exemplo prático:**

```yaml
# application.yml (05-transversal: Configuration)
spring:
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:dev}

# deployment.yaml (06-infraestrutura: Kubernetes)
env:
  - name: SPRING_PROFILES_ACTIVE
    value: "prod"
```

---

## 📚 Recursos

### Documentação Oficial

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)

### Tutoriais

- [Spring Boot com Docker](https://spring.io/guides/topicals/spring-boot-docker/)
- [Spring Boot no Kubernetes](https://spring.io/guides/gs/spring-boot-kubernetes/)

### Livros

- **"Docker Deep Dive"** - Nigel Poulton
- **"Kubernetes in Action"** - Marko Lukša
- **"Continuous Delivery"** - Jez Humble

---

## 📝 Resumo

**Infraestrutura moderna** = **Docker** + **Kubernetes** + **CI/CD**

- ✅ **Docker**: Empacota aplicação (isolamento, portabilidade)
- ✅ **Kubernetes**: Orquestra containers (self-healing, autoscaling)
- ✅ **CI/CD**: Automatiza deploy (feedback rápido, confiabilidade)

**Regra de ouro:** Comece com **Docker** (fácil), depois **CI/CD** (automação), e só então **Kubernetes** (quando escala justificar complexidade).
