/*
 * C99 CMP Client with PBM Protection
 */

#include <arpa/inet.h>
#include <netdb.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>

#include <asn1/asn1.h>
#include <asn1/asn1_types.h>

// Generated ASN.1 Headers
#include "PKCS_10_CERTIFICATIONREQUEST.h"
#include "PKIX1EXPLICIT88_ALGORITHMIDENTIFIER.h"
#include "PKIX1IMPLICIT88_GENERALNAME.h"
#include "PKIXCMP_2009_PBMPARAMETER.h"
#include "PKIXCMP_2009_PKIBODY.h"
#include "PKIXCMP_2009_PKIHEADER.h"
#include "PKIXCMP_2009_PKIMESSAGE.h"
#include "PKIXCRMF_2009_ID_PASSWORDBASEDMAC.h"

/* ============================================================================
 * Minimal Crypto (SHA-256 / HMAC)
 * ============================================================================
 */

#define SHA256_BLOCK_SIZE 64
#define SHA256_DIGEST_SIZE 32

typedef struct {
  uint8_t data[64];
  uint32_t datalen;
  uint64_t bitlen;
  uint32_t state[8];
} SHA256_CTX;

static const uint32_t k[64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2};

#define ROTRIGHT(a, b) (((a) >> (b)) | ((a) << (32 - (b))))
#define CH(x, y, z) (((x) & (y)) ^ (~(x) & (z)))
#define MAJ(x, y, z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
#define EP0(x) (ROTRIGHT(x, 2) ^ ROTRIGHT(x, 13) ^ ROTRIGHT(x, 22))
#define EP1(x) (ROTRIGHT(x, 6) ^ ROTRIGHT(x, 11) ^ ROTRIGHT(x, 25))
#define SIG0(x) (ROTRIGHT(x, 7) ^ ROTRIGHT(x, 18) ^ ((x) >> 3))
#define SIG1(x) (ROTRIGHT(x, 17) ^ ROTRIGHT(x, 19) ^ ((x) >> 10))

static void sha256_transform(SHA256_CTX *ctx, const uint8_t data[]) {
  uint32_t a, b, c, d, e, f, g, h, i, j, t1, t2, m[64];

  for (i = 0, j = 0; i < 16; ++i, j += 4)
    m[i] = (data[j] << 24) | (data[j + 1] << 16) | (data[j + 2] << 8) |
           (data[j + 3]);
  for (; i < 64; ++i)
    m[i] = SIG1(m[i - 2]) + m[i - 7] + SIG0(m[i - 15]) + m[i - 16];

  a = ctx->state[0];
  b = ctx->state[1];
  c = ctx->state[2];
  d = ctx->state[3];
  e = ctx->state[4];
  f = ctx->state[5];
  g = ctx->state[6];
  h = ctx->state[7];

  for (i = 0; i < 64; ++i) {
    t1 = h + EP1(e) + CH(e, f, g) + k[i] + m[i];
    t2 = EP0(a) + MAJ(a, b, c);
    h = g;
    g = f;
    f = e;
    e = d + t1;
    d = c;
    c = b;
    b = a;
    a = t1 + t2;
  }

  ctx->state[0] += a;
  ctx->state[1] += b;
  ctx->state[2] += c;
  ctx->state[3] += d;
  ctx->state[4] += e;
  ctx->state[5] += f;
  ctx->state[6] += g;
  ctx->state[7] += h;
}

static void sha256_init(SHA256_CTX *ctx) {
  ctx->datalen = 0;
  ctx->bitlen = 0;
  ctx->state[0] = 0x6a09e667;
  ctx->state[1] = 0xbb67ae85;
  ctx->state[2] = 0x3c6ef372;
  ctx->state[3] = 0xa54ff53a;
  ctx->state[4] = 0x510e527f;
  ctx->state[5] = 0x9b05688c;
  ctx->state[6] = 0x1f83d9ab;
  ctx->state[7] = 0x5be0cd19;
}

