/*
 * ASN.1 Parser Tests
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <asn1/asn1.h>
#include <asn1/asn1_types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ============================================================================
 * Test Framework
 * ============================================================================
 */

static int tests_run = 0;
static int tests_passed = 0;

#define TEST(name) static void name(void)
#define RUN_TEST(name)                                                         \
  do {                                                                         \
    printf("  Running %s... ", #name);                                         \
    tests_run++;                                                               \
    name();                                                                    \
    tests_passed++;                                                            \
    printf("OK\n");                                                            \
  } while (0)

#define ASSERT(cond)                                                           \
  do {                                                                         \
    if (!(cond)) {                                                             \
      printf("FAILED at %s:%d: %s\n", __FILE__, __LINE__, #cond);              \
      exit(1);                                                                 \
    }                                                                          \
  } while (0)

#define ASSERT_OK(err) ASSERT(asn1_is_ok(err))
#define ASSERT_ERR(err, expected_code) ASSERT((err).code == (expected_code))

/* ============================================================================
 * Identifier Tests
 * ============================================================================
 */

TEST(test_identifier_short_form) {
  /* Boolean identifier: 0x01 */
  asn1_identifier_t id = ASN1_ID_BOOLEAN;
  ASSERT(id.tag_number == 1);
  ASSERT(id.tag_class == ASN1_TAG_CLASS_UNIVERSAL);
  ASSERT(asn1_identifier_is_short_form(id));
  ASSERT(asn1_identifier_short_form(id, false) == 0x01);

  /* SEQUENCE identifier: 0x30 (constructed) */
  id = ASN1_ID_SEQUENCE;
  ASSERT(id.tag_number == 16);
  ASSERT(asn1_identifier_short_form(id, true) == 0x30);
}

TEST(test_identifier_context_tag) {
  asn1_identifier_t id = asn1_context_tag(0);
  ASSERT(id.tag_number == 0);
  ASSERT(id.tag_class == ASN1_TAG_CLASS_CONTEXT_SPECIFIC);
  ASSERT(asn1_identifier_short_form(id, false) == 0x80);
  ASSERT(asn1_identifier_short_form(id, true) == 0xA0);
}

/* ============================================================================
 * Parser Tests
 * ============================================================================
 */

TEST(test_parse_boolean_true) {
  /* BOOLEAN TRUE: 01 01 FF */
  uint8_t data[] = {0x01, 0x01, 0xFF};
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  asn1_node_t *node = asn1_root_node(&result);
  ASSERT(node != NULL);
  ASSERT(asn1_identifier_equal(node->identifier, ASN1_ID_BOOLEAN));
  ASSERT(node->content_type == ASN1_CONTENT_PRIMITIVE);
  ASSERT(node->data_length == 1);
  ASSERT(node->data_bytes[0] == 0xFF);

  bool value;
  err = asn1_parse_boolean(node, &value, ASN1_ENCODING_DER);
  ASSERT_OK(err);
  ASSERT(value == true);
}

TEST(test_parse_boolean_false) {
  /* BOOLEAN FALSE: 01 01 00 */
  uint8_t data[] = {0x01, 0x01, 0x00};
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  bool value;
  err = asn1_parse_boolean(&result.nodes[0], &value, ASN1_ENCODING_DER);
  ASSERT_OK(err);
  ASSERT(value == false);
}

TEST(test_parse_integer_positive) {
  /* INTEGER 127: 02 01 7F */
  uint8_t data[] = {0x02, 0x01, 0x7F};
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  int64_t value;
  err = asn1_parse_int64(&result.nodes[0], &value);
  ASSERT_OK(err);
  ASSERT(value == 127);
}

TEST(test_parse_integer_negative) {
  /* INTEGER -128: 02 01 80 */
  uint8_t data[] = {0x02, 0x01, 0x80};
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  int64_t value;
  err = asn1_parse_int64(&result.nodes[0], &value);
  ASSERT_OK(err);
  ASSERT(value == -128);
}

TEST(test_parse_integer_large) {
  /* INTEGER 256: 02 02 01 00 */
  uint8_t data[] = {0x02, 0x02, 0x01, 0x00};
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  int64_t value;
  err = asn1_parse_int64(&result.nodes[0], &value);
  ASSERT_OK(err);
  ASSERT(value == 256);
}

TEST(test_parse_null) {
  /* NULL: 05 00 */
  uint8_t data[] = {0x05, 0x00};
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  err = asn1_parse_null(&result.nodes[0]);
  ASSERT_OK(err);
}

TEST(test_parse_octet_string) {
  /* OCTET STRING "abc": 04 03 61 62 63 */
  uint8_t data[] = {0x04, 0x03, 0x61, 0x62, 0x63};
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  const uint8_t *bytes;
  size_t length;
  err = asn1_parse_octet_string(&result.nodes[0], &bytes, &length);
  ASSERT_OK(err);
  ASSERT(length == 3);
  ASSERT(memcmp(bytes, "abc", 3) == 0);
}

TEST(test_parse_sequence) {
  /* SEQUENCE { INTEGER 1, INTEGER 2 }: 30 06 02 01 01 02 01 02 */
  uint8_t data[] = {0x30, 0x06, 0x02, 0x01, 0x01, 0x02, 0x01, 0x02};
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);
  ASSERT(result.count == 3); /* SEQUENCE + 2 INTEGERs */

  /* Check root is SEQUENCE */
  asn1_node_t *root = asn1_root_node(&result);
  ASSERT(asn1_identifier_equal(root->identifier, ASN1_ID_SEQUENCE));
  ASSERT(root->content_type == ASN1_CONTENT_CONSTRUCTED);
  ASSERT(root->subtree_size == 3);

  /* Iterate children */
  asn1_node_iterator_t iter = asn1_children(&result, 0);

  asn1_node_t *child1 = asn1_next_child(&iter);
  ASSERT(child1 != NULL);
  int64_t val1;
  err = asn1_parse_int64(child1, &val1);
  ASSERT_OK(err);
  ASSERT(val1 == 1);

  asn1_node_t *child2 = asn1_next_child(&iter);
  ASSERT(child2 != NULL);
  int64_t val2;
  err = asn1_parse_int64(child2, &val2);
  ASSERT_OK(err);
  ASSERT(val2 == 2);

  ASSERT(asn1_next_child(&iter) == NULL); /* No more children */
}

TEST(test_parse_nested_sequence) {
  /* SEQUENCE { SEQUENCE { INTEGER 42 } } */
  uint8_t data[] = {0x30, 0x05, 0x30, 0x03, 0x02, 0x01, 0x2A};
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);
  ASSERT(result.count == 3); /* Outer SEQUENCE, inner SEQUENCE, INTEGER */

  /* Outer SEQUENCE */
  ASSERT(result.nodes[0].depth == 1);
  ASSERT(result.nodes[0].subtree_size == 3);

  /* Inner SEQUENCE */
  ASSERT(result.nodes[1].depth == 2);
  ASSERT(result.nodes[1].subtree_size == 2);

  /* INTEGER */
  ASSERT(result.nodes[2].depth == 3);
  ASSERT(result.nodes[2].subtree_size == 1);

  int64_t value;
  err = asn1_parse_int64(&result.nodes[2], &value);
  ASSERT_OK(err);
  ASSERT(value == 42);
}

