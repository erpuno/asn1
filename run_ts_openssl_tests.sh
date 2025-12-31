#!/bin/bash
set -e

echo "=== OpenSSL Comparison Tests (Generated TypeScript Structures) ==="
echo ""

# Setup directories
TEST_DIR="test_openssl"
mkdir -p $TEST_DIR

# Check if test data already exists
if [ ! -f "$TEST_DIR/rsa_key.der" ]; then
    echo "Generating test data..."
    
    # RSA Key
    openssl genrsa -out $TEST_DIR/rsa_key.pem 2048 2>/dev/null
    openssl pkcs8 -topk8 -inform PEM -outform DER -in $TEST_DIR/rsa_key.pem -out $TEST_DIR/rsa_key.der -nocrypt
    
    # EC Key
    openssl ecparam -name prime256v1 -genkey -noout -out $TEST_DIR/ec_key.pem 2>/dev/null
    openssl pkcs8 -topk8 -inform PEM -outform DER -in $TEST_DIR/ec_key.pem -out $TEST_DIR/ec_key.der -nocrypt
    
    # CSR
    openssl req -new -key $TEST_DIR/rsa_key.pem -out $TEST_DIR/csr.der -outform DER -subj "/CN=Test/O=Org" 2>/dev/null
    
    # CA Certificate
    openssl req -x509 -key $TEST_DIR/rsa_key.pem -out $TEST_DIR/ca_cert.der -outform DER -days 365 -subj "/CN=CA" 2>/dev/null
    
    # EE Certificate
    openssl x509 -req -in $TEST_DIR/csr.der -inform DER -CA $TEST_DIR/ca_cert.der -CAform DER -CAkey $TEST_DIR/rsa_key.pem \
        -out $TEST_DIR/ee_cert.der -outform DER -days 30 -CAcreateserial 2>/dev/null
    
    # Extended cert with SAN
    cat > $TEST_DIR/ext.cnf << EOF
[req]
distinguished_name = req_dn
x509_extensions = v3_ext
[req_dn]
CN = Extended
[v3_ext]
basicConstraints = CA:FALSE
keyUsage = digitalSignature
subjectAltName = DNS:example.com
EOF
    openssl req -x509 -key $TEST_DIR/rsa_key.pem -out $TEST_DIR/extended_cert.der -outform DER -days 30 \
        -subj "/CN=Extended" -config $TEST_DIR/ext.cnf 2>/dev/null

    # Convert CA cert to PEM for CMS operations
    openssl x509 -in $TEST_DIR/ca_cert.der -inform DER -out $TEST_DIR/ca_cert.pem

    # PKCS#7 Bundle
    openssl crl2pkcs7 -nocrl -certfile $TEST_DIR/ca_cert.pem -out $TEST_DIR/bundle.p7b -outform DER 2>/dev/null

    # CMS Signed Data
    echo "Test" > $TEST_DIR/message.txt
    openssl cms -sign -in $TEST_DIR/message.txt -signer $TEST_DIR/ca_cert.pem -inkey $TEST_DIR/rsa_key.pem -outform DER -out $TEST_DIR/signed.cms -nodetach 2>/dev/null || true

    # CMS Encrypted Data
    openssl cms -encrypt -in $TEST_DIR/message.txt -recip $TEST_DIR/ca_cert.pem -outform DER -out $TEST_DIR/encrypted.cms 2>/dev/null || true

    # Public Keys
    openssl rsa -in $TEST_DIR/rsa_key.pem -pubout -outform DER -out $TEST_DIR/rsa_pubkey.der 2>/dev/null
    openssl ec -in $TEST_DIR/ec_key.pem -pubout -outform DER -out $TEST_DIR/ec_pubkey.der 2>/dev/null

    # OCSP Request (basic self-signed)
    openssl ocsp -issuer $TEST_DIR/ca_cert.pem -cert $TEST_DIR/ee_cert.der -reqout $TEST_DIR/ocsp_request.der -no_nonce 2>/dev/null || true

    echo "Test data generated."
else
    echo "Using existing test data."
fi

echo ""

# Ensure der.ts exists
if [ ! -d "Languages/TypeScript/der.ts" ]; then
    echo "Cloning der.ts library..."
    cd Languages/TypeScript
    git clone https://github.com/chat-x509/der.ts 2>/dev/null || true
    cd ../..
fi

# Run tests
echo "Running TypeScript tests with generated structures..."
cd Languages/TypeScript
bun run openssl_test.ts
