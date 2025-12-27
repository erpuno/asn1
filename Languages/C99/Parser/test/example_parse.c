/*
 * ASN.1 Parser Example - Parse and dump ASN.1 structure
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <asn1/asn1.h>
#include <asn1/asn1_types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ============================================================================
 * Tag Name Lookup
 * ============================================================================
 */

static const char *get_universal_tag_name(uint32_t tag) {
  switch (tag) {
  case ASN1_TAG_BOOLEAN:
    return "BOOLEAN";
  case ASN1_TAG_INTEGER:
    return "INTEGER";
  case ASN1_TAG_BIT_STRING:
    return "BIT STRING";
  case ASN1_TAG_OCTET_STRING:
    return "OCTET STRING";
  case ASN1_TAG_NULL:
    return "NULL";
  case ASN1_TAG_OBJECT_IDENTIFIER:
    return "OBJECT IDENTIFIER";
  case ASN1_TAG_OBJECT_DESCRIPTOR:
    return "ObjectDescriptor";
  case ASN1_TAG_EXTERNAL:
    return "EXTERNAL";
  case ASN1_TAG_REAL:
    return "REAL";
  case ASN1_TAG_ENUMERATED:
    return "ENUMERATED";
  case ASN1_TAG_EMBEDDED_PDV:
    return "EMBEDDED PDV";
  case ASN1_TAG_UTF8_STRING:
    return "UTF8String";
  case ASN1_TAG_RELATIVE_OID:
    return "RELATIVE-OID";
  case ASN1_TAG_SEQUENCE:
    return "SEQUENCE";
  case ASN1_TAG_SET:
    return "SET";
  case ASN1_TAG_NUMERIC_STRING:
    return "NumericString";
  case ASN1_TAG_PRINTABLE_STRING:
    return "PrintableString";
  case ASN1_TAG_TELETEX_STRING:
    return "TeletexString";
  case ASN1_TAG_VIDEOTEX_STRING:
    return "VideotexString";
  case ASN1_TAG_IA5_STRING:
    return "IA5String";
  case ASN1_TAG_UTC_TIME:
    return "UTCTime";
  case ASN1_TAG_GENERALIZED_TIME:
    return "GeneralizedTime";
  case ASN1_TAG_GRAPHIC_STRING:
    return "GraphicString";
  case ASN1_TAG_VISIBLE_STRING:
    return "VisibleString";
  case ASN1_TAG_GENERAL_STRING:
    return "GeneralString";
  case ASN1_TAG_UNIVERSAL_STRING:
    return "UniversalString";
  case ASN1_TAG_CHARACTER_STRING:
    return "CHARACTER STRING";
  case ASN1_TAG_BMP_STRING:
    return "BMPString";
  default:
    return NULL;
  }
}

static const char *get_tag_class_name(asn1_tag_class_t tag_class) {
  switch (tag_class) {
  case ASN1_TAG_CLASS_UNIVERSAL:
    return "UNIVERSAL";
  case ASN1_TAG_CLASS_APPLICATION:
    return "APPLICATION";
  case ASN1_TAG_CLASS_CONTEXT_SPECIFIC:
    return "CONTEXT";
  case ASN1_TAG_CLASS_PRIVATE:
    return "PRIVATE";
  default:
    return "UNKNOWN";
  }
}

/* ============================================================================
 * Hex Dump
 * ============================================================================
 */

static void print_hex(const uint8_t *data, size_t len, size_t max) {
  size_t show = len < max ? len : max;
  for (size_t i = 0; i < show; i++) {
    printf("%02X ", data[i]);
  }
  if (len > max) {
    printf("... (%zu more)", len - max);
  }
}

/* ============================================================================
 * Print ASN.1 Tree
 * ============================================================================
 */

