#!/bin/bash

# Create a directory for your certificates

mkdir -p proxy/ssl

# Generate a private key (2048-bit)

openssl genrsa -out proxy/ssl/server.key 2048

# Generate a certificate signing request (CSR)

openssl req -new -key proxy/ssl/server.key -out proxy/ssl/server.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=localhost"

# Generate a self-signed certificate valid for 1 year (365 days)

openssl x509 -req -days 365 -in proxy/ssl/server.csr -signkey proxy/ssl/server.key -out proxy/ssl/server.crt

# (Optional) Verify the certificate

openssl x509 -in proxy/ssl/server.crt -text -noout