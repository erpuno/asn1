
import { Serializer, parse as derParse, ASN1Node, ASN1Identifier, TagClass } from "./der.ts/src/der";
import { ASN1Integer } from "./der.ts/src/types/integer";
import { ASN1ObjectIdentifier } from "./der.ts/src/types/object_identifier";
import { ASN1OctetString } from "./der.ts/src/types/octet_string";
import { ASN1BitString } from "./der.ts/src/types/bit_string";
import { ASN1PrintableString, ASN1IA5String, ASN1UTF8String } from "./der.ts/src/types/strings";
import { ASN1Null } from "./der.ts/src/types/null";

// PKCS#10
import { PKCS_10_CertificationRequest } from "./generated/PKCS_10_CertificationRequest";
import { PKCS_10_CertificationRequestInfo } from "./generated/PKCS_10_CertificationRequestInfo";
// PKCS_10_AlgorithmIdentifier not found, using PKIX1Explicit88_AlgorithmIdentifier
import { PKCS_10_Attributes } from "./generated/PKCS_10_Attributes";

// PKIX1Explicit (Name)
import { PKIX1Explicit_2009_Name } from "./generated/PKIX1Explicit_2009_Name";
import { PKIX1Explicit_2009_RDNSequence } from "./generated/PKIX1Explicit_2009_RDNSequence";
import { PKIX1Explicit_2009_RelativeDistinguishedName } from "./generated/PKIX1Explicit_2009_RelativeDistinguishedName";
import { PKIX1Explicit88_AttributeTypeAndValue } from "./generated/PKIX1Explicit88_AttributeTypeAndValue";
import { PKIX1Explicit88_AttributeType } from "./generated/PKIX1Explicit88_AttributeType";
import { PKIX1Explicit88_AttributeValue } from "./generated/PKIX1Explicit88_AttributeValue";

// PKIX1Explicit88 (SPKI)
import { PKIX1Explicit88_SubjectPublicKeyInfo } from "./generated/PKIX1Explicit88_SubjectPublicKeyInfo";

// CMP
import { PKIXCMP_2009_PKIMessage } from "./generated/PKIXCMP_2009_PKIMessage";
import { PKIXCMP_2009_PKIHeader } from "./generated/PKIXCMP_2009_PKIHeader";
import { PKIXCMP_2009_PKIBody } from "./generated/PKIXCMP_2009_PKIBody";
import { PKIXCMP_2009_PKIProtection } from "./generated/PKIXCMP_2009_PKIProtection";
import { PKIXCMP_2009_InfoTypeAndValue } from "./generated/PKIXCMP_2009_InfoTypeAndValue";
import { PKIX1Implicit_2009_GeneralName } from "./generated/PKIX1Implicit_2009_GeneralName";
import { PKIX1Explicit88_AlgorithmIdentifier } from "./generated/PKIX1Explicit88_AlgorithmIdentifier";

// --- Helpers ---

function toHex(arr: Uint8Array): string {
    return Array.from(arr).map(b => b.toString(16).padStart(2, '0')).join('');
}

function toBase64(arr: Uint8Array): string {
    const binary = Array.from(arr, b => String.fromCharCode(b)).join('');
    return btoa(binary);
}

// Helper to wrap primitive in ASN1Node for ANY fields
function wrapAny(val: any): ASN1Node {
    const s = new Serializer();
    val.serialize(s);
    const bytes = s.serializedBytes();
    // Parse back to get a node - inefficient but safe for ANY
    return derParse(bytes);
}

