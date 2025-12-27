/*
 * ASN.1 BER/DER Parser - Main Header
 * Based on swift-asn1 by Apple Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef ASN1_H
#define ASN1_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "asn1_error.h"
#include "asn1_identifier.h"

#ifdef __cplusplus
extern "C" {
#endif

/* ============================================================================
 * Constants
 * ============================================================================
 */

/** Maximum parsing depth to prevent stack overflow attacks */
#define ASN1_MAX_DEPTH 50

/* ============================================================================
 * Encoding Rules
 * ============================================================================
 */

/**
 * ASN.1 encoding rules to use for parsing.
 */
typedef enum {
  /** Basic Encoding Rules - more permissive, allows indefinite length */
  ASN1_ENCODING_BER,

  /** Distinguished Encoding Rules - strict, canonical encoding */
  ASN1_ENCODING_DER,
} asn1_encoding_rules_t;

/* ============================================================================
 * Node Types
 * ============================================================================
 */

/**
 * Type of content in an ASN.1 node.
 */
typedef enum {
  /** Primitive content - raw bytes, no children */
  ASN1_CONTENT_PRIMITIVE,

  /** Constructed content - contains child nodes */
  ASN1_CONTENT_CONSTRUCTED,
} asn1_content_type_t;

/**
 * Represents a single parsed ASN.1 TLV (Tag-Length-Value) node.
 *
 * Nodes are stored in a flat array in pre-order traversal order.
 * This allows efficient iteration without recursion.
 */
typedef struct {
  /** The identifier (tag) for this node */
  asn1_identifier_t identifier;

  /** Whether this is primitive or constructed */
  asn1_content_type_t content_type;

  /**
   * Pointer to the complete encoded TLV bytes.
   * Useful for re-serializing or computing hashes.
   */
  const uint8_t *encoded_bytes;

  /** Length of encoded_bytes */
  size_t encoded_length;

  /**
   * For primitive nodes: pointer to the value bytes (within encoded_bytes).
   * For constructed nodes: NULL.
   */
  const uint8_t *data_bytes;

  /** Length of data_bytes (0 for constructed nodes) */
  size_t data_length;

  /** Depth in the tree (root = 1) */
  size_t depth;

  /**
   * Total number of nodes in this subtree including self.
   * For primitive nodes, this is always 1.
   * For constructed nodes, this includes all descendants + 1.
   */
  size_t subtree_size;
} asn1_node_t;

/* ============================================================================
 * Parse Result
 * ============================================================================
 */

/**
 * Result of parsing ASN.1 data.
 *
 * Contains a flat array of nodes in pre-order traversal order.
 * The caller provides the node array; this structure tracks usage.
 */
typedef struct {
  /** Array of parsed nodes (caller-provided) */
  asn1_node_t *nodes;

  /** Number of nodes currently in the array */
  size_t count;

  /** Maximum capacity of the nodes array */
  size_t capacity;
} asn1_parse_result_t;

/* ============================================================================
 * Core Parsing API
 * ============================================================================
 */

/**
 * Initialize a parse result structure.
 *
 * @param result    Result structure to initialize
 * @param nodes     Caller-provided array of nodes
 * @param capacity  Maximum number of nodes the array can hold
 */
static inline void asn1_parse_result_init(asn1_parse_result_t *result,
                                          asn1_node_t *nodes, size_t capacity) {
  result->nodes = nodes;
  result->count = 0;
  result->capacity = capacity;
}

/**
 * Parse ASN.1 encoded data.
 *
 * The parser populates the result with nodes in pre-order traversal order.
 * This means a parent node appears before its children, and siblings appear
 * in the order they were encoded.
 *
 * @param data      Input data to parse
 * @param length    Length of input data
 * @param rules     Encoding rules to use (BER or DER)
 * @param result    Pre-initialized result structure
 * @return          ASN1_OK on success, error code otherwise
 */
asn1_error_t asn1_parse(const uint8_t *data, size_t length,
                        asn1_encoding_rules_t rules,
                        asn1_parse_result_t *result);