static void sha256_update(SHA256_CTX *ctx, const uint8_t data[], size_t len) {
  uint32_t i;
  for (i = 0; i < len; ++i) {
    ctx->data[ctx->datalen] = data[i];
    ctx->datalen++;
    if (ctx->datalen == 64) {
      sha256_transform(ctx, ctx->data);
      ctx->bitlen += 512;
      ctx->datalen = 0;
    }
  }
}

static void sha256_final(SHA256_CTX *ctx, uint8_t hash[]) {
  uint32_t i;
  i = ctx->datalen;
  if (ctx->datalen < 56) {
    ctx->data[i++] = 0x80;
    while (i < 56)
      ctx->data[i++] = 0x00;
  } else {
    ctx->data[i++] = 0x80;
    while (i < 64)
      ctx->data[i++] = 0x00;
    sha256_transform(ctx, ctx->data);
    memset(ctx->data, 0, 56);
  }
  ctx->bitlen += ctx->datalen * 8;
  ctx->data[63] = ctx->bitlen;
  ctx->data[62] = ctx->bitlen >> 8;
  ctx->data[61] = ctx->bitlen >> 16;
  ctx->data[60] = ctx->bitlen >> 24;
  ctx->data[59] = ctx->bitlen >> 32;
  ctx->data[58] = ctx->bitlen >> 40;
  ctx->data[57] = ctx->bitlen >> 48;
  ctx->data[56] = ctx->bitlen >> 56;
  sha256_transform(ctx, ctx->data);
  for (i = 0; i < 4; ++i) {
    hash[i] = (ctx->state[0] >> (24 - i * 8)) & 0x000000ff;
    hash[i + 4] = (ctx->state[1] >> (24 - i * 8)) & 0x000000ff;
    hash[i + 8] = (ctx->state[2] >> (24 - i * 8)) & 0x000000ff;
    hash[i + 12] = (ctx->state[3] >> (24 - i * 8)) & 0x000000ff;
    hash[i + 16] = (ctx->state[4] >> (24 - i * 8)) & 0x000000ff;
    hash[i + 20] = (ctx->state[5] >> (24 - i * 8)) & 0x000000ff;
    hash[i + 24] = (ctx->state[6] >> (24 - i * 8)) & 0x000000ff;
    hash[i + 28] = (ctx->state[7] >> (24 - i * 8)) & 0x000000ff;
  }
}

static void hmac_sha256(const uint8_t *key, size_t key_len, const uint8_t *data,
                        size_t data_len, uint8_t *output) {
  SHA256_CTX ctx;
  uint8_t k_ipad[64];
  uint8_t k_opad[64];
  uint8_t tk[32];
  int i;
  if (key_len > 64) {
    sha256_init(&ctx);
    sha256_update(&ctx, key, key_len);
    sha256_final(&ctx, tk);
    key = tk;
    key_len = 32;
  }
  memset(k_ipad, 0, sizeof(k_ipad));
  memset(k_opad, 0, sizeof(k_opad));
  memcpy(k_ipad, key, key_len);
  memcpy(k_opad, key, key_len);
  for (i = 0; i < 64; i++) {
    k_ipad[i] ^= 0x36;
    k_opad[i] ^= 0x5c;
  }
  sha256_init(&ctx);
  sha256_update(&ctx, k_ipad, 64);
  sha256_update(&ctx, data, data_len);
  sha256_final(&ctx, output);
  sha256_init(&ctx);
  sha256_update(&ctx, k_opad, 64);
  sha256_update(&ctx, output, 32);
  sha256_final(&ctx, output);
}

static void derive_key(const char *password, const uint8_t *salt,
                       size_t salt_len, int iterations, uint8_t *output_key) {
  SHA256_CTX ctx;
  sha256_init(&ctx);
  sha256_update(&ctx, (const uint8_t *)password, strlen(password));
  sha256_update(&ctx, salt, salt_len);
  sha256_final(&ctx, output_key);
  for (int i = 0; i < iterations - 1; i++) {
    sha256_init(&ctx);
    sha256_update(&ctx, output_key, 32);
    sha256_final(&ctx, output_key);
  }
}

