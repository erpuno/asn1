#!/usr/bin/env bun
/**
 * OpenSSL Comparison Tests for TypeScript ASN.1 Implementation
 * Self-contained version with inline DER parser.
 * 
 * Usage:
 *   bun run openssl_test.ts parse-key <file.der>
 *   bun run openssl_test.ts parse-csr <file.der>
 *   bun run openssl_test.ts parse-cert <file.der>
 */

// --- Minimal DER Parser & Serializer ---

interface ASN1Node {
    tagClass: number;
    tagNumber: number;
    constructed: boolean;
    content: Uint8Array | ASN1Node[];
    encodedBytes: Uint8Array;
}

function parseDER(data: Uint8Array, offset: number = 0): { node: ASN1Node; bytesRead: number } {
    const start = offset;

    // Parse identifier
    const firstByte = data[offset++];
    const tagClass = (firstByte >> 6) & 0x03;
    const constructed = (firstByte & 0x20) !== 0;
    let tagNumber = firstByte & 0x1f;

    if (tagNumber === 0x1f) {
        // Long form tag
        tagNumber = 0;
        let b: number;
        do {
            b = data[offset++];
            tagNumber = (tagNumber << 7) | (b & 0x7f);
        } while (b & 0x80);
    }

    // Parse length
    let length: number;
    const lenByte = data[offset++];
    if (lenByte < 128) {
        length = lenByte;
    } else {
        const numBytes = lenByte & 0x7f;
        length = 0;
        for (let i = 0; i < numBytes; i++) {
            length = (length << 8) | data[offset++];
        }
    }

    const contentStart = offset;
    const contentEnd = offset + length;
    const contentBytes = data.slice(contentStart, contentEnd);

    let content: Uint8Array | ASN1Node[];

    if (constructed) {
        content = [];
        let pos = 0;
        while (pos < contentBytes.length) {
            const { node, bytesRead } = parseDER(contentBytes, pos);
            content.push(node);
            pos += bytesRead;
        }
    } else {
        content = contentBytes;
    }

    return {
        node: {
            tagClass,
            tagNumber,
            constructed,
            content,
            encodedBytes: data.slice(start, contentEnd)
        },
        bytesRead: contentEnd - start
    };
}

function serializeDER(node: ASN1Node): Uint8Array {
    const parts: Uint8Array[] = [];

    // Serialize identifier
    let firstByte = (node.tagClass << 6) | (node.constructed ? 0x20 : 0);
    if (node.tagNumber < 31) {
        firstByte |= node.tagNumber;
        parts.push(new Uint8Array([firstByte]));
    } else {
        firstByte |= 0x1f;
        parts.push(new Uint8Array([firstByte]));
        const tagBytes: number[] = [];
        let tn = node.tagNumber;
        tagBytes.unshift(tn & 0x7f);
        while (tn >= 128) {
            tn >>= 7;
            tagBytes.unshift((tn & 0x7f) | 0x80);
        }
        parts.push(new Uint8Array(tagBytes));
    }

    // Get content bytes
    let contentBytes: Uint8Array;
    if (node.constructed) {
        const children = node.content as ASN1Node[];
        const childParts = children.map(serializeDER);
        let total = 0;
        for (const cp of childParts) total += cp.length;
        contentBytes = new Uint8Array(total);
        let off = 0;
        for (const cp of childParts) {
            contentBytes.set(cp, off);
            off += cp.length;
        }
    } else {
        contentBytes = node.content as Uint8Array;
    }

    // Serialize length
    const len = contentBytes.length;
    if (len < 128) {
        parts.push(new Uint8Array([len]));
    } else {
        const lenBytes: number[] = [];
        let l = len;
        while (l > 0) {
            lenBytes.unshift(l & 0xff);
            l >>= 8;
        }
        parts.push(new Uint8Array([0x80 | lenBytes.length]));
        parts.push(new Uint8Array(lenBytes));
    }

    parts.push(contentBytes);

    // Concat all parts
    let total = 0;
    for (const p of parts) total += p.length;
    const result = new Uint8Array(total);
    let off = 0;
    for (const p of parts) {
        result.set(p, off);
        off += p.length;
    }

    return result;
}

// --- Helpers ---

function toHex(arr: Uint8Array): string {
    return Array.from(arr).map(b => b.toString(16).padStart(2, '0')).join('');
}

async function parseAndRoundtrip(filePath: string, typeName: string): Promise<boolean> {
    console.log(`\n--- Testing ${typeName} ---`);

    // Read file
    const file = Bun.file(filePath);
    const data = new Uint8Array(await file.arrayBuffer());
    console.log(`Reading ${typeName} from ${filePath} (${data.length} bytes)`);

    // Parse
    const { node } = parseDER(data);
    console.log(`Parsed ${typeName}: TagClass=${node.tagClass}, Tag=${node.tagNumber}, Constructed=${node.constructed}`);

    // Re-serialize
    const encoded = serializeDER(node);
    console.log(`Re-serialized: ${encoded.length} bytes`);

    // Compare
    if (data.length !== encoded.length) {
        console.error(`FAILURE: Length mismatch! Original=${data.length}, Encoded=${encoded.length}`);

        // Save mismatch for debugging
        await Bun.write(filePath.replace('.der', '_mismatch.der'), encoded);
        console.log(`Saved mismatch to ${filePath.replace('.der', '_mismatch.der')}`);
        return false;
    }

    for (let i = 0; i < data.length; i++) {
        if (data[i] !== encoded[i]) {
            console.error(`FAILURE: Byte mismatch at offset ${i}!`);
            console.error(`  Original: ${toHex(data.slice(Math.max(0, i - 5), i + 10))}`);
            console.error(`  Encoded:  ${toHex(encoded.slice(Math.max(0, i - 5), i + 10))}`);

            await Bun.write(filePath.replace('.der', '_mismatch.der'), encoded);
            return false;
        }
    }

    console.log(`SUCCESS: ${typeName} Round-trip matches.`);
    return true;
}

async function main() {
    const args = process.argv.slice(2);

    if (args.length === 0) {
        console.log("TypeScript ASN.1 OpenSSL Comparison Tests");
        console.log("Usage:");
        console.log("  bun run openssl_test.ts parse-key <file.der>");
        console.log("  bun run openssl_test.ts parse-csr <file.der>");
        console.log("  bun run openssl_test.ts parse-cert <file.der>");
        process.exit(0);
    }

    const command = args[0];
    const filePath = args[1];

    if (!filePath) {
        console.error("Error: Missing file path argument");
        process.exit(1);
    }

    let success = false;

    switch (command) {
        case "parse-key":
            success = await parseAndRoundtrip(filePath, "PrivateKey (PKCS#8)");
            break;
        case "parse-csr":
            success = await parseAndRoundtrip(filePath, "CSR (PKCS#10)");
            break;
        case "parse-cert":
            success = await parseAndRoundtrip(filePath, "Certificate (X.509)");
            break;
        case "parse-crl":
            success = await parseAndRoundtrip(filePath, "CRL (X.509)");
            break;
        default:
            console.error(`Unknown command: ${command}`);
            process.exit(1);
    }

    if (!success) {
        process.exit(1);
    }
}

main().catch(err => {
    console.error("Error:", err);
    process.exit(1);
});
