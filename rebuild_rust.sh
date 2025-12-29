#!/bin/bash
set -e
export ASN1_OUTPUT="Languages/Rust"
echo "Cleaning generated code..."
rm -rf Languages/Rust/Suite/crates/*
rm -rf Languages/Rust/src/*

echo "Generating Rust code for Basic modules..."
ASN1_LANG=rust elixir basic.ex

# Run for X-Series modules (if supported)
echo "Generating Rust code for X-Series modules..."
ASN1_LANG=rust elixir x-series.ex

# echo "Generating mod.rs..."
# elixir generate_mod_rs.ex

echo "Rust code generation complete."

