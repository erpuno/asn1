#!/usr/bin/env bun
/**
 * OpenSSL Comparison Tests - Using GENERATED TypeScript Structures
 * 
 * Tests parsing of real-world crypto formats using der.ts library
 * and verifying round-trip serialization produces identical bytes.
 * 
 * Usage:
 *   bun run openssl_test.ts
 */

// --- Import der.ts Library ---
import { Serializer, parse as derParse, sequence } from "./der.ts/src/der";
import { ASN1Node, ContentType } from "./der.ts/src/collection";
import { ASN1Identifier, TagClass } from "./der.ts/src/types/identifier";
import { ASN1Integer } from "./der.ts/src/types/integer";
import { ASN1ObjectIdentifier } from "./der.ts/src/types/object_identifier";

// --- Import Generated Type Interfaces ---
import type { PKCS_10_CertificationRequest } from "./generated/PKCS_10_CertificationRequest";
import type { PKCS_8_PrivateKeyInfo } from "./generated/PKCS_8_PrivateKeyInfo";
import type { AuthenticationFramework_Certificate } from "./generated/AuthenticationFramework_Certificate";

// --- Helpers ---

function toHex(arr: Uint8Array): string {
    return Array.from(arr).map(b => b.toString(16).padStart(2, '0')).join('');
}

// --- Test Runner ---

interface TestResult {
    name: string;
    size: number;
    roundTripSuccess: boolean;
    error?: string;
}

async function testRoundTrip(filePath: string, typeName: string): Promise<TestResult> {
    const result: TestResult = {
        name: typeName,
        size: 0,
        roundTripSuccess: false
    };

    try {
        // Read file
        const file = Bun.file(filePath);
        const data = new Uint8Array(await file.arrayBuffer());
        result.size = data.length;

        // Parse using der.ts
        const root = derParse(data);

        // Re-serialize using new writeNode method
        const serializer = new Serializer();
        serializer.writeNode(root);
        const encoded = serializer.serializedBytes();

        // Compare
        if (data.length !== encoded.length) {
            result.error = `Length mismatch: ${data.length} vs ${encoded.length}`;
            return result;
        }

        for (let i = 0; i < data.length; i++) {
            if (data[i] !== encoded[i]) {
                result.error = `Byte mismatch at offset ${i}`;
                return result;
            }
        }

        result.roundTripSuccess = true;
    } catch (e: any) {
        result.error = e.message;
    }

    return result;
}

async function main() {
    console.log("=== OpenSSL Comparison Tests (der.ts + Generated TypeScript Structures) ===\n");

    const testDir = "../../test_openssl";
    const results: TestResult[] = [];

    // Define tests with file patterns
    const tests = [
        { file: "rsa_key.der", name: "PKCS_8_PrivateKeyInfo (RSA 2048)" },
        { file: "ec_key.der", name: "PKCS_8_PrivateKeyInfo (EC P-256)" },
        { file: "csr.der", name: "PKCS_10_CertificationRequest" },
        { file: "ca_cert.der", name: "AuthenticationFramework_Certificate (CA)" },
        { file: "ee_cert.der", name: "AuthenticationFramework_Certificate (EE)" },
        { file: "extended_cert.der", name: "AuthenticationFramework_Certificate (Extensions)" },
        { file: "bundle.p7b", name: "PKCS7_SignedData (Bundle)" },
        { file: "signed.cms", name: "CMS_SignedData" },
        { file: "encrypted.cms", name: "CMS_EnvelopedData" },
        { file: "ocsp_request.der", name: "OCSP_Request" },
        { file: "ts_request.tsq", name: "TimeStampReq (RFC 3161)" },
        { file: "dh_params.der", name: "DHParameter" },
        { file: "rsa_pubkey.der", name: "SubjectPublicKeyInfo (RSA)" },
        { file: "ec_pubkey.der", name: "SubjectPublicKeyInfo (EC)" },
    ];

    for (const test of tests) {
        const path = `${testDir}/${test.file}`;
        const file = Bun.file(path);
        if (await file.exists()) {
            results.push(await testRoundTrip(path, test.name));
        }
    }

    // Print results
    console.log("| Type | Size | Round-Trip |");
    console.log("|------|------|------------|");

    let passed = 0;
    let failed = 0;

    for (const r of results) {
        const status = r.roundTripSuccess ? "✓" : "✗";
        console.log(`| ${r.name} | ${r.size} | ${status} |`);
        if (r.error) {
            console.log(`|   → Error: ${r.error} |`);
        }
        if (r.roundTripSuccess) passed++; else failed++;
    }

    console.log("");
    console.log(`Results: ${passed} passed, ${failed} failed`);

    if (failed > 0) {
        process.exit(1);
    }
}

main().catch(err => {
    console.error("Error:", err);
    process.exit(1);
});
