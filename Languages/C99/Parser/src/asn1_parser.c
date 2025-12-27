/*
 * ASN.1 BER/DER Parser Implementation
 * Based on swift-asn1 by Apple Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "asn1_internal.h"

/* ============================================================================
 * Error Code Names
 * ============================================================================
 */

const char *asn1_error_code_name(asn1_error_code_t code) {
  switch (code) {
  case ASN1_OK:
    return "OK";
  case ASN1_ERROR_TRUNCATED_FIELD:
    return "TRUNCATED_FIELD";
  case ASN1_ERROR_INVALID_OBJECT:
    return "INVALID_OBJECT";
  case ASN1_ERROR_UNEXPECTED_FIELD_TYPE:
    return "UNEXPECTED_FIELD_TYPE";
  case ASN1_ERROR_UNSUPPORTED_LENGTH:
    return "UNSUPPORTED_LENGTH";
  case ASN1_ERROR_INVALID_INTEGER_ENCODING:
    return "INVALID_INTEGER_ENCODING";
  case ASN1_ERROR_EXCESSIVE_DEPTH:
    return "EXCESSIVE_DEPTH";
  case ASN1_ERROR_BUFFER_TOO_SMALL:
    return "BUFFER_TOO_SMALL";
  case ASN1_ERROR_INVALID_OID:
    return "INVALID_OID";
  case ASN1_ERROR_CAPACITY_EXCEEDED:
    return "CAPACITY_EXCEEDED";
  case ASN1_ERROR_INVALID_BOOLEAN:
    return "INVALID_BOOLEAN";
  case ASN1_ERROR_TRAILING_DATA:
    return "TRAILING_DATA";
  default:
    return "UNKNOWN";
  }
}

/* ============================================================================
 * Identifier Parsing
 * ============================================================================
 */

/**
 * Read a base-128 encoded unsigned integer (used for long-form tags).
 */
static asn1_error_t parse_base128_uint(asn1_buffer_t *buf, uint32_t *value) {
  *value = 0;
  uint8_t byte;
  int count = 0;

  do {
    if (!asn1_buffer_read_byte(buf, &byte)) {
      return asn1_error(ASN1_ERROR_TRUNCATED_FIELD,
                        "Truncated base-128 integer", buf->offset);
    }

    /* Check for overflow (more than 4 bytes of 7-bit data) */
    if (count >= 5) {
      return asn1_error(ASN1_ERROR_INVALID_OBJECT, "Tag number too large",
                        buf->offset);
    }

    *value = (*value << 7) | (byte & 0x7F);
    count++;
  } while (byte & 0x80);

  return asn1_ok();
}

/**
 * Parse an ASN.1 identifier from the buffer.
 */
static asn1_error_t parse_identifier(asn1_buffer_t *buf,
                                     asn1_identifier_t *identifier,
                                     bool *constructed) {
  uint8_t first_byte;
  if (!asn1_buffer_read_byte(buf, &first_byte)) {
    return asn1_error(ASN1_ERROR_TRUNCATED_FIELD, "Truncated identifier",
                      buf->offset);
  }

  /* Extract class (bits 7-6) */
  identifier->tag_class = (asn1_tag_class_t)(first_byte >> 6);

  /* Extract constructed flag (bit 5) */
  *constructed = (first_byte & 0x20) != 0;

  /* Extract tag number (bits 4-0) */
  uint8_t tag_bits = first_byte & 0x1F;

  if (tag_bits == 0x1F) {
    /* Long form: tag number encoded in subsequent bytes */
    asn1_error_t err = parse_base128_uint(buf, &identifier->tag_number);
    if (!asn1_is_ok(err))
      return err;

    /* DER requires minimal encoding: long form only for tags >= 31 */
    if (identifier->tag_number < 0x1F) {
      return asn1_error(ASN1_ERROR_INVALID_OBJECT,
                        "Tag incorrectly encoded in long form", buf->offset);
    }
  } else {
    /* Short form */
    identifier->tag_number = tag_bits;
  }

  return asn1_ok();
}

/* ============================================================================
 * Length Parsing
 * ============================================================================
 */

/**
 * Parse an ASN.1 length from the buffer.
 */
