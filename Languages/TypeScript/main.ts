import { PKCS_10_CertificationRequest } from "./generated/PKCS_10_CertificationRequest";
import { PKCS_10_CertificationRequestInfo } from "./generated/PKCS_10_CertificationRequestInfo";
import { PKCS_10_SubjectPublicKeyInfo } from "./generated/PKCS_10_SubjectPublicKeyInfo";
import { PKCS_10_AlgorithmIdentifier } from "./generated/PKCS_10_AlgorithmIdentifier";
import { PKCS_10_Name } from "./generated/PKCS_10_Name";
import { PKIX1Explicit88_RDNSequence } from "./generated/PKIX1Explicit88_RDNSequence";
import { PKIX1Explicit88_RelativeDistinguishedName } from "./generated/PKIX1Explicit88_RelativeDistinguishedName";
import { PKIX1Explicit88_AttributeTypeAndValue } from "./generated/PKIX1Explicit88_AttributeTypeAndValue";
import { PKIX1Explicit88_AttributeValue } from "./generated/PKIX1Explicit88_AttributeValue";
// Removed unused node:crypto imports to prefer Web Crypto API

// --- Manual DER Encoder (Minimal) ---

import { Serializer, parse as derParse } from "./der.ts/src/der";
import { ASN1Integer } from "./der.ts/src/types/integer";
import { ASN1ObjectIdentifier } from "./der.ts/src/types/object_identifier";
import { ASN1OctetString } from "./der.ts/src/types/octet_string";
import { ASN1BitString } from "./der.ts/src/types/bit_string";
import { ASN1PrintableString, ASN1IA5String, ASN1UTF8String } from "./der.ts/src/types/strings";
import { ASN1Null } from "./der.ts/src/types/null";
import { ASN1Identifier, TagClass } from "./der.ts/src/types/identifier";
import { ContentType, ASN1Node } from "./der.ts/src/collection";

/**
 * Helper to allow serializing an existing ASN1Node tree back to DER.
 */
class NodeSerializable {
    constructor(private node: ASN1Node) { }

    serialize(s: Serializer): void {
        if (this.node.content.type === ContentType.Primitive) {
            const data = this.node.content.value;
            s.appendPrimitiveNode(this.node.identifier, (buf) => {
                for (const b of data) buf.push(b);
            });
        } else {
            s.appendConstructedNode(this.node.identifier, (nested) => {
                for (const child of this.node.content.value as any) {
                    new NodeSerializable(child).serialize(nested);
                }
            });
        }
    }
}

// --- Manual DER Encoder Shim (Using der.ts) ---

namespace DER {
    export function concat(...arrays: Uint8Array[]): Uint8Array {
        let total = 0;
        for (const arr of arrays) total += arr.length;
        const result = new Uint8Array(total);
        let offset = 0;
        for (const arr of arrays) {
            result.set(arr, offset);
            offset += arr.length;
        }
        return result;
    }

    function serialize(node: any): Uint8Array {
        const s = new Serializer();
        node.serialize(s);
        return s.serializedBytes();
    }

    export function encodeOID(oid: string): Uint8Array {
        return serialize(ASN1ObjectIdentifier.fromComponents(oid.split('.').map(BigInt)));
    }

    export function encodeInteger(num: number | bigint): Uint8Array {
        return serialize(new ASN1Integer(BigInt(num)));
    }

    export function encodePrintableString(str: string): Uint8Array {
        return serialize(new ASN1PrintableString(str));
    }

    export function encodeUTF8String(str: string): Uint8Array {
        return serialize(new ASN1UTF8String(str));
    }

    export function encodeIA5String(str: string): Uint8Array {
        return serialize(new ASN1IA5String(str));
    }

    export function encodeOctetString(data: Uint8Array): Uint8Array {
        return serialize(new ASN1OctetString(data));
    }

    export function encodeBitString(data: Uint8Array, unusedBits: number = 0): Uint8Array {
        return serialize(new ASN1BitString(data, unusedBits));
    }

    export function encodeNull(): Uint8Array {
        return serialize(new ASN1Null());
    }

