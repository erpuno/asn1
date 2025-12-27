/*
 * ASN.1 Basic Type Implementation
 * Based on swift-asn1 by Apple Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "../include/asn1/asn1_types.h"
#include "asn1_internal.h"
#include <stdio.h>
#include <string.h>

/* ============================================================================
 * BOOLEAN
 * ============================================================================
 */

asn1_error_t asn1_parse_boolean(const asn1_node_t *node, bool *value,
                                asn1_encoding_rules_t rules) {
  if (!asn1_identifier_equal(node->identifier, ASN1_ID_BOOLEAN)) {
    return asn1_error(ASN1_ERROR_UNEXPECTED_FIELD_TYPE, "Expected BOOLEAN", 0);
  }

  if (node->content_type != ASN1_CONTENT_PRIMITIVE) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT, "BOOLEAN must be primitive",
                      0);
  }

  if (node->data_length != 1) {
    return asn1_error(ASN1_ERROR_INVALID_BOOLEAN,
                      "BOOLEAN must be exactly 1 byte", 0);
  }

  uint8_t byte = node->data_bytes[0];

  if (rules == ASN1_ENCODING_DER) {
    /* DER: false = 0x00, true = 0xFF */
    if (byte != 0x00 && byte != 0xFF) {
      return asn1_error(ASN1_ERROR_INVALID_BOOLEAN,
                        "DER BOOLEAN must be 0x00 or 0xFF", 0);
    }
  }

  *value = (byte != 0x00);
  return asn1_ok();
}

asn1_error_t asn1_serialize_boolean(asn1_serializer_t *s, bool value) {
  uint8_t byte = value ? 0xFF : 0x00;
  return asn1_serialize_primitive(s, ASN1_ID_BOOLEAN, &byte, 1);
}

/* ============================================================================
 * INTEGER
 * ============================================================================
 */

asn1_error_t asn1_parse_integer_bytes(const asn1_node_t *node,
                                      const uint8_t **bytes, size_t *length,
                                      bool *negative) {
  if (!asn1_identifier_equal(node->identifier, ASN1_ID_INTEGER)) {
    return asn1_error(ASN1_ERROR_UNEXPECTED_FIELD_TYPE, "Expected INTEGER", 0);
  }

  if (node->content_type != ASN1_CONTENT_PRIMITIVE) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT, "INTEGER must be primitive",
                      0);
  }

  if (node->data_length == 0) {
    return asn1_error(ASN1_ERROR_INVALID_INTEGER_ENCODING,
                      "INTEGER cannot be empty", 0);
  }

  *bytes = node->data_bytes;
  *length = node->data_length;
  *negative = (node->data_bytes[0] & 0x80) != 0;

  return asn1_ok();
}

asn1_error_t asn1_parse_int64(const asn1_node_t *node, int64_t *value) {
  const uint8_t *bytes;
  size_t length;
  bool negative;

  asn1_error_t err = asn1_parse_integer_bytes(node, &bytes, &length, &negative);
  if (!asn1_is_ok(err))
    return err;

  /* Check if it fits in int64 */
  if (length > 8) {
    return asn1_error(ASN1_ERROR_INVALID_INTEGER_ENCODING,
                      "INTEGER too large for int64", 0);
  }

  /* Check for non-minimal encoding */
  if (length > 1) {
    if ((bytes[0] == 0x00 && (bytes[1] & 0x80) == 0) ||
        (bytes[0] == 0xFF && (bytes[1] & 0x80) != 0)) {
      return asn1_error(ASN1_ERROR_INVALID_INTEGER_ENCODING,
                        "Non-minimal INTEGER encoding", 0);
    }
  }

  /* Parse as signed big-endian */
  int64_t result = negative ? -1 : 0; /* Sign extend */
  for (size_t i = 0; i < length; i++) {
    result = (result << 8) | bytes[i];
  }

  *value = result;
  return asn1_ok();
}

