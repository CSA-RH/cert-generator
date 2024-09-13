# Bash Script for Generating Certificates with a Private CA (for Demo Purposes)

This script allows you to easily generate SSL certificates signed by a self-managed Private Certificate Authority (CA). It is designed for demonstration purposes, simplifying the creation of certificates with OpenSSL.

## Usage: 


```console
./gen-cert.sh <DOMAIN>
```

- `<DOMAIN>`: Replace this with the domain name or hostname for which you want to generate a certificate.

## Description

Upon execution, the script performs the following actions:

1. **Private CA Creation:**
    - If not already present, a private CA key (privateCA.key) and corresponding certificate (privateCA.pem) will be generated and stored in the ./ca directory.
    - These files represent the Private Certificate Authority that will be used to sign the generated certificate.
2. **Certificate Generation:**
    - A new SSL certificate for the specified domain (`<DOMAIN>`) will be generated using OpenSSL.
    - The certificate will be signed by the Private CA created in the previous step.
3. **Organized Output:**
    - The resulting certificate and key files will be stored in a timestamped subdirectory within the output directory (e.g., `./output/20230913123456/`), ensuring that each run produces uniquely named output files without overwriting previous ones.

## Folder Structure Example:

```console
./ca/
    ├── privateCA.key   # Private CA key
    └── privateCA.pem   # Private CA certificate
./output/
    └── 20230913123456/  # Timestamped folder
        ├── cert.key   # Generated private key for <DOMAIN>
        ├── cert.csr   # Generated CSR
        ├── cert.ext   # Additional data generated 
        └── cert.crt   # Certificate signed by Private CA
```