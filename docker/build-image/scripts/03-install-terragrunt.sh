#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 <terragrunt_version>"
  exit 1
fi

TERRAGRUNT_VERSION=$1
APK_URL="https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"

echo "Installing Terragrunt version ${TERRAGRUNT_VERSION} on Alpine Linux..."

wget -q $APK_URL -O /tmp/terragrunt
if [ $? -ne 0 ]; then
  echo "Failed to download terragrunt. Please check the version and URL."
  exit 1
fi

mv /tmp/terragrunt /usr/bin/terragrunt && chmod +x /usr/bin/terragrunt

echo "Terragrunt version ${TERRAGRUNT_VERSION} installed successfully."