asn1_error_t asn1_parse_uint64(const asn1_node_t *node, uint64_t *value) {
  const uint8_t *bytes;
  size_t length;
  bool negative;

  asn1_error_t err = asn1_parse_integer_bytes(node, &bytes, &length, &negative);
  if (!asn1_is_ok(err))
    return err;

  if (negative) {
    return asn1_error(ASN1_ERROR_INVALID_INTEGER_ENCODING,
                      "Negative INTEGER cannot be parsed as unsigned", 0);
  }

  /* Check if it fits in uint64 (up to 9 bytes with leading zero) */
  if (length > 9 || (length == 9 && bytes[0] != 0)) {
    return asn1_error(ASN1_ERROR_INVALID_INTEGER_ENCODING,
                      "INTEGER too large for uint64", 0);
  }

  uint64_t result = 0;
  for (size_t i = 0; i < length; i++) {
    result = (result << 8) | bytes[i];
  }

  *value = result;
  return asn1_ok();
}

asn1_error_t asn1_serialize_int64(asn1_serializer_t *s, int64_t value) {
  uint8_t buf[9];
  size_t len = 0;

  if (value >= 0) {
    /* Positive: minimal big-endian, add leading zero if MSB set */
    uint64_t uval = (uint64_t)value;

    /* Find minimal encoding */
    int shift;
    for (shift = 56; shift > 0; shift -= 8) {
      if ((uval >> shift) != 0)
        break;
    }

    /* Check if we need leading zero */
    if ((uval >> shift) & 0x80) {
      buf[len++] = 0x00;
    }

    for (; shift >= 0; shift -= 8) {
      buf[len++] = (uint8_t)(uval >> shift);
    }
  } else {
    /* Negative: two's complement */
    int shift;
    for (shift = 56; shift > 0; shift -= 8) {
      uint8_t byte = (uint8_t)(value >> shift);
      uint8_t next = (uint8_t)(value >> (shift - 8));
      /* Skip leading 0xFF bytes if next byte has sign bit set */
      if (byte == 0xFF && (next & 0x80))
        continue;
      break;
    }

    for (; shift >= 0; shift -= 8) {
      buf[len++] = (uint8_t)(value >> shift);
    }
  }

  return asn1_serialize_primitive(s, ASN1_ID_INTEGER, buf, len);
}

asn1_error_t asn1_serialize_uint64(asn1_serializer_t *s, uint64_t value) {
  uint8_t buf[9];
  size_t len = 0;

  /* Find minimal encoding */
  int shift;
  for (shift = 56; shift > 0; shift -= 8) {
    if ((value >> shift) != 0)
      break;
  }

  /* Add leading zero if MSB is set (would look negative) */
  if ((value >> shift) & 0x80) {
    buf[len++] = 0x00;
  }

  for (; shift >= 0; shift -= 8) {
    buf[len++] = (uint8_t)(value >> shift);
  }

  if (len == 0) {
    buf[len++] = 0x00; /* Zero is encoded as single 0x00 */
  }

  return asn1_serialize_primitive(s, ASN1_ID_INTEGER, buf, len);
}

asn1_error_t asn1_serialize_integer_bytes(asn1_serializer_t *s,
                                          const uint8_t *bytes, size_t length) {
  return asn1_serialize_primitive(s, ASN1_ID_INTEGER, bytes, length);
}

/* ============================================================================
 * NULL
 * ============================================================================
 */

asn1_error_t asn1_parse_null(const asn1_node_t *node) {
  if (!asn1_identifier_equal(node->identifier, ASN1_ID_NULL)) {
    return asn1_error(ASN1_ERROR_UNEXPECTED_FIELD_TYPE, "Expected NULL", 0);
  }

  if (node->content_type != ASN1_CONTENT_PRIMITIVE) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT, "NULL must be primitive", 0);
  }

  if (node->data_length != 0) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT, "NULL must have zero length",
                      0);
  }

  return asn1_ok();
}

asn1_error_t asn1_serialize_null(asn1_serializer_t *s) {
  return asn1_serialize_primitive(s, ASN1_ID_NULL, NULL, 0);
}

/* ============================================================================
 * BIT STRING
 * ============================================================================
 */

