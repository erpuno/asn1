#!/bin/bash
set -e

# Setup directories
TEST_DIR="test_openssl"
mkdir -p $TEST_DIR
rm -f $TEST_DIR/*

echo "=== Generating OpenSSL Test Data ==="

# 1. Generate Private Key (PKCS#8)
echo "Generating Private Key..."
openssl genrsa -out $TEST_DIR/key.pem 2048
openssl pkcs8 -topk8 -inform PEM -outform DER -in $TEST_DIR/key.pem -out $TEST_DIR/key.der -nocrypt
echo "Generated $TEST_DIR/key.der"

# 2. Generate CSR (PKCS#10)
echo "Generating CSR..."
openssl req -new -key $TEST_DIR/key.pem -out $TEST_DIR/csr.der -outform DER -subj "/CN=Test User/O=Test Org"
echo "Generated $TEST_DIR/csr.der"

# 3. Generate Self-Signed Cert (for CRL, future use) - skipping CRL complex generation for now as it needs CA config
# openssl req -x509 -key $TEST_DIR/key.pem -in $TEST_DIR/csr.der -out $TEST_DIR/cert.der -outform DER -days 365

echo "=== Rebuilding Java Code ==="
./rebuild_java.sh

echo "=== Running Java Verification ==="
cd Languages/Java

# Run Key Test
echo "--- Testing Private Key Parsing ---"
gradle run --args="parse-key ../../$TEST_DIR/key.der"

# Run CSR Test
echo "--- Testing CSR Parsing ---"
gradle run --args="parse-csr ../../$TEST_DIR/csr.der"

echo "=== OpenSSL Comparison Tests Completed Successfully ==="
