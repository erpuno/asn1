/*
 * ASN.1 Suite Tests - Matching Swift Test Suite
 *
 * This test file mirrors the Swift test suite in main.swift
 * Tests: OID verification, Pentanomial, Certificate, DirectoryString,
 *        Name, GeneralName, CHATMessage
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
    fflush(stdout);                                                            \
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
 * OID Verification Tests (matching Swift verifyOID)
 * ============================================================================
 */

TEST(test_oid_id_ce) {
  /* id-ce: 2.5.29 - Certificate Extensions OID */
  /* Verify OID round-trip: serialize then parse */
  asn1_oid_t id_ce = {.components = {2, 5, 29}, .count = 3};

  uint8_t buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buf, sizeof(buf));

  asn1_error_t err = asn1_serialize_oid(&s, &id_ce);
  ASSERT_OK(err);

  /* Parse back */
  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);
  err = asn1_parse(buf, s.length, ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  asn1_oid_t parsed;
  err = asn1_parse_oid(&result.nodes[0], &parsed);
  ASSERT_OK(err);

  ASSERT(asn1_oid_equal(&id_ce, &parsed));

  char str_buf[100];
  asn1_oid_to_string(&parsed, str_buf, sizeof(str_buf));
  ASSERT(strcmp(str_buf, "2.5.29") == 0);
  printf("id-ce = %s... ", str_buf);
}

TEST(test_oid_rsa_encryption) {
  /* 1.2.840.113549.1.1.1 - RSA Encryption */
  asn1_oid_t rsa_oid = {.components = {1, 2, 840, 113549, 1, 1, 1}, .count = 7};

  uint8_t buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buf, sizeof(buf));

  asn1_error_t err = asn1_serialize_oid(&s, &rsa_oid);
  ASSERT_OK(err);

  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  err = asn1_parse(buf, s.length, ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  asn1_oid_t parsed;
  err = asn1_parse_oid(&result.nodes[0], &parsed);
  ASSERT_OK(err);

  ASSERT(asn1_oid_equal(&rsa_oid, &parsed));

  char str_buf[100];
  asn1_oid_to_string(&parsed, str_buf, sizeof(str_buf));
  ASSERT(strcmp(str_buf, "1.2.840.113549.1.1.1") == 0);
}

/* ============================================================================
 * Pentanomial Test (matching Swift showPentanomial)
 * ============================================================================
 */

TEST(test_pentanomial) {
  /* SEQUENCE { INTEGER 1, INTEGER 2, INTEGER 3 }
   * DER: 30 09 02 01 01 02 01 02 02 01 03 */
  uint8_t data[] = {0x30, 0x09, 0x02, 0x01, 0x01, 0x02,
                    0x01, 0x02, 0x02, 0x01, 0x03};

  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);
  ASSERT(result.count == 4); /* SEQUENCE + 3 INTEGERs */

  /* Check root is SEQUENCE */
  asn1_node_t *root = asn1_root_node(&result);
  ASSERT(asn1_identifier_equal(root->identifier, ASN1_ID_SEQUENCE));

  /* Parse k, j, l values */
  asn1_node_iterator_t iter = asn1_children(&result, 0);

  asn1_node_t *k_node = asn1_next_child(&iter);
  ASSERT(k_node != NULL);
  int64_t k;
  err = asn1_parse_int64(k_node, &k);
  ASSERT_OK(err);
  ASSERT(k == 1);

  asn1_node_t *j_node = asn1_next_child(&iter);
  ASSERT(j_node != NULL);
  int64_t j;
  err = asn1_parse_int64(j_node, &j);
  ASSERT_OK(err);
  ASSERT(j == 2);

  asn1_node_t *l_node = asn1_next_child(&iter);
  ASSERT(l_node != NULL);
  int64_t l;
  err = asn1_parse_int64(l_node, &l);
  ASSERT_OK(err);
  ASSERT(l == 3);

  printf("Pentanomial(k=%ld, j=%ld, l=%ld)... ", (long)k, (long)j, (long)l);

  /* Verify round-trip serialization */
  uint8_t out_buf[100];
  asn1_serializer_t s;
  asn1_serializer_init(&s, out_buf, sizeof(out_buf));

  size_t marker;
  err = asn1_serialize_constructed_begin(&s, ASN1_ID_SEQUENCE, &marker);
  ASSERT_OK(err);
  err = asn1_serialize_int64(&s, k);
  ASSERT_OK(err);
  err = asn1_serialize_int64(&s, j);
  ASSERT_OK(err);
  err = asn1_serialize_int64(&s, l);
  ASSERT_OK(err);
  err = asn1_serialize_constructed_end(&s, marker);
  ASSERT_OK(err);

  ASSERT(s.length == sizeof(data));
  ASSERT(memcmp(out_buf, data, sizeof(data)) == 0);
}

