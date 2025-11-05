# OpenLDAP + CPF + Username (Versão Enxuta)

Guia mínimo para subir OpenLDAP com atributos brasileiros `cpf` e `username` via `objectClass brUser`.

## Contexto e Motivação

OpenLDAP não possui por padrão atributos como `cpf` ou `username` customizado porque ele só entrega os schemas genéricos (core, cosine, inetOrgPerson, nis, etc.). Esses schemas abrangem padrões amplos (ex.: `cn`, `sn`, `mail`, `uid`) mas não incluem identificadores nacionais específicos. Para usar `cpf` você precisa:
- Definir um atributo novo (olcAttributeTypes) com OID único (evita conflito e identifica de forma global).
- Escolher uma sintaxe suportada (Directory String foi usada) e limitar tamanho `{11}`.
- Criar uma objectClass (`brUser`) que herda `inetOrgPerson` para reaproveitar atributos comuns e adicionar os novos em MAY.
- Carregar o schema via `ldapadd -Y EXTERNAL` porque alterações de schema só podem ser feitas como root do config (cn=config) através do socket ldapi:///.

A limpeza dos volumes antes de cada tentativa evita estado inconsistente entre `/etc/ldap/slapd.d` (config) e `/var/lib/ldap` (dados). A formatação em linha única dos atributos evita quebras interpretadas de forma incorreta pelo parser do slapd dentro da imagem. 

Esse ambiente foi criado localmente para testar uma biblioteca sem acesso ao ambiente corporativo de desenvolvimento; assim foi possível validar buscas por `(cpf=...)` e autenticação usando os novos atributos antes de integrar com o sistema real.

## 1. Pré-requisitos

Docker + Docker Compose (ldap-utils opcional para testes externos).

```bash
sudo apt update && sudo apt install -y ldap-utils
```

## 2. docker-compose mínimo

```yaml
version: "3.8"
services:
  openldap:
    image: osixia/openldap:1.5.0
    container_name: openldap
    command: --copy-service
    environment:
      LDAP_ORGANISATION: umbrella
      LDAP_DOMAIN: umbrella.com.br
      LDAP_ADMIN_PASSWORD: admin123
      LDAP_CONFIG_PASSWORD: config123
      LDAP_TLS: "false"
    ports: ["389:389"]
    volumes:
      - ./ldap-data:/var/lib/ldap
      - ./ldap-config:/etc/ldap/slapd.d
    networks: [ldap-net]
  phpldapadmin:
    image: osixia/phpldapadmin:0.9.0
    container_name: phpldapadmin
    environment:
      PHPLDAPADMIN_LDAP_HOSTS: openldap
      PHPLDAPADMIN_HTTPS: "false"
    ports: ["8080:80"]
    depends_on: [openldap]
    networks: [ldap-net]
networks:
  ldap-net:
    driver: bridge
```

## 3. Método Manual (funcionando)

