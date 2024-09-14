FROM ubuntu:jammy AS base

RUN apt update --fix-missing && apt upgrade -y
RUN apt install -y curl

# Install java 22 for MC 1.21.1+
WORKDIR /opt
ADD ./scripts/install-platform-java.sh .
RUN ./install-platform-java.sh

################################################################

FROM base

EXPOSE 25565/tcp

WORKDIR /server

ADD . .

CMD ["/server/scripts/start.sh"]