asn1_error_t asn1_parse_bit_string(const asn1_node_t *node,
                                   asn1_bit_string_t *bs) {
  if (!asn1_identifier_equal(node->identifier, ASN1_ID_BIT_STRING)) {
    return asn1_error(ASN1_ERROR_UNEXPECTED_FIELD_TYPE, "Expected BIT STRING",
                      0);
  }

  if (node->content_type != ASN1_CONTENT_PRIMITIVE) {
    /* Note: BER allows constructed bit strings, but we don't support them yet
     */
    return asn1_error(ASN1_ERROR_INVALID_OBJECT,
                      "Constructed BIT STRING not supported", 0);
  }

  if (node->data_length == 0) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT,
                      "BIT STRING must have at least 1 byte", 0);
  }

  uint8_t unused = node->data_bytes[0];
  if (unused > 7) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT, "Invalid unused bits count",
                      0);
  }

  if (node->data_length == 1 && unused != 0) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT,
                      "Empty BIT STRING must have 0 unused bits", 0);
  }

  /* Check that unused bits are actually zero (DER requirement) */
  if (unused > 0 && node->data_length > 1) {
    uint8_t last_byte = node->data_bytes[node->data_length - 1];
    uint8_t mask = (1 << unused) - 1;
    if (last_byte & mask) {
      return asn1_error(ASN1_ERROR_INVALID_OBJECT, "Unused bits must be zero",
                        0);
    }
  }

  bs->bytes = node->data_bytes + 1;
  bs->byte_count = node->data_length - 1;
  bs->unused_bits = unused;

  return asn1_ok();
}

asn1_error_t asn1_serialize_bit_string(asn1_serializer_t *s,
                                       const asn1_bit_string_t *bs) {
  size_t total_len = 1 + bs->byte_count;

  asn1_error_t err;
  err = asn1_serialize_primitive(s, ASN1_ID_BIT_STRING, NULL, 0);
  if (!asn1_is_ok(err))
    return err;

  /* Rewind and do it properly with the data */
  s->length -= 2; /* Remove the empty TL we just wrote */

  /* Write identifier */
  uint8_t id_buf[2];
  size_t id_len = asn1_encode_identifier(id_buf, ASN1_ID_BIT_STRING, false);
  for (size_t i = 0; i < id_len; i++) {
    err = asn1_serialize_raw(s, &id_buf[i], 1);
    if (!asn1_is_ok(err))
      return err;
  }

  /* Write length */
  uint8_t len_buf[9];
  size_t len_len = asn1_encode_length(len_buf, total_len);
  err = asn1_serialize_raw(s, len_buf, len_len);
  if (!asn1_is_ok(err))
    return err;

  /* Write unused bits count */
  err = asn1_serialize_raw(s, &bs->unused_bits, 1);
  if (!asn1_is_ok(err))
    return err;

  /* Write bit data */
  if (bs->byte_count > 0) {
    err = asn1_serialize_raw(s, bs->bytes, bs->byte_count);
    if (!asn1_is_ok(err))
      return err;
  }

  return asn1_ok();
}

/* ============================================================================
 * OCTET STRING
 * ============================================================================
 */

asn1_error_t asn1_parse_octet_string(const asn1_node_t *node,
                                     const uint8_t **bytes, size_t *length) {
  if (!asn1_identifier_equal(node->identifier, ASN1_ID_OCTET_STRING)) {
    return asn1_error(ASN1_ERROR_UNEXPECTED_FIELD_TYPE, "Expected OCTET STRING",
                      0);
  }

  if (node->content_type != ASN1_CONTENT_PRIMITIVE) {
    /* Note: BER allows constructed octet strings */
    return asn1_error(ASN1_ERROR_INVALID_OBJECT,
                      "Constructed OCTET STRING not supported", 0);
  }

  *bytes = node->data_bytes;
  *length = node->data_length;

  return asn1_ok();
}

asn1_error_t asn1_serialize_octet_string(asn1_serializer_t *s,
                                         const uint8_t *bytes, size_t length) {
  return asn1_serialize_primitive(s, ASN1_ID_OCTET_STRING, bytes, length);
}

/* ============================================================================
 * OBJECT IDENTIFIER
 * ============================================================================
 */

