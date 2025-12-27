/*
 * ASN.1 BER/DER Parser - Basic Type Helpers
 * Based on swift-asn1 by Apple Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef ASN1_TYPES_H
#define ASN1_TYPES_H

#include "asn1.h"

#ifdef __cplusplus
extern "C" {
#endif

/* ============================================================================
 * BOOLEAN
 * ============================================================================
 */

/**
 * Parse a BOOLEAN value from a node.
 *
 * DER requires: false = 0x00, true = 0xFF
 * BER allows: false = 0x00, true = any non-zero
 *
 * @param node   Node to parse (must have BOOLEAN identifier)
 * @param value  Output: the boolean value
 * @param rules  Encoding rules for validation
 * @return       ASN1_OK on success
 */
asn1_error_t asn1_parse_boolean(const asn1_node_t *node, bool *value,
                                asn1_encoding_rules_t rules);

/**
 * Serialize a BOOLEAN value.
 *
 * @param s      The serializer
 * @param value  Boolean value to serialize
 * @return       ASN1_OK on success
 */
asn1_error_t asn1_serialize_boolean(asn1_serializer_t *s, bool value);

/* ============================================================================
 * INTEGER
 * ============================================================================
 */

/**
 * Parse an INTEGER as int64_t.
 *
 * @param node   Node to parse (must have INTEGER identifier)
 * @param value  Output: the integer value
 * @return       ASN1_OK on success, error if value doesn't fit
 */
asn1_error_t asn1_parse_int64(const asn1_node_t *node, int64_t *value);

/**
 * Parse an INTEGER as uint64_t.
 *
 * @param node   Node to parse (must have INTEGER identifier)
 * @param value  Output: the unsigned integer value
 * @return       ASN1_OK on success, error if negative or doesn't fit
 */
asn1_error_t asn1_parse_uint64(const asn1_node_t *node, uint64_t *value);

/**
 * Get raw INTEGER bytes (for arbitrary precision).
 *
 * The bytes are in big-endian two's complement format.
 *
 * @param node      Node to parse
 * @param bytes     Output: pointer to integer bytes
 * @param length    Output: number of bytes
 * @param negative  Output: true if the integer is negative
 * @return          ASN1_OK on success
 */
asn1_error_t asn1_parse_integer_bytes(const asn1_node_t *node,
                                      const uint8_t **bytes, size_t *length,
                                      bool *negative);

/**
 * Serialize an int64_t as INTEGER.
 *
 * @param s      The serializer
 * @param value  Value to serialize
 * @return       ASN1_OK on success
 */
asn1_error_t asn1_serialize_int64(asn1_serializer_t *s, int64_t value);

/**
 * Serialize a uint64_t as INTEGER.
 *
 * @param s      The serializer
 * @param value  Value to serialize
 * @return       ASN1_OK on success
 */
asn1_error_t asn1_serialize_uint64(asn1_serializer_t *s, uint64_t value);

/**
 * Serialize raw bytes as INTEGER.
 *
 * @param s         The serializer
 * @param bytes     Big-endian two's complement bytes
 * @param length    Number of bytes
 * @return          ASN1_OK on success
 */
asn1_error_t asn1_serialize_integer_bytes(asn1_serializer_t *s,
                                          const uint8_t *bytes, size_t length);

/* ============================================================================
 * NULL
 * ============================================================================
 */

/**
 * Validate a NULL node.
 *
 * @param node  Node to validate (must have NULL identifier and zero length)
 * @return      ASN1_OK on success
 */
asn1_error_t asn1_parse_null(const asn1_node_t *node);

/**
 * Serialize a NULL value.
 *
 * @param s  The serializer
 * @return   ASN1_OK on success
 */
asn1_error_t asn1_serialize_null(asn1_serializer_t *s);

/* ============================================================================
 * BIT STRING
 * ============================================================================
 */

/**
 * Parsed BIT STRING value.
 */
typedef struct {
  /** Pointer to bit data bytes */
  const uint8_t *bytes;

  /** Number of bytes containing bit data */
  size_t byte_count;

  /** Number of unused bits (0-7) in the last byte */
  uint8_t unused_bits;
} asn1_bit_string_t;

/**
 * Parse a BIT STRING value.
 *
 * @param node  Node to parse
 * @param bs    Output: parsed bit string
 * @return      ASN1_OK on success
 */
asn1_error_t asn1_parse_bit_string(const asn1_node_t *node,
                                   asn1_bit_string_t *bs);

