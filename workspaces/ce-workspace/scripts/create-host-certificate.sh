#!/bin/bash

# Set the file paths and details for the certificate
CA_CERT="/opt/GlideinWMS/secrets/gwms-workspace-ca-cert.pem"
CA_KEY="/opt/GlideinWMS/secrets/gwms-workspace-ca-key.pem"
KEY_FILE="/etc/grid-security/hostkey.pem"
CERT_FILE="/etc/grid-security/hostcert.pem"
PASSPHRASE="glideinwms"
COMMON_NAME="$HOSTNAME"
VALIDITY_PERIOD=365

# Generate a private key
openssl genpkey -algorithm RSA -out "$KEY_FILE" -pass pass:"$PASSPHRASE"

# Generate a certificate signing request (CSR)
openssl req -new -key "$KEY_FILE" -out "$CERT_FILE" -subj "/C=US/ST=Illinois/L=Batavia/O=Fermilab/CN=$COMMON_NAME"

# Generate a self-signed certificate using the CSR
openssl x509 -req -in "$CERT_FILE" -CA "$CA_CERT" -CAkey "$CA_KEY" -out "$CERT_FILE" -days "$VALIDITY_PERIOD"

cp "$CA_CERT" /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
