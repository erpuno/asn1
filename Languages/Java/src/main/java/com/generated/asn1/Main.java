package com.generated.asn1;

import org.bouncycastle.asn1.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.Arrays;

public class Main {

    public static void main(String[] args) {
        System.out.println("Starting ASN.1 Demo (Enhanced API)...");

        // Ensure clean state
        try {
            Files.deleteIfExists(Path.of("generated_cert.der"));
            Files.deleteIfExists(Path.of("saved_cert.der"));
        } catch (IOException e) {
            e.printStackTrace();
        }

        demonstrateCertificateParsing();
        demonstrateCertificateCreation();
    }

    private static void demonstrateCertificateParsing() {
        System.out.println("\n=== Certificate Parsing/Saving Demo ===");
        try {
            Path path = Path.of("clean.der"); // Or any valid cert file
            if (!Files.exists(path)) {
                System.out.println("clean.der not found, skipping parsing existing file.");
                return;
            }

            // High-level API usage: .parse(byte[])
            byte[] data = Files.readAllBytes(path);
            System.out.println("Read " + data.length + " bytes from " + path);

            AuthenticationFramework_Certificate cert = AuthenticationFramework_Certificate.parse(data);
            System.out.println("Parsed Certificate: " + cert.getClass().getSimpleName());

            // High-level API usage: .serialize()
            byte[] encoded = cert.serialize();
            Files.write(Path.of("saved_cert.der"), encoded);
            System.out.println("Saved " + encoded.length + " bytes to saved_cert.der");

        } catch (IOException e) {
            System.err.println("Parsing failed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void demonstrateCertificateCreation() {
        System.out.println("\n=== Certificate Creation Demo ===");
        try {
            // 1. TBSCertificate
            // We use the generated Builder
            AuthenticationFramework_Certificate_toBeSigned.Builder tbsBuilder = AuthenticationFramework_Certificate_toBeSigned
                    .builder();

            // version: [0] EXPLICIT Version DEFAULT v1 (2)
            tbsBuilder.version(new DERTaggedObject(true, 0, new ASN1Integer(2)));

            // serialNumber
            tbsBuilder.serialnumber(new AuthenticationFramework_CertificateSerialNumber(new ASN1Integer(1234567890L)));

            // signature (AlgorithmIdentifier)
            ASN1EncodableVector algoVector = new ASN1EncodableVector();
            algoVector.add(new ASN1ObjectIdentifier("1.2.840.113549.1.1.11")); // sha256WithRSAEncryption
            algoVector.add(DERNull.INSTANCE);
            AuthenticationFramework_AlgorithmIdentifier algoId = new AuthenticationFramework_AlgorithmIdentifier(
                    new DERSequence(algoVector));
            tbsBuilder.signature(algoId);

            // issuer (Name) - simplified
            ASN1EncodableVector issuerVector = new ASN1EncodableVector();
            ASN1EncodableVector rdnVector = new ASN1EncodableVector();
            ASN1EncodableVector avaVector = new ASN1EncodableVector();
            avaVector.add(new ASN1ObjectIdentifier("2.5.4.3")); // CN
            avaVector.add(new DERPrintableString("Test CA"));
            rdnVector.add(new DERSet(new DERSequence(avaVector)));
            issuerVector.add(new DERSet(rdnVector)); // RDNSequence
            InformationFramework_Name issuer = new InformationFramework_Name(new DERSequence(issuerVector));
            tbsBuilder.issuer(issuer);

            // validity
            ASN1EncodableVector validityVector = new ASN1EncodableVector();
            validityVector.add(new ASN1UTCTime("230101000000Z"));
            validityVector.add(new ASN1UTCTime("240101000000Z"));
            AuthenticationFramework_Validity validity = new AuthenticationFramework_Validity(
                    new DERSequence(validityVector));
            tbsBuilder.validity(validity);

            // subject (Name) - same as issuer
            tbsBuilder.subject(issuer);

            // subjectPublicKeyInfo
            ASN1EncodableVector spkiVector = new ASN1EncodableVector();
            spkiVector.add(algoId); // Algorithm
            spkiVector.add(new DERBitString(new byte[] { 0x01, 0x02, 0x03 })); // PublicKey
            AuthenticationFramework_SubjectPublicKeyInfo spki = new AuthenticationFramework_SubjectPublicKeyInfo(
                    new DERSequence(spkiVector));
            tbsBuilder.subjectpublickeyinfo(spki);

            AuthenticationFramework_Certificate_toBeSigned tbsCert = tbsBuilder.build();

            // 2. Signature Algorithm
            AuthenticationFramework_AlgorithmIdentifier sigAlgo = algoId;

            // 3. Signature Value
            DERBitString sigValue = new DERBitString(new byte[] { (byte) 0xAA, (byte) 0xBB });

            // Wrap basic types in generated classes helps readability if possible,
            // but for top-level Sequence construction, we do this:

            AuthenticationFramework_Certificate cert = AuthenticationFramework_Certificate.builder()
                    .tobesigned(tbsCert)
                    .algorithmidentifier(sigAlgo)
                    .encrypted(sigValue)
                    .build();

            System.out.println("Constructed Certificate object: " + cert);

            // High-level API usage: .serialize()
            byte[] encoded = cert.serialize();
            Files.write(Path.of("generated_cert.der"), encoded);
            System.out.println("Saved " + encoded.length + " bytes to generated_cert.der");

            // Verify Round-Trip using High-Level API
            AuthenticationFramework_Certificate parsedCert = AuthenticationFramework_Certificate.parse(encoded);
            System.out.println("Parsed Back Created Certificate: " + parsedCert.getClass().getSimpleName());

            // Check content equality
            if (Arrays.equals(encoded, parsedCert.serialize())) {
                System.out.println("SUCCESS: Round-Trip serialisation matches.");
            } else {
                System.out.println("FAILURE: Serialized bytes do not match.");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