/* ============================================================================
 * DirectoryString Test (matching Swift showDirectoryString)
 * ============================================================================
 */

TEST(test_directory_string_printable) {
  /* PrintableString "123": 13 03 31 32 33 */
  uint8_t data[] = {0x13, 0x03, 0x31, 0x32, 0x33};

  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  asn1_node_t *node = asn1_root_node(&result);
  ASSERT(node != NULL);
  ASSERT(node->identifier.tag_number == 19); /* PrintableString */
  ASSERT(node->data_length == 3);
  ASSERT(memcmp(node->data_bytes, "123", 3) == 0);

  printf("DirectoryString(printableString: \"123\")... ");
}

/* ============================================================================
 * Name/RDNSequence Test (matching Swift showName)
 * ============================================================================
 */

TEST(test_name_with_country) {
  /* Name { RDNSequence { RDN { AttributeTypeAndValue { type: 2.5.4.6 (country),
   * value: "UA" } } } } DER: 30 0D 31 0B 30 09 06 03 55 04 06 13 02 55 41 */
  uint8_t data[] = {0x30, 0x0D, 0x31, 0x0B, 0x30, 0x09, 0x06, 0x03,
                    0x55, 0x04, 0x06, 0x13, 0x02, 0x55, 0x41};

  asn1_node_t nodes[20];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 20);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  /* Check structure: SEQUENCE -> SET -> SEQUENCE -> OID, PrintableString */
  asn1_node_t *root = asn1_root_node(&result);
  ASSERT(asn1_identifier_equal(root->identifier,
                               ASN1_ID_SEQUENCE)); /* RDNSequence */

  /* Navigate to attribute type OID */
  /* nodes[0] = outer SEQUENCE (RDNSequence)
   * nodes[1] = SET (RDN)
   * nodes[2] = inner SEQUENCE (AttributeTypeAndValue)
   * nodes[3] = OID (attribute type)
   * nodes[4] = PrintableString (value) */

  asn1_oid_t oid;
  err = asn1_parse_oid(&result.nodes[3], &oid);
  ASSERT_OK(err);

  char oid_str[100];
  asn1_oid_to_string(&oid, oid_str, sizeof(oid_str));
  ASSERT(strcmp(oid_str, "2.5.4.6") == 0); /* id-at-countryName */

  /* Check country value "UA" */
  ASSERT(result.nodes[4].identifier.tag_number == 19); /* PrintableString */
  ASSERT(result.nodes[4].data_length == 2);
  ASSERT(memcmp(result.nodes[4].data_bytes, "UA", 2) == 0);

  printf("Name(country: UA)... ");
}

TEST(test_name_empty) {
  /* Empty Name (empty RDNSequence): 30 00 */
  uint8_t data[] = {0x30, 0x00};

  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);
  ASSERT(result.count == 1);

  asn1_node_t *root = asn1_root_node(&result);
  ASSERT(asn1_identifier_equal(root->identifier, ASN1_ID_SEQUENCE));
  ASSERT(root->data_length == 0);

  printf("Name(empty)... ");
}

/* ============================================================================
 * GeneralName Test (matching Swift showGeneralName)
 * ============================================================================
 */

