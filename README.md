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

## 3. Instalar Metamod + CounterStrikeSharp

Esses dois são a base para rodar plugins. Vão para a pasta `addons/` dentro do CS2.

### Metamod:Source
1. Baixe em: https://www.sourcemm.net/downloads.php?branch=master
   - Linux → versão **Linux CS2**
   - Windows → versão **Windows CS2**
2. Extraia em:
   - Linux: `~/cs2server/game/csgo/addons/`
   - Windows: `%USERPROFILE%\cs2server\game\csgo\addons\`

### CounterStrikeSharp
1. Baixe em: https://github.com/roflmuffin/CounterStrikeSharp/releases
   - Linux → `counterstrikesharp-with-runtime-linux.zip`
   - Windows → `counterstrikesharp-with-runtime-windows.zip`
2. Extraia na mesma pasta `addons/`

---

## 4. Instalar plugins

### MatchZy
1. Baixe em: https://github.com/shobhit-pathak/MatchZy/releases
2. Coloque em: `plugins/MatchZy/`
3. O `install.sh` / `install.ps1` copia automaticamente para o CS2

### WeaponPaints (skins, facas e luvas)
1. Baixe em: https://github.com/Nereziel/cs2-WeaponPaints/releases
2. Coloque em: `plugins/WeaponPaints/`
3. Configure `plugins/WeaponPaints/WeaponPaints.json`:

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

## 7. Comandos no jogo

### Jogadores
| Comando | Função |
|---------|--------|
| `!ready` | Marcar como pronto |
| `!unready` | Desmarcar pronto |
| `!pause` | Solicitar pause |
| `!unpause` | Tirar pause |
| `!ws` | Menu de skins de armas |
| `!knife` | Menu de skins de faca |
| `!gloves` | Menu de luvas |

### Admin
| Comando | Função |
|---------|--------|
| `!start` | Iniciar partida |
| `!forcerestart` | Reiniciar partida |
| `!forceend` | Encerrar partida |
| `!map de_inferno` | Trocar mapa |

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
