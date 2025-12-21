#!/bin/bash
set -e

# Clean up any existing generated files to prevent conflicts
rm -rf Sources/Suite/Generated
rm -rf Sources/Suite/Basic
rm -rf Sources/Suite/XSeries

# Re-create the unified output directory
mkdir -p Sources/Suite/Generated

# Pass 1: Run basic compiler to generate unique types and base definitions
# We set ASN1_OUTPUT to the unified directory
ASN1_LANG=swift ASN1_OUTPUT=Sources/Suite/Generated elixir basic.ex

# Pass 2: Run x-series compiler to overwrite or add refined definitions
# It will use the same unified directory
ASN1_LANG=swift ASN1_OUTPUT=Sources/Suite/Generated elixir x-series.ex

echo "Unified Swift generation complete in Sources/Suite/Generated"