// --- PBM Crypto Helpers (Web Crypto API) ---
async function deriveKey(password: Uint8Array, salt: Uint8Array, iterations: number): Promise<Uint8Array> {
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

// --- Main ---

async function main() {
    console.log("Constructing CA Request using Generated Structures...");

    // 1. Generate Key Pair (ECDSA P-384)
    console.log("Generating ECDSA P-384 Key Pair...");
    const keyPair = await crypto.subtle.generateKey(
        { name: "ECDSA", namedCurve: "P-384" },
        true, ["sign", "verify"]
    );
    const spkiBuffer = await crypto.subtle.exportKey("spki", keyPair.publicKey);
    const spkiDer = new Uint8Array(spkiBuffer);

    // Parse SPKI using generated class
    const spki = PKIX1Explicit88_SubjectPublicKeyInfo.fromDERNode(derParse(spkiDer));

    // 2. Construct Info
    console.log("Constructing CertificationRequestInfo...");

    // Subject Name: CN=robot_go
    const atv = new PKIX1Explicit88_AttributeTypeAndValue(
        new PKIX1Explicit88_AttributeType(ASN1ObjectIdentifier.fromComponents([2n, 5n, 4n, 3n])), // commonName
        new PKIX1Explicit88_AttributeValue(wrapAny(new ASN1PrintableString("robot_go")))
    );
    const rdn = new PKIX1Explicit_2009_RelativeDistinguishedName();
    rdn.push(atv);
    const rdnSeq = new PKIX1Explicit_2009_RDNSequence();
    rdnSeq.push(rdn);
    const subject = new PKIX1Explicit_2009_Name();
    subject.rdnsequence = rdnSeq;

    // Attributes (Empty)
    const attributes = new PKCS_10_Attributes();

    const info = new PKCS_10_CertificationRequestInfo(
        new ASN1Integer(0n),
        subject,
        spki,
        attributes
    );

    // Serialize Info to sign it
    const infoSerializer = new Serializer();
    info.serialize(infoSerializer);
    const infoBytes = infoSerializer.serializedBytes();

    // 3. Sign
    console.log("Signing...");
    // 1.2.840.10045.4.3.3 ecdsa-with-SHA384
    const sigAlg = new PKIX1Explicit88_AlgorithmIdentifier("1.2.840.10045.4.3.3");

    const rawSig = await crypto.subtle.sign(
        { name: "ECDSA", hash: { name: "SHA-384" } },
        keyPair.privateKey,
        infoBytes
    );
    const rawSigBuf = new Uint8Array(rawSig);

    // Convert R|S to DER SEQUENCE
    const r = rawSigBuf.slice(0, 48);
    const s = rawSigBuf.slice(48, 96);
    const sigSeqSerializer = new Serializer();
    sigSeqSerializer.writeSequence((nested) => {
        new ASN1Integer(BigInt("0x" + toHex(r))).serialize(nested);
        new ASN1Integer(BigInt("0x" + toHex(s))).serialize(nested);
    });
    const sigDerBytes = sigSeqSerializer.serializedBytes();
    const signature = new ASN1BitString(sigDerBytes, 0);

    // 4. CertificationRequest
    const csr = new PKCS_10_CertificationRequest(info, sigAlg, signature);

    const csrSerializer = new Serializer();
    csr.serialize(csrSerializer);
    const csrBytes = csrSerializer.serializedBytes();
    console.log(`CSR constructed. Length: ${csrBytes.length}`);


    // --- CMP PKIMessage ---
    console.log("Wrapping in CMP PKIMessage...");

    // Header
    const sender = new PKIX1Implicit_2009_GeneralName();
    sender.dnsname = "robot_go"; // dNSName [2] IMPLICIT IA5String

    const recipient = new PKIX1Implicit_2009_GeneralName();
    recipient.dnsname = "localhost";

    // Protection Alg: 
    // PBMParameter ::= SEQUENCE { salt OCTET STRING, owf AlgorithmIdentifier, iterationCount INTEGER, mac AlgorithmIdentifier }
    const salt = getRandomBytes(16);
    const owf = new PKIX1Explicit88_AlgorithmIdentifier("2.16.840.1.101.3.4.2.1"); // sha256
    const macAlg = new PKIX1Explicit88_AlgorithmIdentifier("1.2.840.113549.2.9"); // hmacWithSHA256

    // We need PBMParameter class but simpler to construct manually via ANY if needed, or use generated if available.
    // PKIXCMP_2009_PBMParameter.ts matches.
    // But check if it's imported? I didn't import it.
    // Let's rely on manual sequence for params to save import search, or wrapAny using manual construction.
    const pbmParamSerializer = new Serializer();
    pbmParamSerializer.writeSequence((s) => {
        new ASN1OctetString(salt).serialize(s);
        owf.serialize(s);
        new ASN1Integer(10000n).serialize(s);
        macAlg.serialize(s);
    });
    const pbmParamsNode = derParse(pbmParamSerializer.serializedBytes());

    const protectionAlg = new PKIX1Explicit88_AlgorithmIdentifier("1.2.840.113533.7.66.13", pbmParamsNode);

    const header = new PKIXCMP_2009_PKIHeader(
        new ASN1Integer(2n),    // pvno
        sender,
        recipient
    );
    // Optional Header fields
    // protectionAlg [1] EXPLICIT
    header.protectionalg = protectionAlg;

    // transactionID [4] OCTET STRING
    const transID = getRandomBytes(16);
    header.transactionid = transID; // Generated expects Uint8Array directly, or wrapping?
    // Generated: public transactionid?: Uint8Array
    // Serialization: new ASN1OctetString(this.transactionid).serialize
    // So just assign bytes.

    // senderNonce [5] OCTET STRING
    const nonce = getRandomBytes(16);
    header.sendernonce = nonce;

    // Body
    const body = new PKIXCMP_2009_PKIBody();
    body.p10cr = csr; // [4] CertificationRequest

    // ProtectedPart for MAC calc
    // ProtectedPart ::= SEQUENCE { header PKIHeader, body PKIBody }
    const protectedPartSerializer = new Serializer();
    protectedPartSerializer.writeSequence((s) => {
        header.serialize(s);
        body.serialize(s);
    });
    const protectedPartBytes = protectedPartSerializer.serializedBytes();

    // Mac Calc
    const password = new TextEncoder().encode("0000");
    const key = await deriveKey(password, salt, 10000);
    const mac = await calculateMAC(key, protectedPartBytes);

    const protection = new PKIXCMP_2009_PKIProtection(new ASN1BitString(mac, 0));

    // PKIMessage
    const msg = new PKIXCMP_2009_PKIMessage(
        header,
        body,
        protection
    );

    const msgSerializer = new Serializer();
    msg.serialize(msgSerializer);
    const msgBytes = msgSerializer.serializedBytes();

    console.log(`PKIMessage constructed. Length: ${msgBytes.length}`);

    // --- Send ---
    console.log("\nSending to CA...");

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 10000);

    try {
        const response = await fetch("http://localhost:8829/", {
            method: "POST",
            headers: { "Content-Type": "application/pkixcmp", "Connection": "close" },
            body: msgBytes,
            signal: controller.signal
        });
        clearTimeout(timeout);

        console.log(`Response: ${response.status} ${response.statusText}`);
        if (!response.body) return;

        // Collect body
        const buffer = await response.arrayBuffer();
        const combined = new Uint8Array(buffer);
        console.log(`Received ${combined.length} bytes.`);

        try {
            const respRoot = derParse(combined);
            const respMsg = PKIXCMP_2009_PKIMessage.fromDERNode(respRoot);
            console.log("PKIMessage Parsed Successfully!");

            if (respMsg.body.cp) {
                console.log("Received CertRepMessage");
                const cp = respMsg.body.cp;
                if (cp.response && cp.response.length > 0) {
                    const certResp = cp.response[0];
                    console.log("certResp status:", certResp.status);

                    if (certResp.certifiedkeypair) {
                        const ckp = certResp.certifiedkeypair;
                        console.log("ckp certOrEncCert:", ckp.certorenccert);
                        if (ckp.certorenccert) {
                            const coec = ckp.certorenccert;
                            console.log("coec certificate:", coec.certificate);
                            console.log("coec encryptedCert:", coec.encryptedcert);

                            if (coec.certificate) {
                                console.log("Extracted Certificate!");
                                const certObj = coec.certificate;
                                // Serialize it to get bytes
                                const certS = new Serializer();
                                (certObj as any).serialize(certS);
                                const certDer = certS.serializedBytes();

                                const b64 = toBase64(certDer);
                                const pem = `-----BEGIN CERTIFICATE-----\n${b64.match(/.{1,64}/g)?.join('\n')}\n-----END CERTIFICATE-----\n`;
                                console.log(pem);

                                // Write file if bun
                                // @ts-ignore
                                if (typeof Bun !== 'undefined') {
                                    // @ts-ignore
                                    await Bun.write("robot_go_gen.crt", pem);
                                }
                                return; // Done
                            }
                        }
                    }
                }
            } else if (respMsg.body.error) {
                console.log("Received Error Message");
            } else {
                console.log("Received other body type:", Object.keys(respMsg.body));
            }

        } catch (e) {
            console.error("Failed to parse response:", e);
        }

    } catch (e) {
        console.error("Error:", e);
    }
}

main().catch(console.error);
