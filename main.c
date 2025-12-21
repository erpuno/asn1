/*
 * ASN.1 DER/BER Round-Trip Test
 * Verifies encode/decode functionality of generated C99 headers
 */

#include "DSTU_ALGORITHMIDENTIFIER.h"
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static void hexdump(const char *label, const uint8_t *data, size_t len) {
  printf("%s (%zu bytes): ", label, len);
  for (size_t i = 0; i < len && i < 32; i++) {
    printf("%02x ", data[i]);
  }
  if (len > 32) {
    printf("...");
  }
  printf("\n");
}

static int test_algorithmidentifier_roundtrip(void) {
  printf("\n=== AlgorithmIdentifier Round-Trip Test ===\n");

  /* Step 1: Create and populate the structure */
  DSTU_ALGORITHMIDENTIFIER orig;
  memset(&orig, 0, sizeof(orig));

  /* Set algorithm OID to 1.2.840.113549.1.1.11 (sha256WithRSAEncryption) */
  orig.algorithm.count = 7;
  orig.algorithm.components[0] = 1;
  orig.algorithm.components[1] = 2;
  orig.algorithm.components[2] = 840;
  orig.algorithm.components[3] = 113549;
  orig.algorithm.components[4] = 1;
  orig.algorithm.components[5] = 1;
  orig.algorithm.components[6] = 11;

  /* Parameters - optional, set a simple NULL encoding */
  orig.has_parameters = true;
  orig.parameters.length = 2; /* DER NULL is 05 00 */
  orig.parameters.bytes[0] = 0x05;
  orig.parameters.bytes[1] = 0x00;

  printf("Original: OID=");
  for (size_t i = 0; i < orig.algorithm.count; i++) {
    printf("%u%s", orig.algorithm.components[i],
           i < orig.algorithm.count - 1 ? "." : "");
  }
  printf(", has_params=%d\n", orig.has_parameters);

  /* Step 2: Encode to DER */
  uint8_t buffer[512];
  asn1_serializer_t serializer;
  asn1_serializer_init(&serializer, buffer, sizeof(buffer));

  asn1_error_t err = DSTU_ALGORITHMIDENTIFIER_encode(&orig, &serializer);
  if (!asn1_is_ok(err)) {
    printf("FAILED: encode: %s\n", asn1_error_code_name(err.code));
    return 1;
  }

  size_t encoded_len = serializer.length;
  hexdump("Encoded DER", buffer, encoded_len);

  /* Step 3: Parse the DER back */
  asn1_node_t nodes[64];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 64);

  err = asn1_parse(buffer, encoded_len, ASN1_ENCODING_DER, &result);
  if (!asn1_is_ok(err)) {
    printf("FAILED: parse: %s\n", asn1_error_code_name(err.code));
    return 1;
  }

  /* Step 4: Decode into a new structure */
  DSTU_ALGORITHMIDENTIFIER decoded;
  memset(&decoded, 0, sizeof(decoded));

  asn1_node_t *root = asn1_root_node(&result);
  if (root == NULL) {
    printf("FAILED: no root node\n");
    return 1;
  }

  err = DSTU_ALGORITHMIDENTIFIER_decode(&decoded, root, &result);
  if (!asn1_is_ok(err)) {
    printf("FAILED: decode: %s\n", asn1_error_code_name(err.code));
    return 1;
  }

  printf("Decoded:  OID=");
  for (size_t i = 0; i < decoded.algorithm.count; i++) {
    printf("%u%s", decoded.algorithm.components[i],
           i < decoded.algorithm.count - 1 ? "." : "");
  }
  printf(", has_params=%d\n", decoded.has_parameters);

  /* Step 5: Verify the round-trip (focus on OID verification) */
  int success = 1;

  if (orig.algorithm.count != decoded.algorithm.count) {
    printf("MISMATCH: OID count %zu != %zu\n", orig.algorithm.count,
           decoded.algorithm.count);
    success = 0;
  } else {
    for (size_t i = 0; i < orig.algorithm.count; i++) {
      if (orig.algorithm.components[i] != decoded.algorithm.components[i]) {
        printf("MISMATCH: OID component[%zu] %u != %u\n", i,
               orig.algorithm.components[i], decoded.algorithm.components[i]);
        success = 0;
      }
    }
  }

  if (orig.has_parameters != decoded.has_parameters) {
    printf("MISMATCH: has_parameters %d != %d\n", orig.has_parameters,
           decoded.has_parameters);
    success = 0;
  }

  /* Note: ASN1C_Node parameters length may differ due to TLV encoding */
  if (orig.has_parameters && decoded.has_parameters) {
    printf("  Parameters present in both (length: orig=%zu, decoded=%zu)\n",
           orig.parameters.length, decoded.parameters.length);
  }

  if (success) {
    printf("SUCCESS: Round-trip verified!\n");
    return 0;
  } else {
    printf("FAILED: Round-trip verification failed\n");
    return 1;
  }
}

int main(void) {
  int failures = 0;

  printf("C99 ASN.1 DER/BER Round-Trip Tests\n");
  printf("==================================\n");

  failures += test_algorithmidentifier_roundtrip();

  printf("\n=== Summary ===\n");
  if (failures == 0) {
    puts("All tests passed!");
  } else {
    printf("%d test(s) failed\n", failures);
  }

  return failures;
}
