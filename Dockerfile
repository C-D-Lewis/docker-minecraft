FROM ubuntu:jammy AS platform

RUN apt update --fix-missing && apt upgrade -y
RUN apt install -y curl jq

# Install java 22 for MC 1.21.1+
WORKDIR /opt
ADD ./scripts/install-platform-java.sh .
RUN ./install-platform-java.sh
RUN java --version || (echo "java was not found" && false)

ARG ON_AWS=false
RUN if [ "$ON_AWS" = "true" ]; then \
  # Install python3 for healthcheck server
  apt install -y python3 python3-pip unzip && \
  python3 --version || (echo "python3 was not found" && false) && \
  # Install AWS CLI for fetching world
  pip install --no-cache-dir awscli && \
  aws --version || (echo "aws was not found" && false); \
fi

################################################################

FROM platform

ARG SERVER_NAME
RUN test -n "$SERVER_NAME" || (echo "SERVER_NAME not set" && false)

WORKDIR /server

# Copy server-specific config first
ADD ./config/${SERVER_NAME}/config.json .

# Download required minecraft server
ADD ./scripts/fetch-server.sh .
RUN ./fetch-server.sh

# Copy other scripts
ADD ./scripts ./scripts

# Then all other files for optimal layering
ADD ./config/${SERVER_NAME} .
ADD ./config/${SERVER_NAME} ./config/${SERVER_NAME}/

CMD ["/server/scripts/start.sh"]
