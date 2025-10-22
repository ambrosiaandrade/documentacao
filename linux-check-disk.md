Para verificar se o HD tem setores danificados (bad blocks) no **Lubuntu (ou qualquer distro baseada em Ubuntu)**, você pode usar ferramentas como `smartctl` e `badblocks`.

---

## ✅ Passo 1: Verificar o estado geral do disco com S.M.A.R.T.

### 📥 Instale o `smartmontools` (caso não tenha):

```bash
sudo apt update
sudo apt install smartmontools
```

### 🔍 Testar o disco com S.M.A.R.T.

Substitua `/dev/sdX` pelo seu disco (geralmente `/dev/sda`, mas confira com `lsblk` ou `sudo fdisk -l`):

```bash
sudo smartctl -a /dev/sda
```

### 📌 O que olhar no resultado:

* **Reallocated\_Sector\_Ct**: setores remapeados → sinal de dano.
* **Current\_Pending\_Sector**: setores aguardando remapeamento.
* **Raw\_Read\_Error\_Rate** ou **Offline\_Uncorrectable**.

Esses valores devem ser **zero** em um disco saudável.

---

## ✅ Passo 2: Verificar setores danificados com `badblocks`

### ⚠️ Atenção:

* A verificação **não-destrutiva** é segura.
* A verificação **destrutiva** apaga seus dados (não use sem backup!).

### 📘 Modo seguro (não destrutivo):

```bash
sudo badblocks -sv /dev/sdX
```

* `-s` mostra o progresso
* `-v` mostra detalhes

⚠️ **Use o disco inteiro `/dev/sdX`, não a partição (`/dev/sdX1`)**.

### 📘 Modo com gravação (destrutivo, apaga tudo):

```bash
sudo badblocks -wsv /dev/sdX
```

Só use se for formatar o HD mesmo.

---

## ✅ (Opcional) Verificar partições montadas com `fsck` (corrige erros no sistema de arquivos)

**Para uma partição específica (ex: `/dev/sda1`):**

```bash
sudo umount /dev/sda1
sudo fsck -v /dev/sda1
```

---

## ✅ Resumo:

| Comando                  | O que faz                             |
| ------------------------ | ------------------------------------- |
| `smartctl -a /dev/sdX`   | Diagnóstico S.M.A.R.T.                |
| `badblocks -sv /dev/sdX` | Verifica setores defeituosos          |
| `fsck /dev/sdX1`         | Verifica erros no sistema de arquivos |

---

Se quiser, posso te ajudar a interpretar a saída do `smartctl` — só colar aqui.