asn1_error_t asn1_parse_oid(const asn1_node_t *node, asn1_oid_t *oid) {
  if (!asn1_identifier_equal(node->identifier, ASN1_ID_OBJECT_IDENTIFIER)) {
    return asn1_error(ASN1_ERROR_UNEXPECTED_FIELD_TYPE,
                      "Expected OBJECT IDENTIFIER", 0);
  }

  if (node->content_type != ASN1_CONTENT_PRIMITIVE) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT, "OID must be primitive", 0);
  }

  if (node->data_length == 0) {
    return asn1_error(ASN1_ERROR_INVALID_OID, "OID cannot be empty", 0);
  }

  oid->count = 0;

  /* First byte encodes first two components: val = 40*c1 + c2 */
  uint8_t first = node->data_bytes[0];
  if (oid->count >= ASN1_OID_MAX_COMPONENTS) {
    return asn1_error(ASN1_ERROR_INVALID_OID, "Too many OID components", 0);
  }
  oid->components[oid->count++] = first / 40;
  if (oid->count >= ASN1_OID_MAX_COMPONENTS) {
    return asn1_error(ASN1_ERROR_INVALID_OID, "Too many OID components", 0);
  }
  oid->components[oid->count++] = first % 40;

  /* Subsequent bytes are base-128 encoded components */
  size_t i = 1;
  while (i < node->data_length) {
    uint32_t value = 0;
    int byte_count = 0;

    do {
      if (i >= node->data_length) {
        return asn1_error(ASN1_ERROR_INVALID_OID, "Truncated OID component", 0);
      }
      if (byte_count >= 5) {
        return asn1_error(ASN1_ERROR_INVALID_OID, "OID component too large", 0);
      }

      uint8_t byte = node->data_bytes[i++];
      value = (value << 7) | (byte & 0x7F);
      byte_count++;

      if ((byte & 0x80) == 0)
        break;
    } while (1);

    if (oid->count >= ASN1_OID_MAX_COMPONENTS) {
      return asn1_error(ASN1_ERROR_INVALID_OID, "Too many OID components", 0);
    }
    oid->components[oid->count++] = value;
  }

  return asn1_ok();
}

asn1_error_t asn1_serialize_oid(asn1_serializer_t *s, const asn1_oid_t *oid) {
  if (oid->count < 2) {
    return asn1_error(ASN1_ERROR_INVALID_OID,
                      "OID must have at least 2 components", 0);
  }

  /* Encode into temporary buffer */
  uint8_t buf[128]; /* Should be enough for any reasonable OID */
  size_t len = 0;

  /* First byte: 40*c1 + c2 */
  if (oid->components[0] > 2 ||
      (oid->components[0] < 2 && oid->components[1] > 39)) {
    return asn1_error(ASN1_ERROR_INVALID_OID,
                      "Invalid first two OID components", 0);
  }
  buf[len++] = (uint8_t)(oid->components[0] * 40 + oid->components[1]);

  /* Remaining components in base-128 */
  for (size_t i = 2; i < oid->count; i++) {
    uint32_t value = oid->components[i];
    uint8_t temp[5];
    size_t temp_len = 0;

    temp[temp_len++] = value & 0x7F;
    value >>= 7;
    while (value > 0) {
      temp[temp_len++] = 0x80 | (value & 0x7F);
      value >>= 7;
    }

    /* Write in reverse order */
    for (size_t j = temp_len; j > 0; j--) {
      if (len >= sizeof(buf)) {
        return asn1_error(ASN1_ERROR_BUFFER_TOO_SMALL, "OID too large", 0);
      }
      buf[len++] = temp[j - 1];
    }
  }

  return asn1_serialize_primitive(s, ASN1_ID_OBJECT_IDENTIFIER, buf, len);
}

size_t asn1_oid_to_string(const asn1_oid_t *oid, char *buffer, size_t size) {
  if (oid->count == 0) {
    if (size > 0)
      buffer[0] = '\0';
    return 0;
  }

  size_t written = 0;
  for (size_t i = 0; i < oid->count; i++) {
    int n;
    if (i == 0) {
      n = snprintf(buffer + written, size - written, "%u", oid->components[i]);
    } else {
      n = snprintf(buffer + written, size - written, ".%u", oid->components[i]);
    }
    if (n < 0)
      break;
    written += (size_t)n;
    if (written >= size)
      break;
  }

  return written;
}

/* ============================================================================
 * String Types
 * ============================================================================
 */

asn1_error_t asn1_parse_string(const asn1_node_t *node, const char **str,
                               size_t *length) {
  if (node->content_type != ASN1_CONTENT_PRIMITIVE) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT,
                      "Constructed strings not supported", 0);
  }

  *str = (const char *)node->data_bytes;
  *length = node->data_length;

  return asn1_ok();
}

asn1_error_t asn1_serialize_string(asn1_serializer_t *s, asn1_identifier_t id,
                                   const char *str, size_t length) {
  return asn1_serialize_primitive(s, id, (const uint8_t *)str, length);
}
