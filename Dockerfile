FROM cm2network/steamcmd:latest

ENV CS2_DIR=/home/steam/cs2server
ENV STEAMAPP_ID=730

USER steam
WORKDIR /home/steam

# Sem RUN de instalação do CS2
# Sem COPY de cfg/plugins/addons (já são volumes no compose)

EXPOSE 27015/udp
EXPOSE 27015/tcp
EXPOSE 27020/udp

COPY --chown=steam:steam scripts/entrypoint.sh /home/steam/entrypoint.sh
RUN chmod +x /home/steam/entrypoint.sh

ENTRYPOINT ["/home/steam/entrypoint.sh"]
