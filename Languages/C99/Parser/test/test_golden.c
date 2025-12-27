/*
 * ASN.1 Golden File Tests
 * Tests parsing against OpenSSL-generated golden files
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

/* ============================================================================
 * File Loading Utilities
 * ============================================================================
 */

static uint8_t *load_file(const char *path, size_t *out_len) {
  FILE *f = fopen(path, "rb");
  if (!f) {
    fprintf(stderr, "Failed to open: %s\n", path);
    return NULL;
  }

  fseek(f, 0, SEEK_END);
  long size = ftell(f);
  fseek(f, 0, SEEK_SET);

  if (size <= 0) {
    fclose(f);
    return NULL;
  }

  uint8_t *data = malloc((size_t)size);
  if (!data) {
    fclose(f);
    return NULL;
  }

  size_t read = fread(data, 1, (size_t)size, f);
  fclose(f);

  if (read != (size_t)size) {
    free(data);
    return NULL;
  }

  *out_len = (size_t)size;
  return data;
}

static asn1_error_t parse_golden(const char *filename,
                                 asn1_parse_result_t *result,
                                 asn1_node_t *nodes, size_t capacity,
                                 uint8_t **data_out) {
  char path[256];
  snprintf(path, sizeof(path), "tests/golden/%s", filename);

  size_t len;
  uint8_t *data = load_file(path, &len);
  if (!data) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT, "Failed to load file", 0);
  }

  asn1_parse_result_init(result, nodes, capacity);
  asn1_error_t err = asn1_parse(data, len, ASN1_ENCODING_DER, result);

  if (data_out) {
    *data_out = data;
  } else {
    free(data);
  }

  return err;
}

/* ============================================================================
 * Boolean Tests
 * ============================================================================
 */

TEST(test_golden_true) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("true.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  bool value;
  err = asn1_parse_boolean(&result.nodes[0], &value, ASN1_ENCODING_DER);
  ASSERT_OK(err);
  ASSERT(value == true);

  free(data);
}

TEST(test_golden_false) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("false.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  bool value;
  err = asn1_parse_boolean(&result.nodes[0], &value, ASN1_ENCODING_DER);
  ASSERT_OK(err);
  ASSERT(value == false);

  free(data);
}

/* ============================================================================
 * Integer Tests
 * ============================================================================
 */

TEST(test_golden_int_42) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("int_42.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  int64_t value;
  err = asn1_parse_int64(&result.nodes[0], &value);
  ASSERT_OK(err);
  ASSERT(value == 42);

  free(data);
}

TEST(test_golden_int_neg1) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("int_neg1.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  int64_t value;
  err = asn1_parse_int64(&result.nodes[0], &value);
  ASSERT_OK(err);
  ASSERT(value == -1);

  free(data);
}

TEST(test_golden_int_large) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("int_large.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  /* 0x0102030405060708 */
  uint64_t value;
  err = asn1_parse_uint64(&result.nodes[0], &value);
  ASSERT_OK(err);
  ASSERT(value == 0x0102030405060708ULL);

  free(data);
}

/* ============================================================================
 * NULL Test
 * ============================================================================
 */

TEST(test_golden_null) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("null.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  err = asn1_parse_null(&result.nodes[0]);
  ASSERT_OK(err);

  free(data);
}

/* ============================================================================
 * OID Test
 * ============================================================================
 */

TEST(test_golden_oid) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("oid.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  asn1_oid_t oid;
  err = asn1_parse_oid(&result.nodes[0], &oid);
  ASSERT_OK(err);

  /* 1.2.840.113549.1.1.11 (sha256WithRSAEncryption) */
  ASSERT(oid.count == 7);
  ASSERT(oid.components[0] == 1);
  ASSERT(oid.components[1] == 2);
  ASSERT(oid.components[2] == 840);
  ASSERT(oid.components[3] == 113549);
  ASSERT(oid.components[4] == 1);
  ASSERT(oid.components[5] == 1);
  ASSERT(oid.components[6] == 11);

  char buf[100];
  asn1_oid_to_string(&oid, buf, sizeof(buf));
  ASSERT(strcmp(buf, "1.2.840.113549.1.1.11") == 0);

  free(data);
}