/**
 * Serialize a BIT STRING value.
 *
 * @param s   The serializer
 * @param bs  Bit string to serialize
 * @return    ASN1_OK on success
 */
asn1_error_t asn1_serialize_bit_string(asn1_serializer_t *s,
                                       const asn1_bit_string_t *bs);

/**
 * Get total number of bits in a bit string.
 */
static inline size_t asn1_bit_string_bit_count(const asn1_bit_string_t *bs) {
  if (bs->byte_count == 0)
    return 0;
  return bs->byte_count * 8 - bs->unused_bits;
}

/**
 * Get a specific bit from a bit string (0-indexed, MSB first).
 */
static inline bool asn1_bit_string_get(const asn1_bit_string_t *bs,
                                       size_t bit_index) {
  size_t byte_index = bit_index / 8;
  size_t bit_offset = 7 - (bit_index % 8);
  if (byte_index >= bs->byte_count)
    return false;
  return (bs->bytes[byte_index] >> bit_offset) & 1;
}

/* ============================================================================
 * OCTET STRING
 * ============================================================================
 */

/**
 * Parse an OCTET STRING value.
 *
 * @param node    Node to parse
 * @param bytes   Output: pointer to octet data
 * @param length  Output: length of octet data
 * @return        ASN1_OK on success
 */
asn1_error_t asn1_parse_octet_string(const asn1_node_t *node,
                                     const uint8_t **bytes, size_t *length);

/**
 * Serialize an OCTET STRING value.
 *
 * @param s       The serializer
 * @param bytes   Octet data
 * @param length  Length of octet data
 * @return        ASN1_OK on success
 */
asn1_error_t asn1_serialize_octet_string(asn1_serializer_t *s,
                                         const uint8_t *bytes, size_t length);

/* ============================================================================
 * OBJECT IDENTIFIER
 * ============================================================================
 */

/** Maximum OID components supported */
#define ASN1_OID_MAX_COMPONENTS 32

/**
 * Object Identifier value.
 */
typedef struct {
  /** OID component values */
  uint32_t components[ASN1_OID_MAX_COMPONENTS];

  /** Number of components */
  size_t count;
} asn1_oid_t;

/**
 * Parse an OBJECT IDENTIFIER.
 *
 * @param node  Node to parse
 * @param oid   Output: parsed OID
 * @return      ASN1_OK on success
 */
asn1_error_t asn1_parse_oid(const asn1_node_t *node, asn1_oid_t *oid);

/**
 * Serialize an OBJECT IDENTIFIER.
 *
 * @param s    The serializer
 * @param oid  OID to serialize
 * @return     ASN1_OK on success
 */
asn1_error_t asn1_serialize_oid(asn1_serializer_t *s, const asn1_oid_t *oid);

/**
 * Compare two OIDs for equality.
 */
static inline bool asn1_oid_equal(const asn1_oid_t *a, const asn1_oid_t *b) {
  if (a->count != b->count)
    return false;
  for (size_t i = 0; i < a->count; i++) {
    if (a->components[i] != b->components[i])
      return false;
  }
  return true;
}

/**
 * Format OID as dotted string (e.g., "1.2.840.113549").
 *
 * @param oid     OID to format
 * @param buffer  Output buffer
 * @param size    Buffer size
 * @return        Number of characters written (excluding null), or required
 * size if buffer too small
 */
size_t asn1_oid_to_string(const asn1_oid_t *oid, char *buffer, size_t size);

/* ============================================================================
 * String Types
 * ============================================================================
 */

/**
 * Parse a string type (UTF8String, PrintableString, IA5String, etc.).
 *
 * This does not validate character set; it just extracts the bytes.
 * The caller should validate based on the specific string type.
 *
 * @param node    Node to parse
 * @param str     Output: pointer to string bytes (not null-terminated)
 * @param length  Output: string length in bytes
 * @return        ASN1_OK on success
 */
asn1_error_t asn1_parse_string(const asn1_node_t *node, const char **str,
                               size_t *length);

/**
 * Serialize a string with a specific identifier.
 *
 * @param s       The serializer
 * @param id      String type identifier (e.g., ASN1_ID_UTF8_STRING)
 * @param str     String bytes
 * @param length  String length
 * @return        ASN1_OK on success
 */
asn1_error_t asn1_serialize_string(asn1_serializer_t *s, asn1_identifier_t id,
                                   const char *str, size_t length);

#ifdef __cplusplus
}
#endif

#endif /* ASN1_TYPES_H */
