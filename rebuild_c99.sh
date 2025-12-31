#!/bin/bash
set -eu

ROOT_DIR="Languages/C99/Generated"

printf ': cleaning previous C99 output (%s)\n' "$ROOT_DIR"
rm -rf "$ROOT_DIR"
mkdir -p "$ROOT_DIR"

printf ': generating C99 headers for Basic suite -> %s\n' "$ROOT_DIR"
ASN1_LANG=c99 ASN1_OUTPUT="$ROOT_DIR" elixir basic.ex

printf ': generating C99 headers for X-Series suite -> %s\n' "$ROOT_DIR"
ASN1_LANG=c99 ASN1_OUTPUT="$ROOT_DIR" elixir x-series.ex

printf ': done. C99 headers available under %s\n' "$ROOT_DIR"

cd Languages/C99/Parser

sh build_and_test.sh

cd ..

make

cd ../..

gcc -std=c99 -Wall -Wno-unused-function -I Languages/C99/Parser/include -I "${ROOT_DIR}" \
  -L Languages/C99/Parser/build -o Languages/C99/test_roundtrip Languages/C99/main.c -lasn1
DYLD_LIBRARY_PATH=Languages/C99/Parser/build Languages/C99/test_roundtrip

printf '\n: compiling C99 CMP Client -> c99_client\n'
gcc -std=c99 -Wall -Wno-unused-function -I Languages/C99/Parser/include -I "${ROOT_DIR}" \
  -L Languages/C99/Parser/build -o Languages/C99/c99_client Languages/C99/c99_client.c -lasn1

