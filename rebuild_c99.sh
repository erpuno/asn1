#!/bin/bash
set -euo pipefail

ROOT_DIR="c99_output"
BASIC_DIR="${ROOT_DIR}/basic"
XSERIES_DIR="${ROOT_DIR}/xseries"

printf ': cleaning previous C99 output (%s)\n' "$ROOT_DIR"
rm -rf "$ROOT_DIR"

printf ': generating C99 headers for Basic suite -> %s\n' "$BASIC_DIR"
ASN1_LANG=c99 ASN1_OUTPUT="$BASIC_DIR" elixir basic.ex

printf ': generating C99 headers for X-Series suite -> %s\n' "$XSERIES_DIR"
ASN1_LANG=c99 ASN1_OUTPUT="$XSERIES_DIR" elixir x-series.ex

printf ': done. C99 headers available under %s\n' "$ROOT_DIR"


# gcc -std=c99 -Wall -I c99-asn1/include -I c99_output/basic \
#     -L c99-asn1/build -o test_roundtrip main.c -lasn1
# DYLD_LIBRARY_PATH=c99-asn1/build ./test_roundtrip