#!/bin/bash
set -e 


echo "ATTENTION: It requires CA server to run locally"

echo "Cleaning up generated files..."
rm -rf Sources/Suite/XSeries/*
rm -rf Sources/Suite/Basic
echo "Done cleaning up."
echo "Running ASN.1 compiler..."
echo "Compiling X-Series modules..."
elixir x-series.ex
echo "X-Series compilation complete."

echo "Compiling basic modules..."
elixir basic.ex
echo "Basic modules compilation complete."

echo "Building project..."
./rebuild.sh

echo "All done!"
exit 0
