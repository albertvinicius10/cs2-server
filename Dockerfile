FROM cm2network/steamcmd:latest

# ─── Variáveis de ambiente ───────────────────────────────────────────────────
ENV CS2_DIR=/home/steam/cs2server
ENV STEAMAPP_ID=730

USER steam
WORKDIR /home/steam

# ─── Instala o CS2 via SteamCMD ──────────────────────────────────────────────
RUN ./steamcmd/steamcmd.sh \
    +force_install_dir ${CS2_DIR} \
    +login anonymous \
    +app_update ${STEAMAPP_ID} validate \
    +quit

# ─── Copia configs, plugins e addons ─────────────────────────────────────────
COPY --chown=steam:steam cfg/         ${CS2_DIR}/game/csgo/cfg/
COPY --chown=steam:steam plugins/     ${CS2_DIR}/game/csgo/addons/counterstrikesharp/plugins/
COPY --chown=steam:steam addons/      ${CS2_DIR}/game/csgo/addons/

# ─── Portas ──────────────────────────────────────────────────────────────────
EXPOSE 27015/udp
EXPOSE 27015/tcp
EXPOSE 27020/udp

# ─── Entrypoint ──────────────────────────────────────────────────────────────
COPY --chown=steam:steam scripts/entrypoint.sh /home/steam/entrypoint.sh
RUN chmod +x /home/steam/entrypoint.sh

ENTRYPOINT ["/home/steam/entrypoint.sh"]