TEST(test_parse_oid) {
  /* OID 1.2.840.113549.1.1.1 (RSA encryption) */
  uint8_t data[] = {0x06, 0x09, 0x2A, 0x86, 0x48, 0x86,
                    0xF7, 0x0D, 0x01, 0x01, 0x01};
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  asn1_oid_t oid;
  err = asn1_parse_oid(&result.nodes[0], &oid);
  ASSERT_OK(err);
  ASSERT(oid.count == 7);
  ASSERT(oid.components[0] == 1);
  ASSERT(oid.components[1] == 2);
  ASSERT(oid.components[2] == 840);
  ASSERT(oid.components[3] == 113549);
  ASSERT(oid.components[4] == 1);
  ASSERT(oid.components[5] == 1);
  ASSERT(oid.components[6] == 1);

  char buf[100];
  asn1_oid_to_string(&oid, buf, sizeof(buf));
  ASSERT(strcmp(buf, "1.2.840.113549.1.1.1") == 0);
}

TEST(test_parse_bit_string) {
  /* BIT STRING with 1 unused bit: 03 03 01 AB CD */
  /* This represents 15 bits of data */
  uint8_t data[] = {0x03, 0x03, 0x01, 0xAA,
                    0xFE}; /* Last bit is 0, so unused=1 works */
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  asn1_bit_string_t bs;
  err = asn1_parse_bit_string(&result.nodes[0], &bs);
  ASSERT_OK(err);
  ASSERT(bs.byte_count == 2);
  ASSERT(bs.unused_bits == 1);
  ASSERT(asn1_bit_string_bit_count(&bs) == 15);
}

/* ============================================================================
 * Error Tests
 * ============================================================================
 */

TEST(test_error_truncated) {
  uint8_t data[] = {0x30, 0x10}; /* SEQUENCE claiming 16 bytes, but only 0 */
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_ERR(err, ASN1_ERROR_TRUNCATED_FIELD);
}

TEST(test_error_trailing_data) {
  uint8_t data[] = {0x05, 0x00, 0xFF}; /* NULL followed by garbage */
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_ERR(err, ASN1_ERROR_TRAILING_DATA);
}

/* ============================================================================
 * Serialization Tests
 * ============================================================================
 */

