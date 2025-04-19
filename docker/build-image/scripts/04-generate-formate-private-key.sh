#!/bin/sh

SCRIPT_NAME="format-private-key"
SCRIPT_PATH="/usr/bin/$SCRIPT_NAME"

echo "Creating the $SCRIPT_NAME script..."

# Write the script content to /usr/bin
cat << 'EOF' > "$SCRIPT_PATH"
#!/bin/sh

# Check if the private key variable is provided
if [ -z "$1" ]; then
  echo "Usage: $0 '<private_key>'"
  exit 1
fi

PRIVATE_KEY="$1"
SSH_DIR="$HOME/.ssh"
KEY_FILE="$SSH_DIR/id_rsa"

# Create the .ssh directory if it doesn't exist
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Format the private key properly
# Use echo with option -e to interpret backslash escapes
# This allows proper handling of newlines in the key
echo -e "$PRIVATE_KEY" > "$KEY_FILE"

# Ensure the file has correct permissions
chmod 600 "$KEY_FILE"

echo "Private key saved successfully at $KEY_FILE"
EOF

# Make the script executable
chmod +x "$SCRIPT_PATH"

echo "$SCRIPT_NAME script created and added to /usr/bin. You can now execute it anywhere."

echo "Updating Docker Image"
