/*
 * ASN.1 DER Serializer Implementation
 * Based on swift-asn1 by Apple Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "asn1_internal.h"
#include <string.h>

/* ============================================================================
 * Helper Functions
 * ============================================================================
 */

/**
 * Reserve space in the serializer buffer.
 */
static asn1_error_t reserve(asn1_serializer_t *s, size_t bytes) {
  if (s->length + bytes > s->capacity) {
    return asn1_error(ASN1_ERROR_BUFFER_TOO_SMALL, "Output buffer too small",
                      s->length);
  }
  return asn1_ok();
}

/**
 * Write multiple bytes.
 */
static asn1_error_t write_bytes(asn1_serializer_t *s, const uint8_t *data,
                                size_t len) {
  asn1_error_t err = reserve(s, len);
  if (!asn1_is_ok(err))
    return err;
  memcpy(s->buffer + s->length, data, len);
  s->length += len;
  return asn1_ok();
}

/**
 * Write identifier.
 */
static asn1_error_t write_identifier(asn1_serializer_t *s, asn1_identifier_t id,
                                     bool constructed) {
  uint8_t buf[6]; /* Max 6 bytes for identifier */
  size_t len = asn1_encode_identifier(buf, id, constructed);
  return write_bytes(s, buf, len);
}

/**
 * Write length in DER format.
 */
static asn1_error_t write_length(asn1_serializer_t *s, size_t length) {
  uint8_t buf[9]; /* Max 9 bytes for length (1 + 8 for 64-bit) */
  size_t len = asn1_encode_length(buf, length);
  return write_bytes(s, buf, len);
}

/* ============================================================================
 * Public API
 * ============================================================================
 */

asn1_error_t asn1_serialize_raw(asn1_serializer_t *s, const uint8_t *data,
                                size_t len) {
  return write_bytes(s, data, len);
}

asn1_error_t asn1_serialize_primitive(asn1_serializer_t *s,
                                      asn1_identifier_t id, const uint8_t *data,
                                      size_t len) {
  asn1_error_t err;

  err = write_identifier(s, id, false);
  if (!asn1_is_ok(err))
    return err;

  err = write_length(s, len);
  if (!asn1_is_ok(err))
    return err;

  if (len > 0) {
    err = write_bytes(s, data, len);
    if (!asn1_is_ok(err))
      return err;
  }

  return asn1_ok();
}

asn1_error_t asn1_serialize_constructed_begin(asn1_serializer_t *s,
                                              asn1_identifier_t id,
                                              size_t *marker) {
  asn1_error_t err;

  err = write_identifier(s, id, true);
  if (!asn1_is_ok(err))
    return err;

  /* Reserve maximum length encoding (5 bytes for up to 4GB) */
  /* We'll fix this up in asn1_serialize_constructed_end */
  *marker = s->length;

  /* Write placeholder bytes for length (will be adjusted later) */
  /* Use 5-byte form which can encode lengths up to 2^32-1 */
  err = reserve(s, 5);
  if (!asn1_is_ok(err))
    return err;

  s->buffer[s->length++] = 0x84; /* Long form, 4 bytes */
  s->buffer[s->length++] = 0x00;
  s->buffer[s->length++] = 0x00;
  s->buffer[s->length++] = 0x00;
  s->buffer[s->length++] = 0x00;

  return asn1_ok();
}

asn1_error_t asn1_serialize_constructed_end(asn1_serializer_t *s,
                                            size_t marker) {
  /* Calculate content length */
  size_t content_start = marker + 5; /* After 5-byte length placeholder */
  size_t content_length = s->length - content_start;

  /* Determine minimal length encoding */
  uint8_t length_buf[9];
  size_t length_bytes = asn1_encode_length(length_buf, content_length);

  if (length_bytes <= 5) {
    /* We can fit in reserved space, may need to shift */
    size_t saved = 5 - length_bytes;

    if (saved > 0) {
      /* Shift content left to remove unused length bytes */
      memmove(s->buffer + marker + length_bytes, s->buffer + content_start,
              content_length);
      s->length -= saved;
    }

    /* Write actual length */
    memcpy(s->buffer + marker, length_buf, length_bytes);
  } else {
    /* Need more than 5 bytes - this means >4GB which shouldn't happen */
    return asn1_error(ASN1_ERROR_BUFFER_TOO_SMALL,
                      "Content too large to encode", s->length);
  }

  return asn1_ok();
}