```bash
# Limpeza / subida
docker-compose down -v && rm -rf ldap-data ldap-config ldap-schemas/* \
  && mkdir -p ldap-data ldap-config ldap-schemas \
  && docker-compose up -d && sleep 15
# Schema
docker exec openldap bash -c "cat > /tmp/schema-cpf.ldif <<'EOF'\ndn: cn=cpfschema,cn=schema,cn=config\nobjectClass: olcSchemaConfig\ncn: cpfschema\nolcAttributeTypes: ( 1.3.6.1.4.1.99999.1.1.1 NAME 'cpf' DESC 'CPF do usuário brasileiro' EQUALITY caseIgnoreMatch SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{11} SINGLE-VALUE )\nolcAttributeTypes: ( 1.3.6.1.4.1.99999.1.1.4 NAME 'username' DESC 'Username customizado do usuário' EQUALITY caseIgnoreMatch SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 SINGLE-VALUE )\nolcObjectClasses: ( 1.3.6.1.4.1.99999.2.1.1 NAME 'brUser' DESC 'Usuário brasileiro completo' SUP inetOrgPerson STRUCTURAL MAY ( cpf $ username ) )\nEOF" \
  && docker exec openldap ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/schema-cpf.ldif
# OU users
docker exec openldap bash -c "cat > /tmp/ou.ldif <<'EOF'\ndn: ou=users,dc=umbrella,dc=com,dc=br\nobjectClass: organizationalUnit\nou: users\nEOF" \
  && docker exec openldap ldapadd -x -D 'cn=admin,dc=umbrella,dc=com,dc=br' -w admin123 -f /tmp/ou.ldif
# Usuários
docker exec openldap bash -c "cat > /tmp/users.ldif <<'EOF'\ndn: uid=ana.costa,ou=users,dc=umbrella,dc=com,dc=br\nobjectClass: brUser\ncn: Ana Costa\nsn: Costa\nuid: ana.costa\nusername: ana.costa\nuserPassword: {PLAIN}senha321\nmail: ana.costa@umbrella.com.br\ncpf: 11144477735\ntelephoneNumber: +55 11 95555-6666\ntitle: Analista de Marketing\n\ndn: uid=joao.brasil,ou=users,dc=umbrella,dc=com,dc=br\nobjectClass: brUser\ncn: João Brasil\nsn: Brasil\nuid: joao.brasil\nusername: joao.brasil\nuserPassword: {PLAIN}senha123\nmail: joao.brasil@umbrella.com.br\ncpf: 12345678901\ntelephoneNumber: +55 11 98765-4321\ntitle: Analista de Sistemas\nEOF" \
  && docker exec openldap ldapadd -x -D 'cn=admin,dc=umbrella,dc=com,dc=br' -w admin123 -f /tmp/users.ldif
```

## 4. Verificação rápida

```bash
# Schema presente
docker exec openldap ldapsearch -x -b "cn=schema,cn=config" -D "cn=admin,cn=config" -w config123 -s one | grep cpfschema
# Usuários brUser
docker exec openldap ldapsearch -x -b "ou=users,dc=umbrella,dc=com,dc=br" -D "cn=admin,dc=umbrella,dc=com,dc=br" -w admin123 "(objectClass=brUser)" uid cn cpf username
# Buscar CPF
docker exec openldap ldapsearch -x -b "ou=users,dc=umbrella,dc=com,dc=br" -D "cn=admin,dc=umbrella,dc=com,dc=br" -w admin123 "(cpf=12345678901)"
```

## 5. One-liner único

```bash
( docker-compose down -v && rm -rf ldap-data ldap-config && mkdir -p ldap-data ldap-config \
  && docker-compose up -d && sleep 15 \
  && docker exec openldap bash -c "cat > /tmp/schema-cpf.ldif <<'EOF'\ndn: cn=cpfschema,cn=schema,cn=config\nobjectClass: olcSchemaConfig\ncn: cpfschema\nolcAttributeTypes: ( 1.3.6.1.4.1.99999.1.1.1 NAME 'cpf' DESC 'CPF do usuário brasileiro' EQUALITY caseIgnoreMatch SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{11} SINGLE-VALUE )\nolcAttributeTypes: ( 1.3.6.1.4.1.99999.1.1.4 NAME 'username' DESC 'Username customizado do usuário' EQUALITY caseIgnoreMatch SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 SINGLE-VALUE )\nolcObjectClasses: ( 1.3.6.1.4.1.99999.2.1.1 NAME 'brUser' DESC 'Usuário brasileiro completo' SUP inetOrgPerson STRUCTURAL MAY ( cpf $ username ) )\nEOF" \
  && docker exec openldap ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/schema-cpf.ldif \
  && docker exec openldap bash -c "cat > /tmp/users.ldif <<'EOF'\ndn: ou=users,dc=umbrella,dc=com,dc=br\nobjectClass: organizationalUnit\nou: users\n\ndn: uid=ana.costa,ou=users,dc=umbrella,dc=com,dc=br\nobjectClass: brUser\ncn: Ana Costa\nsn: Costa\nuid: ana.costa\nusername: ana.costa\nuserPassword: {PLAIN}senha321\nmail: ana.costa@umbrella.com.br\ncpf: 11144477735\ntelephoneNumber: +55 11 95555-6666\ntitle: Analista de Marketing\n\ndn: uid=joao.brasil,ou=users,dc=umbrella,dc=com,dc=br\nobjectClass: brUser\ncn: João Brasil\nsn: Brasil\nuid: joao.brasil\nusername: joao.brasil\nuserPassword: {PLAIN}senha123\nmail: joao.brasil@umbrella.com.br\ncpf: 12345678901\ntelephoneNumber: +55 11 98765-4321\ntitle: Analista de Sistemas\nEOF" \
  && docker exec openldap ldapadd -x -D 'cn=admin,dc=umbrella,dc=com,dc=br' -w admin123 -f /tmp/users.ldif \
  && docker exec openldap ldapsearch -x -b "ou=users,dc=umbrella,dc=com,dc=br" -D "cn=admin,dc=umbrella,dc=com,dc=br" -w admin123 "(objectClass=brUser)" uid cn cpf username )
```

