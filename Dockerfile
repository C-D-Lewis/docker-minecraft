FROM ubuntu:jammy AS base

RUN apt update --fix-missing && apt upgrade -y
RUN apt install -y curl

# Install java 22 for MC 1.21.1+
WORKDIR /opt
ADD ./scripts/install-platform-java.sh .
RUN ./install-platform-java.sh
RUN tar -xzf java.tar.gz
RUN update-alternatives --install /usr/bin/java java /opt/jdk-22.0.2/bin/java 1

################################################################

FROM base

EXPOSE 25565/tcp

WORKDIR /server

ADD ./server .
ADD ./scripts/start.sh .

CMD ["/server/start.sh"]
