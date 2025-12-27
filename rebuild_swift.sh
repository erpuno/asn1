#!/bin/bash
set -e

# Clean up any existing generated files to prevent conflicts
rm -rf Languages/AppleSwift/Generated
rm -rf Languages/AppleSwift/Basic
rm -rf Languages/AppleSwift/XSeries

# Re-create the unified output directory
mkdir -p Languages/AppleSwift/Generated

# Pass 1: Run basic compiler to generate unique types and base definitions
# We set ASN1_OUTPUT to the unified directory
ASN1_LANG=swift ASN1_OUTPUT=Languages/AppleSwift/Generated elixir basic.ex

# Pass 2: Run x-series compiler to overwrite or add refined definitions
# It will use the same unified directory
ASN1_LANG=swift ASN1_OUTPUT=Languages/AppleSwift/Generated elixir x-series.ex

echo "Unified Swift generation complete in Languages/AppleSwift/Generated"
