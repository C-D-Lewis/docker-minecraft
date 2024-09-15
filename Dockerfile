FROM ubuntu:jammy AS platform

RUN apt update --fix-missing && apt upgrade -y
RUN apt install -y curl

# Install java 22 for MC 1.21.1+
WORKDIR /opt
ADD ./scripts/install-platform-java.sh .
RUN ./install-platform-java.sh
RUN tar -xzf java.tar.gz
RUN update-alternatives --install /usr/bin/java java /opt/jdk-22.0.2/bin/java 1

# Verify java
RUN java --version && sleep 5

################################################################

FROM platform

ARG CONFIG
RUN test -n "$CONFIG" || (echo "CONFIG  not set" && false)

EXPOSE 25565/tcp

WORKDIR /server

# Copy always
ADD ./scripts ./scripts
ADD ./eula.txt .

# Copy server-specific files
ADD ./config/${CONFIG} .

CMD ["/server/scripts/start.sh"]
