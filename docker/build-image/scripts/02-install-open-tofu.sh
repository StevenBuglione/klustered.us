#!/bin/sh

if [ -z "$1" ]; then
  echo "Usage: $0 <open_tofu_version>"
  exit 1
fi

OPEN_TOFU_VERSION=$1
APK_URL="https://github.com/opentofu/opentofu/releases/download/v${OPEN_TOFU_VERSION}/tofu_${OPEN_TOFU_VERSION}_amd64.apk"

echo "Installing OpenTofu version ${OPEN_TOFU_VERSION} on Alpine Linux..."

wget -q $APK_URL -O /tmp/tofu_"${OPEN_TOFU_VERSION}".apk
if [ $? -ne 0 ]; then
  echo "Failed to download OpenTofu APK. Please check the version and URL."
  exit 1
fi

apk add --allow-untrusted /tmp/tofu_"${OPEN_TOFU_VERSION}".apk
if [ $? -ne 0 ]; then
  echo "Failed to install OpenTofu APK."
  exit 1
fi

rm /tmp/tofu_"${OPEN_TOFU_VERSION}".apk

echo "OpenTofu version ${OPEN_TOFU_VERSION} installed successfully."