FROM mcr.microsoft.com/vscode/devcontainers/base:0-buster

#-----------------------------------------------------------
# Project Details
#-----------------------------------------------------------

LABEL project="swarm-manager"
LABEL github="https://github.com/CryptoKasm/9c-swarm-manager"
LABEL maintainer="CryptoKasm"
LABEL discord="https://discord.gg/CYaSzs4CSk"

#-----------------------------------------------------------
# Base Setup
#-----------------------------------------------------------

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby CLI instead of the licensed Docker CLI
ARG USE_MOBY="true"

# Install needed packages and setup non-root user.
ARG USERNAME=automatic
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh /tmp/library-scripts/
RUN apt-get update \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    # Use Docker script from script library to set things up
    && /bin/bash /tmp/library-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}" \
    # Clean up
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts/

RUN apt-get install jq -y

#-----------------------------------------------------------
# Settings
#-----------------------------------------------------------

# Enable/Disable Debugging
ENV DEBUG="1"

# Enable/disable Advanced Debugging
ENV TRACE="1"

# Development mode with less security and a demo account
ENV DEV_MODE="true"

# Disable mining (Node only)
ENV DISABLE_MINING="false"

# Disable PrivateKey at runtime
ENV DISABLE_PRIVATE_KEY="false"

# Nine Chronicles Private Key **KEEP SECRET**
ENV PRIVATE_KEY="DISABLE"

# Amount of miners to deploy
ENV MINERS="1"

# GraphQL Forwarding Port
ENV GRAPHQL_PORT="23075"

# Peer Forwarding Port
ENV PEER_PORT="31275"

# Set MAX RAM Per Miner **PROTECTION FROM MEMORY LEAKS**
ENV RAM_LIMIT="4096M"

# Set MIN RAM Per Miner **SAVES RESOURCES FOR THAT CONTAINER**
ENV RAM_RESERVE="2048M"

# Enable GraphQL Query Commands
ENV AUTHORIZE_GRAPHQL="1"

# Enable/Disable CORS policy (For development)
ENV DISABLE_CORS="false"

# Auto-restart after set time (in hours)
ENV AUTO_RESTART="2"

# Filters to GREP out of miner logs (0 None, # of Miner, ALL)
ENV MINER_LOG_FILTERS="ALL"

# Set MINER name (example)
# NAME_MINER_1="Joe"

#-----------------------------------------------------------
# Entrypoint /w ARGs
#-----------------------------------------------------------

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]