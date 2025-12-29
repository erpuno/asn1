#!/bin/bash

sh clean.sh
sh rebuild_go.sh

cd Languages/Rust
cargo test
cargo run --example ca_client
cargo run --example cert_parser -- ../../ca.crt
cd ../..

