#!/bin/bash
set -e

CS2_DIR="/home/steam/cs2server"

echo "=============================================="
echo "  CS2 Server - Iniciando..."
echo "=============================================="

# ─── Atualiza o servidor antes de iniciar ────────────────────────────────────
echo "[INFO] Verificando atualizações do CS2..."
/home/steam/steamcmd/steamcmd.sh \
  +force_install_dir ${CS2_DIR} \
  +login anonymous \
  +app_update 730 \
  +quit

echo "[INFO] CS2 atualizado com sucesso!"

# ─── Verifica token obrigatório ───────────────────────────────────────────────
if [ -z "${STEAM_TOKEN}" ]; then
  echo "[AVISO] STEAM_TOKEN não definido! O servidor pode não aparecer na lista pública."
  echo "        Pegue seu token em: https://steamcommunity.com/dev/managegameservers"
fi

# ─── Inicia o servidor CS2 ───────────────────────────────────────────────────
echo "[INFO] Iniciando CS2 Dedicated Server..."
exec ${CS2_DIR}/game/bin/linuxsteamrt64/cs2 \
  -dedicated \
  -console \
  -usercon \
  -nobots \
  +game_type 0 \
  +game_mode 1 \
  +mapgroup mg_active \
  +map de_dust2 \
  +sv_setsteamaccount "${STEAM_TOKEN}" \
  +hostname "${SERVER_NAME:-CS2 Server 5x5}" \
  +sv_password "${SERVER_PASSWORD:-}" \
  +sv_cheats 0 \
  +sv_lan 0
