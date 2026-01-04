FROM debian:bookworm-slim AS platform

ARG ON_AWS=false

RUN apt update --fix-missing && \
  apt upgrade -y && \
  apt install -y curl jq && \
  # Clean up APT cache immediately
  rm -rf /var/lib/apt/lists/*

# Install java 22 for MC 1.21.1+
ADD ./scripts/install-platform-java.sh .
RUN ./install-platform-java.sh
RUN java --version || (echo "java was not found" && false)

RUN if [ "$ON_AWS" = "true" ]; then \
  # Install python3 for healthcheck server and AWS CLI
  apt update && \
  apt install -y python3 python3-pip unzip zip && \
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
ADD ./servers/${SERVER_NAME}/config.json .

# Download required minecraft server
ADD ./scripts/fetch-server.sh .
RUN ./fetch-server.sh

# Copy other scripts
ADD ./scripts ./scripts

# Copy all server-specific files the MC server expects at the top
# For PaperMC, this also copies the 'config' dif
ADD ./servers/${SERVER_NAME} .

# Copy config dir in places scripts expect it
# TODO: Can this be rolled into the above layer?
ADD ./servers/${SERVER_NAME} ./servers/${SERVER_NAME}/

# Remove any added plugins before being mounted
RUN rm -rf ./plugins

# For Forge/modded servers
ADD libraries ./libraries

CMD ["/server/scripts/start.sh"]
