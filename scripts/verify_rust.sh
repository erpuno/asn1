#!/bin/bash

sh scripts/clean.sh
sh scripts/rebuild_rust.sh

cd Languages/Rust
cargo test
cargo run --example ca_client
cargo run --example cert_parser -- ../../ca.crt
cd ../..

