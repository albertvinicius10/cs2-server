# CS2 Server 5x5 — Docker

Servidor competitivo CS2 com MatchZy, WeaponPaints (skins/facas/luvas) e MySQL, tudo em Docker.

---

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado
- Pelo menos **8 GB de RAM** e **30 GB livres** no disco
- CS2 instalado na sua máquina (para conectar)

---

## 1. Configuração inicial

### 1.1 Edite o arquivo `.env`

```env
SERVER_NAME="Meu Servidor 5x5"
SERVER_PASSWORD=              # deixe vazio para sem senha
STEAM_TOKEN=                  # veja abaixo como pegar
MYSQL_PASSWORD=cs2senha123
MYSQL_ROOT_PASSWORD=rootsenha123
```

### 1.2 Steam Token (para servidor público)

1. Acesse: https://steamcommunity.com/dev/managegameservers
2. Crie um token com **App ID: 730**
3. Cole no `.env` no campo `STEAM_TOKEN`

> Para teste local, pode deixar vazio. O servidor vai funcionar na LAN.

---

## 2. Instalar a base do servidor → pasta `addons/`

Metamod e CounterStrikeSharp são a base que faz os plugins funcionarem. Ambos vão para a pasta `addons/`.

### Metamod:Source (CS2)
1. Acesse: https://www.sourcemm.net/downloads.php?branch=master
2. Baixe a versão **Linux CS2**
3. Extraia o conteúdo na pasta `addons/`

### CounterStrikeSharp
1. Acesse: https://github.com/roflmuffin/CounterStrikeSharp/releases
2. Baixe o arquivo `counterstrikesharp-with-runtime-linux.zip`
3. Extraia o conteúdo na pasta `addons/`

---

## 3. Instalar os plugins → pasta `plugins/`

Com a base instalada, agora os plugins de funcionalidade. Cada um vai em sua própria subpasta dentro de `plugins/`.

### MatchZy
1. Acesse: https://github.com/shobhit-pathak/MatchZy/releases
2. Baixe o `.zip` mais recente
3. Extraia na pasta `plugins/MatchZy/`

### WeaponPaints (skins, facas e luvas)
1. Acesse: https://github.com/Nereziel/cs2-WeaponPaints/releases
2. Baixe o `.zip` mais recente
3. Extraia na pasta `plugins/WeaponPaints/`
4. Configure o arquivo `plugins/WeaponPaints/WeaponPaints.json`:

```json
{
  "DatabaseHost": "mysql",
  "DatabasePort": 3306,
  "DatabaseUser": "exemplo",
  "DatabasePassword": "exemplo",
  "DatabaseName": "exemplo"
}
```

---

## 3. Subir o servidor

```bash
# Primeira vez (vai demorar — baixa o CS2 inteiro ~30 GB)
docker-compose up --build

# Próximas vezes
docker-compose up -d

# Ver logs em tempo real
docker-compose logs -f cs2

# Parar tudo
docker-compose down
```

---

## 4. Conectar ao servidor

No console do CS2:
```
connect localhost:27015
```

Ou pelo menu **Jogar > Servidores da comunidade** (LAN).

---

## 5. Comandos no jogo

### Para jogadores
| Comando | Função |
|---------|--------|
| `!ready` | Marcar como pronto |
| `!unready` | Desmarcar pronto |
| `!pause` | Solicitar pause |
| `!unpause` | Tirar pause |
| `!ws` | Menu de skins de armas |
| `!knife` | Menu de skins de faca |
| `!gloves` | Menu de luvas |

### Para admin
| Comando | Função |
|---------|--------|
| `!start` | Iniciar partida |
| `!forcerestart` | Reiniciar partida |
| `!forceend` | Encerrar partida |
| `!map de_inferno` | Trocar mapa |

---

## 6. Interface do banco de dados

Acesse o phpMyAdmin para ver e editar o banco:
```
http://localhost:8080
```

---

## 7. Estrutura de arquivos

```
cs2-server/
├── Dockerfile              ← imagem do servidor
├── docker-compose.yml      ← orquestração dos containers
├── .env                    ← suas configurações (não compartilhe!)
├── cfg/
│   ├── server.cfg          ← configuração principal
│   └── matchzy/
│       └── matchzy.cfg     ← configuração das partidas
├── plugins/                ← seus plugins CSS (MatchZy, WeaponPaints...)
├── addons/                 ← Metamod + CounterStrikeSharp
├── mysql/
│   └── init.sql            ← cria as tabelas automaticamente
└── scripts/
    └── entrypoint.sh       ← script de inicialização
```

---

## 8. Subir para VPS (quando estiver tudo funcionando)

```bash
# 1. Copie a pasta inteira para a VPS
scp -r cs2-server/ usuario@ip-da-vps:~/

# 2. Na VPS, instale o Docker
curl -fsSL https://get.docker.com | sh

# 3. Suba o servidor
cd cs2-server
docker-compose up -d
```

---

## Problemas comuns

**Servidor não aparece na lista**
→ Verifique se o `STEAM_TOKEN` está preenchido no `.env`

**Plugins não carregam**
→ Verifique se o Metamod e CounterStrikeSharp estão na pasta `addons/`

**Erro de MySQL**
→ Aguarde 30 segundos após subir — o MySQL demora para inicializar

**Download muito lento**
→ O CS2 tem ~30 GB, é normal demorar na primeira vez