    /**
     * Internal manual tag encoding for shim wrappers.
     * der.ts Serializer doesn't expose raw tag/length writing, so we use a minimal implementation here.
     */
    export function encodeTag(tagClass: number, constructed: boolean, tagNumber: number): Uint8Array {
        if (tagNumber < 31) {
            let byte = (tagClass << 6) | (constructed ? 0x20 : 0x00) | tagNumber;
            return new Uint8Array([byte]);
        }
        // Simplified high tag number (only supporting up to a few bytes for shim)
        let firstByte = (tagClass << 6) | (constructed ? 0x20 : 0x00) | 0x1f;
        const bytes = [firstByte];
        const nBytes = [];
        let n = tagNumber;
        nBytes.unshift(n & 0x7f);
        while (n >= 128) {
            n >>= 7;
            nBytes.unshift((n & 0x7f) | 0x80);
        }
        return new Uint8Array([...bytes, ...nBytes]);
    }

    export function encodeLength(len: number): Uint8Array {
        if (len < 128) {
            return new Uint8Array([len]);
        }
        const bytes = [];
        let l = len;
        while (l > 0) {
            bytes.unshift(l & 0xff);
            l >>= 8;
        }
        return new Uint8Array([0x80 | bytes.length, ...bytes]);
    }

    export function encodeSequence(content: Uint8Array): Uint8Array {
        return concat(encodeTag(0, true, 16), encodeLength(content.length), content);
    }

    export function encodeSet(content: Uint8Array): Uint8Array {
        return concat(encodeTag(0, true, 17), encodeLength(content.length), content);
    }

    export function encodeContextSpecific(tag: number, content: Uint8Array, constructed: boolean = true): Uint8Array {
        return concat(encodeTag(2, constructed, tag), encodeLength(content.length), content);
    }
}

// --- Helpers ---

function toHex(arr: Uint8Array): string {
    return Array.from(arr).map(b => b.toString(16).padStart(2, '0')).join('');
}

function toBase64(arr: Uint8Array): string {
    // Using a way that handles large arrays and works in modern environments
    const binary = Array.from(arr, b => String.fromCharCode(b)).join('');
    return btoa(binary);
}

function printASN1Tree(node: ASN1Node, depth: number = 0): void {
    const indent = "  ".repeat(depth);
    const tag = node.identifier.tagNumber;
    const cls = TagClass[node.identifier.tagClass];
    const len = node.encodedBytes.length;

    if (node.content.type === ContentType.Primitive) {
        let valStr = "";
        if (tag === 2n) { // INTEGER
            valStr = BigInt("0x" + toHex(node.content.value)).toString();
        } else if (tag === 6n) { // OID
            valStr = "(OID bytes)";
        } else if (tag === 12n || tag === 19n || tag === 22n) { // UTF8/Printable/IA5
            valStr = `'${new TextDecoder().decode(node.content.value)}'`;
        } else {
            valStr = `hex:${toHex(node.content.value.slice(0, 16))}...`;
        }
        console.log(`${indent}${cls}[${tag}] Primitive Len=${len} Val=${valStr}`);
    } else {
        console.log(`${indent}${cls}[${tag}] Constructed Len=${len}`);
        for (const child of node.content.value) {
            printASN1Tree(child, depth + 1);
        }
    }
}

async function runCertificateRoundtrip(certDer: Uint8Array) {
    console.log("\n--- Starting Certificate Roundtrip Test ---");

    // 1. Parse
    const root = derParse(certDer);
    console.log("ASN.1 Structure of Extracted Certificate:");
    printASN1Tree(root);

    // 2. Re-serialize
    const serializer = new Serializer();
    new NodeSerializable(root).serialize(serializer);
    const reSerialized = serializer.serializedBytes();

    console.log(`Original: ${certDer.length} bytes`);
    console.log(`Re-serialized: ${reSerialized.length} bytes`);

    // 3. Save to files
    // @ts-ignore
    if (typeof Bun !== 'undefined') {
        // @ts-ignore
        await Bun.write("robot_go_roundtrip.der", reSerialized);
        console.log("Saved re-serialized to robot_go_roundtrip.der");
    }

    // 4. Compare
    if (certDer.length !== reSerialized.length) {
        console.error("FAIL: Length mismatch!");
        return;
    }

    for (let i = 0; i < certDer.length; i++) {
        if (certDer[i] !== reSerialized[i]) {
            console.error(`FAIL: Byte mismatch at offset ${i}!`);
            return;
        }
    }
    console.log("SUCCESS: Roundtrip Identity Check passed! (Bit-for-bit identical)");
}

// --- Manual DER Decoder (Using der.ts) ---

