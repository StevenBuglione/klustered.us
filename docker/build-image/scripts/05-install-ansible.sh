#!/bin/sh
set -e

echo "Updating apk repositories..."
apk update

echo "Attempting to install Ansible from apk..."
set +e
apk add --no-cache ansible
status=$?
set -e

if [ $status -eq 0 ]; then
    echo "Ansible installed successfully using apk."
else
    echo "Installation via apk failed. Installing via pip."
    echo "Installing Python3 and pip..."
    apk add --no-cache python3 py3-pip
    echo "Installing Ansible using pip..."
    pip3 install ansible
fi

echo "Verifying Ansible installation..."
if command -v ansible >/dev/null 2>&1; then
    ansible --version
    echo "Ansible installation complete."
else
    echo "Ansible installation failed."
fi
