#!/bin/bash
set -euo pipefail

export ASN1_LANG=java
export ASN1_OUTPUT=Languages/Java/src/main/java/com/generated/asn1/

# Clone der.java if not present
if [ ! -d "Languages/Java/der.java" ]; then
    cd Languages/Java
    git clone https://github.com/iho/der.java
    cd ../..
fi

# Remove all generated Java files except Main.java and OpenSSLTest.java
[ -d "./Languages/Java/src/main/java/com/generated/asn1" ] && find ./Languages/Java/src/main/java/com/generated/asn1 -maxdepth 1 -type f ! -name 'Main.java' ! -name 'OpenSSLTest.java' -exec rm -f {} +

elixir basic.ex
elixir x-series.ex
