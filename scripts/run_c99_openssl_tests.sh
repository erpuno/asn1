#!/bin/bash
set -e

echo "=== OpenSSL Comparison Tests (Generated C99 Structures) ==="
echo ""

# Setup directories
TEST_DIR="test_openssl"
mkdir -p $TEST_DIR

# Check if test data already exists
if [ ! -f "$TEST_DIR/rsa_key.der" ]; then
    echo "Generating test data..."
    
    # Create a minimal openssl.cnf for commands that need it
    cat > $TEST_DIR/min.cnf << EOF
[req]
distinguished_name = req_dn
[req_dn]
EOF

    # RSA Key
    openssl genrsa -out $TEST_DIR/rsa_key.pem 2048
    openssl pkcs8 -topk8 -inform PEM -outform DER -in $TEST_DIR/rsa_key.pem -out $TEST_DIR/rsa_key.der -nocrypt
    
    # EC Key
    openssl ecparam -name prime256v1 -genkey -noout -out $TEST_DIR/ec_key.pem
    openssl pkcs8 -topk8 -inform PEM -outform DER -in $TEST_DIR/ec_key.pem -out $TEST_DIR/ec_key.der -nocrypt
    
    # CSR
    openssl req -new -key $TEST_DIR/rsa_key.pem -out $TEST_DIR/csr.der -outform DER -subj "/CN=Test/O=Org" -config $TEST_DIR/min.cnf
    
    # CA Certificate
    openssl req -x509 -key $TEST_DIR/rsa_key.pem -out $TEST_DIR/ca_cert.der -outform DER -days 365 -subj "/CN=CA" -config $TEST_DIR/min.cnf
    
    # EE Certificate
    openssl x509 -req -inform DER -in $TEST_DIR/csr.der -CA $TEST_DIR/ca_cert.der -CAform DER -CAkey $TEST_DIR/rsa_key.pem \
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

# Rebuild C99 headers and library
echo "Rebuilding C99..."
./scripts/rebuild_c99.sh > /dev/null

# Clean and build openssl_test
echo "Building C99 openssl_test..."
cd Languages/C99
make clean > /dev/null
make openssl_test > /dev/null

# Run tests
echo "Running C99 OpenSSL tests..."
export DYLD_LIBRARY_PATH=Parser/build
./openssl_test