/* ============================================================================
 * Octet String Tests
 * ============================================================================
 */

TEST(test_golden_octet_string) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err =
      parse_golden("octet_string.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  const uint8_t *bytes;
  size_t length;
  err = asn1_parse_octet_string(&result.nodes[0], &bytes, &length);
  ASSERT_OK(err);
  ASSERT(length == 11);
  ASSERT(memcmp(bytes, "Hello World", 11) == 0);

  free(data);
}

TEST(test_golden_octet_string_empty) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err =
      parse_golden("octet_string_empty.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  const uint8_t *bytes;
  size_t length;
  err = asn1_parse_octet_string(&result.nodes[0], &bytes, &length);
  ASSERT_OK(err);
  ASSERT(length == 0);

  free(data);
}

/* ============================================================================
 * String Tests
 * ============================================================================
 */

TEST(test_golden_utf8_string) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("utf8_string.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  /* Verify it's a UTF8String (tag 12) */
  ASSERT(result.nodes[0].identifier.tag_number == ASN1_TAG_UTF8_STRING);
  ASSERT(result.nodes[0].identifier.tag_class == ASN1_TAG_CLASS_UNIVERSAL);

  const char *str;
  size_t length;
  err = asn1_parse_string(&result.nodes[0], &str, &length);
  ASSERT_OK(err);
  ASSERT(length == 10);
  ASSERT(memcmp(str, "Hello UTF8", 10) == 0);

  free(data);
}

TEST(test_golden_printable_string) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err =
      parse_golden("printable_string.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  ASSERT(result.nodes[0].identifier.tag_number == ASN1_TAG_PRINTABLE_STRING);

  const char *str;
  size_t length;
  err = asn1_parse_string(&result.nodes[0], &str, &length);
  ASSERT_OK(err);
  ASSERT(length == 15);
  ASSERT(memcmp(str, "Hello Printable", 15) == 0);

  free(data);
}

TEST(test_golden_ia5_string) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("ia5_string.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  ASSERT(result.nodes[0].identifier.tag_number == ASN1_TAG_IA5_STRING);

  const char *str;
  size_t length;
  err = asn1_parse_string(&result.nodes[0], &str, &length);
  ASSERT_OK(err);
  ASSERT(length == 9);
  ASSERT(memcmp(str, "Hello IA5", 9) == 0);

  free(data);
}

TEST(test_golden_numeric_string) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err =
      parse_golden("numeric_string.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  ASSERT(result.nodes[0].identifier.tag_number == ASN1_TAG_NUMERIC_STRING);

  const char *str;
  size_t length;
  err = asn1_parse_string(&result.nodes[0], &str, &length);
  ASSERT_OK(err);
  ASSERT(length == 10);
  ASSERT(memcmp(str, "1234567890", 10) == 0);

  free(data);
}

/* ============================================================================
 * Time Tests
 * ============================================================================
 */

TEST(test_golden_utc_time) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("utc_time.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  ASSERT(result.nodes[0].identifier.tag_number == ASN1_TAG_UTC_TIME);

  const char *str;
  size_t length;
  err = asn1_parse_string(&result.nodes[0], &str, &length);
  ASSERT_OK(err);
  /* UTCTime: YYMMDDHHMMSSZ = 230101120000Z */
  ASSERT(length == 13);
  ASSERT(memcmp(str, "230101120000Z", 13) == 0);

  free(data);
}

TEST(test_golden_generalized_time) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err =
      parse_golden("generalized_time.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  ASSERT(result.nodes[0].identifier.tag_number == ASN1_TAG_GENERALIZED_TIME);

  const char *str;
  size_t length;
  err = asn1_parse_string(&result.nodes[0], &str, &length);
  ASSERT_OK(err);
  /* GeneralizedTime: YYYYMMDDHHMMSSZ = 20230101120000Z */
  ASSERT(length == 15);
  ASSERT(memcmp(str, "20230101120000Z", 15) == 0);

  free(data);
}

