/*
 * ASN.1 BER/DER Parser - Identifier (Tag) Definitions
 * Based on swift-asn1 by Apple Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef ASN1_IDENTIFIER_H
#define ASN1_IDENTIFIER_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * ASN.1 tag class (bits 7-6 of identifier octet).
 */
typedef enum {
  ASN1_TAG_CLASS_UNIVERSAL = 0,        /* 00 - Built-in types */
  ASN1_TAG_CLASS_APPLICATION = 1,      /* 01 - Application-specific */
  ASN1_TAG_CLASS_CONTEXT_SPECIFIC = 2, /* 10 - Context-specific (tagging) */
  ASN1_TAG_CLASS_PRIVATE = 3,          /* 11 - Private use */
} asn1_tag_class_t;

/**
 * ASN.1 identifier (tag) structure.
 *
 * An identifier specifies the type of an ASN.1 value and consists of:
 * - A tag class (universal, application, context-specific, private)
 * - A tag number (0-30 for short form, or larger for long form)
 */
typedef struct {
  /** The tag number */
  uint32_t tag_number;

  /** The tag class */
  asn1_tag_class_t tag_class;
} asn1_identifier_t;

/* ============================================================================
 * Well-known Universal Tag Numbers (X.680)
 * ============================================================================
 */

#define ASN1_TAG_END_OF_CONTENTS 0
#define ASN1_TAG_BOOLEAN 1
#define ASN1_TAG_INTEGER 2
#define ASN1_TAG_BIT_STRING 3
#define ASN1_TAG_OCTET_STRING 4
#define ASN1_TAG_NULL 5
#define ASN1_TAG_OBJECT_IDENTIFIER 6
#define ASN1_TAG_OBJECT_DESCRIPTOR 7
#define ASN1_TAG_EXTERNAL 8
#define ASN1_TAG_REAL 9
#define ASN1_TAG_ENUMERATED 10
#define ASN1_TAG_EMBEDDED_PDV 11
#define ASN1_TAG_UTF8_STRING 12
#define ASN1_TAG_RELATIVE_OID 13
#define ASN1_TAG_TIME 14
/* 15 is reserved */
#define ASN1_TAG_SEQUENCE 16 /* SEQUENCE and SEQUENCE OF */
#define ASN1_TAG_SET 17      /* SET and SET OF */
#define ASN1_TAG_NUMERIC_STRING 18
#define ASN1_TAG_PRINTABLE_STRING 19
#define ASN1_TAG_TELETEX_STRING 20 /* T61String */
#define ASN1_TAG_VIDEOTEX_STRING 21
#define ASN1_TAG_IA5_STRING 22
#define ASN1_TAG_UTC_TIME 23
#define ASN1_TAG_GENERALIZED_TIME 24
#define ASN1_TAG_GRAPHIC_STRING 25
#define ASN1_TAG_VISIBLE_STRING 26 /* ISO646String */
#define ASN1_TAG_GENERAL_STRING 27
#define ASN1_TAG_UNIVERSAL_STRING 28
#define ASN1_TAG_CHARACTER_STRING 29
#define ASN1_TAG_BMP_STRING 30

/* ============================================================================
 * Predefined Identifiers (matching swift-asn1)
 * ============================================================================
 */

/** BOOLEAN identifier */
#define ASN1_ID_BOOLEAN                                                        \
  ((asn1_identifier_t){ASN1_TAG_BOOLEAN, ASN1_TAG_CLASS_UNIVERSAL})

/** INTEGER identifier */
#define ASN1_ID_INTEGER                                                        \
  ((asn1_identifier_t){ASN1_TAG_INTEGER, ASN1_TAG_CLASS_UNIVERSAL})

/** BIT STRING identifier */
#define ASN1_ID_BIT_STRING                                                     \
  ((asn1_identifier_t){ASN1_TAG_BIT_STRING, ASN1_TAG_CLASS_UNIVERSAL})

