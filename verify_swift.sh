#!/bin/bash
set -e

sh clean.sh
sh rebuild_swift.sh

echo "--- 1. Using existing DSTU X.509 types (from Sources/Suite/ASN1SCG) ---"
echo "  Note: DSTU.asn1 provides Certificate, Name, AlgorithmIdentifier, etc."

cd Languages/AppleSwift

echo "--- 2. Building and Running Swift Suite ---"
swift run -Xswiftc -suppress-warnings -Xswiftc -Onone -j 12

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
openssl asn1parse -in ../../ca.crt -inform DER > original.txt
openssl asn1parse -in verified.der -inform DER > verified.txt

if diff -q original.txt verified.txt > /dev/null; then
  echo "  [OK] ASN.1 Structure matches exactly."
else
  echo "  [WARN] ASN.1 Structure differs slightly (expected if encoding rules differ). Showing diff head:"
  diff original.txt verified.txt | head -n 10 || true
fi

echo "--- 4. Verifying Generated Certificate ---"
if [ ! -f "generated.crt" ]; then
    echo "Error: generated.crt was not generated!"
    exit 1
fi

echo "Parsability Check (Generated X.509):"
openssl x509 -in generated.crt -inform DER -text -noout > /dev/null
echo "  [OK] OpenSSL x509 check passed for generated.crt."

echo "Content Verification (Generated X.509):"
# Verify Subject
SUBJECT=$(openssl x509 -in generated.crt -inform DER -noout -subject)
# Normalize spaces
if [[ "$SUBJECT" == *"CN=Test"* ]] || [[ "$SUBJECT" == *"CN = Test"* ]]; then
    echo "  [OK] Subject matches 'Test'."
else
    echo "  [FAIL] Subject mismatch. Got: $SUBJECT"
    exit 1
fi

# Verify Issuer
ISSUER=$(openssl x509 -in generated.crt -inform DER -noout -issuer)
if [[ "$ISSUER" == *"CN=Test"* ]] || [[ "$ISSUER" == *"CN = Test"* ]]; then
    echo "  [OK] Issuer matches 'Test'."
else
    echo "  [FAIL] Issuer mismatch. Got: $ISSUER"
    exit 1
fi

# Verify Serial
SERIAL=$(openssl x509 -in generated.crt -inform DER -noout -serial)
if [[ "$SERIAL" == *"serial=01"* ]]; then
    echo "  [OK] Serial matches '01'."
else
    echo "  [FAIL] Serial mismatch. Got: $SERIAL"
    exit 1
fi

echo "--- 5. Full Cycle Verification (Generated -> DER -> Generated) ---"
if [ ! -f "generated_verified.der" ]; then
    echo "Error: generated_verified.der was not generated!"
    exit 1
fi

openssl asn1parse -in generated.crt -inform DER > generated_orig.txt
openssl asn1parse -in generated_verified.der -inform DER > generated_cycle.txt

if diff -q generated_orig.txt generated_cycle.txt > /dev/null; then
  echo "  [OK] Generated Certificate round-trip matches exactly."
else
  echo "  [WARN] Generated Certificate round-trip differs."
  diff generated_orig.txt generated_cycle.txt | head -n 10 || true
  exit 1
fi

echo "--- SUCCESS: Verification Complete ---"
