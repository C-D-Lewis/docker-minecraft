FROM debian:bookworm-slim AS platform

RUN apt update --fix-missing && \
  apt upgrade -y && \
  apt install -y curl jq && \
  # Clean up APT cache immediately
  rm -rf /var/lib/apt/lists/*

# Install java 22 for MC 1.21.1+
WORKDIR /opt
ADD ./scripts/install-platform-java.sh .
RUN ./install-platform-java.sh
RUN java --version || (echo "java was not found" && false)

ARG ON_AWS=false
RUN if [ "$ON_AWS" = "true" ]; then \
  # Install python3 for healthcheck server and AWS CLI
  apt update && \
  apt install -y python3 python3-pip unzip && \
  python3 --version || (echo "python3 was not found" && false) && \
  pip3 install --no-cache-dir awscli --break-system-packages && \
  aws --version || (echo "aws was not found" && false) && \
  # Clean up APT cache after Python/AWS install
  rm -rf /var/lib/apt/lists/*; \
fi

# Note: Should copy out only the files I need into smaller image in the next stage

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
