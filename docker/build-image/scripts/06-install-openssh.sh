#!/bin/sh

echo "Installing OpenSSH on Alpine Linux..."

# Install OpenSSH package
apk add --no-cache openssh openssh-client openssh-keygen openssh-sftp-server openssh-server-common

# Create SSH directory if it doesn't exist
mkdir -p /etc/ssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Generate host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  echo "Generating SSH host keys..."
  ssh-keygen -A
fi

# Set proper permissions
chmod 600 ~/.ssh/* 2>/dev/null || true

echo "OpenSSH installed successfully."