static void hexdump(const char *label, const uint8_t *data, size_t len) {
  printf("%s (%zu bytes): ", label, len);
  for (size_t i = 0; i < len && i < 32; i++)
    printf("%02X ", data[i]);
  if (len > 32)
    printf("...");
  printf("\n");
}

/* ============================================================================
 * Helper to parse hex CSR
 * ============================================================================
 */
static void hydrate_csr(PKIXCMP_2009_PKIBODY *body, const uint8_t *csr_bytes,
                        size_t csr_len) {
  // Parse CSR bytes
  asn1_node_t nodes[128];
  asn1_parse_result_t result;
  asn1_parse_result_init(&result, nodes, 128);

  asn1_error_t err = asn1_parse(csr_bytes, csr_len, ASN1_ENCODING_DER, &result);
  if (!asn1_is_ok(err)) {
    printf("FAILED to parse CSR: error code %d\n", err.code);
    exit(1);
  }

  // Set selector and decode into p10cr struct
  body->selector = PKIXCMP_2009_PKIBODY_SELECTOR_P10CR;
  memset(&body->data.p10cr, 0, sizeof(body->data.p10cr));

  err = PKCS_10_CERTIFICATIONREQUEST_decode(&body->data.p10cr,
                                            asn1_root_node(&result), &result);
  if (!asn1_is_ok(err)) {
    printf("FAILED to decode CSR into struct: error code %d\n", err.code);
    printf("Trying to continue anyway...\n");
    // Don't exit - the CSR might still serialize correctly from the parsed data
  } else {
    printf("CSR successfully decoded (%zu bytes)\n", csr_len);
  }
}

/* ============================================================================
 * Main
 * ============================================================================
 */