static asn1_error_t parse_length(asn1_buffer_t *buf, asn1_length_t *length,
                                 asn1_encoding_rules_t rules) {
  uint8_t first_byte;
  if (!asn1_buffer_read_byte(buf, &first_byte)) {
    return asn1_error(ASN1_ERROR_TRUNCATED_FIELD, "Truncated length",
                      buf->offset);
  }

  if (first_byte == 0x80) {
    /* Indefinite length */
    if (rules == ASN1_ENCODING_DER) {
      return asn1_error(ASN1_ERROR_UNSUPPORTED_LENGTH,
                        "Indefinite length not allowed in DER", buf->offset);
    }
    length->type = ASN1_LENGTH_INDEFINITE;
    length->value = 0;
    return asn1_ok();
  }

  if ((first_byte & 0x80) == 0) {
    /* Short form: length is in the lower 7 bits */
    length->type = ASN1_LENGTH_DEFINITE;
    length->value = first_byte;
    return asn1_ok();
  }

  /* Long form: lower 7 bits indicate number of length bytes */
  size_t num_bytes = first_byte & 0x7F;

  if (num_bytes == 0) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT, "Invalid length encoding",
                      buf->offset);
  }

  if (num_bytes > sizeof(size_t)) {
    return asn1_error(ASN1_ERROR_UNSUPPORTED_LENGTH, "Length too large",
                      buf->offset);
  }

  size_t value = 0;
  for (size_t i = 0; i < num_bytes; i++) {
    uint8_t byte;
    if (!asn1_buffer_read_byte(buf, &byte)) {
      return asn1_error(ASN1_ERROR_TRUNCATED_FIELD, "Truncated length field",
                        buf->offset);
    }
    value = (value << 8) | byte;
  }

  /* DER requires minimal encoding */
  if (rules == ASN1_ENCODING_DER) {
    /* Check leading zeros */
    if (num_bytes > 1) {
      /* First byte shouldn't be zero (non-minimal) */
      /* This is implicitly checked by the loop above for value */
    }

    /* Values <= 127 should use short form */
    if (value <= 0x7F) {
      return asn1_error(ASN1_ERROR_UNSUPPORTED_LENGTH,
                        "Length should be encoded in short form", buf->offset);
    }

    /* Check minimal byte count */
    size_t required_bytes = 0;
    size_t temp = value;
    while (temp > 0) {
      required_bytes++;
      temp >>= 8;
    }
    if (num_bytes > required_bytes) {
      return asn1_error(ASN1_ERROR_UNSUPPORTED_LENGTH,
                        "Length encoded with too many bytes", buf->offset);
    }
  }

  length->type = ASN1_LENGTH_DEFINITE;
  length->value = value;
  return asn1_ok();
}

/* ============================================================================
 * Node Parsing
 * ============================================================================
 */

/**
 * Add a node to the parse result.
 */
static asn1_error_t add_node(asn1_parse_result_t *result,
                             const asn1_node_t *node) {
  if (result->count >= result->capacity) {
    return asn1_error(ASN1_ERROR_CAPACITY_EXCEEDED,
                      "Node array capacity exceeded", 0);
  }
  result->nodes[result->count++] = *node;
  return asn1_ok();
}

/**
 * Parse a single ASN.1 node (and its children recursively).
 */
static asn1_error_t parse_node(asn1_buffer_t *buf, asn1_encoding_rules_t rules,
                               size_t depth, asn1_parse_result_t *result);

/**
 * Parse children of a constructed node with definite length.
 */
static asn1_error_t parse_definite_children(asn1_buffer_t *buf,
                                            size_t content_length,
                                            asn1_encoding_rules_t rules,
                                            size_t depth,
                                            asn1_parse_result_t *result) {
  size_t end_offset = buf->offset + content_length;

  while (buf->offset < end_offset) {
    asn1_error_t err = parse_node(buf, rules, depth, result);
    if (!asn1_is_ok(err))
      return err;
  }

  if (buf->offset != end_offset) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT, "Content length mismatch",
                      buf->offset);
  }

  return asn1_ok();
}

/**
 * Parse children of a constructed node with indefinite length (BER only).
 */
static asn1_error_t parse_indefinite_children(asn1_buffer_t *buf,
                                              asn1_encoding_rules_t rules,
                                              size_t depth,
                                              asn1_parse_result_t *result) {
  while (asn1_buffer_remaining(buf) >= 2) {
    /* Check for end-of-contents marker (0x00, 0x00) */
    uint8_t byte1, byte2;
    if (!asn1_buffer_peek_byte(buf, &byte1)) {
      return asn1_error(ASN1_ERROR_TRUNCATED_FIELD,
                        "Truncated indefinite content", buf->offset);
    }

    if (byte1 == 0x00) {
      asn1_buffer_t temp = *buf;
      asn1_buffer_skip(&temp, 1);
      if (asn1_buffer_peek_byte(&temp, &byte2) && byte2 == 0x00) {
        /* Found end-of-contents, consume it */
        asn1_buffer_skip(buf, 2);
        return asn1_ok();
      }
    }

    asn1_error_t err = parse_node(buf, rules, depth, result);
    if (!asn1_is_ok(err))
      return err;
  }

  return asn1_error(ASN1_ERROR_TRUNCATED_FIELD,
                    "Missing end-of-contents marker", buf->offset);
}

