package com.generated.asn1;

import com.iho.asn1.ASN1Exception;
import com.iho.asn1.DERParser;
import com.iho.asn1.DERWriter;
import com.iho.asn1.DERSerializable;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Base64;
import java.util.stream.Collectors;

public class OpenSSLTest {

    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Usage: java OpenSSLTest <test_type> <file_path>");
            System.exit(1);
        }

        String testType = args[0];
        String filePath = args[1];

        try {
            System.out.println("Running Java OpenSSL Test: " + testType + " on " + filePath);
            byte[] fileBytes = Files.readAllBytes(Paths.get(filePath));
            byte[] data = fileBytes;

            // Handle PEM if needed (simple heuristic)
            String content = new String(fileBytes);
            if (content.startsWith("-----BEGIN")) {
                System.out.println("Detected PEM, decoding...");
                String base64 = content.lines()
                    .filter(line -> !line.startsWith("-----"))
                    .collect(Collectors.joining(""));
                data = Base64.getDecoder().decode(base64);
            }

            switch (testType) {
                case "pkcs8_private_key":
                    testRoundTrip(data, PKCS_8_PrivateKeyInfo::parse);
                    break;
                case "pkcs8_public_key":
                    testRoundTrip(data, PKIX1Explicit88_SubjectPublicKeyInfo::parse);
                    break;
                case "csr":
                    testRoundTrip(data, PKCS_10_CertificationRequest::parse);
                    break;
                case "ca_cert":
                case "ee_cert":
                case "extended_cert":
                    testRoundTrip(data, AuthenticationFramework_Certificate::parse);
                    break;
                case "pkcs7_bundle":
                case "cms_signed":
                case "cms_encrypted":
                    testRoundTrip(data, CryptographicMessageSyntax_2010_ContentInfo::parse);
                    break;
                case "bundle":
                    // Bundle is often PKCS7 or just concatenation? 
                    // TS test uses PKCS_7_ContentInfo for bundle
                    testRoundTrip(data, PKCS_7_ContentInfo::parse);
                    break;
                case "cert": // Keep original 'cert' case for PKIX1Explicit_2009_Certificate
                    testRoundTrip(data, PKIX1Explicit_2009_Certificate::parse);
                    break;
                default:
                    System.err.println("Unknown test type: " + testType);
                    System.exit(1);
            }

            System.out.println("PASS: " + testType);

        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    interface Parser<T extends DERSerializable> {
        T parse(byte[] data) throws IOException, ASN1Exception;
    }

    private static <T extends DERSerializable> void testRoundTrip(byte[] original, Parser<T> parser) throws Exception {
        // 1. Parse
        T obj = parser.parse(original);
        
        // 2. Serialize
        DERWriter writer = new DERWriter();
        obj.serialize(writer);
        byte[] reSerialized = writer.toByteArray();

        // 3. Compare
        if (!Arrays.equals(original, reSerialized)) {
            System.err.println("Serialization Mismatch!");
            System.err.println("Original len: " + original.length);
            System.err.println("Serialized len: " + reSerialized.length);
            
             throw new RuntimeException("Round-trip failed");
        }
        System.out.println("Round-trip verified. Length: " + original.length);
    }
}