/** OCTET STRING identifier */
#define ASN1_ID_OCTET_STRING                                                   \
  ((asn1_identifier_t){ASN1_TAG_OCTET_STRING, ASN1_TAG_CLASS_UNIVERSAL})

/** NULL identifier */
#define ASN1_ID_NULL                                                           \
  ((asn1_identifier_t){ASN1_TAG_NULL, ASN1_TAG_CLASS_UNIVERSAL})

/** OBJECT IDENTIFIER identifier */
#define ASN1_ID_OBJECT_IDENTIFIER                                              \
  ((asn1_identifier_t){ASN1_TAG_OBJECT_IDENTIFIER, ASN1_TAG_CLASS_UNIVERSAL})

/** SEQUENCE identifier */
#define ASN1_ID_SEQUENCE                                                       \
  ((asn1_identifier_t){ASN1_TAG_SEQUENCE, ASN1_TAG_CLASS_UNIVERSAL})

/** SET identifier */
#define ASN1_ID_SET                                                            \
  ((asn1_identifier_t){ASN1_TAG_SET, ASN1_TAG_CLASS_UNIVERSAL})

/** UTF8String identifier */
#define ASN1_ID_UTF8_STRING                                                    \
  ((asn1_identifier_t){ASN1_TAG_UTF8_STRING, ASN1_TAG_CLASS_UNIVERSAL})

/** PrintableString identifier */
#define ASN1_ID_PRINTABLE_STRING                                               \
  ((asn1_identifier_t){ASN1_TAG_PRINTABLE_STRING, ASN1_TAG_CLASS_UNIVERSAL})

/** IA5String identifier */
#define ASN1_ID_IA5_STRING                                                     \
  ((asn1_identifier_t){ASN1_TAG_IA5_STRING, ASN1_TAG_CLASS_UNIVERSAL})

/** UTCTime identifier */
#define ASN1_ID_UTC_TIME                                                       \
  ((asn1_identifier_t){ASN1_TAG_UTC_TIME, ASN1_TAG_CLASS_UNIVERSAL})

/** GeneralizedTime identifier */
#define ASN1_ID_GENERALIZED_TIME                                               \
  ((asn1_identifier_t){ASN1_TAG_GENERALIZED_TIME, ASN1_TAG_CLASS_UNIVERSAL})

/* ============================================================================
 * Identifier Functions
 * ============================================================================
 */

/**
 * Create an identifier with a specific tag number and class.
 */
static inline asn1_identifier_t asn1_identifier(uint32_t tag_number,
                                                asn1_tag_class_t tag_class) {
  asn1_identifier_t id = {tag_number, tag_class};
  return id;
}

/**
 * Create a context-specific identifier (commonly used for tagging).
 */
static inline asn1_identifier_t asn1_context_tag(uint32_t tag_number) {
  asn1_identifier_t id = {tag_number, ASN1_TAG_CLASS_CONTEXT_SPECIFIC};
  return id;
}

/**
 * Compare two identifiers for equality.
 */
static inline bool asn1_identifier_equal(asn1_identifier_t a,
                                         asn1_identifier_t b) {
  return a.tag_number == b.tag_number && a.tag_class == b.tag_class;
}

/**
 * Check if identifier can be encoded in short form (tag number < 31).
 */
static inline bool asn1_identifier_is_short_form(asn1_identifier_t id) {
  return id.tag_number < 0x1f;
}

/**
 * Get the short-form encoding byte for an identifier (if applicable).
 * Returns 0 if long-form encoding is required.
 * The 'constructed' parameter sets the constructed bit (bit 5).
 */
static inline uint8_t asn1_identifier_short_form(asn1_identifier_t id,
                                                 bool constructed) {
  if (id.tag_number >= 0x1f) {
    return 0; /* Requires long form */
  }
  uint8_t byte = (uint8_t)id.tag_number;
  byte |= (uint8_t)(id.tag_class << 6);
  if (constructed) {
    byte |= 0x20;
  }
  return byte;
}

#ifdef __cplusplus
}
#endif

#endif /* ASN1_IDENTIFIER_H */