namespace DERDecoder {
    export function parsePKIMessage(data: Uint8Array): Uint8Array | null {
        console.log("\n--- Parsing Response ---");
        try {
            const root = derParse(data);
            if (!root.identifier.equals(ASN1Identifier.SEQUENCE)) {
                throw new Error("Expected SEQUENCE (PKIMessage)");
            }
            if (root.content.type !== ContentType.Constructed) {
                throw new Error("Expected constructed PKIMessage");
            }

            const nodes = root.content.value;
            const iter = nodes[Symbol.iterator]();

            // 1. PKIHeader
            const header = iter.next().value;
            if (!header) throw new Error("Missing PKIHeader");
            console.log(`  PKIHeader (${header.encodedBytes.length} bytes)`);

            // 2. PKIBody (CHOICE)
            const body = iter.next().value;
            if (!body) throw new Error("Missing PKIBody");
            console.log(`  PKIBody Tag=[${body.identifier.tagNumber}] Len=${body.encodedBytes.length}`);

            // Tag 3 (cp) = CertRepMessage
            if (body.identifier.tagClass === TagClass.ContextSpecific && body.identifier.tagNumber === 3n) {
                console.log("    Parsing CertRepMessage...");
                if (body.content.type !== ContentType.Constructed) throw new Error("CertRepMessage must be constructed");

                const bodyIter = body.content.value[Symbol.iterator]();
                let next = bodyIter.next().value;
                if (!next) throw new Error("Empty CertRepMessage");

                // Optional caPubs [1]
                if (next.identifier.tagClass === TagClass.ContextSpecific && next.identifier.tagNumber === 1n) {
                    console.log(`    Skipping caPubs [1] (${next.encodedBytes.length} bytes)`);
                    next = bodyIter.next().value;
                }

                if (!next || !next.identifier.equals(ASN1Identifier.SEQUENCE)) {
                    throw new Error("Expected SEQUENCE OF CertResponse");
                }

                if (next.content.type !== ContentType.Constructed) throw new Error("CertResponse sequence must be constructed");

                const responsesIter = next.content.value[Symbol.iterator]();
                const certResp = responsesIter.next().value;
                if (!certResp) throw new Error("Missing CertResponse");
                console.log(`      CertResponse Element (len=${certResp.encodedBytes.length} tag=${certResp.identifier.tagNumber})`);

                let contentNode = certResp;
                // Handle double wrapping if found (Tag 16 inside Tag 16)
                if (certResp.identifier.equals(ASN1Identifier.SEQUENCE) &&
                    certResp.content.type === ContentType.Constructed) {
                    const innerIter = certResp.content.value[Symbol.iterator]();
                    const firstInner = innerIter.peek();
                    if (firstInner && firstInner.identifier.equals(ASN1Identifier.SEQUENCE)) {
                        console.log("      Detected double SEQUENCE wrapping, drilling down...");
                        contentNode = innerIter.next().value!;
                    }
                }

                if (contentNode.content.type !== ContentType.Constructed) throw new Error("CertResponse content must be constructed");
                const contentIter = contentNode.content.value[Symbol.iterator]();

                const reqId = contentIter.next().value; // INTEGER
                if (!reqId) throw new Error("Missing certReqId");
                console.log(`        certReqId: tag=${reqId.identifier.tagNumber} len=${reqId.encodedBytes.length}`);

                const status = contentIter.next().value; // PKIStatusInfo
                if (!status) throw new Error("Missing statusInfo");
                console.log(`        statusInfo: tag=${status.identifier.tagNumber} len=${status.encodedBytes.length}`);

                const ckp = contentIter.next().value; // CertifiedKeyPair
                if (ckp) {
                    console.log(`        certifiedKeyPair: tag=${ckp.identifier.tagNumber} len=${ckp.encodedBytes.length}`);
                    if (ckp.content.type !== ContentType.Constructed) throw new Error("CertifiedKeyPair must be constructed");

                    const ckpIter = ckp.content.value[Symbol.iterator]();
                    const certOrEncCert = ckpIter.next().value;
                    if (!certOrEncCert) throw new Error("Missing certOrEncCert");
                    console.log(`          certOrEncCert Tag=[${certOrEncCert.identifier.tagNumber}] Class=${certOrEncCert.identifier.tagClass}`);

                    // [0] CMPCertificate (SEQUENCE)
                    if (certOrEncCert.identifier.tagClass === TagClass.ContextSpecific && certOrEncCert.identifier.tagNumber === 0n) {
                        // The content of [0] might be the Certificate itself if it was EXPLICITly tagged
                        // CMPCertificate ::= CHOICE { certificate Certificate ... }
                        // If it's EXPLICIT [0], it wraps the Certificate SEQUENCE.
                        if (certOrEncCert.content.type === ContentType.Constructed) {
                            const certIter = certOrEncCert.content.value[Symbol.iterator]();
                            const certVal = certIter.next().value;
                            if (certVal && certVal.identifier.equals(ASN1Identifier.SEQUENCE)) {
                                console.log(`            SUCCESS! Extracted Certificate (Len=${certVal.encodedBytes.length})`);
                                return certVal.encodedBytes;
                            }
                        }
                    }
                }
            } else if (body.identifier.tagNumber === 23n) {
                console.log("    Error Body content detected (tag 23).");
            }
        } catch (e) {
            console.error("Parsing failed:", e);
        }
        return null;
    }
}

