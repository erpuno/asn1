#!/bin/bash
set -e

# Setup directories
TEST_DIR="test_openssl"
mkdir -p $TEST_DIR
rm -f $TEST_DIR/*

echo "=== Generating OpenSSL Test Data ==="
echo ""

# 1. Generate RSA Private Key (PKCS#8)
echo "1. RSA Private Key (2048-bit)..."
openssl genrsa -out $TEST_DIR/rsa_key.pem 2048
openssl pkcs8 -topk8 -inform PEM -outform DER -in $TEST_DIR/rsa_key.pem -out $TEST_DIR/rsa_key.der -nocrypt

# 2. Generate EC Private Key (PKCS#8)
echo "2. EC Private Key (P-256)..."
openssl ecparam -name prime256v1 -genkey -noout -out $TEST_DIR/ec_key.pem
openssl pkcs8 -topk8 -inform PEM -outform DER -in $TEST_DIR/ec_key.pem -out $TEST_DIR/ec_key.der -nocrypt

# 3. Generate CSR (PKCS#10)
echo "3. CSR (PKCS#10)..."
openssl req -new -key $TEST_DIR/rsa_key.pem -out $TEST_DIR/csr.der -outform DER -subj "/CN=Test User/O=Test Org/C=US"

# 4. Generate Self-Signed CA Certificate
echo "4. CA Certificate..."
openssl req -x509 -key $TEST_DIR/rsa_key.pem -out $TEST_DIR/ca_cert.der -outform DER -days 365 -subj "/CN=Test CA/O=Test Org/C=US"
openssl x509 -in $TEST_DIR/ca_cert.der -inform DER -out $TEST_DIR/ca_cert.pem

# 5. Generate End-Entity Certificate
echo "5. End-Entity Certificate..."
openssl x509 -req -in $TEST_DIR/csr.der -inform DER -CA $TEST_DIR/ca_cert.pem -CAkey $TEST_DIR/rsa_key.pem -out $TEST_DIR/ee_cert.der -outform DER -days 30 -CAcreateserial 2>/dev/null

# 6. PKCS#7 Certificate Bundle
echo "6. PKCS#7 Certificate Bundle..."
openssl crl2pkcs7 -nocrl -certfile $TEST_DIR/ca_cert.pem -out $TEST_DIR/bundle.p7b -outform DER

# 7. Public Keys
echo "7. RSA Public Key..."
openssl rsa -in $TEST_DIR/rsa_key.pem -pubout -outform DER -out $TEST_DIR/rsa_pubkey.der 2>/dev/null

echo "8. EC Public Key..."
openssl ec -in $TEST_DIR/ec_key.pem -pubout -outform DER -out $TEST_DIR/ec_pubkey.der 2>/dev/null

# 9. CMS Signed Data
echo "9. CMS Signed Data..."
echo "Test message for CMS signing" > $TEST_DIR/message.txt
openssl cms -sign -in $TEST_DIR/message.txt -signer $TEST_DIR/ca_cert.pem -inkey $TEST_DIR/rsa_key.pem -outform DER -out $TEST_DIR/signed.cms -nodetach 2>/dev/null || echo "   (CMS signing requires specific OpenSSL version)"

# 10. CMS Enveloped Data (Encrypted)
echo "10. CMS Enveloped Data..."
openssl cms -encrypt -in $TEST_DIR/message.txt -recip $TEST_DIR/ca_cert.pem -outform DER -out $TEST_DIR/encrypted.cms 2>/dev/null || echo "   (CMS encryption requires specific OpenSSL version)"

# 11. OCSP Request
echo "11. OCSP Request..."
# Create a simple OCSP request
openssl ocsp -issuer $TEST_DIR/ca_cert.pem -cert $TEST_DIR/ca_cert.pem -reqout $TEST_DIR/ocsp_request.der 2>/dev/null || echo "   (OCSP request generation skipped)"

# 12. Timestamp Request (RFC 3161)
echo "12. Timestamp Request..."
openssl ts -query -data $TEST_DIR/message.txt -out $TEST_DIR/ts_request.tsq -sha256 2>/dev/null || echo "   (TSA request generation skipped)"

# 13. DSA Key
echo "13. DSA Key..."
openssl dsaparam -genkey 2048 -out $TEST_DIR/dsa_key.pem 2>/dev/null || echo "   (DSA key generation skipped)"
if [ -f $TEST_DIR/dsa_key.pem ]; then
    openssl pkcs8 -topk8 -inform PEM -outform DER -in $TEST_DIR/dsa_key.pem -out $TEST_DIR/dsa_key.der -nocrypt 2>/dev/null
fi

# 14. DH Parameters
echo "14. DH Parameters..."
openssl dhparam -outform DER -out $TEST_DIR/dh_params.der 512 2>/dev/null || echo "   (DH params generation skipped)"

# 15. Certificate with Extensions
echo "15. Certificate with Extensions..."
cat > $TEST_DIR/ext.cnf << EOF
[req]
distinguished_name = req_dn
x509_extensions = v3_ext

[req_dn]
CN = Extended Cert

[v3_ext]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = DNS:example.com, DNS:*.example.com, IP:192.168.1.1
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
EOF
openssl req -x509 -key $TEST_DIR/rsa_key.pem -out $TEST_DIR/extended_cert.der -outform DER -days 30 -subj "/CN=Extended Cert" -config $TEST_DIR/ext.cnf 2>/dev/null || echo "   (Extended cert skipped)"

echo ""
echo "=== Running TypeScript Verification ==="
cd Languages/TypeScript

# Function to run test
run_test() {
    local cmd=$1
    local file=$2
    local name=$3
    if [ -f "../../$file" ]; then
        echo ""
        echo "--- $name ---"
        bun run openssl_test.ts $cmd ../../$file
    fi
}

# Core tests
run_test "parse-key" "$TEST_DIR/rsa_key.der" "RSA Private Key (PKCS#8)"
run_test "parse-key" "$TEST_DIR/ec_key.der" "EC Private Key (PKCS#8)"
run_test "parse-csr" "$TEST_DIR/csr.der" "CSR (PKCS#10)"
run_test "parse-cert" "$TEST_DIR/ca_cert.der" "CA Certificate (X.509)"
run_test "parse-cert" "$TEST_DIR/ee_cert.der" "End-Entity Certificate (X.509)"
run_test "parse-cert" "$TEST_DIR/bundle.p7b" "PKCS#7 Certificate Bundle"
run_test "parse-key" "$TEST_DIR/rsa_pubkey.der" "RSA Public Key"
run_test "parse-key" "$TEST_DIR/ec_pubkey.der" "EC Public Key"

# Advanced tests
run_test "parse-cert" "$TEST_DIR/signed.cms" "CMS Signed Data"
run_test "parse-cert" "$TEST_DIR/encrypted.cms" "CMS Enveloped Data"
run_test "parse-cert" "$TEST_DIR/ocsp_request.der" "OCSP Request"
run_test "parse-cert" "$TEST_DIR/ts_request.tsq" "Timestamp Request (RFC 3161)"
run_test "parse-key" "$TEST_DIR/dsa_key.der" "DSA Private Key"
run_test "parse-cert" "$TEST_DIR/dh_params.der" "DH Parameters"
run_test "parse-cert" "$TEST_DIR/extended_cert.der" "Certificate with Extensions"

echo ""
echo "=== All TypeScript OpenSSL Comparison Tests Completed ==="
echo ""
echo "Summary of tested formats:"
echo "  ✓ RSA Private Key (PKCS#8)"
echo "  ✓ EC Private Key (PKCS#8, P-256)"
echo "  ✓ Certificate Signing Request (PKCS#10)"
echo "  ✓ Self-Signed CA Certificate (X.509)"
echo "  ✓ End-Entity Certificate (X.509)"
echo "  ✓ PKCS#7 Certificate Bundle"
echo "  ✓ RSA Public Key (SubjectPublicKeyInfo)"
echo "  ✓ EC Public Key (SubjectPublicKeyInfo)"
echo "  ✓ CMS Signed Data (if generated)"
echo "  ✓ CMS Enveloped Data (if generated)"
echo "  ✓ OCSP Request (if generated)"
echo "  ✓ Timestamp Request RFC 3161 (if generated)"
echo "  ✓ DSA Private Key (if generated)"
echo "  ✓ DH Parameters (if generated)"
echo "  ✓ Certificate with Extensions (if generated)"
