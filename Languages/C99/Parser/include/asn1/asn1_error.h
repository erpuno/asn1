/*
 * ASN.1 BER/DER Parser - Error Handling
 * Based on swift-asn1 by Apple Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef ASN1_ERROR_H
#define ASN1_ERROR_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Error codes for ASN.1 parsing and serialization operations.
 */
typedef enum {
    /** No error - operation succeeded */
    ASN1_OK = 0,
    
    /** An ASN.1 field was truncated and could not be decoded */
    ASN1_ERROR_TRUNCATED_FIELD,
    
    /** The format of the parsed ASN.1 object is invalid */
    ASN1_ERROR_INVALID_OBJECT,
    
    /** The ASN.1 tag does not match the expected type */
    ASN1_ERROR_UNEXPECTED_FIELD_TYPE,
    
    /** The length encoding is not supported (e.g., indefinite in DER) */
    ASN1_ERROR_UNSUPPORTED_LENGTH,
    
    /** An ASN.1 integer does not use minimal encoding */
    ASN1_ERROR_INVALID_INTEGER_ENCODING,
    
    /** Maximum parsing depth exceeded */
    ASN1_ERROR_EXCESSIVE_DEPTH,
    
    /** Output buffer is too small */
    ASN1_ERROR_BUFFER_TOO_SMALL,
    
    /** Invalid OID encoding */
    ASN1_ERROR_INVALID_OID,
    
    /** Node array capacity exceeded */
    ASN1_ERROR_CAPACITY_EXCEEDED,
    
    /** Boolean encoding invalid */
    ASN1_ERROR_INVALID_BOOLEAN,
    
    /** Trailing unparsed data present */
    ASN1_ERROR_TRAILING_DATA,
} asn1_error_code_t;

/**
 * Error structure containing error code and context.
 */
typedef struct {
    /** The error code */
    asn1_error_code_t code;
    
    /** Human-readable error message (may be NULL) */
    const char *message;
    
    /** Byte offset in input where error occurred (SIZE_MAX if unknown) */
    size_t offset;
} asn1_error_t;

/**
 * Create a success result.
 */
static inline asn1_error_t asn1_ok(void) {
    asn1_error_t err = {ASN1_OK, NULL, (size_t)-1};
    return err;
}

/**
 * Create an error result.
 */
static inline asn1_error_t asn1_error(asn1_error_code_t code, const char *message, size_t offset) {
    asn1_error_t err = {code, message, offset};
    return err;
}

/**
 * Check if an error represents success.
 */
static inline int asn1_is_ok(asn1_error_t err) {
    return err.code == ASN1_OK;
}

/**
 * Get human-readable name for an error code.
 */
const char *asn1_error_code_name(asn1_error_code_t code);

#ifdef __cplusplus
}
#endif

#endif /* ASN1_ERROR_H */
