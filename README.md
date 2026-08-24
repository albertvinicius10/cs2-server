# CS2 Server 5x5 — Linux & Windows

Servidor competitivo CS2 com **MatchZy** e **WeaponPaints** (skins/facas/luvas).  
Funciona nativamente no **Linux** e no **Windows** — sem Docker.

---

## Pré-requisitos

| | Linux | Windows |
|---|---|---|
| **Sistema** | Ubuntu 20.04+, Debian 11+, Fedora 37+, Arch | Windows 10/11 64-bit |
| **RAM** | 8 GB+ | 8 GB+ |
| **Disco** | 35 GB livres | 35 GB livres |
| **PowerShell** | — | 5.1+ (já incluso no Windows 10+) |
| **MySQL** | `sudo apt install mysql-server` | [MySQL Community](https://dev.mysql.com/downloads/mysql/) |

---

## 1. Configuração inicial

### 1.1 Copie e edite o `.env`

```bash
cp .env.example .env
```

Edite o `.env`:

```env
SERVER_NAME="Meu Servidor 5x5"
SERVER_PASSWORD=        # vazio = sem senha
SERVER_PORT=27015
START_MAP=de_dust2

STEAM_TOKEN=            # veja abaixo como obter
```

### 1.2 Steam Token (para servidor público)

1. Acesse: https://steamcommunity.com/dev/managegameservers
2. Crie com **App ID: 730**
3. Cole no `.env` → `STEAM_TOKEN=SEU_TOKEN`

> Para teste local na LAN, pode deixar em branco.

---

## 2. Instalar o servidor CS2

### No Linux

```bash
bash install.sh
```

O script instala o SteamCMD automaticamente e baixa o CS2 (~30 GB).

### No Windows

Abra o **PowerShell como Administrador** e execute:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\install.ps1
```

> O CS2 será instalado em `%USERPROFILE%\cs2server`

---

## 3. Metamod e CounterStrikeSharp

Esses componentes são obrigatórios para carregar os plugins. O repositório mantém
os frameworks separados por plataforma:

```text
game/linux/csgo/addons/    # Ubuntu 22.04 / Linux
game/csgo/addons/          # Windows
```

O `install.sh` copia somente `game/linux/csgo/addons/` para a VPS. O `install.ps1`
usa os arquivos Windows. Não misture `win64/*.dll` com `linuxsteamrt64/*.so`.

Os arquivos Linux incluídos foram baixados de:

- CounterStrikeSharp `v1.0.372` com runtime:
  https://github.com/roflmuffin/CounterStrikeSharp/releases/tag/v1.0.372
- Metamod:Source Linux build `1410`:
  https://www.sourcemm.net/downloads.php?branch=master

Se atualizar esses frameworks, baixe sempre o pacote correspondente à plataforma.

---

## 4. Instalar plugins

### MatchZy
1. Baixe em: https://github.com/shobhit-pathak/MatchZy/releases
2. Coloque em: `plugins/MatchZy/`
3. O `install.sh` / `install.ps1` copia automaticamente para o CS2

### Retakes
Plugin usado para partidas de retomada de bombsite.

- Projeto: https://github.com/B3none/cs2-retakes
- Arquivos já incluídos em `plugins/RetakesPlugin-3.1.0/`
- Dependência `RetakesPluginShared` incluída

### Deathmatch
Plugin usado para respawn, FFA/Team Deathmatch, escolha de armas e modos personalizados.

- Projeto: https://github.com/NockyCZ/CS2-Deathmatch
- Arquivos já incluídos em `plugins/Deathmatch/`
- O pacote inclui `DeathmatchAPI`, necessário para o plugin carregar

### WeaponPaints (skins, facas e luvas)
1. Baixe em: https://github.com/Nereziel/cs2-WeaponPaints/releases
2. Coloque em: `plugins/WeaponPaints/`
3. Depois do primeiro carregamento, configure:
   `game/csgo/addons/counterstrikesharp/configs/plugins/WeaponPaints/WeaponPaints.json`

```json
{
  "DatabaseHost": "localhost",
  "DatabasePort": 3306,
  "DatabaseUser": "cs2user",
  "DatabasePassword": "cs2senha123",
  "DatabaseName": "cs2"
}
```

4. Importe o banco de dados:
   ```bash
   # Linux
   mysql -u root -p < mysql/init.sql

   # Windows (no MySQL Command Line Client)
   source caminho\para\mysql\init.sql
   ```

> O `start.sh` e o `start.ps1` executam `configure_weaponpaints.py` antes de iniciar.
> Ele lê `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` e `DB_NAME` do `.env` e atualiza
> o `WeaponPaints.json` privado. Assim, não é necessário configurar o banco manualmente
> depois de cada reinicialização.

> Nunca publique `.env`, Steam Token ou senha do banco no GitHub. Como essas credenciais
> já foram expostas durante a configuração, gere um novo Steam Token e troque a senha do banco.

---

## 5. Iniciar o servidor

### Linux

```bash
bash start.sh
```

### Windows

```powershell
.\start.ps1
```

---

## 6. Conectar ao servidor

No console do CS2:
```
connect localhost:27015
```

Ou via menu **Jogar → Servidores da comunidade** (LAN).

---

## 7. Comandos e modos

### Competitivo / MatchZy

Comandos de jogador:

| Comando | Função |
|---------|--------|
| `!ready` | Marcar como pronto |
| `!unready` | Remover o estado pronto |
| `!pause` | Solicitar pause |
| `!unpause` | Solicitar o fim do pause |
| `!ws` | Abrir menu de skins |
| `!knife` | Abrir menu de facas |
| `!gloves` | Abrir menu de luvas |

Comandos de admin:

| Comando | Função |
|---------|--------|
| `!start` | Iniciar partida configurada |
| `!forcerestart` | Reiniciar a partida |
| `!forceend` | Encerrar a partida |
| `!map <mapa>` | Trocar de mapa |

### Practice

Comandos principais do MatchZy:

| Comando | Função |
|---------|--------|
| `.bot` | Adicionar/remover bots |
| `.spawn` | Mostrar/usar posições de spawn |
| `.ctspawn` | Ir para spawn CT |
| `.tspawn` | Ir para spawn T |
| `.nobots` | Remover bots |
| `.rethrow` | Repetir a última granada |
| `.last` | Repetir a última ação/lançamento |
| `.timer` | Mostrar o timer de treino |
| `.clear` | Limpar granadas |
| `.exitprac` | Sair do practice |

### Retakes

O modo começa automaticamente quando o plugin está ativo e há jogadores suficientes.
Use `!ready` somente se o MatchZy estiver controlando a partida.

| Comando | Permissão | Função |
|---------|-----------|--------|
| `!mapconfigs` | Admin | Listar configurações de mapas |
| `!mapconfig <mapa>` | Admin | Carregar config, por exemplo `!mapconfig de_mirage` |
| `!forcebombsite A\|B` | Admin | Forçar o bombsite |
| `!forcebombsitestop` | Admin | Remover o bombsite forçado |
| `!scramble` | Admin | Embaralhar times na próxima rodada |
| `!scrambleteams` | Admin | Alias de `!scramble` |
| `!voices` | Jogador | Alternar anúncios de voz |
| `!showspawns A\|B` | Admin | Mostrar spawns do bombsite |
| `!spawns A\|B` | Admin | Alias de `!showspawns` |
| `!addspawn <CT\|T> <Y\|N>` | Admin | Adicionar spawn |
| `!removespawn` | Admin | Remover o spawn mais próximo |
| `!nearestspawn` | Admin | Teleportar para o spawn mais próximo |
| `!hidespawns` | Admin | Sair do editor de spawns |

Comandos no console do servidor:

```text
retakes_enabled 1
mp_restartgame 1
```

### Deathmatch

O Deathmatch usa o modo nativo do CS2. Para iniciar pelo console do servidor:

```text
game_type 1
game_mode 2
map de_mirage
```

Comandos administrativos do plugin:

| Comando | Função |
|---------|--------|
| `css_dm_startmode` | Definir/iniciar o modo configurado |
| `css_dm_spawns` | Ativar/desativar editor de spawns |
| `css_dm_spawnseditor` | Alias do editor de spawns |
| `css_dm_editor` | Ativar/desativar editor de spawns |
| `css_dm_checkdistance` | Verificar distância entre spawns |

Os comandos de seleção de armas dependem da configuração do plugin e aparecem no
menu do Deathmatch. Não use Deathmatch e Retakes simultaneamente no mesmo mapa.

### Comandos gerais do servidor

```text
css_plugins list
css_plugins load Deathmatch
css_plugins unload Deathmatch
css_plugins load RetakesPlugin
css_plugins unload RetakesPlugin
```

`css_plugins` deve ser usado no console do servidor. Para trocar de modo, reinicie o
mapa depois de carregar ou descarregar o plugin correspondente.

---

## 8. Estrutura de arquivos

```
cs2-server/
├── .env                    ← suas configurações (não suba no git!)
├── .env.example            ← modelo do .env
├── install.sh              ← instala CS2 no Linux
├── install.ps1             ← instala CS2 no Windows
├── start.sh                ← inicia o servidor no Linux
├── start.ps1               ← inicia o servidor no Windows
├── cfg/
│   ├── server.cfg          ← configuração principal
│   └── matchzy/
│       └── matchzy.cfg     ← configuração das partidas
├── plugins/                ← seus plugins (MatchZy, WeaponPaints...)
└── mysql/
    └── init.sql            ← cria as tabelas no banco
```

---

## 9. Atualizar o CS2

Basta rodar o instalador novamente — ele só baixa o que mudou:

```bash
# Linux
bash install.sh

# Windows
.\install.ps1
```

---

## Problemas comuns

**Servidor não aparece na lista pública**
→ Verifique se `STEAM_TOKEN` está preenchido no `.env`

**Plugins não carregam**
→ Verifique se Metamod e CounterStrikeSharp estão instalados em `addons/`

**Erro de conexão MySQL (WeaponPaints)**
→ Confirme que o MySQL está rodando e os dados do `.env` estão corretos

**Windows: "não é possível executar scripts"**
→ Execute no PowerShell: `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`

**Download lento (~30 GB)**
→ É normal na primeira vez. Atualizações futuras são incrementais.
