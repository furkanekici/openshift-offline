#!/bin/bash

# Define directories and domain
CERT_DIR="/data/cert"
DOCKER_CERT_DIR="/etc/docker/certs.d/harbor.registry.openshift.test"
DOMAIN="harbor.registry.openshift.test"
COUNTRY="TR"
STATE="Ankara"
LOCALITY="Ankara"
ORGANIZATION="TrustBT"
ORG_UNIT="IT"
DAYS=3650

# Create directories
mkdir -p "$CERT_DIR"
mkdir -p "$DOCKER_CERT_DIR"

# Generate CA key and certificate
openssl genrsa -out "$CERT_DIR/ca.key" 4096
openssl req -x509 -new -nodes -sha512 -days $DAYS \
 -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORG_UNIT/CN=$DOMAIN" \
 -key "$CERT_DIR/ca.key" \
 -out "$CERT_DIR/ca.crt"

# Generate server key and CSR
openssl genrsa -out "$CERT_DIR/$DOMAIN.key" 4096
openssl req -sha512 -new \
    -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORG_UNIT/CN=$DOMAIN" \
    -key "$CERT_DIR/$DOMAIN.key" \
    -out "$CERT_DIR/$DOMAIN.csr"

# Create v3.ext file
cat > "$CERT_DIR/v3.ext" <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$DOMAIN
DNS.2=harbor.registry
DNS.3=registry
EOF

# Generate server certificate
openssl x509 -req -sha512 -days $DAYS \
    -extfile "$CERT_DIR/v3.ext" \
    -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial \
    -in "$CERT_DIR/$DOMAIN.csr" \
    -out "$CERT_DIR/$DOMAIN.crt"

# Copy certificates to Docker cert directory
cp "$CERT_DIR/$DOMAIN.crt" "$DOCKER_CERT_DIR/"
cp "$CERT_DIR/$DOMAIN.key" "$DOCKER_CERT_DIR/"
cp "$CERT_DIR/ca.crt" "$DOCKER_CERT_DIR/"

# Convert crt to cert for Docker
openssl x509 -inform PEM -in "$CERT_DIR/$DOMAIN.crt" -out "$DOCKER_CERT_DIR/$DOMAIN.cert"

