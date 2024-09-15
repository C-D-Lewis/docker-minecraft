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

EXPOSE 25565/tcp

WORKDIR /server

# Copy always
ADD ./scripts ./scripts

# Copy server-specific files
ADD ./config/${CONFIG} .

# Download required minecraft server
RUN ./scripts/fetch-server.sh

CMD ["/server/scripts/start.sh"]
