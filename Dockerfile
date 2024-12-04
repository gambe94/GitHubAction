FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SF_AUTOUPDATE_DISABLE=true
ENV SFDX_CONTAINER_MODE=true

# Update the package lists, install necessary packages, and clean up in one command to reduce layers
RUN apt-get update && apt-get install -y --no-install-recommends \
  wget \
  xz-utils \
  ca-certificates \
  jq \
  bc \
  git \
  python3 \
  python3-pip \
  xmlstarlet \
  sudo \
  curl \
  && rm -rf /var/lib/apt/lists/*

# Create a symbolic link from python3 to python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Node.js (LTS version) and update npm to the latest version
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && npm install -g npm@latest \
  && rm -rf /var/lib/apt/lists/*

# Install Salesforce CLI
RUN npm install --global @salesforce/cli

# Verify Salesforce CLI installation
RUN sf --version

# Create user and set permissions for sfautomation
RUN useradd -m -s /bin/bash sfautomation && \
    mkdir -p /home/sfautomation/.npm && \
    chown -R sfautomation:sfautomation /home/sfautomation

RUN echo "sfautomation ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set working directory
WORKDIR /home/sfautomation

# Set default user
USER sfautomation

