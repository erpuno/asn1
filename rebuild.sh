
rm -rf .build
rm -rf Sources/Suite/ASN1SCG
./asn1.ex compile -v priv/basic Sources/Suite/ASN1SCG
swift run 