int main(void) {
  printf("Starting C99 CMP Client...\n");

  // 1. PBM Config
  const char *password = "0000";
  uint8_t salt[16];
  for (int i = 0; i < 16; i++)
    salt[i] = i;
  int iterations = 10000;
  uint8_t key[32];
  derive_key(password, salt, 16, iterations, key);
  hexdump("PBM Key", key, 32);

  // 2. Build PKIMessage (heap-allocated to avoid stack overflow)
  PKIXCMP_2009_PKIMESSAGE *msg = calloc(1, sizeof(PKIXCMP_2009_PKIMESSAGE));
  if (msg == NULL) {
    printf("ERROR: Failed to allocate memory for PKIMessage\n");
    return 1;
  }

  // HEADER
  PKIXCMP_2009_PKIHEADER *h = &msg->header;
  h->pvno = 2;

  // Sender "robot_c99" (dNSName) - Need to set selector and data
  // NOTE: Generating C99 for IMPLICIT GeneralName might not handle the implicit
  // tagging perfectly if calling simple serialize_string. But let's try.
  h->sender.selector = PKIX1IMPLICIT88_GENERALNAME_SELECTOR_DNSNAME;
  h->sender.data.d_ns_name.length =
      snprintf((char *)h->sender.data.d_ns_name.bytes,
               sizeof(h->sender.data.d_ns_name.bytes), "robot_c99");

  h->recipient.selector = PKIX1IMPLICIT88_GENERALNAME_SELECTOR_DNSNAME;
  h->recipient.data.d_ns_name.length =
      snprintf((char *)h->recipient.data.d_ns_name.bytes,
               sizeof(h->recipient.data.d_ns_name.bytes), "localhost");

  h->has_message_time = true;
  h->message_time.length =
      snprintf((char *)h->message_time.bytes, sizeof(h->message_time.bytes),
               "20251222120000Z");

  h->has_protection_alg = true;
  // Construct PBM Param: OID: 1.2.840.113533.7.66.13
  // Parameters: SEQUENCE { OCTET STRING salt, INTEGER owf, INTEGER iterations,
  // INTEGER mac } Manually build DER for AlgorithmIdentifier for PBM 30 2B
  // (Seq)
  //    06 09 2A 86 48 86 F6 7D 07 42 0D (OID)
  //    30 1E (Params Seq)
  //       04 10 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F (Salt)
  //       02 01 02 (OWF SHA256)
  //       02 02 27 10 (Iter 10000)
  //       02 01 02 (MAC HMAC-SHA256)
  // Total len: 2 + 11 + 2 + 18 + 3 + 4 + 3 = 43 bytes (0x2B)
  uint8_t pbm_alg_der[] = {0x30, 0x3C, // Sequence, longer?
                                       // OID 1.2.840.113533.7.66.13
                           0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF6, 0x7D, 0x07,
                           0x42, 0x0D,
                           // Params Sequence
                           0x30, 0x2F,
                           // Salt
                           0x04, 0x10, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
                           0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
                           // OWF (2)
                           0x02, 0x01, 0x02,
                           // Iter (10000 = 0x2710)
                           0x02, 0x02, 0x27, 0x10,
                           // MAC (2)
                           0x02, 0x01, 0x02};
  // The inner param seq length is 18+3+4+3 = 28 (0x1C)?
  // 2+16=18. 02 01 02 = 3. 02 02 27 10 = 4. 02 01 02 = 3.
  // 18+3+4+3 = 28.
  // wait. 04 10 .. is 2+16=18.
  // Total 28. -> 1C.
  // My manual bytes above had 2F. Let's fix.
  // OID is 11 bytes. Total 11 + 2 + 28 = 41.
  // Outer seq len 41 (0x29).
  // Let's rely on the bytes I used in Go:
  // Go hex: ... A1 3E 30 3C 06 09 2A 86 48 86 F6 7D 07 42 0D 30 2F 04 10 ...
  // Go used 3C (60) total length?
  // Ah, Go params length: 47 (2F)?
  // Salt 16 bytes.
  // Go salt was random.
  // I'll stick to my deterministic salt bytes but use correct lengths.
  // Params:
  // 04 10 ... (18)
  // 30 0B 06 09 ... (OWF AlgId?) No, generated Go used simple Integers?
  // Wait, Go implementation:
  // owf := AlgorithmIdentifier{Algorithm: oidSHA256}
  // mac := AlgorithmIdentifier{Algorithm: oidHMAC_SHA256}
  // So logic uses AlgIDs, not Integers!
  // My manual calc above assumed Integers.
  // OK, I'll copy the PBM DER bytes exactly from a known good source or just
  // construct roughly correct ones. Actually, checking standard: PBMParameter
  // ::= SEQUENCE { salt OCTET STRING, owf AlgorithmIdentifier, iterationCount
  // INTEGER, mac AlgorithmIdentifier } So yes, Algorithms.

  // I'll use the bytes corresponding to the Go logic.
  // Copy/paste logic:
  // OID PBM: 06 09 2A 86 48 86 F6 7D 07 42 0D
  // Params:
  //   Salt: 04 10 [00..0F]
  //   OWF: 30 0B 06 09 60 86 48 01 65 03 04 02 01 (SHA256 OID)
  //   Iter: 02 02 27 10
  //   MAC: 30 0A 06 08 2A 86 48 86 F7 0D 02 09 (HMAC-SHA256 OID)
  // Total Params Len: 18 + 13 + 4 + 12 = 47 (0x2F).
  // Total AlgId Len: 11 + 2 + 47 = 60 (0x3C).
  // Correct!

  uint8_t pbm_alg_bytes[] = {
      0x30, 0x3C, 0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF6, 0x7D, 0x07,
      0x42, 0x0D, 0x30, 0x2F, 0x04, 0x10, 0x00, 0x01, 0x02, 0x03, 0x04,
      0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
      0x30, 0x0B, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04,
      0x02, 0x01, 0x02, 0x02, 0x27, 0x10, 0x30, 0x0A, 0x06, 0x08, 0x2A,
      0x86, 0x48, 0x86, 0xF7, 0x0D, 0x02, 0x09};
  memcpy(h->protection_alg.bytes, pbm_alg_bytes, sizeof(pbm_alg_bytes));
  h->protection_alg.length = sizeof(pbm_alg_bytes);

  // Other header fields
  h->has_sender_kid = true;
  h->sender_kid.length = 8;
  memcpy(h->sender_kid.bytes, "robot_go", 8);

  h->has_transaction_id = true;
  const char *tid = "1234";
  h->transaction_id.length = 4;
  memcpy(h->transaction_id.bytes, tid, 4);

  h->has_sender_nonce = true;
  h->sender_nonce.length = 16;
  memset(h->sender_nonce.bytes, 0xAA, 16);

  // BODY (CSR)
  // Valid CSR generated by OpenSSL: CN=robot_c99, secp384r1 EC key
  uint8_t csr_bytes[] = {
      0x30, 0x82, 0x01, 0x0b, 0x30, 0x81, 0x93, 0x02, 0x01, 0x00, 0x30, 0x14,
      0x31, 0x12, 0x30, 0x10, 0x06, 0x03, 0x55, 0x04, 0x03, 0x0c, 0x09, 0x72,
      0x6f, 0x62, 0x6f, 0x74, 0x5f, 0x63, 0x39, 0x39, 0x30, 0x76, 0x30, 0x10,
      0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x05, 0x2b,
      0x81, 0x04, 0x00, 0x22, 0x03, 0x62, 0x00, 0x04, 0x04, 0x64, 0x45, 0x58,
      0x18, 0xed, 0x2f, 0xdd, 0xe4, 0x84, 0x54, 0x10, 0x07, 0xd8, 0xd0, 0x78,
      0x1d, 0x43, 0x16, 0x37, 0x0a, 0x6b, 0x77, 0x3c, 0x67, 0x3a, 0x17, 0x8e,
      0xe5, 0x37, 0xc6, 0x92, 0xd6, 0x99, 0x82, 0x92, 0x68, 0x9a, 0x01, 0x44,
      0xee, 0xea, 0x24, 0x5a, 0x3e, 0x5a, 0xc0, 0x42, 0xf6, 0x37, 0x7d, 0xa2,
      0x73, 0x3d, 0x8b, 0x8e, 0xcf, 0x6a, 0x3c, 0xe8, 0x6b, 0xbf, 0x21, 0x4b,
      0x09, 0x36, 0x8e, 0xdd, 0xe4, 0x0f, 0xcc, 0xb7, 0xf0, 0x55, 0x20, 0xaf,
      0xde, 0xb7, 0xd5, 0xa1, 0x2b, 0xdd, 0xf8, 0x95, 0xa8, 0xc0, 0x6b, 0xac,
      0x45, 0x82, 0x6f, 0xc1, 0x9a, 0x24, 0xb0, 0xa2, 0xa0, 0x00, 0x30, 0x0a,
      0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x04, 0x03, 0x02, 0x03, 0x67,
      0x00, 0x30, 0x64, 0x02, 0x30, 0x22, 0x30, 0x92, 0xd2, 0x80, 0xda, 0x4a,
      0x43, 0x04, 0x02, 0xf2, 0x93, 0x8d, 0xcf, 0x22, 0x6a, 0xb0, 0x96, 0xd6,
      0xff, 0xd9, 0x3f, 0xbf, 0x85, 0xc7, 0x94, 0x92, 0xe8, 0xde, 0xed, 0x1e,
      0x56, 0x3a, 0x94, 0x3b, 0x50, 0x8e, 0x3a, 0x2d, 0xe0, 0xd1, 0x8d, 0x73,
      0x89, 0x18, 0x59, 0x98, 0xdc, 0x02, 0x30, 0x4d, 0xdf, 0x80, 0x6d, 0xd4,
      0x79, 0x5d, 0xbb, 0xa2, 0xf6, 0xd9, 0x5c, 0xa3, 0x3f, 0xeb, 0x90, 0xa5,
      0xd8, 0xe7, 0x71, 0xa5, 0xbc, 0x89, 0x44, 0x16, 0xab, 0x48, 0x13, 0xca,
      0x8d, 0x04, 0xce, 0xe9, 0xc5, 0xdc, 0xfe, 0x79, 0xf1, 0x89, 0x89, 0xec,
      0x8f, 0xfc, 0x94, 0x07, 0x11, 0xeb, 0x56};
  hydrate_csr(&msg->body, csr_bytes, sizeof(csr_bytes));

  // 3. Serialized ProtectedPart (Header + Body)
  // We must manually encode SEQUENCE { header, body } to calculate MAC
  // Because ASN.1 generates 'PKIMessage' which writes Sequence(head, body,
  // protection...), we need an intermediate buffer.
  uint8_t buffer[2048];
  asn1_serializer_t s;
  asn1_serializer_init(&s, buffer, sizeof(buffer));

  // Explicitly write SEQUENCE for ProtectedPart
  size_t marker;
  asn1_serialize_constructed_begin(&s, ASN1_ID_SEQUENCE, &marker);
  PKIXCMP_2009_PKIHEADER_encode(&msg->header, &s);
  PKIXCMP_2009_PKIBODY_encode(&msg->body, &s);
  asn1_serialize_constructed_end(&s, marker);

  hexdump("ProtectedPart", buffer, s.length);

  // 4. Calculate MAC
  // Protection: BIT STRING
  msg->has_protection = true;
  uint8_t mac[32];
  hmac_sha256(key, 32, buffer, s.length, mac);
  msg->protection.byte_count = 32;
  msg->protection.unused_bits = 0;
  memcpy(msg->protection.bytes, mac, 32);

  // 5. Final Encode
  uint8_t final_buf[2048];
  asn1_serializer_init(&s, final_buf, sizeof(final_buf));
  asn1_error_t err = PKIXCMP_2009_PKIMESSAGE_encode(msg, &s);
  if (!asn1_is_ok(err)) {
    printf("FAILED to encode PKIMessage: %d\n", err.code);
    return 1;
  }
  hexdump("Final PKIMessage", final_buf, s.length);

  // 6. Send to Server
  printf("\n=== Connecting to CA Server ===\n");
  int sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock < 0) {
    printf("ERROR: Failed to create socket\n");
    return 1;
  }

  struct sockaddr_in serv_addr;
  memset(&serv_addr, 0, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  serv_addr.sin_port = htons(8829);
  struct hostent *server = gethostbyname("localhost");
  if (server == NULL) {
    printf("ERROR: No such host (localhost)\n");
    return 1;
  }
  memcpy(&serv_addr.sin_addr.s_addr, server->h_addr, server->h_length);

  printf("Connecting to localhost:8829...\n");
  if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
    perror("ERROR connecting");
    return 1;
  }
  printf("Connected!\n");

  char header_buf[256];
  sprintf(header_buf, "POST / HTTP/1.0\r\nContent-Length: %zu\r\n\r\n",
          s.length);
  printf("Sending HTTP headers (%zu bytes)...\n", strlen(header_buf));
  int sent = send(sock, header_buf, strlen(header_buf), 0);
  printf("Sent %d header bytes\n", sent);

  printf("Sending PKIMessage body (%zu bytes)...\n", s.length);
  sent = send(sock, final_buf, s.length, 0);
  printf("Sent %d body bytes\n", sent);

  shutdown(sock, SHUT_WR); // Close write to signal EOF
  printf("Waiting for response...\n");

  // 7. Read Response
  char resp[4096];
  int n = recv(sock, resp, sizeof(resp) - 1, 0);
  printf("Received %d bytes\n", n);

  if (n > 0) {
    // Print raw response for debugging
    // printf("\n=== Server Response (Raw) ===\n%.*s\n", n, resp);

    // Find body start
    char *body_start = strstr(resp, "\r\n\r\n");
    if (body_start) {
      body_start += 4;
      size_t header_len = body_start - resp;
      size_t body_len = n - header_len;

      printf("\n=== Server Response (Decoded) ===\n");
      printf("Header Length: %zu\n", header_len);
      printf("Body Length: %zu\n", body_len);

      if (body_len > 0) {
        // Parse ASN.1
        asn1_node_t nodes[512];
        asn1_parse_result_t result;
        asn1_parse_result_init(&result, nodes, 512);
        asn1_error_t err = asn1_parse((const uint8_t *)body_start, body_len,
                                      ASN1_ENCODING_DER, &result);
        if (!asn1_is_ok(err)) {
          printf("FAILED to parse response ASN.1: code %d\n", err.code);
        } else {
          PKIXCMP_2009_PKIMESSAGE *resp_msg =
              calloc(1, sizeof(PKIXCMP_2009_PKIMESSAGE));
          if (resp_msg) {
            err = PKIXCMP_2009_PKIMESSAGE_decode(
                resp_msg, asn1_root_node(&result), &result);
            if (!asn1_is_ok(err)) {
              printf("FAILED to decode PKIMessage: code %d\n", err.code);
              printf("--- Body Hex Dump (%zu bytes) ---\n", body_len);
              for (size_t i = 0; i < body_len; i++) {
                printf("%02X ", (uint8_t)body_start[i]);
                if ((i + 1) % 16 == 0)
                  printf("\n");
              }
              printf("\n-------------------------------\n");
            } else {
              printf("Successfully decoded PKIMessage!\n");
              // Log Transaction ID
              if (resp_msg->header.has_transaction_id) {
                printf("Transaction ID: ");
                for (size_t i = 0; i < resp_msg->header.transaction_id.length;
                     i++)
                  printf("%02X", resp_msg->header.transaction_id.bytes[i]);
                printf("\n");
              }

              // Log Body Type
              printf("Body Type: ");
              switch (resp_msg->body.selector) {
              case PKIXCMP_2009_PKIBODY_SELECTOR_IR:
                printf("IR (Initialization Request)\n");
                break;
              case PKIXCMP_2009_PKIBODY_SELECTOR_IP:
                printf("IP (Initialization Response)\n");
                break;
              case PKIXCMP_2009_PKIBODY_SELECTOR_CR:
                printf("CR (Certification Request)\n");
                break;
              case PKIXCMP_2009_PKIBODY_SELECTOR_CP:
                printf("CP (Certification Response)\n");
                break;
              case PKIXCMP_2009_PKIBODY_SELECTOR_P10CR:
                printf("P10CR (PKCS#10 Request)\n");
                break;
              case PKIXCMP_2009_PKIBODY_SELECTOR_PKICONF:
                printf("PKIConf (Confirmation)\n");
                break;
              case PKIXCMP_2009_PKIBODY_SELECTOR_ERROR:
                printf("ERROR (Error Message)\n");
                break;
              default:
                printf("Unknown (%d)\n", resp_msg->body.selector);
                break;
              }

              // Log Protection
              if (resp_msg->has_protection) {
                printf("Protection: Present (%zu bytes)\n",
                       resp_msg->protection.byte_count);
              } else {
                printf("Protection: None\n");
              }
            }
            free(resp_msg);
          } else {
            printf("Memory allocation failed for response message\n");
          }
        }
      }
    } else {
      printf("Could not find body delimiter in response\n");
      printf("%.*s\n", n, resp);
    }

  } else if (n == 0) {
    printf("Connection closed by server (no data)\n");
  } else {
    perror("ERROR receiving response");
  }
  close(sock);

  free(msg);
  return 0;
}
