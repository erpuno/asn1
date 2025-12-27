#!/bin/bash
set -e

DIR="tests/golden"
mkdir -p "$DIR"

# Boolean
# OpenSSL CLI doesn't easily generate pure boolean values without a container (like SEQUENCE).
# But we can generate manually or use `asn1parse -genconf`.
# Let's use `asn1parse -genconf` which allows arbitrary ASN.1 creation.

# Helper to generate via config
gen_asn1() {
    FILE="$1"
    CONTENT="$2"
    echo "$CONTENT" > "$DIR/temp.conf"
    openssl asn1parse -genconf "$DIR/temp.conf" -out "$DIR/$FILE" -noout
    rm "$DIR/temp.conf"
}

# Boolean: TRUE (0xFF)
# OpenSSL config syntax `asn1 = BOOLEAN:TRUE`
gen_asn1 "true.der" "asn1 = BOOLEAN:TRUE"

# Boolean: FALSE (0x00)
gen_asn1 "false.der" "asn1 = BOOLEAN:FALSE"

# Integer: 42
gen_asn1 "int_42.der" "asn1 = INTEGER:42"

# Integer: -1
gen_asn1 "int_neg1.der" "asn1 = INTEGER:-1"

# Integer: Large (needs explicit hex for very large in some versions, but let's try decimal first or standard large hex)
# 0x01020304050607
gen_asn1 "int_large.der" "asn1 = INTEGER:0x0102030405060708" 

# Octet String
gen_asn1 "octet_string.der" "asn1 = OCTETSTRING:Hello World"

# Octet String (empty)
gen_asn1 "octet_string_empty.der" "asn1 = OCTETSTRING:"

# OID: 1.2.840.113549.1.1.11 (sha256WithRSAEncryption)
gen_asn1 "oid.der" "asn1 = OID:1.2.840.113549.1.1.11"

# GeneralizedTime
# YYYYMMDDHHMMSSZ
gen_asn1 "generalized_time.der" "asn1 = GENERALIZEDTIME:20230101120000Z"

# UTCTime
# YYMMDDHHMMSSZ
gen_asn1 "utc_time.der" "asn1 = UTCTIME:230101120000Z"

# NULL
gen_asn1 "null.der" "asn1 = NULL"

# BitString
# OpenSSL syntax: BITSTRING:value
# "FORMAT:HEX,BITSTRING:0x1234" ?
# simple usage:
gen_asn1 "bit_string.der" "asn1 = BITSTRING:0A3B5F291CD"

# Strings
gen_asn1 "utf8_string.der" "asn1 = UTF8String:Hello UTF8"
gen_asn1 "printable_string.der" "asn1 = PRINTABLESTRING:Hello Printable"
gen_asn1 "ia5_string.der" "asn1 = IA5STRING:Hello IA5"
gen_asn1 "numeric_string.der" "asn1 = NUMERICSTRING:1234567890"

echo "Golden files generated in $DIR"