/**
 * Get the root node from a parse result.
 *
 * @param result    Parse result (must have at least one node)
 * @return          Pointer to root node, or NULL if empty
 */
static inline asn1_node_t *asn1_root_node(asn1_parse_result_t *result) {
  return result->count > 0 ? &result->nodes[0] : NULL;
}

/* ============================================================================
 * Node Iteration
 * ============================================================================
 */

/**
 * Iterator for traversing child nodes of a constructed node.
 */
typedef struct {
  /** The parse result containing the nodes */
  const asn1_parse_result_t *result;

  /** Parent node's depth */
  size_t parent_depth;

  /** Current position in the nodes array */
  size_t current_index;

  /** One past the last index in the parent's subtree */
  size_t end_index;
} asn1_node_iterator_t;

/**
 * Create an iterator for the direct children of a node.
 *
 * @param result      The parse result
 * @param node_index  Index of the parent node
 * @return            Iterator positioned before the first child
 */
asn1_node_iterator_t asn1_children(const asn1_parse_result_t *result,
                                   size_t node_index);

/**
 * Get the next child node from an iterator.
 *
 * @param iter  The iterator
 * @return      Pointer to next child, or NULL if no more children
 */
asn1_node_t *asn1_next_child(asn1_node_iterator_t *iter);

/**
 * Get the index of a node in the parse result.
 *
 * @param result  The parse result
 * @param node    Pointer to a node within the result
 * @return        Index of the node, or SIZE_MAX if not found
 */
static inline size_t asn1_node_index(const asn1_parse_result_t *result,
                                     const asn1_node_t *node) {
  if (node >= result->nodes && node < result->nodes + result->count) {
    return (size_t)(node - result->nodes);
  }
  return (size_t)-1;
}

/* ============================================================================
 * Serialization
 * ============================================================================
 */

/**
 * Serializer for DER encoding.
 */
typedef struct {
  /** Output buffer (caller-provided) */
  uint8_t *buffer;

  /** Current write position (bytes written) */
  size_t length;

  /** Maximum capacity of buffer */
  size_t capacity;
} asn1_serializer_t;

/**
 * Initialize a serializer.
 *
 * @param s         Serializer to initialize
 * @param buffer    Output buffer
 * @param capacity  Buffer capacity
 */
static inline void asn1_serializer_init(asn1_serializer_t *s, uint8_t *buffer,
                                        size_t capacity) {
  s->buffer = buffer;
  s->length = 0;
  s->capacity = capacity;
}

/**
 * Serialize a primitive ASN.1 node.
 *
 * @param s     The serializer
 * @param id    Identifier for the node
 * @param data  Value bytes
 * @param len   Length of value bytes
 * @return      ASN1_OK on success
 */
asn1_error_t asn1_serialize_primitive(asn1_serializer_t *s,
                                      asn1_identifier_t id, const uint8_t *data,
                                      size_t len);

/**
 * Begin serializing a constructed node.
 *
 * Call asn1_serialize_constructed_end() after writing all children.
 *
 * @param s       The serializer
 * @param id      Identifier for the node
 * @param marker  Output: position marker for length fixup
 * @return        ASN1_OK on success
 */
asn1_error_t asn1_serialize_constructed_begin(asn1_serializer_t *s,
                                              asn1_identifier_t id,
                                              size_t *marker);

/**
 * Finish serializing a constructed node.
 *
 * This fixes up the length field based on what was written since begin.
 *
 * @param s       The serializer
 * @param marker  Position marker from asn1_serialize_constructed_begin
 * @return        ASN1_OK on success
 */
asn1_error_t asn1_serialize_constructed_end(asn1_serializer_t *s,
                                            size_t marker);

/**
 * Serialize raw bytes without any encoding.
 * Useful for writing pre-encoded content.
 *
 * @param s     The serializer
 * @param data  Bytes to write
 * @param len   Number of bytes
 * @return      ASN1_OK on success
 */
asn1_error_t asn1_serialize_raw(asn1_serializer_t *s, const uint8_t *data,
                                size_t len);

#ifdef __cplusplus
}
#endif

#endif /* ASN1_H */