TEST(test_general_name_directory) {
  /* directoryName [4] EXPLICIT empty sequence: A4 02 30 00 */
  uint8_t data[] = {0xA4, 0x02, 0x30, 0x00};

  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  asn1_node_t *root = asn1_root_node(&result);
  /* Context-specific tag [4], constructed */
  ASSERT(root->identifier.tag_class == ASN1_TAG_CLASS_CONTEXT_SPECIFIC);
  ASSERT(root->identifier.tag_number == 4);
  ASSERT(root->content_type == ASN1_CONTENT_CONSTRUCTED);

  /* Inner is empty SEQUENCE */
  asn1_node_iterator_t iter = asn1_children(&result, 0);
  asn1_node_t *inner = asn1_next_child(&iter);
  ASSERT(inner != NULL);
  ASSERT(asn1_identifier_equal(inner->identifier, ASN1_ID_SEQUENCE));
  ASSERT(inner->data_length == 0);

  printf("GeneralName(directoryName: empty)... ");
}

TEST(test_general_name_dns) {
  /* dNSName [2] IMPLICIT IA5String("example.com")
   * Tag [2] -> 0x82 (Context-specific, primitive, tag 2)
   * "example.com" -> 65 78 61 6D 70 6C 65 2E 63 6F 6D (11 bytes) */
  uint8_t data[] = {0x82, 0x0B, 0x65, 0x78, 0x61, 0x6D, 0x70,
                    0x6C, 0x65, 0x2E, 0x63, 0x6F, 0x6D};

  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  asn1_node_t *root = asn1_root_node(&result);
  ASSERT(root->identifier.tag_class == ASN1_TAG_CLASS_CONTEXT_SPECIFIC);
  ASSERT(root->identifier.tag_number == 2);
  ASSERT(root->content_type == ASN1_CONTENT_PRIMITIVE);
  ASSERT(root->data_length == 11);
  ASSERT(memcmp(root->data_bytes, "example.com", 11) == 0);

  printf("GeneralName(dNSName: example.com)... ");
}

TEST(test_general_name_registered_id) {
  /* registeredID [8] IMPLICIT OBJECT IDENTIFIER(1.2.840.113549.1.7.1)
   * Tag [8] -> 0x88 (Context-specific, primitive, tag 8) */
  uint8_t data[] = {0x88, 0x09, 0x2A, 0x86, 0x48, 0x86,
                    0xF7, 0x0D, 0x01, 0x07, 0x01};

  asn1_node_t nodes[10];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  asn1_node_t *root = asn1_root_node(&result);
  ASSERT(root->identifier.tag_class == ASN1_TAG_CLASS_CONTEXT_SPECIFIC);
  ASSERT(root->identifier.tag_number == 8);

  /* Parse as OID (need to override identifier for parsing) */
  asn1_node_t oid_node = *root;
  oid_node.identifier = ASN1_ID_OBJECT_IDENTIFIER;

  asn1_oid_t oid;
  err = asn1_parse_oid(&oid_node, &oid);
  ASSERT_OK(err);

  char oid_str[100];
  asn1_oid_to_string(&oid, oid_str, sizeof(oid_str));
  ASSERT(strcmp(oid_str, "1.2.840.113549.1.7.1") == 0);

  printf("GeneralName(registeredID: 1.2.840.113549.1.7.1)... ");
}

/* ============================================================================
 * Certificate Structure Test (matching Swift showCertificateData)
 * ============================================================================
 */

