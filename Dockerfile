FROM ubuntu:jammy AS platform

RUN apt update --fix-missing && apt upgrade -y
RUN apt install -y curl jq

# Install java 22 for MC 1.21.1+
WORKDIR /opt
ADD ./scripts/install-platform-java.sh .
RUN ./install-platform-java.sh
RUN java --version || (echo "java was not found" && false)

# Install python3 for healthcheck server
RUN apt install -y python3 python3-pip
RUN python3 --version || (echo "python3 was not found" && false)

################################################################

FROM platform

ARG CONFIG
RUN test -n "$CONFIG" || (echo "CONFIG not set" && false)

WORKDIR /server

# Copy server-specific config first
ADD ./config/${CONFIG}/config.json .

# Download required minecraft server
ADD ./scripts/fetch-server.sh .
RUN ./fetch-server.sh

# Copy other scripts
ADD ./scripts ./scripts

# Then all other files for optimal layering
ADD ./config/${CONFIG} .

CMD ["/server/scripts/start.sh"]
