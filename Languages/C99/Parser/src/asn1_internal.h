/*
 * ASN.1 BER/DER Parser - Internal Utilities
 * Based on swift-asn1 by Apple Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef ASN1_INTERNAL_H
#define ASN1_INTERNAL_H

#include "../include/asn1/asn1.h"
#include <string.h>

/* ============================================================================
 * Buffer Reading Utilities
 * ============================================================================
 */

/**
 * Buffer reader for parsing.
 */
typedef struct {
  const uint8_t *data;
  size_t length;
  size_t offset;
} asn1_buffer_t;

static inline void asn1_buffer_init(asn1_buffer_t *buf, const uint8_t *data,
                                    size_t length) {
  buf->data = data;
  buf->length = length;
  buf->offset = 0;
}

static inline size_t asn1_buffer_remaining(const asn1_buffer_t *buf) {
  return buf->length - buf->offset;
}

static inline const uint8_t *asn1_buffer_current(const asn1_buffer_t *buf) {
  return buf->data + buf->offset;
}

static inline bool asn1_buffer_read_byte(asn1_buffer_t *buf, uint8_t *byte) {
  if (buf->offset >= buf->length)
    return false;
  *byte = buf->data[buf->offset++];
  return true;
}

static inline bool asn1_buffer_peek_byte(const asn1_buffer_t *buf,
                                         uint8_t *byte) {
  if (buf->offset >= buf->length)
    return false;
  *byte = buf->data[buf->offset];
  return true;
}

static inline bool asn1_buffer_skip(asn1_buffer_t *buf, size_t count) {
  if (buf->offset + count > buf->length)
    return false;
  buf->offset += count;
  return true;
}

static inline bool asn1_buffer_read_bytes(asn1_buffer_t *buf,
                                          const uint8_t **ptr, size_t count) {
  if (buf->offset + count > buf->length)
    return false;
  *ptr = buf->data + buf->offset;
  buf->offset += count;
  return true;
}

/* ============================================================================
 * Length Encoding/Decoding
 * ============================================================================
 */

/**
 * Length encoding result.
 */
typedef enum {
  ASN1_LENGTH_DEFINITE,
  ASN1_LENGTH_INDEFINITE,
} asn1_length_type_t;

typedef struct {
  asn1_length_type_t type;
  size_t value; /* Only valid if type == ASN1_LENGTH_DEFINITE */
} asn1_length_t;

/**
 * Calculate bytes needed to encode a length in DER.
 */
static inline size_t asn1_length_bytes_needed(size_t length) {
  if (length <= 0x7F) {
    return 1; /* Short form */
  }
  /* Long form: count octets needed */
  size_t bytes = 0;
  size_t temp = length;
  while (temp > 0) {
    bytes++;
    temp >>= 8;
  }
  return bytes + 1; /* +1 for the leading octet */
}

/**
 * Encode a length in DER format.
 * Returns number of bytes written.
 */
static inline size_t asn1_encode_length(uint8_t *buf, size_t length) {
  if (length <= 0x7F) {
    buf[0] = (uint8_t)length;
    return 1;
  }

  /* Count bytes needed for length */
  size_t bytes = 0;
  size_t temp = length;
  while (temp > 0) {
    bytes++;
    temp >>= 8;
  }

  buf[0] = (uint8_t)(0x80 | bytes);
  for (size_t i = bytes; i > 0; i--) {
    buf[i] = (uint8_t)(length & 0xFF);
    length >>= 8;
  }

  return bytes + 1;
}

/**
 * Calculate bytes needed to encode an identifier.
 */
static inline size_t asn1_identifier_bytes_needed(asn1_identifier_t id) {
  if (id.tag_number < 0x1f) {
    return 1; /* Short form */
  }

  /* Long form: base-128 encoding */
  size_t bytes = 1; /* First byte with 0x1F */
  uint32_t temp = id.tag_number;
  while (temp > 0) {
    bytes++;
    temp >>= 7;
  }
  return bytes;
}

/**
 * Encode an identifier.
 * Returns number of bytes written.
 */
static inline size_t asn1_encode_identifier(uint8_t *buf, asn1_identifier_t id,
                                            bool constructed) {
  uint8_t class_bits = (uint8_t)(id.tag_class << 6);
  uint8_t constructed_bit = constructed ? 0x20 : 0x00;

  if (id.tag_number < 0x1f) {
    buf[0] = class_bits | constructed_bit | (uint8_t)id.tag_number;
    return 1;
  }

  /* Long form */
  buf[0] = class_bits | constructed_bit | 0x1F;

  /* Encode tag number in base-128 */
  uint32_t tag = id.tag_number;
  size_t len = 0;
  uint8_t temp[5]; /* Max 5 bytes for 32-bit tag */

  temp[len++] = tag & 0x7F;
  tag >>= 7;
  while (tag > 0) {
    temp[len++] = 0x80 | (tag & 0x7F);
    tag >>= 7;
  }

  /* Reverse into output */
  for (size_t i = 0; i < len; i++) {
    buf[1 + i] = temp[len - 1 - i];
  }

  return 1 + len;
}

#endif /* ASN1_INTERNAL_H */