// --- PBM Crypto Helpers (Web Crypto API) ---

async function deriveKey(password: Uint8Array, salt: Uint8Array, iterations: number): Promise<Uint8Array> {
    // Custom KDF: acc = H(password || salt) -> acc = H(acc) ...
    const msg = new Uint8Array(password.length + salt.length);
    msg.set(password);
    msg.set(salt, password.length);

    let acc = new Uint8Array(await crypto.subtle.digest("SHA-256", msg));

    for (let i = 1; i < iterations; i++) {
        acc = new Uint8Array(await crypto.subtle.digest("SHA-256", acc));
    }
    return acc;
}

async function calculateMAC(key: Uint8Array, data: Uint8Array): Promise<Uint8Array> {
    const cryptoKey = await crypto.subtle.importKey(
        "raw", key,
        { name: "HMAC", hash: "SHA-256" },
        false, ["sign"]
    );
    const signature = await crypto.subtle.sign("HMAC", cryptoKey, data);
    return new Uint8Array(signature);
}

function getRandomBytes(len: number): Uint8Array {
    return crypto.getRandomValues(new Uint8Array(len));
}


// --- Construction & Encoding Logic ---

async function main() {
    console.log("Constructing CA Request...");

    // 1. Generate Key Pair (ECC P-384)
    console.log("Generating Real ECDSA Key Pair (P-384)...");
    const keyPair = await crypto.subtle.generateKey(
        {
            name: "ECDSA",
            namedCurve: "P-384"
        },
        true, // extractable
        ["sign", "verify"]
    );
    const publicKey = keyPair.publicKey;
    const privateKey = keyPair.privateKey;

    // Export SPKI (SubjectPublicKeyInfo) - already DER encoded
    const spkiBuffer = await crypto.subtle.exportKey("spki", publicKey);
    const spkiDer = new Uint8Array(spkiBuffer);

    console.log("SPKI generated:", spkiDer.length, "bytes");

    // 2. Encode Contents (Inner to Outer)

    // Encode Name (Subject)
    const cnOid = DER.encodeOID("2.5.4.3");
    const cnValue = DER.encodePrintableString("robot_go");
    const cnSeq = DER.encodeSequence(DER.concat(cnOid, cnValue));
    const cnSet = DER.encodeSet(cnSeq);
    const subjectDer = DER.encodeSequence(cnSet);

    // Encode Attributes
    const attributesDer = new Uint8Array([0xA0, 0x00]);

    // Encode CertificationRequestInfo
    const versionDer = DER.encodeInteger(0);
    const infoContent = DER.concat(versionDer, subjectDer, spkiDer, attributesDer);
    const infoDer = DER.encodeSequence(infoContent);

    // 3. Signature Algorithm
    // ecdsa-with-SHA384: 1.2.840.10045.4.3.3
    const sigAlgOid = DER.encodeOID("1.2.840.10045.4.3.3");
    const sigAlgDer = DER.encodeSequence(sigAlgOid);

    // 4. Sign
    console.log("Signing CSR...");
    const rawSig = await crypto.subtle.sign(
        {
            name: "ECDSA",
            hash: { name: "SHA-384" },
        },
        privateKey,
        infoDer
    );

    // WebCrypto returns raw r|s for ECDSA (P-384 = 48 bytes r + 48 bytes s = 96 bytes)
    const rawSigBuf = new Uint8Array(rawSig);
    const r = rawSigBuf.slice(0, 48);
    const s = rawSigBuf.slice(48, 96);

    function encodeBigIntBuffer(buf: Uint8Array): Uint8Array {
        // Remove leading zeros if present (but check msb of remainder)
        // Actually, just handle MSB strictly.
        // If MSB (buf[0] & 0x80) is set, prepend 0x00.
        // Note: r and s are unsigned integers.
        // We should skip leading zeros from the buffer if we want minimal encoding, 
        // but adding 0x00 if needed is sufficient for validity.
        // However, if the buffer starts with 0x00 and the next byte is < 0x80, the 0x00 is redundant?
        // Let's just do the simple MSB check.
        // But also, if the number is small, we shouldn't output 48 bytes.
        // But P-384 signatures are usually full length.
        // Let's just prepend 00 if needed.
        if (buf[0] & 0x80) {
            return DER.concat(DER.encodeTag(0, false, 2), DER.encodeLength(buf.length + 1), new Uint8Array([0]), buf);
        }
        return DER.concat(DER.encodeTag(0, false, 2), DER.encodeLength(buf.length), buf);
    }

    const rDer = encodeBigIntBuffer(r);
    const sDer = encodeBigIntBuffer(s);
    const sigContent = DER.encodeSequence(DER.concat(rDer, sDer));
    const sigDer = DER.encodeBitString(sigContent);

    // 5. Final CertificationRequest
    const csrContent = DER.concat(infoDer, sigAlgDer, sigDer);
    const csrDer = DER.encodeSequence(csrContent);

    console.log(`CSR Encoded. Length: ${csrDer.length} bytes`);

    // --- WRAP IN PKIMESSAGE (CMP) ---
    console.log("Wrapping in PKIMessage with PBM Protection...");

    // 1. Header
    // GeneralName: dNSName [2] IMPLICIT IA5String
    function encodeDNSName(name: string): Uint8Array {
        const encoder = new TextEncoder();
        const content = encoder.encode(name);
        return DER.concat(new Uint8Array([0x82]), DER.encodeLength(content.length), content);
    }

    const sender = encodeDNSName("robot_go");
    const recipient = encodeDNSName("localhost");
    const pvno = DER.encodeInteger(2);

    // TransactionID and Nonce
    const rawTransID = getRandomBytes(16);
    const rawSenderNonce = getRandomBytes(16);

    // PBM Protection Setup
    const pbmOID = DER.encodeOID("1.2.840.113533.7.66.13");
    const salt = getRandomBytes(16);
    const iterationCount = 10000;

    // AlgorithmIdentifiers for OWF and MAC
    // OWF: sha256 (2.16.840.1.101.3.4.2.1)
    const owfAlgSimple = DER.encodeSequence(DER.encodeOID("2.16.840.1.101.3.4.2.1"));

    // MAC: hmacWithSHA256 (1.2.840.113549.2.9)
    const macAlgSimple = DER.encodeSequence(DER.encodeOID("1.2.840.113549.2.9"));

    // PBMParameter ::= SEQUENCE { salt OCTET STRING, owf AlgorithmIdentifier, iterationCount INTEGER, mac AlgorithmIdentifier }
    const pbmParams = DER.encodeSequence(DER.concat(
        DER.encodeOctetString(salt),
        owfAlgSimple,
        DER.encodeInteger(iterationCount),
        macAlgSimple
    ));

    // ProtectionAlg = AlgorithmIdentifier { algorithm pbmOID, parameters pbmParams }
    const protectionAlg = DER.encodeSequence(DER.concat(pbmOID, pbmParams));

    // Header Fields:
    // pvno, sender, recipient, messageTime [0]?, protectionAlg [1]?, senderKID [2], recipKID [3], transID [4], senderNonce [5], ...
    // Note: protectionAlg is [1] EXPLICIT AlgorithmIdentifier OPTIONAL
    const protectionAlgTagged = DER.encodeContextSpecific(1, protectionAlg, true);

    // transID is [4] OCTET STRING OPTIONAL.
    // Server error suggests it expects EXPLICIT tagging (trying to decode the content).
    // So we assume [4] EXPLICIT OCTET STRING.
    // DER.encodeContextSpecific(4, transID, true) -> A4 Length (04 Length Value)
    const transIDTagged = DER.encodeContextSpecific(4, DER.encodeOctetString(rawTransID), true);
    const senderNonceTagged = DER.encodeContextSpecific(5, DER.encodeOctetString(rawSenderNonce), true);

    const headerContent = DER.concat(pvno, sender, recipient, protectionAlgTagged, transIDTagged, senderNonceTagged);
    const headerDer = DER.encodeSequence(headerContent);

    // 2. Body
    const bodyDer = DER.encodeContextSpecific(4, csrDer, true);

    // 3. Calculate Protection
    // Input: DER(ProtectedPart)
    // ProtectedPart ::= SEQUENCE { header PKIHeader, body PKIBody }
    // Matching Go implementation: Wrap in SEQUENCE.
    const protectedPartContent = DER.concat(headerDer, bodyDer);
    const protectedPart = DER.encodeSequence(protectedPartContent);

    // Key Derivation
    const password = new TextEncoder().encode("0000"); // Use U8Array
    const key = await deriveKey(password, salt, iterationCount);
    const mac = await calculateMAC(key, protectedPart);

    console.log("Calculated MAC:", toHex(mac));

    const protectionDer = DER.encodeBitString(mac);

    // Protection is [0] BIT STRING OPTIONAL
    // Server expects [0] tag.
    // Likely [0] EXPLICIT PKIProtection
    const protectionTagged = DER.encodeContextSpecific(0, protectionDer, true);

    // 4. PKIMessage
    // Msg = SEQUENCE { header, body, protection }
    const msgContent = DER.concat(headerDer, bodyDer, protectionTagged);
    const msgDer = DER.encodeSequence(msgContent);

    console.log(`PKIMessage Encoded. Length: ${msgDer.length} bytes`);
    console.log(`  Header: ${headerDer.length}`);
    console.log(`  Body: ${bodyDer.length}`);
    console.log(`  Protection (Tagged): ${protectionTagged.length}`);
    console.log("Full Msg Hex:", toHex(msgDer));


    // --- SEND TO CA ---
    console.log("\nSending PKIMessage to CA at http://localhost:8829/...");

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000); // Increased timeout to 5s

    try {
        const response = await fetch("http://localhost:8829/", {
            method: "POST",
            headers: {
                "Content-Type": "application/pkixcmp",
                "Connection": "close"
            },
            body: msgDer,
            signal: controller.signal
        });
        clearTimeout(timeoutId);

        console.log(`Response Status: ${response.status} ${response.statusText}`);

        // Log Headers
        response.headers.forEach((val, key) => {
            console.log(`Header [${key}]: ${val}`);
        });

        // Read Response Body Stream
        console.log("Reading response body stream...");
        const reader = response.body?.getReader();
        const chunks: Uint8Array[] = [];
        let totalLength = 0;

        if (reader) {
            while (true) {
                const { done, value } = await reader.read();
                if (done) {
                    console.log("Stream complete.");
                    break;
                }
                if (value) {
                    console.log(`Received chunk: ${value.length} bytes`);
                    chunks.push(value);
                    totalLength += value.length;

                    // Attempt Parsing on accumulated data
                    const currentData = new Uint8Array(totalLength);
                    let off = 0;
                    for (const c of chunks) {
                        currentData.set(c, off);
                        off += c.length;
                    }

                    try {
                        console.log(`Attempting to parse ${currentData.length} bytes...`);
                        const certBytes = DERDecoder.parsePKIMessage(currentData);

                        if (certBytes) {
                            console.log("Certificate extracted!");

                            // Save to PEM/DER
                            const b64 = toBase64(certBytes);
                            const pem = `-----BEGIN CERTIFICATE-----\n${b64.match(/.{1,64}/g)?.join('\n')}\n-----END CERTIFICATE-----\n`;

                            console.log("\n" + pem);

                            // @ts-ignore
                            if (typeof Bun !== 'undefined') {
                                // @ts-ignore
                                await Bun.write("robot_go.crt", pem);
                                // @ts-ignore
                                await Bun.write("robot_go.der", certBytes);
                                console.log("Saved to robot_go.crt and robot_go.der");
                            }

                            console.log("Parsing successful! Starting roundtrip test...");
                            await runCertificateRoundtrip(certBytes);
                            reader.cancel(); // Stop reading
                            break;
                        }
                    } catch (e) {
                        // Incomplete data, keep reading
                        console.log("Parsing incomplete or failed:", e);
                    }
                }
            }
        }

        const responseArray = new Uint8Array(totalLength);
        let offset = 0;
        for (const chunk of chunks) {
            responseArray.set(chunk, offset);
            offset += chunk.length;
        }

        console.log(`Total Received: ${responseArray.length} bytes.`);

        if (responseArray.length > 0) {
            // console.log("Response Body Hex:", Buffer.from(responseArray).toString('hex'));
            try {
                DERDecoder.parsePKIMessage(responseArray);
            } catch (err) {
                console.error("Failed to parse response:", err);
                console.log("Raw Hex:", toHex(responseArray));
            }
        }
    } catch (err) {
        console.error("Request failed:", err);
    }
}

main().catch(console.error);
