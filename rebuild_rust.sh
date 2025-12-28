#!/bin/bash
set -e
export ASN1_OUTPUT="Languages/Rust"
echo "Cleaning generated code..."
rm -rf Languages/Rust/crates/asn1_suite/src
echo "Generating Rust code for Basic modules..."
ASN1_LANG=rust ASN1_SINGLE_CRATE=true elixir basic.ex
echo "Generating Rust code for X-Series modules..."
ASN1_LANG=rust ASN1_SINGLE_CRATE=true elixir x-series.ex
echo "Generating mod.rs..."
elixir generate_mod_rs.ex
echo "Rust code generation complete."

