import {
    ASN1Node,
    Serializer,
    DERSerializable,
    parse as derParse
} from "./der.ts/src/der";
import { PKCS_8_PrivateKeyInfo } from "./generated/PKCS_8_PrivateKeyInfo";
import { PKCS_10_CertificationRequest } from "./generated/PKCS_10_CertificationRequest";
import { AuthenticationFramework_Certificate } from "./generated/AuthenticationFramework_Certificate";
import { PKCS_7_ContentInfo } from "./generated/PKCS_7_ContentInfo";
import { CryptographicMessageSyntax_2010_ContentInfo } from "./generated/CryptographicMessageSyntax_2010_ContentInfo";
import { OCSP_OCSPRequest } from "./generated/OCSP_OCSPRequest";
import { PKIX1Explicit_2009_SubjectPublicKeyInfo } from "./generated/PKIX1Explicit_2009_SubjectPublicKeyInfo";
import { PKIX1Explicit88_SubjectPublicKeyInfo } from "./generated/PKIX1Explicit88_SubjectPublicKeyInfo";
import { PKIX1Explicit88_AlgorithmIdentifier as PKCS_5_AlgorithmIdentifier } from "./generated/PKIX1Explicit88_AlgorithmIdentifier";

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

async function testTypedRoundTrip<T extends DERSerializable>(
    filePath: string,
    typeName: string,
    typeClass: any
): Promise<TestResult> {
    const result: TestResult = {
        name: typeName,
        size: 0,
        roundTripSuccess: false
    };

    try {
        // Read file
        const file = Bun.file(filePath);
        if (!(await file.exists())) {
            result.error = `File not found: ${filePath}`;
            return result;
        }
        const data = new Uint8Array(await file.arrayBuffer());
        result.size = data.length;

        // 1. Generic Parse
        const root = derParse(data);

        // 2. Typed Parse
        const typedObj = typeClass.fromDERNode(root);

        // 3. Serialize back
        const serializer = new Serializer();
        typedObj.serialize(serializer);
        const encoded = serializer.serializedBytes();

        // 4. Compare
        if (data.length !== encoded.length) {
            result.error = `Length mismatch: ${data.length} vs ${encoded.length}`;
            return result;
        }

        for (let i = 0; i < data.length; i++) {
            if (data[i] !== encoded[i]) {
                result.error = `Byte mismatch at offset ${i}. \nExpected: ${toHex(data.slice(i, i + 10))}\nActual:   ${toHex(encoded.slice(i, i + 10))}`;
                return result;
            }
        }

        result.roundTripSuccess = true;
    } catch (e: any) {
        result.error = `${e.message}\n${e.stack}`;
    }

    return result;
}

async function main() {
    console.log("=== OpenSSL Comparison Tests (Typed Parsing & Serialization) ===\n");
    console.log(`Current Working Directory: ${process.cwd()}`);

    const testDir = "../../test_openssl";
    const results: TestResult[] = [];

    // Define tests with their corresponding generated classes
    const tests = [
        { file: "rsa_key.der", name: "PKCS_8_PrivateKeyInfo (RSA 2048)", class: PKCS_8_PrivateKeyInfo },
        { file: "ec_key.der", name: "PKCS_8_PrivateKeyInfo (EC P-256)", class: PKCS_8_PrivateKeyInfo },
        { file: "csr.der", name: "PKCS_10_CertificationRequest", class: PKCS_10_CertificationRequest },
        { file: "ca_cert.der", name: "AuthenticationFramework_Certificate (CA)", class: AuthenticationFramework_Certificate },
        { file: "ee_cert.der", name: "AuthenticationFramework_Certificate (EE)", class: AuthenticationFramework_Certificate },
        { file: "extended_cert.der", name: "AuthenticationFramework_Certificate (Extensions)", class: AuthenticationFramework_Certificate },
        { file: "bundle.p7b", name: "PKCS_7_ContentInfo (Bundle)", class: PKCS_7_ContentInfo },
        { file: "signed.cms", name: "CMS_SignedData (CryptographicMessageSyntax_2010)", class: CryptographicMessageSyntax_2010_ContentInfo },
        { file: "encrypted.cms", name: "CMS_EnvelopedData (CryptographicMessageSyntax_2010)", class: CryptographicMessageSyntax_2010_ContentInfo },
        { file: "ocsp_request.der", name: "OCSP_Request", class: OCSP_OCSPRequest },
        { file: "rsa_pubkey.der", name: "SubjectPublicKeyInfo (RSA)", class: PKIX1Explicit_2009_SubjectPublicKeyInfo },
        { file: "ec_pubkey.der", name: "SubjectPublicKeyInfo (EC)", class: PKIX1Explicit88_SubjectPublicKeyInfo },
    ];

    for (const test of tests) {
        results.push(await testTypedRoundTrip(`${testDir}/${test.file}`, test.name, test.class));
    }

    // Print results table
    console.log("| Type | Size | Round-Trip |");
    console.log("|------|------|------------|");

    let passed = 0;
    let failed = 0;

    for (const r of results) {
        const status = r.roundTripSuccess ? "✓" : "✗";
        console.log(`| ${r.name} | ${r.size} | ${status} |`);
        if (r.error) {
            console.log(`|   → Error: ${r.error.split('\n')[0]} |`);
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
    console.error("Fatal Error:", err);
    process.exit(1);
});
