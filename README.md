# CS2 Dedicated Server — 5x5 Competitivo

Servidor dedicado de CS2 pronto para uso competitivo, com suporte a skins via banco de dados.  
Funciona nativamente no **Linux** e no **Windows** — sem Docker.

**Plugins ativos por padrão:**
- [MatchZy](https://github.com/shobhit-pathak/MatchZy) — modo competitivo 5x5 com knife round, pause, practice e estatísticas
- [WeaponPaints](https://github.com/Nereziel/cs2-WeaponPaints) — skins, facas e luvas persistidas por Steam ID via MySQL

**Plugins incluídos, desativados por padrão:**
- [RetakesPlugin](https://github.com/B3none/cs2-retakes) — modo retake de bombsite
- [Deathmatch](https://github.com/NockyCZ/CS2-Deathmatch) — respawn contínuo com seleção de armas

---

## Pré-requisitos

| | Linux | Windows |
|---|---|---|
| **Sistema** | Ubuntu 20.04+, Debian 11+, Fedora 37+, Arch | Windows 10/11 64-bit |
| **RAM** | 8 GB+ | 8 GB+ |
| **Disco** | 35 GB livres | 35 GB livres |
| **Python** | `python3` (geralmente já incluso) | [Python 3.x](https://python.org/downloads) |
| **MySQL** | `sudo apt install mysql-server` | [MySQL Community](https://dev.mysql.com/downloads/mysql/) |
| **PowerShell** | — | 5.1+ (já incluso no Windows 10+) |

---

## 1. Configuração inicial

### 1.1 Copie o `.env`

```bash
# Linux
cp .env.example .env

# Windows (PowerShell)
Copy-Item .env.example .env
```

Edite o `.env` com seus valores:

```env
SERVER_NAME="CS2 Server 5x5"
SERVER_PASSWORD=          # vazio = sem senha
SERVER_PORT=27015
START_MAP=de_mirage

STEAM_TOKEN=              # necessário para aparecer na lista pública

DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=cs2user
DB_PASSWORD=troque-esta-senha
DB_NAME=cs2
```

### 1.2 Steam Game Server Token

Obrigatório para o servidor aparecer na lista pública. Para uso apenas na LAN, pode deixar vazio.

1. Acesse: https://steamcommunity.com/dev/managegameservers
2. Crie um token com **App ID: 730**
3. Cole no `.env` → `STEAM_TOKEN=SEU_TOKEN`

---

## 2. Banco de dados (WeaponPaints)

O WeaponPaints requer um banco MySQL para persistir as skins dos jogadores.

**Crie o usuário e importe o schema:**

```sql
-- Linux
mysql -u root -p < mysql/init.sql

-- Windows (MySQL Command Line Client)
source C:\caminho\para\mysql\init.sql
```

O arquivo `mysql/init.sql` cria o banco, as tabelas e o usuário `cs2user` automaticamente.

> As credenciais do banco são lidas do `.env` pelos scripts de inicialização — não é necessário editar o `WeaponPaints.json` manualmente.

---

## 3. Instalar

### Linux

```bash
bash install.sh
```

O script:
- Instala o SteamCMD (detecta apt, dnf ou pacman)
- Baixa o CS2 (~30 GB) via SteamCMD
- Copia Metamod + CounterStrikeSharp (incluídos no repo)
- Registra o Metamod no `gameinfo.gi`
- Copia configs e plugins para o CS2

### Windows

Abra o **PowerShell** e execute:

```powershell
# Necessário apenas uma vez por máquina
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

.\install.ps1
```

O script faz tudo automaticamente:
- Baixa o SteamCMD
- Baixa o CS2 (~30 GB)
- **Baixa e instala Metamod + CounterStrikeSharp** (apenas na primeira vez)
- Registra o Metamod no `gameinfo.gi`
- Copia configs e plugins para o CS2

> O CS2 é instalado em `%USERPROFILE%\cs2server`

---

## 4. Iniciar o servidor

```bash
# Linux
bash start.sh

# Windows
.\start.ps1
```

Antes de iniciar o CS2, o script executa `configure_weaponpaints.py`, que lê as variáveis `DB_*` do `.env` e atualiza o `WeaponPaints.json` instalado. Isso garante que as credenciais do banco nunca precisem ser editadas manualmente.

---

## 5. Conectar

No console do CS2:

```
connect SEU_IP:27015
```

Para conectar localmente:

```
connect localhost:27015
```

---

## 6. Referência de comandos

### MatchZy — Competitivo

O servidor inicia em modo de **warmup**. A partida só começa após todos os 10 jogadores confirmarem `!ready`.

**Comandos de jogador (chat):**

| Comando | Função |
|---------|--------|
| `!ready` | Confirmar prontidão |
| `!unready` | Cancelar prontidão |
| `!pause` | Solicitar pausa técnica |
| `!unpause` | Solicitar fim da pausa |
| `!ws` | Abrir menu de skins |
| `!knife` | Abrir menu de facas |
| `!gloves` | Abrir menu de luvas |

**Comandos de admin (chat):**

| Comando | Função |
|---------|--------|
| `!start` | Forçar início da partida |
| `!forcerestart` | Reiniciar partida |
| `!forceend` | Encerrar partida |
| `!map <mapa>` | Trocar de mapa |

### MatchZy — Practice

Para entrar no modo practice, um admin usa `!prac` no chat.

| Comando | Função |
|---------|--------|
| `.bot` | Adicionar/remover bot |
| `.nobots` | Remover todos os bots |
| `.ctspawn` | Teleportar para spawn CT |
| `.tspawn` | Teleportar para spawn T |
| `.rethrow` | Repetir o último lançamento de granada |
| `.last` | Repetir a última ação |
| `.clear` | Limpar granadas do mapa |
| `.timer` | Exibir timer de treino |
| `.exitprac` | Sair do practice |

---

## 7. Modos opcionais

Retakes e Deathmatch são instalados em `plugins/disabled/` e **não carregam automaticamente**.

### Ativar Retakes

No console do servidor:

```
css_plugins load RetakesPlugin
mp_restartgame 1
```

Para desativar:

```
css_plugins unload RetakesPlugin
```

**Comandos de admin do Retakes:**

| Comando | Função |
|---------|--------|
| `!mapconfig <mapa>` | Carregar config do mapa (ex: `!mapconfig de_mirage`) |
| `!forcebombsite A\|B` | Forçar bombsite específico |
| `!forcebombsitestop` | Remover bombsite forçado |
| `!scramble` | Embaralhar times na próxima rodada |
| `!showspawns A\|B` | Exibir spawns do bombsite |
| `!addspawn <CT\|T> <Y\|N>` | Adicionar spawn |
| `!removespawn` | Remover spawn mais próximo |

### Ativar Deathmatch

```
css_plugins load Deathmatch
game_type 1
game_mode 2
map de_mirage
```

Para desativar:

```
css_plugins unload Deathmatch
```

> Não use Retakes e Deathmatch simultaneamente. Após trocar de modo, reinicie o mapa.

---

## 8. Frameworks (Metamod + CounterStrikeSharp)

| Plataforma | Versão | Como é instalado |
|------------|--------|-----------------|
| **Linux** | CSS v1.0.372 · Metamod build 1410 | Incluído no repo em `game/linux/csgo/addons/`, copiado pelo `install.sh` |
| **Windows** | CSS v1.0.372 · Metamod build 1410 | Baixado automaticamente pelo `install.ps1` na primeira instalação |

Para atualizar as versões Windows, edite as variáveis `$CSS_VERSION` e `$MMBuild` em `install.ps1`.

---

## 9. Estrutura do repositório

```
cs2-server/
├── .env.example                ← modelo de configuração
├── .env                        ← suas configs locais (não sobe no git)
├── install.sh                  ← instalador Linux
├── install.ps1                 ← instalador Windows
├── start.sh                    ← inicializador Linux
├── start.ps1                   ← inicializador Windows
├── configure_weaponpaints.py   ← injeta credenciais do banco no WeaponPaints.json
├── cfg/
│   ├── server.cfg              ← configurações gerais do servidor
│   ├── admins.json             ← lista de admins do CounterStrikeSharp
│   └── matchzy/
│       └── matchzy.cfg         ← configurações do MatchZy
├── plugins/
│   ├── MatchZy-0.8.15/         ← ativo por padrão
│   ├── WeaponPaints/           ← ativo por padrão
│   ├── RetakesPlugin-3.1.0/    ← instalado em disabled/, ativação manual
│   └── Deathmatch/             ← instalado em disabled/, ativação manual
├── game/
│   ├── linux/csgo/addons/      ← Metamod + CSS para Linux
│   └── csgo/addons/            ← configs compartilhadas (vdf, gamedata, lang)
└── mysql/
    └── init.sql                ← cria banco, tabelas e usuário
```

---

## 10. Atualizar o CS2

Basta rodar o instalador novamente — o SteamCMD baixa apenas o que mudou:

```bash
# Linux
bash install.sh

# Windows
.\install.ps1
```

---

## Problemas comuns

**Servidor não aparece na lista pública**  
→ Confirme que `STEAM_TOKEN` está preenchido no `.env`

**Plugins não carregam**  
→ Linux: verifique se os arquivos em `game/linux/csgo/addons/` foram copiados corretamente  
→ Windows: o `install.ps1` baixa os frameworks automaticamente — rode novamente com acesso à internet

**Skins não aparecem / erro MySQL**  
→ Confirme que o MySQL está rodando e que as variáveis `DB_*` no `.env` estão corretas  
→ Confirme que o `mysql/init.sql` foi importado

**WeaponPaints não carrega (erro no log)**  
→ Verifique se `FollowCS2ServerGuidelines` está como `false` em `configs/core.json` — o instalador faz isso automaticamente

**Windows: erro "não é possível executar scripts"**  
→ Execute no PowerShell: `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`

**Download lento (~30 GB)**  
→ Normal na primeira instalação. Atualizações futuras são incrementais.