TEST(test_certificate_basic) {
  /* Minimal X.509 Certificate structure - matches Swift test data exactly */
  uint8_t data[] = {
      0x30, 0x81, 0x81,             /* SEQUENCE (Certificate) */
      0x30, 0x6B,                   /* SEQUENCE (TBSCertificate) */
      0xA0, 0x03, 0x02, 0x01, 0x02, /* [0] EXPLICIT version = 2 (v3) */
      0x02, 0x03, 0x01, 0xE2, 0x40, /* INTEGER serialNumber = 123456 */
      0x30, 0x0A, 0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D,
      0x04, 0x03, 0x02, /* AlgorithmIdentifier (ecdsa-with-SHA256) */
      0x30, 0x0D, 0x31, 0x0B, 0x30, 0x09, 0x06, 0x03, 0x55,
      0x04, 0x03, 0x13, 0x02, 0x43, 0x41, /* Issuer: CN=CA */
      0x30, 0x1E,                         /* Validity */
      0x17, 0x0D, 0x32, 0x33, 0x30, 0x31, 0x30, 0x31, 0x31,
      0x32, 0x30, 0x30, 0x30, 0x30, 0x5A, /* notBefore: UTCTime */
      0x17, 0x0D, 0x33, 0x30, 0x30, 0x31, 0x30, 0x31, 0x31,
      0x32, 0x30, 0x30, 0x30, 0x30, 0x5A, /* notAfter: UTCTime */
      0x30, 0x0F, 0x31, 0x0D, 0x30, 0x0B, 0x06, 0x03, 0x55,
      0x04, 0x03, 0x13, 0x04, 0x55, 0x73, 0x65, 0x72, /* Subject: CN=User */
      0x30, 0x13,                                     /* SubjectPublicKeyInfo */
      0x30, 0x09, 0x06, 0x07, 0x2A, 0x86, 0x48, 0xCE, 0x3D,
      0x02, 0x01,                                     /* Algorithm */
      0x03, 0x06, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, /* publicKey */
      0x30, 0x0A, 0x06, 0x08, 0x2A, 0x86, 0x48, 0xCE, 0x3D,
      0x04, 0x03, 0x02,                              /* signatureAlgorithm */
      0x03, 0x06, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05 /* signatureValue */
  };

  asn1_node_t nodes[50];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 50);

  asn1_error_t err = asn1_parse(data, sizeof(data), ASN1_ENCODING_DER, &result);
  ASSERT_OK(err);

  /* Check root is SEQUENCE (Certificate) */
  asn1_node_t *root = asn1_root_node(&result);
  ASSERT(asn1_identifier_equal(root->identifier, ASN1_ID_SEQUENCE));

  /* Navigate structure */
  asn1_node_iterator_t iter = asn1_children(&result, 0);

  /* TBSCertificate */
  asn1_node_t *tbs = asn1_next_child(&iter);
  ASSERT(tbs != NULL);
  ASSERT(asn1_identifier_equal(tbs->identifier, ASN1_ID_SEQUENCE));

  /* SignatureAlgorithm */
  asn1_node_t *sig_alg = asn1_next_child(&iter);
  ASSERT(sig_alg != NULL);

  /* SignatureValue */
  asn1_node_t *sig_val = asn1_next_child(&iter);
  ASSERT(sig_val != NULL);
  ASSERT(sig_val->identifier.tag_number == 3); /* BIT STRING */

  printf("Certificate parsed successfully... ");
}

/* ============================================================================
 * Main
 * ============================================================================
 */

int main(void) {
  printf("ASN.1 Suite Tests (matching Swift test suite)\n");
  printf("==============================================\n\n");

  printf("OID Verification tests:\n");
  RUN_TEST(test_oid_id_ce);
  RUN_TEST(test_oid_rsa_encryption);

  printf("\nPentanomial test:\n");
  RUN_TEST(test_pentanomial);

  printf("\nDirectoryString tests:\n");
  RUN_TEST(test_directory_string_printable);

  printf("\nName/RDNSequence tests:\n");
  RUN_TEST(test_name_with_country);
  RUN_TEST(test_name_empty);

  printf("\nGeneralName tests:\n");
  RUN_TEST(test_general_name_directory);
  RUN_TEST(test_general_name_dns);
  RUN_TEST(test_general_name_registered_id);

  printf("\nCertificate tests:\n");
  RUN_TEST(test_certificate_basic);

  printf("\n==============================================\n");
  printf("Tests: %d/%d passed\n", tests_passed, tests_run);

  return (tests_passed == tests_run) ? 0 : 1;
}
