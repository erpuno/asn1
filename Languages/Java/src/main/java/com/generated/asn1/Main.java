package com.generated.asn1;

import com.iho.asn1.*;
import java.io.File; // Added for new File usage
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;

public class Main {

    public static void main(String[] args) {
        if (args.length > 0) {
            runOpenSSLTests(args);
            return;
        }

        System.out.println("Starting ASN.1 Demo (der.java migration)...");

        // Ensure clean state
        try {
            Files.deleteIfExists(Path.of("saved_cert.der"));
        } catch (IOException e) {
            e.printStackTrace();
        }

        demonstrateCertificateParsing();
    }

    private static void runOpenSSLTests(String[] args) {
        String command = args[0];
        try {
            switch (command) {
                case "parse-csr":
                    parseCSR(args[1]);
                    break;
                case "parse-crl":
                    parseCRL(args[1]);
                    break;
                case "parse-key":
                    parseKey(args[1]);
                    break;
                default:
                     System.err.println("Unknown command: " + command);
                     System.exit(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void parseCSR(String file) throws Exception {
        byte[] data = Files.readAllBytes(Path.of(file));
        System.out.println("Reading CSR from " + file + " (" + data.length + " bytes)");
        PKCS_10_CertificationRequest csr = PKCS_10_CertificationRequest.parse(data);
        System.out.println("Parsed CSR: " + csr.getClass().getSimpleName());
        
        byte[] encoded = csr.serialize();
        if (Arrays.equals(data, encoded)) {
             System.out.println("SUCCESS: CRL Round-trip matches.");
        } else {
             System.out.println("FAILURE: CRL Round-trip mismatch!");
             System.exit(1);
        }
    }

    private static void parseCRL(String file) throws Exception {
        byte[] data = Files.readAllBytes(Path.of(file));
        System.out.println("Reading CRL from " + file + " (" + data.length + " bytes)");
        AuthenticationFramework_CertificateList crl = AuthenticationFramework_CertificateList.parse(data);
        System.out.println("Parsed CRL: " + crl.getClass().getSimpleName());
        
        byte[] encoded = crl.serialize();
        if (Arrays.equals(data, encoded)) {
             System.out.println("SUCCESS: CRL Round-trip matches.");
        } else {
             System.out.println("FAILURE: CRL Round-trip mismatch!");
             System.exit(1);
        }
    }

    private static void parseKey(String file) throws Exception {
        byte[] data = Files.readAllBytes(Path.of(file));
        System.out.println("Reading PrivateKey from " + file + " (" + data.length + " bytes)");
        PKCS_8_PrivateKeyInfo key = PKCS_8_PrivateKeyInfo.parse(data);
        System.out.println("Parsed PrivateKey: " + key.getClass().getSimpleName());
        
        byte[] encoded = key.serialize();
        if (Arrays.equals(data, encoded)) {
             System.out.println("SUCCESS: Key Round-trip matches.");
        } else {
             System.out.println("FAILURE: Key Round-trip mismatch!");
             Files.write(Path.of("key_mismatch.der"), encoded);
             System.out.println("Saved mismatch to key_mismatch.der");
             System.exit(1);
        }
    }

    private static void demonstrateCertificateParsing() {
        System.out.println("\n=== Certificate Parsing/Saving Demo ===");
        try {
            Path path = Path.of("clean.der"); // Or any valid cert file
            if (!Files.exists(path)) {
                // If clean.der not found, try to locate one or just exit
                File f = new File("../../../../../test_certs/clean.der"); // Try relative path?
                // Just message
                System.out.println("clean.der not found in current dir. Please provide a DER file to test parsing.");
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

            // Verify Round-Trip using High-Level API
            AuthenticationFramework_Certificate parsedCert = AuthenticationFramework_Certificate.parse(encoded);
            System.out.println("Parsed Back Serialized Certificate: " + parsedCert.getClass().getSimpleName());

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
