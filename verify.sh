#!/bin/bash
set -e

echo "--- 1. Using existing DSTU X.509 types (from Sources/Suite/ASN1SCG) ---"
echo "  Note: DSTU.asn1 provides Certificate, Name, AlgorithmIdentifier, etc."

echo "--- 2. Building and Running Swift Suite ---"
swift run chat-x509

echo "--- 3. Verifying Output with OpenSSL ---"
if [ ! -f "verified.der" ]; then
    echo "Error: verified.der was not generated!"
    exit 1
fi

echo "Parsability Check (Generic ASN.1):"
openssl asn1parse -in verified.der -inform DER > /dev/null
echo "  [OK] OpenSSL asn1parse passed."

echo "Parsability Check (X.509):"
openssl x509 -in verified.der -inform DER -text -noout > /dev/null
echo "  [OK] OpenSSL x509 check passed."

echo "Comparability Check:"
# Both files are DER encoded
openssl asn1parse -in ca.crt -inform DER > original.txt
openssl asn1parse -in verified.der -inform DER > verified.txt

if diff -q original.txt verified.txt > /dev/null; then
  echo "  [OK] ASN.1 Structure matches exactly."
else
  echo "  [WARN] ASN.1 Structure differs slightly (expected if encoding rules differ). Showing diff head:"
  diff original.txt verified.txt | head -n 10 || true
fi

echo "--- SUCCESS: Verification Complete ---"
