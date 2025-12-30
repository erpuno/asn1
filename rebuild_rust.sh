#!/bin/bash
set -e
export ASN1_OUTPUT="Languages/Rust"
echo "Cleaning generated code..."
rm -rf Languages/Rust/src/*

echo "Generating Rust code for Basic modules..."
ASN1_LANG=rust elixir basic.ex

echo "Generating Rust code for X-Series modules..."
ASN1_LANG=rust elixir x-series.ex

echo "Rust code generation complete."

