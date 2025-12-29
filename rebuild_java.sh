#!/bin/bash
set -euo pipefail
export ASN1_LANG=java
export ASN1_OUTPUT=Languages/Java/src/main/java/com/generated/asn1/

# Remove all generated Java files except Main.java
[ -d "./Languages/Java/src/main/java/com/generated/asn1" ] && find ./Languages/Java/src/main/java/com/generated/asn1 -maxdepth 1 -type f ! -name 'Main.java' -exec rm -f {} +

elixir basic.ex
elixir x-series.ex