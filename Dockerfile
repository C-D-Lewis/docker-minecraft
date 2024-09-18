FROM ubuntu:jammy AS platform

RUN apt update --fix-missing && apt upgrade -y
RUN apt install -y curl jq

# Install java 22 for MC 1.21.1+
WORKDIR /opt
ADD ./scripts/install-platform-java.sh .
RUN ./install-platform-java.sh
RUN java --version || (echo "java was not found" && false)

################################################################

FROM platform

ARG CONFIG
RUN test -n "$CONFIG" || (echo "CONFIG  not set" && false)

# Primary port
EXPOSE 25565/tcp
# Alternative port
EXPOSE 25566/tcp
# Dynmap
EXPOSE 8123/tcp

WORKDIR /server

# Copy always
ADD ./scripts ./scripts

# Copy server-specific config first
ADD ./config/${CONFIG}/config.json .

# Download required minecraft server
RUN ./scripts/fetch-server.sh

# Then all other files for optimal layering
ADD ./config/${CONFIG} .

CMD ["/server/scripts/start.sh"]