static void print_node(const asn1_node_t *node, size_t index) {
  /* Indentation based on depth */
  for (size_t i = 1; i < node->depth; i++) {
    printf("  ");
  }

  /* Offset */
  printf("%4zu: ", (size_t)(node->encoded_bytes - node->encoded_bytes + index));

  /* Tag description */
  if (node->identifier.tag_class == ASN1_TAG_CLASS_UNIVERSAL) {
    const char *name = get_universal_tag_name(node->identifier.tag_number);
    if (name) {
      printf("%s", name);
    } else {
      printf("[UNIVERSAL %u]", node->identifier.tag_number);
    }
  } else {
    printf("[%s %u]", get_tag_class_name(node->identifier.tag_class),
           node->identifier.tag_number);
  }

  /* Content type */
  if (node->content_type == ASN1_CONTENT_CONSTRUCTED) {
    printf(" (constructed)");
  }

  /* Length */
  printf(" len=%zu", node->encoded_length);

  /* Value for primitive types */
  if (node->content_type == ASN1_CONTENT_PRIMITIVE && node->data_length > 0) {
    printf(" : ");

    /* Try to show meaningful content based on type */
    if (node->identifier.tag_class == ASN1_TAG_CLASS_UNIVERSAL) {
      switch (node->identifier.tag_number) {
      case ASN1_TAG_BOOLEAN: {
        printf("%s", node->data_bytes[0] ? "TRUE" : "FALSE");
        break;
      }
      case ASN1_TAG_INTEGER: {
        int64_t val;
        if (asn1_is_ok(asn1_parse_int64(node, &val))) {
          printf("%lld", (long long)val);
        } else {
          print_hex(node->data_bytes, node->data_length, 16);
        }
        break;
      }
      case ASN1_TAG_OBJECT_IDENTIFIER: {
        asn1_oid_t oid;
        if (asn1_is_ok(asn1_parse_oid(node, &oid))) {
          char buf[200];
          asn1_oid_to_string(&oid, buf, sizeof(buf));
          printf("%s", buf);
        } else {
          print_hex(node->data_bytes, node->data_length, 16);
        }
        break;
      }
      case ASN1_TAG_UTF8_STRING:
      case ASN1_TAG_PRINTABLE_STRING:
      case ASN1_TAG_IA5_STRING:
      case ASN1_TAG_VISIBLE_STRING: {
        printf("\"");
        size_t show = node->data_length < 50 ? node->data_length : 50;
        for (size_t i = 0; i < show; i++) {
          uint8_t c = node->data_bytes[i];
          if (c >= 32 && c < 127) {
            putchar(c);
          } else {
            printf("\\x%02X", c);
          }
        }
        if (node->data_length > 50)
          printf("...");
        printf("\"");
        break;
      }
      case ASN1_TAG_UTC_TIME:
      case ASN1_TAG_GENERALIZED_TIME: {
        printf("\"");
        for (size_t i = 0; i < node->data_length; i++) {
          putchar(node->data_bytes[i]);
        }
        printf("\"");
        break;
      }
      case ASN1_TAG_BIT_STRING: {
        if (node->data_length > 0) {
          printf("(%u unused) ", node->data_bytes[0]);
          print_hex(node->data_bytes + 1, node->data_length - 1, 8);
        }
        break;
      }
      default:
        print_hex(node->data_bytes, node->data_length, 16);
        break;
      }
    } else {
      print_hex(node->data_bytes, node->data_length, 16);
    }
  }

  printf("\n");
}

static void print_tree(const asn1_parse_result_t *result) {
  for (size_t i = 0; i < result->count; i++) {
    print_node(&result->nodes[i], i);
  }
}

/* ============================================================================
 * Main
 * ============================================================================
 */

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printf("Usage: %s <file.der>\n", argv[0]);
    printf("\nParses a DER-encoded ASN.1 file and prints the structure.\n");
    printf("\nExample to create test data:\n");
    printf("  echo -n 'test' | openssl asn1parse -genstr 'UTF8:test' -out "
           "test.der\n");
    printf("  openssl req -x509 -newkey rsa:2048 -keyout /dev/null -out "
           "cert.pem -days 1 -nodes -subj '/CN=test'\n");
    printf("  openssl x509 -in cert.pem -outform der -out cert.der\n");
    return 1;
  }

  /* Read file */
  FILE *f = fopen(argv[1], "rb");
  if (!f) {
    perror("Error opening file");
    return 1;
  }

  fseek(f, 0, SEEK_END);
  long file_size = ftell(f);
  fseek(f, 0, SEEK_SET);

  if (file_size <= 0 || file_size > 10 * 1024 * 1024) {
    fprintf(stderr, "File too large or empty\n");
    fclose(f);
    return 1;
  }

  uint8_t *data = malloc((size_t)file_size);
  if (!data) {
    fprintf(stderr, "Out of memory\n");
    fclose(f);
    return 1;
  }

  size_t bytes_read = fread(data, 1, (size_t)file_size, f);
  fclose(f);

  if (bytes_read != (size_t)file_size) {
    fprintf(stderr, "Error reading file\n");
    free(data);
    return 1;
  }

  printf("Parsing %s (%zu bytes)\n", argv[1], bytes_read);
  printf("====================================================================="
         "===========\n\n");

  /* Parse */
  asn1_node_t *nodes = malloc(sizeof(asn1_node_t) * 10000);
  if (!nodes) {
    fprintf(stderr, "Out of memory\n");
    free(data);
    return 1;
  }

  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 10000);

  asn1_error_t err = asn1_parse(data, bytes_read, ASN1_ENCODING_DER, &result);

  if (!asn1_is_ok(err)) {
    fprintf(stderr, "Parse error: %s - %s (at offset %zu)\n",
            asn1_error_code_name(err.code),
            err.message ? err.message : "no details", err.offset);
    free(nodes);
    free(data);
    return 1;
  }

  printf("Parsed %zu nodes:\n\n", result.count);
  print_tree(&result);

  free(nodes);
  free(data);

  return 0;
}