static asn1_error_t parse_node(asn1_buffer_t *buf, asn1_encoding_rules_t rules,
                               size_t depth, asn1_parse_result_t *result) {
  /* Check depth limit */
  if (depth > ASN1_MAX_DEPTH) {
    return asn1_error(ASN1_ERROR_EXCESSIVE_DEPTH,
                      "Maximum parsing depth exceeded", buf->offset);
  }

  /* Remember start position for encoded_bytes */
  size_t start_offset = buf->offset;
  const uint8_t *start_ptr = asn1_buffer_current(buf);

  /* Parse identifier */
  asn1_identifier_t identifier;
  bool constructed;
  asn1_error_t err = parse_identifier(buf, &identifier, &constructed);
  if (!asn1_is_ok(err))
    return err;

  /* Parse length */
  asn1_length_t length;
  err = parse_length(buf, &length, rules);
  if (!asn1_is_ok(err))
    return err;

  /* Indefinite length only allowed for constructed types */
  if (length.type == ASN1_LENGTH_INDEFINITE && !constructed) {
    return asn1_error(ASN1_ERROR_UNSUPPORTED_LENGTH,
                      "Indefinite length requires constructed encoding",
                      buf->offset);
  }

  /* Get index where we'll store this node */
  size_t node_index = result->count;

  /* Create node */
  asn1_node_t node;
  node.identifier = identifier;
  node.content_type =
      constructed ? ASN1_CONTENT_CONSTRUCTED : ASN1_CONTENT_PRIMITIVE;
  node.encoded_bytes = start_ptr;
  node.depth = depth;
  node.subtree_size = 1; /* Will be updated for constructed nodes */

  if (constructed) {
    node.data_bytes = NULL;
    node.data_length = 0;

    /* Add node before parsing children */
    err = add_node(result, &node);
    if (!asn1_is_ok(err))
      return err;

    /* Parse children */
    if (length.type == ASN1_LENGTH_DEFINITE) {
      if (asn1_buffer_remaining(buf) < length.value) {
        return asn1_error(ASN1_ERROR_TRUNCATED_FIELD,
                          "Truncated constructed content", buf->offset);
      }
      err =
          parse_definite_children(buf, length.value, rules, depth + 1, result);
    } else {
      err = parse_indefinite_children(buf, rules, depth + 1, result);
    }
    if (!asn1_is_ok(err))
      return err;

    /* Update subtree size and encoded length */
    result->nodes[node_index].subtree_size = result->count - node_index;
    result->nodes[node_index].encoded_length = buf->offset - start_offset;

  } else {
    /* Primitive: get data pointer */
    if (length.type != ASN1_LENGTH_DEFINITE) {
      return asn1_error(ASN1_ERROR_INVALID_OBJECT,
                        "Primitive with indefinite length", buf->offset);
    }

    const uint8_t *data_ptr;
    if (!asn1_buffer_read_bytes(buf, &data_ptr, length.value)) {
      return asn1_error(ASN1_ERROR_TRUNCATED_FIELD,
                        "Truncated primitive content", buf->offset);
    }

    node.data_bytes = data_ptr;
    node.data_length = length.value;
    node.encoded_length = buf->offset - start_offset;

    err = add_node(result, &node);
    if (!asn1_is_ok(err))
      return err;
  }

  return asn1_ok();
}

/* ============================================================================
 * Public API
 * ============================================================================
 */

asn1_error_t asn1_parse(const uint8_t *data, size_t length,
                        asn1_encoding_rules_t rules,
                        asn1_parse_result_t *result) {
  if (data == NULL || result == NULL || result->nodes == NULL) {
    return asn1_error(ASN1_ERROR_INVALID_OBJECT, "NULL argument", 0);
  }

  if (length == 0) {
    return asn1_error(ASN1_ERROR_TRUNCATED_FIELD, "Empty input", 0);
  }

  result->count = 0;

  asn1_buffer_t buf;
  asn1_buffer_init(&buf, data, length);

  asn1_error_t err = parse_node(&buf, rules, 1, result);
  if (!asn1_is_ok(err))
    return err;

  /* Check for trailing data */
  if (asn1_buffer_remaining(&buf) > 0) {
    return asn1_error(ASN1_ERROR_TRAILING_DATA, "Trailing unparsed data",
                      buf.offset);
  }

  return asn1_ok();
}

/* ============================================================================
 * Node Iteration
 * ============================================================================
 */

asn1_node_iterator_t asn1_children(const asn1_parse_result_t *result,
                                   size_t node_index) {
  asn1_node_iterator_t iter;
  iter.result = result;

  if (node_index >= result->count) {
    iter.current_index = 0;
    iter.end_index = 0;
    iter.parent_depth = 0;
    return iter;
  }

  const asn1_node_t *parent = &result->nodes[node_index];
  iter.parent_depth = parent->depth;
  iter.current_index = node_index + 1;
  iter.end_index = node_index + parent->subtree_size;

  return iter;
}

asn1_node_t *asn1_next_child(asn1_node_iterator_t *iter) {
  while (iter->current_index < iter->end_index) {
    asn1_node_t *node =
        (asn1_node_t *)&iter->result->nodes[iter->current_index];

    /* Only return direct children (depth = parent_depth + 1) */
    if (node->depth == iter->parent_depth + 1) {
      /* Move past this node's subtree */
      iter->current_index += node->subtree_size;
      return node;
    }

    /* Skip deeper nodes */
    iter->current_index++;
  }

  return NULL;
}