## 6. Troubleshooting

| Sintoma               | Causa                | Ação                                        |
| --------------------- | -------------------- | ------------------------------------------- |
| Schema vazio          | Quebra de linha      | Recriar atributo em linha única             |
| No such object        | Base DN errada       | Ajustar LDAP_DOMAIN / LDIF e limpar volumes |
| Usuário não autentica | DN ou senha          | Conferir uid / usar `{SSHA}`                |
| CPF não busca         | Schema faltando      | Verificar `cn=schema,cn=config`             |
| phpLDAPadmin falha    | Container não pronto | Ver logs                                    |

## 7. Produção rápido

```bash
# Gerar hash
docker exec openldap slappasswd -s 'SenhaForte123'
# Backup diário
docker exec openldap slapcat -n 1 > backup-$(date +%Y%m%d).ldif
```

TLS: habilitar LDAP_TLS=true e montar certs.

## 8. Pocket commands

```bash
# Listar usuários
docker exec openldap ldapsearch -x -b "ou=users,dc=umbrella,dc=com,dc=br" -D "cn=admin,dc=umbrella,dc=com,dc=br" -w admin123 "(objectClass=brUser)" uid cn cpf
# Autenticar
docker exec openldap ldapwhoami -x -D "uid=joao.brasil,ou=users,dc=umbrella,dc=com,dc=br" -w senha123
```

## 9. Extensões futuras

Adicionar atributos: RG, pisPasep, dataNascimento, cnpjEmpresa (novos OIDs em 1.3.6.1.4.1.99999.x). Incluir em MAY de `brUser`.

## 10. Resumo

Fluxo: limpar → subir → esperar → schema EXTERNAL → OU → usuários → validar. Resultado: usuários pesquisáveis por `cpf` e `username`.

Fim.


---

```ldif
dn: cn=brasileiro,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: brasileiro

# Atributos Brasileiros
olcAttributeTypes: ( 1.3.6.1.4.1.99999.1.1.1
  NAME 'cpf'
  DESC 'CPF do usuário brasileiro'
  EQUALITY caseIgnoreMatch
  SUBSTR caseIgnoreSubstringsMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{11}
  SINGLE-VALUE )

olcAttributeTypes: ( 1.3.6.1.4.1.99999.1.1.2
  NAME 'rg'
  DESC 'RG do usuário brasileiro'
  EQUALITY caseIgnoreMatch
  SUBSTR caseIgnoreSubstringsMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{20}
  SINGLE-VALUE )

olcAttributeTypes: ( 1.3.6.1.4.1.99999.1.1.3
  NAME 'pis'
  DESC 'PIS/PASEP do usuário brasileiro'
  EQUALITY caseIgnoreMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{11}
  SINGLE-VALUE )

olcAttributeTypes: ( 1.3.6.1.4.1.99999.1.1.4
  NAME 'username'
  DESC 'Username customizado do usuário'
  EQUALITY caseIgnoreMatch
  SUBSTR caseIgnoreSubstringsMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15
  SINGLE-VALUE )

# ObjectClass que usa todos os atributos
olcObjectClasses: ( 1.3.6.1.4.1.99999.2.1.1
  NAME 'brUser'
  DESC 'Usuário brasileiro completo'
  SUP inetOrgPerson
  STRUCTURAL
  MAY ( cpf $ rg $ pis $ username ) )
```