/* ============================================================================
 * Bit String Test
 * ============================================================================
 */

TEST(test_golden_bit_string) {
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  uint8_t *data = NULL;

  asn1_error_t err = parse_golden("bit_string.der", &result, nodes, 10, &data);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  ASSERT(result.nodes[0].identifier.tag_number == ASN1_TAG_BIT_STRING);

  asn1_bit_string_t bs;
  err = asn1_parse_bit_string(&result.nodes[0], &bs);
  ASSERT_OK(err);

  /* The bit string contains "0A3B5F291CD" as hex string in the file */
  /* First byte is unused bits count, rest is the actual string data */
  ASSERT(bs.unused_bits == 0);
  /* The encoding stores the string "0A3B5F291CD" as ASCII bytes */
  ASSERT(bs.byte_count == 11);

  free(data);
}

/* ============================================================================
 * Roundtrip Tests - Serialize and parse back
 * ============================================================================
 */

TEST(test_roundtrip_boolean_true) {
  uint8_t buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buf, sizeof(buf));

  asn1_error_t err = asn1_serialize_boolean(&s, true);
  ASSERT_OK(err);

  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  err = asn1_parse(buf, s.length, ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  bool value;
  err = asn1_parse_boolean(&result.nodes[0], &value, ASN1_ENCODING_DER);
  ASSERT_OK(err);
  ASSERT(value == true);
}

TEST(test_roundtrip_int_negative) {
  uint8_t buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buf, sizeof(buf));

  asn1_error_t err = asn1_serialize_int64(&s, -12345);
  ASSERT_OK(err);

  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  err = asn1_parse(buf, s.length, ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  int64_t value;
  err = asn1_parse_int64(&result.nodes[0], &value);
  ASSERT_OK(err);
  ASSERT(value == -12345);
}

TEST(test_roundtrip_octet_string) {
  uint8_t buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buf, sizeof(buf));

  const char *test_data = "Test data 123";
  asn1_error_t err = asn1_serialize_octet_string(&s, (const uint8_t *)test_data,
                                                 strlen(test_data));
  ASSERT_OK(err);

  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  err = asn1_parse(buf, s.length, ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  const uint8_t *bytes;
  size_t length;
  err = asn1_parse_octet_string(&result.nodes[0], &bytes, &length);
  ASSERT_OK(err);
  ASSERT(length == strlen(test_data));
  ASSERT(memcmp(bytes, test_data, length) == 0);
}

/* ============================================================================
 * Main
 * ============================================================================
 */

int main(void) {
  printf("ASN.1 Golden File Tests\n");
  printf("=======================\n\n");

  printf("Boolean tests:\n");
  RUN_TEST(test_golden_true);
  RUN_TEST(test_golden_false);

  printf("\nInteger tests:\n");
  RUN_TEST(test_golden_int_42);
  RUN_TEST(test_golden_int_neg1);
  RUN_TEST(test_golden_int_large);

  printf("\nNULL test:\n");
  RUN_TEST(test_golden_null);

  printf("\nOID test:\n");
  RUN_TEST(test_golden_oid);

  printf("\nOctet string tests:\n");
  RUN_TEST(test_golden_octet_string);
  RUN_TEST(test_golden_octet_string_empty);

  printf("\nString tests:\n");
  RUN_TEST(test_golden_utf8_string);
  RUN_TEST(test_golden_printable_string);
  RUN_TEST(test_golden_ia5_string);
  RUN_TEST(test_golden_numeric_string);

  printf("\nTime tests:\n");
  RUN_TEST(test_golden_utc_time);
  RUN_TEST(test_golden_generalized_time);

  printf("\nBit string test:\n");
  RUN_TEST(test_golden_bit_string);

  printf("\nRoundtrip tests:\n");
  RUN_TEST(test_roundtrip_boolean_true);
  RUN_TEST(test_roundtrip_int_negative);
  RUN_TEST(test_roundtrip_octet_string);

  printf("\n=======================\n");
  printf("Tests: %d/%d passed\n", tests_passed, tests_run);

  return (tests_passed == tests_run) ? 0 : 1;
}
