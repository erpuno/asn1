package com.generated.asn1;

import com.iho.asn1.*;
import java.io.File; // Added for new File usage
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;

public class Main {

    public static void main(String[] args) {
        System.out.println("Starting ASN.1 Demo (der.java migration)...");

        // Ensure clean state
        try {
            Files.deleteIfExists(Path.of("saved_cert.der"));
        } catch (IOException e) {
            e.printStackTrace();
        }

        demonstrateCertificateParsing();
        // demonstrateCertificateCreation(); // Builders removed in migration, disabled for now
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
