#!/bin/sh

rm -rf ./Languages/C99/Generated
rm -rf ./Languages/C99/c99_client
rm -rf ./Languages/C99/Parser/build
rm -rf ./Languages/C99/test_roundtrip
rm -rf ./Languages/C99/test_suite
rm -rf ./Languages/AppleSwift/Generated
rm -rf ./Languages/Go/chat
rm -rf ./Languages/Go/chat_xseries
rm -rf ./Languages/AppleSwift/.build/
rm -rf ./Languages/AppleSwift/Package.resolved
rm -rf ./Languages/AppleSwift/verified.der
rm -rf ./Languages/AppleSwift/generated.crt
rm -rf ./Languages/AppleSwift/generated_verified.der
rm -rf ./Languages/AppleSwift/generated_orig.txt
rm -rf ./Languages/AppleSwift/generated_cycle.txt
rm -rf ./Languages/AppleSwift/verified.txt
rm -rf ./Languages/AppleSwift/original.txt
rm -rf ./Languages/TypeScript/generated/
rm -rf ./Languages/TypeScript/dist/
rm -rf ./Languages/Java/.gradle/
rm -rf ./Languages/Java/build/
rm -rf ./Languages/TypeScript/der.ts/
rm -rf ./Languages/der-java/
rm -rf ./Languages/Rust/src/*
rm -rf ./Languages/Rust/target/
rm -rf ./Languages/Rust/Cargo.lock

rm -f ./Languages/Java/generated_cert.der
rm -f ./Languages/TypeScript/robot_go.crt
rm -f ./Languages/TypeScript/robot_go.der
rm -f ./Languages/TypeScript/robot_go_roundtrip.der
rm -f ./Languages/Go/tobirama
rm -f ./Languages/AppleSwift/generated_cycle.txt
rm -f ./Languages/AppleSwift/generated_orig.txt
rm -f ./Languages/AppleSwift/generated_verified.der
rm -f ./Languages/AppleSwift/generated.crt
rm -f ./Languages/AppleSwift/original.txt
rm -f ./Languages/AppleSwift/verified.txt
rm -f ./Languages/AppleSwift/Package.resolved

# Remove all generated Java files except Main.java and OpenSSLTest.java
[ -d "./Languages/Java/src/main/java/com/generated/asn1" ] && find ./Languages/Java/src/main/java/com/generated/asn1/ -maxdepth 1 -type f ! -name 'Main.java' ! -name 'OpenSSLTest.java' -exec rm -f {} +
