CERTIFICATE_ENDPOINT=$1

echo "Checking CA..."
PRIVATE_CA_KEY=./ca/privateCA.key
PRIVATE_CA_PEM=./ca/privateCA.pem
echo "- Checking ./ca directory..."
if [ ! -d ./ca ]; then
  mkdir ./ca
fi
echo "- Checking CA private key..."
if [ ! -f $PRIVATE_CA_KEY ]; then
  echo "  Generating private key for CA ..."
  ## Create Private CA key
  openssl genrsa -out ${PRIVATE_CA_KEY} 2048
else
  echo "  Private CA key exists. "
  echo "- Checking CA certificate"
fi
if [ ! -f $PRIVATE_CA_PEM ]; then
  ## Create CA Root Certificate
  echo "  Generating CA root certificate ..."
  openssl req -x509 -new -nodes -key ${PRIVATE_CA_KEY} -sha256 -days 1825 -out ${PRIVATE_CA_PEM} \
    -subj "/C=ES/ST=Caribe/L=Macondo/O=ACME/OU=CSA/CN=PrivateCA for CSA Demos"
else
echo "  CA root certificate exists. "
fi
echo "---"

# --- Create certificate --- 
echo "Generating certificate for <<<$1>>>"

TIMESTAMP=$(date +%Y%m%d%H%M%S)
OUTPUT_PATH=./output/$TIMESTAMP
echo - PATH: $OUTPUT_PATH
mkdir -p $OUTPUT_PATH
CERT_KEY=$OUTPUT_PATH/cert.key
CERT_CSR=$OUTPUT_PATH/cert.csr
CERT_CRT=$OUTPUT_PATH/cert.crt

## Create Private Key for Keycloak route certificate
openssl genrsa -out ${CERT_KEY} 2048
## Create CSR 
openssl req -new -key ${CERT_KEY} -out ${CERT_CSR} \
  -subj "/C=ES/ST=Caribe/L=Macondo/O=ACME/OU=CSA/CN=CSA Demo"

## Add Keycloak route to the certificate
CERT_EXT_TEMPLATE=./data/cert.ext
CERT_EXT=$OUTPUT_PATH/cert.ext
cp $CERT_EXT_TEMPLATE $CERT_EXT
echo "DNS.1 = $CERTIFICATE_ENDPOINT" >> $CERT_EXT
## Signing the certificate
openssl x509 -req -in ${CERT_CSR} \
  -CA ${PRIVATE_CA_PEM} -CAkey ${PRIVATE_CA_KEY} -CAcreateserial \
  -out ${CERT_CRT} -days 825 -sha256 -extfile ${CERT_EXT}
echo ------
echo Certificate generated. Info:
echo ------
cat $CERT_CRT | openssl x509 -text -noout
## Create TLS secret
echo ------
echo Openshift secret creation
echo ------
TLS_SECRET_NAME=tls-certificate-secret
echo "oc create secret tls $TLS_SECRET_NAME \
  --cert=$CERT_CRT \
  --key=$CERT_KEY -oyaml --dry-run=client | tee $OUTPUT_PATH/cert.yaml"