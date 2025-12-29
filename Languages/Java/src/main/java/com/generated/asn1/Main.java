package com.generated.asn1;

import org.bouncycastle.asn1.*;
import org.bouncycastle.asn1.x509.*;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Enumeration;

public class Main {
    public static void main(String[] args) {
        System.out.println("Starting ASN.1 Demo (Bouncy Castle Edition)...");

        // Ensure clean state
        try {
            Files.deleteIfExists(Path.of("generated_cert.der"));
            Files.deleteIfExists(Path.of("saved_cert.der"));
        } catch (IOException e) {
            e.printStackTrace();
        }

        demonstrateCertificateParsing();
        testSimpleParsing();
        demonstrateCertificateCreation();
    }

    private static void demonstrateCertificateParsing() {
        System.out.println("\n=== Certificate Parsing/Saving Demo ===");
        try {
            // Read DER file
            java.io.File file = new java.io.File("clean.der");
            // Fallback to test.der if clean.der missing
            if (!file.exists()) {
                file = new java.io.File("test_bc.der");
            }

            if (!file.exists()) {
                System.out.println("Certificate file not found: " + file.getAbsolutePath());
                // We create one to ensure demo flow
                testSimpleParsing();
                file = new java.io.File("test_bc.der");
            }

            byte[] certDer = Files.readAllBytes(file.toPath());
            System.out.println("Read " + certDer.length + " bytes from " + file.getName());

            // Parse DER
            ASN1InputStream ais = new ASN1InputStream(certDer);
            ASN1Primitive asn1Obj = ais.readObject();
            ais.close();

            // Wrap in generated Certificate class
            // Check if it matches structure roughly
            if (asn1Obj instanceof ASN1Sequence) {
                try {
                    AuthenticationFramework_Certificate cert = new AuthenticationFramework_Certificate(
                            (ASN1Sequence) asn1Obj);
                    System.out.println("Parsed Certificate: " + cert.getClass().getSimpleName());

                    // Save back to file
                    byte[] savedDer = serialize(cert.toASN1Primitive());
                    Files.write(Path.of("saved_cert.der"), savedDer);
                    System.out.println("Saved " + savedDer.length + " bytes to saved_cert.der");
                } catch (Exception e) {
                    System.out.println("Failed to wrap in Certificate class (expected structure mismatch?): " + e);
                }
            } else {
                System.out.println("Error: parsed object is not a SEQUENCE");
            }

        } catch (Exception e) {
            System.out.println("Parsing Demo Failed: " + e);
            e.printStackTrace();
        }
    }

    private static void demonstrateCertificateCreation() {
        System.out.println("\n=== Certificate Creation Demo ===");
        try {
            // 1. TBSCertificate
            ASN1EncodableVector tbsVector = new ASN1EncodableVector();

            // version: [0] EXPLICIT Version DEFAULT v1
            // We use v3 (2)
            tbsVector.add(new DERTaggedObject(true, 0, new ASN1Integer(2)));

            // serialNumber
            tbsVector.add(new ASN1Integer(1234567890L));

            // signature (AlgorithmIdentifier)
            ASN1EncodableVector algoVector = new ASN1EncodableVector();
            algoVector.add(new ASN1ObjectIdentifier("1.2.840.113549.1.1.11")); // sha256WithRSAEncryption
            algoVector.add(DERNull.INSTANCE);
            tbsVector.add(new DERSequence(algoVector));

            // issuer (Name) - simplified
            ASN1EncodableVector issuerVector = new ASN1EncodableVector();
            ASN1EncodableVector rdnVector = new ASN1EncodableVector();
            ASN1EncodableVector avaVector = new ASN1EncodableVector();
            avaVector.add(new ASN1ObjectIdentifier("2.5.4.3")); // CN
            avaVector.add(new DERPrintableString("Test CA"));
            rdnVector.add(new DERSet(new DERSequence(avaVector)));
            issuerVector.add(new DERSet(rdnVector)); // RDNSequence
            tbsVector.add(new DERSequence(issuerVector));

            // validity
            ASN1EncodableVector validityVector = new ASN1EncodableVector();
            validityVector.add(new ASN1UTCTime("230101000000Z"));
            validityVector.add(new ASN1UTCTime("240101000000Z"));
            tbsVector.add(new DERSequence(validityVector));

            // subject (Name) - same as issuer
            tbsVector.add(new DERSequence(issuerVector));

            // subjectPublicKeyInfo
            ASN1EncodableVector spkiVector = new ASN1EncodableVector();
            spkiVector.add(new DERSequence(algoVector)); // Algorithm
            spkiVector.add(new DERBitString(new byte[] { 0x01, 0x02, 0x03 })); // PublicKey
            tbsVector.add(new DERSequence(spkiVector));

            // extensions - optional, skip for now to simplify
            // If we added extensions, it would be [3] EXPLICIT Extensions

            DERSequence tbsCert = new DERSequence(tbsVector);

            // 2. Signature Algorithm
            DERSequence sigAlgo = new DERSequence(algoVector);

            // 3. Signature Value
            DERBitString sigValue = new DERBitString(new byte[] { (byte) 0xAA, (byte) 0xBB });

            // Complete Certificate Sequence
            ASN1EncodableVector certVector = new ASN1EncodableVector();
            certVector.add(tbsCert);
            certVector.add(sigAlgo);
            certVector.add(sigValue);

            DERSequence certSeq = new DERSequence(certVector);

            System.out.println("Constructed Certificate Sequence: " + certSeq);

            // Serialize
            byte[] encoded = certSeq.getEncoded("DER");
            Files.write(Path.of("generated_cert.der"), encoded);
            System.out.println("Saved " + encoded.length + " bytes to generated_cert.der");

            // Verify Round-Trip
            ASN1InputStream ais = new ASN1InputStream(encoded);
            ASN1Primitive parsedObj = ais.readObject();
            ais.close();

            if (parsedObj.equals(certSeq)) {
                AuthenticationFramework_Certificate parsedCert = new AuthenticationFramework_Certificate(
                        ASN1Sequence.getInstance(parsedObj));
                System.out.println("Parsed Back Created Certificate: " + parsedCert.getClass().getSimpleName());
                System.out.println("SUCCESS: Round-Trip complete.");
            } else {
                System.out.println("FAILURE: parsed object does not match created object");
            }

        } catch (Exception e) {
            System.out.println("Creation Demo Failed: " + e);
            e.printStackTrace();
        }
        System.out.println("=============================================");
    }

    private static void testSimpleParsing() {
        System.out.println("Testing Simple Parsing...");
        try {
            // Write a simple test file if not exists
            byte[] bytes = new DERSequence(new ASN1Integer(1)).getEncoded();
            Files.write(Path.of("test_bc.der"), bytes);

            ASN1InputStream ais = new ASN1InputStream(bytes);
            ASN1Primitive obj = ais.readObject();
            ais.close();
            System.out.println("Simple Parse: " + obj.getClass().getSimpleName() + " " + obj);
        } catch (Exception e) {
            System.out.println("Simple Parse Failed: " + e);
            e.printStackTrace();
        }
    }

    private static byte[] serialize(ASN1Encodable obj) throws IOException {
        return obj.toASN1Primitive().getEncoded("DER");
    }
}
