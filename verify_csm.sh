#!/bin/bash
set -e

echo "Preparing plaintext..."
printf "very secret message!\n" > message.txt

KEY=$(openssl rand -hex 16)
IV=$(openssl rand -hex 16)
echo "KEY=$KEY"
echo "IV=$IV"

echo "Encrypting with OpenSSL (AES-128-CBC)..."
openssl enc -aes-128-cbc -nosalt \
  -K "$KEY" -iv "$IV" \
  -in message.txt -out encrypted.bin

echo "Decrypting with OpenSSL (AES-128-CBC)..."
openssl enc -d -aes-128-cbc -nosalt \
  -K "$KEY" -iv "$IV" \
  -in encrypted.bin -out decrypted.txt

echo "Decrypting with Swift (AES-128-CBC)..."
swift run -Xswiftc -suppress-warnings chat-x509 cms aes-decrypt \
  -in encrypted.bin \
  -key "$KEY" \
  -iv "$IV" \
  -out decrypted_swift.txt

echo "Verifying Decrypted Content..."
if diff decrypted.txt decrypted_swift.txt; then
    echo "Files match - verification passed!"
else
    echo "Files differ - verification failed!"
    exit 1
fi

rm decrypted.txt decrypted_swift.txt encrypted.bin message.txt

echo "Passed!"