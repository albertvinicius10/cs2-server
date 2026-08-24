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

# ─── Instala frameworks Linux ────────────────────────
LINUX_ADDONS_SRC="${SCRIPT_DIR}/game/linux/csgo/addons"
LINUX_ADDONS_DEST="${CS2_DIR}/game/csgo/addons"
if [ -d "${LINUX_ADDONS_SRC}" ]; then
  mkdir -p "${LINUX_ADDONS_DEST}"
  cp -r "${LINUX_ADDONS_SRC}/." "${LINUX_ADDONS_DEST}/"
  success "Metamod e CounterStrikeSharp Linux copiados"
else
  warn "Frameworks Linux não encontrados em ${LINUX_ADDONS_SRC}"
fi

# ─── Registra Metamod no gameinfo ─────────────────────
GAMEINFO_FILE="${CS2_DIR}/game/csgo/gameinfo.gi"
if [ -f "${GAMEINFO_FILE}" ] && ! grep -Eq '^[[:space:]]*Game[[:space:]]+csgo/addons/metamod[[:space:]]*$' "${GAMEINFO_FILE}"; then
  cp "${GAMEINFO_FILE}" "${GAMEINFO_FILE}.bak"
  python3 - "${GAMEINFO_FILE}" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
replacement = r"\1\t\tGame\tcsgo/addons/metamod\n"
updated, count = re.subn(
    r"(?m)^(\s*Game_LowViolence\s+csgo_lv[^\r\n]*\r?\n)",
    replacement,
    text,
    count=1,
)
if count != 1:
    raise SystemExit("Não foi possível registrar Metamod no gameinfo.gi")
path.write_text(updated, encoding="utf-8")
PY
  success "Metamod registrado no gameinfo.gi"
fi

# ─── Copia configs ───────────────────────────────────
CFG_DEST="${CS2_DIR}/game/csgo/cfg"
ADDONS_ROOT="${CS2_DIR}/game/csgo/addons/counterstrikesharp"
mkdir -p "${CFG_DEST}/matchzy"

if [ -f "${SCRIPT_DIR}/cfg/server.cfg" ]; then
  cp "${SCRIPT_DIR}/cfg/server.cfg" "${CFG_DEST}/server.cfg"
  success "server.cfg copiado"
fi

if [ -f "${SCRIPT_DIR}/cfg/admins.json" ]; then
  mkdir -p "${ADDONS_ROOT}/configs"
  cp "${SCRIPT_DIR}/cfg/admins.json" "${ADDONS_ROOT}/configs/admins.json"
  success "admins.json copiado"
fi

if [ -f "${SCRIPT_DIR}/cfg/matchzy/matchzy.cfg" ]; then
  cp "${SCRIPT_DIR}/cfg/matchzy/matchzy.cfg" "${CFG_DEST}/matchzy/matchzy.cfg"
  success "matchzy.cfg copiado"
fi

MATCHZY_PRESETS_SRC="${SCRIPT_DIR}/plugins/MatchZy-0.8.15/cfg/MatchZy"
if [ -d "${MATCHZY_PRESETS_SRC}" ]; then
  mkdir -p "${CFG_DEST}/MatchZy"
  cp "${MATCHZY_PRESETS_SRC}"/*.cfg "${CFG_DEST}/MatchZy/"
  success "Presets do MatchZy copiados"
fi

# ─── Copia plugins ───────────────────────────────────
PLUGINS_SRC="${SCRIPT_DIR}/plugins"
ADDONS_ROOT="${CS2_DIR}/game/csgo/addons/counterstrikesharp"
ADDONS_DEST="${ADDONS_ROOT}/plugins"

if [ -d "${PLUGINS_SRC}" ] && [ "$(ls -A "${PLUGINS_SRC}" 2>/dev/null | grep -v .gitkeep)" ]; then
  info "Copiando plugins..."
  mkdir -p "${ADDONS_DEST}"

  MATCHZY_ROOT="${PLUGINS_SRC}/MatchZy-0.8.15"
  if [ -d "${MATCHZY_ROOT}/addons/counterstrikesharp/plugins" ]; then
    cp -r "${MATCHZY_ROOT}/addons/counterstrikesharp/plugins/." "${ADDONS_DEST}/"
  fi

  RETAKES_ROOT="${PLUGINS_SRC}/RetakesPlugin-3.1.0/addons/counterstrikesharp"
  if [ -d "${RETAKES_ROOT}/plugins" ]; then
    cp -r "${RETAKES_ROOT}/plugins/." "${ADDONS_DEST}/"
  fi
  if [ -d "${RETAKES_ROOT}/shared" ]; then
    mkdir -p "${ADDONS_ROOT}/shared"
    cp -r "${RETAKES_ROOT}/shared/." "${ADDONS_ROOT}/shared/"
  fi

  DEATHMATCH_SRC="${PLUGINS_SRC}/Deathmatch"
  if [ -f "${DEATHMATCH_SRC}/Deathmatch.dll" ]; then
    cp -r "${DEATHMATCH_SRC}" "${ADDONS_DEST}/"
  fi
  if [ -d "${DEATHMATCH_SRC}/shared" ]; then
    mkdir -p "${ADDONS_ROOT}/shared"
    cp -r "${DEATHMATCH_SRC}/shared/." "${ADDONS_ROOT}/shared/"
  fi

  WEAPONPAINTS_SRC="${PLUGINS_SRC}/WeaponPaints"
  if [ -f "${WEAPONPAINTS_SRC}/WeaponPaints.dll" ]; then
    cp -r "${WEAPONPAINTS_SRC}" "${ADDONS_DEST}/"
  fi

  if [ -d "${PLUGINS_SRC}/gamedata" ]; then
    mkdir -p "${ADDONS_ROOT}/gamedata"
    cp -r "${PLUGINS_SRC}/gamedata/." "${ADDONS_ROOT}/gamedata/"
  fi
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
