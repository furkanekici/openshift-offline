#!/bin/bash

# Set directory and file paths
HARBOR_DIR="/root/packages/harbor"
ENV_DIR="/root/packages/scripts/envs"
HARBOR_YAML="$HARBOR_DIR/harbor.yml"
HARBOR_INSTALL_SCRIPT="$HARBOR_DIR/install.sh"
HARBOR_ENV_FILE="$ENV_DIR/harbor-config.env"

# Copy harbor.yml template
cp "$HARBOR_DIR/harbor.yml.tmpl" "$HARBOR_YAML"

# Function to get environment variable value from harbor-config.env
get_env_value() {
    local var_name=$1
    local default_value=$2
    local value=$(grep "^$var_name=" "$HARBOR_ENV_FILE" | cut -d'=' -f2-)
    echo ${value:-$default_value}
}

# Load environment variables from harbor-config.env
if [ -f "$HARBOR_ENV_FILE" ]; then
    CERT_PATH=$(get_env_value "certificate-path" "")
    KEY_PATH=$(get_env_value "private-key-path" "")
    ADMIN_PASSWORD=$(get_env_value "password" "Harbor12345")
    EXTERNAL_URL=$(get_env_value "external-url" "harbor.registry.openshift.test")
else
    echo "Harbor configuration environment file not found at $HARBOR_ENV_FILE"
    exit 1
fi

# Update values in harbor.yml file
sed -i "s|hostname: reg.mydomain.com|hostname: $EXTERNAL_URL|" "$HARBOR_YAML"
sed -i "s|certificate: /your/certificate/path|certificate: $CERT_PATH|" "$HARBOR_YAML"
sed -i "s|private_key: /your/private/key/path|private_key: $KEY_PATH|" "$HARBOR_YAML"
sed -i "s|harbor_admin_password: Harbor12345|harbor_admin_password: $ADMIN_PASSWORD|" "$HARBOR_YAML"
sed -i "s|# external_url: https://reg.mydomain.com:8433|external_url: https://$EXTERNAL_URL|" "$HARBOR_YAML"

# Run Harbor installation script
if [ -f "$HARBOR_INSTALL_SCRIPT" ]; then
    bash "$HARBOR_INSTALL_SCRIPT"
else
    echo "Harbor installation script not found at $HARBOR_INSTALL_SCRIPT"
    exit 1
fi

