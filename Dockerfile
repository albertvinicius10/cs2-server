FROM cm2network/steamcmd:latest

ENV CS2_DIR=/home/steam/cs2server
ENV STEAMAPP_ID=730

USER steam
WORKDIR /home/steam

# ─── NÃO instala o CS2 aqui ──────────────────────────────
# O entrypoint faz isso e salva no volume persistente

COPY --chown=steam:steam cfg/         ${CS2_DIR}/game/csgo/cfg/
COPY --chown=steam:steam plugins/     ${CS2_DIR}/game/csgo/addons/counterstrikesharp/plugins/
COPY --chown=steam:steam addons/      ${CS2_DIR}/game/csgo/addons/

EXPOSE 27015/udp
EXPOSE 27015/tcp
EXPOSE 27020/udp

COPY --chown=steam:steam scripts/entrypoint.sh /home/steam/entrypoint.sh
RUN chmod +x /home/steam/entrypoint.sh

ENTRYPOINT ["/home/steam/entrypoint.sh"]