TEST(test_serialize_boolean) {
  uint8_t buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buf, sizeof(buf));

  asn1_error_t err = asn1_serialize_boolean(&s, true);
  ASSERT_OK(err);

  ASSERT(s.length == 3);
  ASSERT(buf[0] == 0x01); /* BOOLEAN tag */
  ASSERT(buf[1] == 0x01); /* Length 1 */
  ASSERT(buf[2] == 0xFF); /* TRUE */

  asn1_serializer_init(&s, buf, sizeof(buf));
  err = asn1_serialize_boolean(&s, false);
  ASSERT_OK(err);
  ASSERT(buf[2] == 0x00); /* FALSE */
}

TEST(test_serialize_integer) {
  uint8_t buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buf, sizeof(buf));

  asn1_error_t err = asn1_serialize_int64(&s, 127);
  ASSERT_OK(err);
  ASSERT(s.length == 3);
  ASSERT(buf[0] == 0x02);
  ASSERT(buf[1] == 0x01);
  ASSERT(buf[2] == 0x7F);

  asn1_serializer_init(&s, buf, sizeof(buf));
  err = asn1_serialize_int64(&s, 128);
  ASSERT_OK(err);
  ASSERT(s.length == 4);
  ASSERT(buf[0] == 0x02);
  ASSERT(buf[1] == 0x02);
  ASSERT(buf[2] == 0x00); /* Leading zero for positive with MSB set */
  ASSERT(buf[3] == 0x80);

  asn1_serializer_init(&s, buf, sizeof(buf));
  err = asn1_serialize_int64(&s, -128);
  ASSERT_OK(err);
  ASSERT(s.length == 3);
  ASSERT(buf[2] == 0x80); /* -128 in two's complement */
}

TEST(test_serialize_null) {
  uint8_t buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buf, sizeof(buf));

  asn1_error_t err = asn1_serialize_null(&s);
  ASSERT_OK(err);
  ASSERT(s.length == 2);
  ASSERT(buf[0] == 0x05);
  ASSERT(buf[1] == 0x00);
}

TEST(test_serialize_sequence) {
  uint8_t buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buf, sizeof(buf));

  size_t marker;
  asn1_error_t err =
      asn1_serialize_constructed_begin(&s, ASN1_ID_SEQUENCE, &marker);
  ASSERT_OK(err);

  err = asn1_serialize_int64(&s, 1);
  ASSERT_OK(err);

  err = asn1_serialize_int64(&s, 2);
  ASSERT_OK(err);

  err = asn1_serialize_constructed_end(&s, marker);
  ASSERT_OK(err);

  /* Expected: 30 06 02 01 01 02 01 02 */
  ASSERT(s.length == 8);
  ASSERT(buf[0] == 0x30);
  ASSERT(buf[1] == 0x06);
}

TEST(test_roundtrip_oid) {
  asn1_oid_t oid = {.components = {1, 2, 840, 113549, 1, 1, 1}, .count = 7};

  uint8_t buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buf, sizeof(buf));

  asn1_error_t err = asn1_serialize_oid(&s, &oid);
  ASSERT_OK(err);

  /* Parse it back */
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  err = asn1_parse(buf, s.length, ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  asn1_oid_t parsed;
  err = asn1_parse_oid(&result.nodes[0], &parsed);
  ASSERT_OK(err);

  ASSERT(asn1_oid_equal(&oid, &parsed));
}

/* ============================================================================
 * Main
 * ============================================================================
 */

int main(void) {
  printf("ASN.1 Parser Tests\n");
  printf("==================\n\n");

  printf("Identifier tests:\n");
  RUN_TEST(test_identifier_short_form);
  RUN_TEST(test_identifier_context_tag);

  printf("\nParser tests:\n");
  RUN_TEST(test_parse_boolean_true);
  RUN_TEST(test_parse_boolean_false);
  RUN_TEST(test_parse_integer_positive);
  RUN_TEST(test_parse_integer_negative);
  RUN_TEST(test_parse_integer_large);
  RUN_TEST(test_parse_null);
  RUN_TEST(test_parse_octet_string);
  RUN_TEST(test_parse_sequence);
  RUN_TEST(test_parse_nested_sequence);
  RUN_TEST(test_parse_oid);
  RUN_TEST(test_parse_bit_string);

  printf("\nError tests:\n");
  RUN_TEST(test_error_truncated);
  RUN_TEST(test_error_trailing_data);

  printf("\nSerialization tests:\n");
  RUN_TEST(test_serialize_boolean);
  RUN_TEST(test_serialize_integer);
  RUN_TEST(test_serialize_null);
  RUN_TEST(test_serialize_sequence);
  RUN_TEST(test_roundtrip_oid);

  printf("\n==================\n");
  printf("Tests: %d/%d passed\n", tests_passed, tests_run);

  return (tests_passed == tests_run) ? 0 : 1;
}
