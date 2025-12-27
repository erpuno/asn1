# C99 ASN.1 BER/DER Parser

A lightweight, portable C99 implementation of BER/DER ASN.1 parsing and serialization, modeled after Apple's [swift-asn1](https://github.com/apple/swift-asn1) library.

## Features

- **Pure C99** - No dependencies beyond the standard library
- **BER and DER support** - Permissive BER parsing and strict DER mode
- **Node-based tree representation** - Efficient flattened array of nodes
- **No dynamic allocation in parsing** - Caller provides node array
- **Security-focused** - Depth limiting (max 50 levels), bounds checking
- **Basic ASN.1 type helpers** - BOOLEAN, INTEGER, NULL, BIT STRING, OCTET STRING, OID, strings

## Quick Start

```c
#include <asn1/asn1.h>
#include <asn1/asn1_types.h>

// Parse DER data
uint8_t der_data[] = {0x02, 0x01, 0x42};  // INTEGER 66
asn1_node_t nodes[100];
asn1_parse_result_t result;
asn1_parse_result_init(&result, nodes, 100);

asn1_error_t err = asn1_parse(der_data, sizeof(der_data), ASN1_ENCODING_DER, &result);
if (asn1_is_ok(err)) {
    int64_t value;
    asn1_parse_int64(&result.nodes[0], &value);
    printf("Parsed integer: %lld\n", (long long)value);
}
```

## Building

### Prerequisites

- CMake 3.14+
- C99-compatible compiler (GCC, Clang, MSVC)

### Build & Test

```bash
# Quick build and test
./build_and_test.sh

# Or manually:
cmake -B build
cmake --build build
ctest --test-dir build
```

### Build Artifacts

After building:
- `build/libasn1.a` - Static library
- `build/test_asn1` - Unit tests (20 tests)
- `build/test_golden` - Golden file tests (19 tests)
- `build/example_parse` - Example DER file parser

## Usage

### Parsing

```c
// Initialize result with caller-provided node array
asn1_node_t nodes[1000];
asn1_parse_result_t result;
asn1_parse_result_init(&result, nodes, 1000);

// Parse data
asn1_error_t err = asn1_parse(data, length, ASN1_ENCODING_DER, &result);
if (!asn1_is_ok(err)) {
    printf("Error: %s\n", asn1_error_code_name(err.code));
    return;
}

// Get root node
asn1_node_t *root = asn1_root_node(&result);

// Iterate children of a constructed node
asn1_node_iterator_t iter = asn1_children(&result, 0);
asn1_node_t *child;
while ((child = asn1_next_child(&iter)) != NULL) {
    // Process child
}
```

### Serialization

```c
uint8_t buffer[1024];
asn1_serializer_t s;
asn1_serializer_init(&s, buffer, sizeof(buffer));

// Primitives
asn1_serialize_int64(&s, 42);
asn1_serialize_boolean(&s, true);
asn1_serialize_null(&s);

// Constructed (SEQUENCE)
size_t marker;
asn1_serialize_constructed_begin(&s, ASN1_ID_SEQUENCE, &marker);
asn1_serialize_int64(&s, 1);
asn1_serialize_int64(&s, 2);
asn1_serialize_constructed_end(&s, marker);

// Result: s.buffer contains s.length bytes
```

### Type Helpers

```c
bool b;       asn1_parse_boolean(node, &b, ASN1_ENCODING_DER);
int64_t i;    asn1_parse_int64(node, &i);
uint64_t u;   asn1_parse_uint64(node, &u);
asn1_oid_t o; asn1_parse_oid(node, &o);

asn1_bit_string_t bs;
asn1_parse_bit_string(node, &bs);

const uint8_t *data; size_t len;
asn1_parse_octet_string(node, &data, &len);
```

## Project Structure

```
c99-asn1/
├── include/asn1/
│   ├── asn1.h           # Main API
│   ├── asn1_error.h     # Error types
│   ├── asn1_identifier.h # Tag definitions
│   └── asn1_types.h     # Type helpers
├── src/
│   ├── asn1_parser.c    # BER/DER parser
│   ├── asn1_serializer.c # DER serializer
│   └── asn1_types.c     # Type implementations
├── test/
│   ├── test_parser.c    # Unit tests
│   ├── test_golden.c    # Golden file tests
│   └── example_parse.c  # Example program
└── tests/golden/        # OpenSSL-generated test files
```

## Encoding Rules

| Feature | DER | BER |
|---------|-----|-----|
| Indefinite length | ❌ | ✅ |
| Non-minimal length encoding | ❌ | ✅ |
| Boolean: only 0x00/0xFF | ✅ | Any non-zero = true |

## Example: Parse X.509 Certificate

```bash
# Generate test certificate
openssl req -x509 -newkey rsa:2048 -keyout /dev/null -out cert.pem \
    -days 1 -nodes -subj '/CN=test' 2>/dev/null
openssl x509 -in cert.pem -outform der -out cert.der

# Parse it
./build/example_parse cert.der
```

## Testing

```bash
# Run all tests
ctest --test-dir build

# Run individual test suites
./build/test_asn1      # 20 unit tests
./build/test_golden    # 19 golden file tests

# Generate new golden files
./generate_golden.sh
```

## License

Apache-2.0 (same as swift-asn1)
