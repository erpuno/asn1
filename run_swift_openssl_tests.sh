#!/bin/bash
set -e

echo "=== OpenSSL Comparison Tests (Swift Generated Structures) ==="
echo ""

# Setup directories
TEST_DIR="test_openssl"
mkdir -p $TEST_DIR

# Check if test data already exists
if [ ! -f "$TEST_DIR/rsa_key.der" ]; then
    echo "Generating test data..."
    
    # Create a minimal config for openssl req
    cat > $TEST_DIR/min.cnf << EOF
[req]
distinguished_name = req_dn
[req_dn]
EOF
    export OPENSSL_CONF=$TEST_DIR/min.cnf

    # RSA Key
    openssl genrsa -out $TEST_DIR/rsa_key.pem 2048
    openssl pkcs8 -topk8 -inform PEM -outform DER -in $TEST_DIR/rsa_key.pem -out $TEST_DIR/rsa_key.der -nocrypt
    
    # EC Key
    openssl ecparam -name prime256v1 -genkey -noout -out $TEST_DIR/ec_key.pem
    openssl pkcs8 -topk8 -inform PEM -outform DER -in $TEST_DIR/ec_key.pem -out $TEST_DIR/ec_key.der -nocrypt
    
    # CSR
    openssl req -new -key $TEST_DIR/rsa_key.pem -out $TEST_DIR/csr.der -outform DER -subj "/CN=Test/O=Org"
    
    # CA Certificate
    openssl req -x509 -key $TEST_DIR/rsa_key.pem -out $TEST_DIR/ca_cert.der -outform DER -days 365 -subj "/CN=CA" -set_serial 1234567890
    openssl x509 -in $TEST_DIR/ca_cert.der -inform DER -out $TEST_DIR/ca_cert.pem

    # EE Certificate
    openssl x509 -req -in $TEST_DIR/csr.der -inform DER -CA $TEST_DIR/ca_cert.pem -CAkey $TEST_DIR/rsa_key.pem \
        -out $TEST_DIR/ee_cert.der -outform DER -days 30 -CAcreateserial

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
        -subj "/CN=Extended" -config $TEST_DIR/ext.cnf

    echo "Test data generated."
else
    echo "Using existing test data."
fi

echo ""

# Build and run Swift tests
echo "Building and running Swift tests with generated structures..."
cd Languages/AppleSwift
swift build 2>&1 | tail -20
swift run chat-x509 --openssl-tests ../../$TEST_DIR
