#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <asn1/asn1.h>
#include <asn1/asn1_types.h>

/* Generated Headers */
#include "PKCS_8_PRIVATEKEYINFO.h"
#include "PKCS_10_CERTIFICATIONREQUEST.h"
#include "PKIX1EXPLICIT88_CERTIFICATE.h"

static void hexdump(const uint8_t *data, size_t len) {
    for (size_t i = 0; i < len; i++) {
        printf("%02x", data[i]);
    }
    printf("\n");
}

static uint8_t* read_file(const char *path, size_t *len) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    fseek(f, 0, SEEK_END);
    *len = ftell(f);
    fseek(f, 0, SEEK_SET);
    uint8_t *data = malloc(*len);
    if (fread(data, 1, *len, f) != *len) {
        free(data);
        fclose(f);
        return NULL;
    }
    fclose(f);
    return data;
}

static int test_roundtrip(const char *filename, const char *typename, 
                         asn1_error_t (*decode)(void*, const asn1_node_t*, const asn1_parse_result_t*),
                         asn1_error_t (*encode)(const void*, asn1_serializer_t*),
                         size_t struct_size) {
    size_t original_len;
    char path[256];
    snprintf(path, sizeof(path), "../../test_openssl/%s", filename);
    uint8_t *original_data = read_file(path, &original_len);
    if (!original_data) {
        printf("FAILED: Could not read %s\n", path);
        return 1;
    }

    printf("Testing %s (%s)... ", filename, typename);

    /* Parse */
    asn1_node_t nodes[512];
    asn1_parse_result_t result;
    asn1_parse_result_init(&result, nodes, 512);
    asn1_error_t err = asn1_parse(original_data, original_len, ASN1_ENCODING_DER, &result);
    if (!asn1_is_ok(err)) {
        printf("FAILED parse: %s\n", asn1_error_code_name(err.code));
        free(original_data);
        return 1;
    }

    /* Decode */
    uint8_t *obj = calloc(1, struct_size);
    const asn1_node_t *root = asn1_root_node(&result);
    err = decode(obj, root, &result);
    if (!asn1_is_ok(err)) {
        printf("FAILED decode: %s\n", asn1_error_code_name(err.code));
        free(obj);
        free(original_data);
        return 1;
    }

    /* Encode */
    uint8_t encoded_buffer[1024 * 16];
    asn1_serializer_t s;
    asn1_serializer_init(&s, encoded_buffer, sizeof(encoded_buffer));
    err = encode(obj, &s);
    if (!asn1_is_ok(err)) {
        printf("FAILED encode: %s\n", asn1_error_code_name(err.code));
        free(obj);
        free(original_data);
        return 1;
    }

    /* Compare */
    if (s.length != original_len || memcmp(encoded_buffer, original_data, original_len) != 0) {
        printf("FAILED mismatch\n");
        printf("  Expected (%zu bytes): ", original_len);
        hexdump(original_data, original_len > 32 ? 32 : original_len);
        printf("  Actual   (%zu bytes): ", s.length);
        hexdump(encoded_buffer, s.length > 32 ? 32 : s.length);
        
        /* Find first difference */
        size_t min_len = s.length < original_len ? s.length : original_len;
        for (size_t i = 0; i < min_len; i++) {
            if (encoded_buffer[i] != original_data[i]) {
                printf("  First difference at byte %zu: expected %02x, got %02x\n", i, original_data[i], encoded_buffer[i]);
                break;
            }
        }
        
        free(obj);
        free(original_data);
        return 1;
    }

    printf("PASSED\n");
    free(obj);
    free(original_data);
    return 0;
}

int main() {
    int failures = 0;

    printf("\n=== C99 OpenSSL Round-trip Tests ===\n\n");

    failures += test_roundtrip("rsa_key.der", "PKCS_8_PRIVATEKEYINFO", 
                              (void*)PKCS_8_PRIVATEKEYINFO_decode, (void*)PKCS_8_PRIVATEKEYINFO_encode, 
                              sizeof(PKCS_8_PRIVATEKEYINFO));

    failures += test_roundtrip("ec_key.der", "PKCS_8_PRIVATEKEYINFO", 
                              (void*)PKCS_8_PRIVATEKEYINFO_decode, (void*)PKCS_8_PRIVATEKEYINFO_encode, 
                              sizeof(PKCS_8_PRIVATEKEYINFO));

    failures += test_roundtrip("csr.der", "PKCS_10_CERTIFICATIONREQUEST", 
                              (void*)PKCS_10_CERTIFICATIONREQUEST_decode, (void*)PKCS_10_CERTIFICATIONREQUEST_encode, 
                              sizeof(PKCS_10_CERTIFICATIONREQUEST));

    failures += test_roundtrip("ca_cert.der", "PKIX1EXPLICIT88_CERTIFICATE", 
                              (void*)PKIX1EXPLICIT88_CERTIFICATE_decode, (void*)PKIX1EXPLICIT88_CERTIFICATE_encode, 
                              sizeof(PKIX1EXPLICIT88_CERTIFICATE));

    failures += test_roundtrip("ee_cert.der", "PKIX1EXPLICIT88_CERTIFICATE", 
                              (void*)PKIX1EXPLICIT88_CERTIFICATE_decode, (void*)PKIX1EXPLICIT88_CERTIFICATE_encode, 
                              sizeof(PKIX1EXPLICIT88_CERTIFICATE));

    failures += test_roundtrip("extended_cert.der", "PKIX1EXPLICIT88_CERTIFICATE", 
                              (void*)PKIX1EXPLICIT88_CERTIFICATE_decode, (void*)PKIX1EXPLICIT88_CERTIFICATE_encode, 
                              sizeof(PKIX1EXPLICIT88_CERTIFICATE));

    if (failures == 0) {
        printf("\n✅ All C99 OpenSSL tests passed!\n\n");
    } else {
        printf("\n❌ %d C99 OpenSSL tests failed!\n\n", failures);
    }

    return failures > 0 ? 1 : 0;
}
