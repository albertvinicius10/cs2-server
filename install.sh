#!/bin/bash
# ═══════════════════════════════════════════════════════
#   CS2 Dedicated Server — Instalador Linux
#   Uso: bash install.sh
# ═══════════════════════════════════════════════════════
set -e

# ─── Configurações ────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEAMCMD_DIR="${HOME}/steamcmd"
CS2_DIR="${HOME}/cs2server"

# ─── Cores ───────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC}   $1"; }
warn()    { echo -e "${YELLOW}[AVISO]${NC} $1"; }
error()   { echo -e "${RED}[ERRO]${NC} $1"; exit 1; }

echo ""
echo "══════════════════════════════════════════════"
echo "   CS2 Dedicated Server — Instalador Linux"
echo "══════════════════════════════════════════════"
echo ""

# ─── Dependências ────────────────────────────────────
info "Verificando dependências..."

if ! command -v steamcmd &>/dev/null && [ ! -f "${STEAMCMD_DIR}/steamcmd.sh" ]; then
  info "Instalando SteamCMD..."

  # Detecta distro
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y lib32gcc-s1 curl tar
    mkdir -p "${STEAMCMD_DIR}"
    curl -sSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
      | tar -xz -C "${STEAMCMD_DIR}"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y glibc.i686 curl tar
    mkdir -p "${STEAMCMD_DIR}"
    curl -sSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
      | tar -xz -C "${STEAMCMD_DIR}"
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm lib32-gcc-libs curl tar
    mkdir -p "${STEAMCMD_DIR}"
    curl -sSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
      | tar -xz -C "${STEAMCMD_DIR}"
  else
    error "Distro não reconhecida. Instale o SteamCMD manualmente em: https://developer.valvesoftware.com/wiki/SteamCMD"
  fi

  success "SteamCMD instalado em ${STEAMCMD_DIR}"
else
  success "SteamCMD já instalado"
fi

STEAMCMD_BIN="${STEAMCMD_DIR}/steamcmd.sh"
[ ! -f "${STEAMCMD_BIN}" ] && STEAMCMD_BIN="$(command -v steamcmd)"

# ─── Instala / Atualiza CS2 ──────────────────────────
info "Baixando/atualizando CS2 Dedicated Server (~30 GB na primeira vez)..."
info "Pasta de instalação: ${CS2_DIR}"

"${STEAMCMD_BIN}" \
  +force_install_dir "${CS2_DIR}" \
  +login anonymous \
  +app_update 730 validate \
  +quit

success "CS2 instalado/atualizado com sucesso!"

# ─── Copia configs ───────────────────────────────────
CFG_DEST="${CS2_DIR}/game/csgo/cfg"
mkdir -p "${CFG_DEST}/matchzy"

if [ -f "${SCRIPT_DIR}/cfg/server.cfg" ]; then
  cp "${SCRIPT_DIR}/cfg/server.cfg" "${CFG_DEST}/server.cfg"
  success "server.cfg copiado"
fi

if [ -f "${SCRIPT_DIR}/cfg/matchzy/matchzy.cfg" ]; then
  cp "${SCRIPT_DIR}/cfg/matchzy/matchzy.cfg" "${CFG_DEST}/matchzy/matchzy.cfg"
  success "matchzy.cfg copiado"
fi

# ─── Copia plugins ───────────────────────────────────
PLUGINS_SRC="${SCRIPT_DIR}/plugins"
ADDONS_DEST="${CS2_DIR}/game/csgo/addons"

if [ -d "${PLUGINS_SRC}" ] && [ "$(ls -A "${PLUGINS_SRC}" 2>/dev/null | grep -v .gitkeep)" ]; then
  info "Copiando plugins..."
  cp -r "${PLUGINS_SRC}/." "${ADDONS_DEST}/counterstrikesharp/plugins/" 2>/dev/null || true
  success "Plugins copiados"
else
  warn "Pasta plugins/ está vazia. Instale Metamod + CounterStrikeSharp em ${ADDONS_DEST}/ manualmente."
fi

# ─── Finaliza ────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════"
echo -e "   ${GREEN}Instalação concluída!${NC}"
echo "══════════════════════════════════════════════"
echo ""
echo "  Próximos passos:"
echo "  1. Edite o arquivo .env com seu STEAM_TOKEN"
echo "  2. Execute: bash start.sh"
echo ""
echo "  CS2 instalado em: ${CS2_DIR}"
echo ""
