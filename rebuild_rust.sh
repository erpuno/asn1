#!/bin/bash
set -e
rustup component add rustc-codegen-cranelift
# Run for basic modules
echo "Cleaning generated directory..."
rm -rf asn1_suite/src/generated/*

echo "Generating Rust code for Basic modules..."
ASN1_LANG=rust elixir basic.ex

# Run for X-Series modules (if supported)
# echo "Generating Rust code for X-Series modules..."
# ASN1_LANG=rust elixir x-series.ex

echo "Generating mod.rs..."
elixir generate_mod_rs.ex

echo "Rust code generation complete."
