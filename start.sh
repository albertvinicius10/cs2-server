#!/bin/bash
# ═══════════════════════════════════════════════════════
#   CS2 Dedicated Server — Inicializador Linux
#   Uso: bash start.sh
# ═══════════════════════════════════════════════════════
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CS2_DIR="${HOME}/cs2server"
CS2_BINARY="${CS2_DIR}/game/bin/linuxsteamrt64/cs2"

# ─── Cores ───────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[AVISO]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; exit 1; }

echo ""
echo "══════════════════════════════════════════════"
echo "   CS2 Dedicated Server — Iniciando (Linux)"
echo "══════════════════════════════════════════════"
echo ""

# ─── Carrega .env ────────────────────────────────────
ENV_FILE="${SCRIPT_DIR}/.env"
if [ -f "${ENV_FILE}" ]; then
  # Exporta todas as variáveis do .env (ignora linhas vazias e comentários)
  set -a
  # shellcheck disable=SC1090
  source <(grep -v '^\s*#' "${ENV_FILE}" | grep -v '^\s*$')
  set +a
  info ".env carregado"
else
  warn "Arquivo .env não encontrado. Usando valores padrão."
fi

# ─── Verifica instalação ─────────────────────────────
if [ ! -f "${CS2_BINARY}" ]; then
  error "CS2 não encontrado em ${CS2_BINARY}\n       Execute primeiro: bash install.sh"
fi

# ─── Verifica token ──────────────────────────────────
if [ -z "${STEAM_TOKEN}" ]; then
  warn "STEAM_TOKEN não definido! Servidor não aparecerá na lista pública."
  warn "Obtenha em: https://steamcommunity.com/dev/managegameservers"
fi

# ─── Inicia CS2 ──────────────────────────────────────
info "Iniciando CS2 Dedicated Server..."
info "Nome:  ${SERVER_NAME:-CS2 Server 5x5}"
info "Porta: ${SERVER_PORT:-27015}"
echo ""

exec "${CS2_BINARY}" \
  -dedicated \
  -console \
  -usercon \
  -nobots \
  -port "${SERVER_PORT:-27015}" \
  +game_type 0 \
  +game_mode 1 \
  +mapgroup mg_active \
  +map "${START_MAP:-de_dust2}" \
  +sv_setsteamaccount "${STEAM_TOKEN:-}" \
  +hostname "${SERVER_NAME:-CS2 Server 5x5}" \
  +sv_password "${SERVER_PASSWORD:-}" \
  +sv_cheats 0 \
  +sv_lan 0
