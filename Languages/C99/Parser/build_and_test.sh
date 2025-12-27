#!/bin/bash
# Build and test script for c99-asn1
set -e

echo "=== Building c99-asn1 ==="

# Configure with CMake
cmake -B build -DCMAKE_BUILD_TYPE=Debug

# Build
cmake --build build

echo ""
echo "=== Running Tests ==="

# Run all tests
ctest --test-dir build --output-on-failure

echo ""
echo "=== Build Complete ==="
echo "Binaries are in ./build/"
echo ""
echo "Available commands:"
echo "  ./build/test_asn1      - Run unit tests"
echo "  ./build/test_golden    - Run golden file tests"
echo "  ./build/example_parse <file.der> - Parse a DER file"
