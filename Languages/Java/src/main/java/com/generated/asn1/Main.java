package com.generated.asn1;

import com.iho.asn1.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;
import java.security.MessageDigest;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.util.Random;

public class Main {

    public static void main(String[] args) {
        if (args.length > 0) {
            runOpenSSLTests(args);
            return;
        }

        System.out.println("Starting ASN.1 Demo (der.java migration)...");

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
                case "request-ca":
                    requestCertificate();
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

    // --- Crypto Helpers ---

    private static byte[] deriveKey(byte[] password, byte[] salt, int iterations) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        digest.update(password);
        digest.update(salt);
        byte[] acc = digest.digest();

        for (int i = 1; i < iterations; i++) {
            digest.reset();
            acc = digest.digest(acc);
        }
        return acc;
    }

    private static byte[] calculateMAC(byte[] key, byte[] data) throws Exception {
        Mac hmac = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKey = new SecretKeySpec(key, "HmacSHA256");
        hmac.init(secretKey);
        return hmac.doFinal(data);
    }

    private static byte[] randomBytes(int len) {
        byte[] b = new byte[len];
        new Random().nextBytes(b);
        return b;
    }

    // --- Helpers for Node Construction ---
    
    // Helper to get raw bytes of OID for specific known OIDs
    private static byte[] getEncodedSHA256OID() {
        // 2.16.840.1.101.3.4.2.1 -> 60 86 48 01 65 03 04 02 01
        return new byte[]{0x60, (byte)0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x01};
    }

    private static byte[] getEncodedHmacSHA256OID() {
        // 1.2.840.113549.2.9 -> 2A 86 48 86 F7 0D 02 09
        return new byte[]{0x2A, (byte)0x86, 0x48, (byte)0x86, (byte)0xF7, 0x0D, 0x02, 0x09};
    }

    private static byte[] getEncodedPBMOID() {
        // 1.2.840.113533.7.66.13 -> 2A 86 48 86 F6 7D 07 42 0D
        return new byte[]{0x2A, (byte)0x86, 0x48, (byte)0x86, (byte)0xF6, 0x7D, 0x07, 0x42, 0x0D};
    }
    
    private static ASN1Node createConstructed(ASN1Identifier tag, List<ASN1Node> children) throws Exception {
        DERWriter writer = new DERWriter();
        writer.writeConstructed(tag, w -> {
            try {
                for (ASN1Node child : children) {
                    ASN1Utilities.serializeNode(w, child);
                }
            } catch (ASN1Exception e) {
                throw new RuntimeException(e);
            }
        });
        return DERParser.parse(writer.toByteArray());
    }

    private static ASN1Node createPrimitive(ASN1Identifier tag, byte[] content) throws Exception {
        DERWriter writer = new DERWriter();
        writer.writePrimitive(tag, content);
        return DERParser.parse(writer.toByteArray());
    }

    private static ASN1Node createInteger(long value) throws Exception {
        return createPrimitive(ASN1Identifier.INTEGER, java.math.BigInteger.valueOf(value).toByteArray());
    }
    
    private static ASN1Node createOctetString(byte[] value) throws Exception {
        return createPrimitive(ASN1Identifier.OCTET_STRING, value);
    }
    
    private static void requestCertificate() throws Exception {
        System.out.println("Constructing CA Request (PBM Protected)...");
        
        System.out.println("Generating ECDSA P-384 Key Pair...");
        java.security.KeyPairGenerator kpg = java.security.KeyPairGenerator.getInstance("EC");
        kpg.initialize(384);
        java.security.KeyPair kp = kpg.generateKeyPair();

        // --- PBM Parameters ---
        byte[] salt = randomBytes(16);
        ASN1Node saltNode = createOctetString(salt);
        
        // OWF: SHA256
        ASN1Node owfOid = createPrimitive(ASN1Identifier.OBJECT_IDENTIFIER, getEncodedSHA256OID());
        ASN1Node owfSeq = createConstructed(ASN1Identifier.SEQUENCE, Arrays.asList(owfOid)); 

        // Iterations
        ASN1Node iterNode = createInteger(10000);
        
        // MAC: HMAC-SHA256
        ASN1Node macOid = createPrimitive(ASN1Identifier.OBJECT_IDENTIFIER, getEncodedHmacSHA256OID());
        ASN1Node macSeq = createConstructed(ASN1Identifier.SEQUENCE, Arrays.asList(macOid));

        // PBMParameter ::= SEQUENCE { salt, owf, iter, mac }
        ASN1Node pbmParams = createConstructed(ASN1Identifier.SEQUENCE, Arrays.asList(
            saltNode, owfSeq, iterNode, macSeq
        ));

        // Protection AlgId
        // 1.2.840.113533.7.66.13
        ASN1Node pbmOidNode = createPrimitive(ASN1Identifier.OBJECT_IDENTIFIER, getEncodedPBMOID());
        ASN1Node protectionAlgSeq = createConstructed(ASN1Identifier.SEQUENCE, Arrays.asList(pbmOidNode, pbmParams));

        // Construct Header Fields
        ASN1Node pvno = createInteger(2);
        
        // Sender: "robot_java" (DNSName)
        ASN1Node senderName = createPrimitive(new ASN1Identifier(2, TagClass.ContextSpecific), "robot_java".getBytes("UTF-8"));
        PKIX1Implicit_2009_GeneralName sender = new PKIX1Implicit_2009_GeneralName(senderName);
        
        // Recipient: "localhost"
        ASN1Node recipientName = createPrimitive(new ASN1Identifier(2, TagClass.ContextSpecific), "localhost".getBytes("UTF-8"));
        PKIX1Implicit_2009_GeneralName recipient = new PKIX1Implicit_2009_GeneralName(recipientName);

        // TransactionID, Nonce
        byte[] transIDBytes = randomBytes(16);
        byte[] nonceBytes = randomBytes(16);

        ASN1Time.GeneralizedTime msgTime = new ASN1Time.GeneralizedTime(java.time.ZonedDateTime.now());

        // Header wrapping
        AuthenticationFramework_AlgorithmIdentifier protectionAlg = new AuthenticationFramework_AlgorithmIdentifier(protectionAlgSeq);

        PKIXCMP_2009_PKIHeader header = new PKIXCMP_2009_PKIHeader(
            pvno, sender, recipient, 
            msgTime, 
            protectionAlg, // protectionalg
            null, // senderkid
            null, // recipkid
            new ASN1OctetString(transIDBytes), // transactionid
            new ASN1OctetString(nonceBytes), // sendernonce
            null, 
            null, 
            null
        );


        // --- Body: p10cr ---
        PKCS_10_CertificationRequest csr = createCSR(kp, "robot_java");
        ASN1Node csrNode = DERParser.parse(csr.serialize());
        ASN1Node bodyNode = createConstructed(new ASN1Identifier(4, TagClass.ContextSpecific), Arrays.asList(csrNode));
        PKIXCMP_2009_PKIBody body = new PKIXCMP_2009_PKIBody(bodyNode);

        // --- Calculate Protection ---
        // ProtectedPart = SEQUENCE { header, body }
        DERWriter ppWriter = new DERWriter();
        ppWriter.writeSequence(w -> {
             header.serialize(w);
             body.serialize(w);
        });
        byte[] protectedPartBytes = ppWriter.toByteArray();

        System.out.println("Calculating PBM MAC...");
        byte[] key = deriveKey("0000".getBytes("UTF-8"), salt, 10000);
        byte[] mac = calculateMAC(key, protectedPartBytes);

        // Protection: BIT STRING
        DERWriter protWriter = new DERWriter();
        byte[] bitString = new byte[mac.length + 1];
        bitString[0] = 0;
        System.arraycopy(mac, 0, bitString, 1, mac.length);
        protWriter.writePrimitive(ASN1Identifier.BIT_STRING, bitString);
        ASN1Node protectionNode = DERParser.parse(protWriter.toByteArray());
        
        PKIXCMP_2009_PKIProtection protection = new PKIXCMP_2009_PKIProtection(protectionNode);

        PKIXCMP_2009_PKIMessage msg = new PKIXCMP_2009_PKIMessage(header, body, protection, null);
        byte[] msgBytes = msg.serialize();
        
        System.out.println("PKIMessage ready. Length: " + msgBytes.length);

        // Send
        System.out.println("Sending...");
        java.net.URL url = new java.net.URL("http://localhost:8829/");
        java.net.HttpURLConnection con = (java.net.HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setDoOutput(true);
        con.setRequestProperty("Content-Type", "application/pkixcmp");
        con.setRequestProperty("Content-Length", String.valueOf(msgBytes.length));
        
        try (java.io.OutputStream os = con.getOutputStream()) {
            os.write(msgBytes);
        }

        int status = con.getResponseCode();
        System.out.println("Response: " + status + " " + con.getResponseMessage());

        if (status == 200) {
            byte[] respBytes = readAllBytes(con.getInputStream());
            System.out.println("Received " + respBytes.length + " bytes.");
            
            PKIXCMP_2009_PKIMessage respMsg = PKIXCMP_2009_PKIMessage.parse(respBytes);
            System.out.println("PKIMessage Parsed Successfully!");
            
            ASN1Node respBody = respMsg.body.getValue();
            System.out.println("Body Tag: " + respBody.identifier.tagNumber); 
            
            // CertRepMessage = [1]
            if (respBody.identifier.tagNumber == 1) { 
                System.out.println("SUCCESS: Certificate received (saved response).");
                Files.write(Path.of("received_response.der"), respBytes);
            } else {
                 System.out.println("Received Body Tag " + respBody.identifier.tagNumber + " (Expected 1 for CertRepMessage)");
                 Files.write(Path.of("received_response.der"), respBytes);
            }
        } else {
             System.err.println("Error response from CA");
             if (con.getErrorStream() != null) {
                  System.err.println("Error Body: " + new String(con.getErrorStream().readAllBytes()));
             }
             System.exit(1);
        }
    }

    private static PKCS_10_CertificationRequest createCSR(java.security.KeyPair kp, String cn) throws Exception {
        ASN1Node version = createInteger(0);

        // CN=...
        // 2.5.4.3
        ASN1Node commonNameOID = createPrimitive(ASN1Identifier.OBJECT_IDENTIFIER, new byte[]{0x55, 0x04, 0x03});
        ASN1Node commonNameValue = createPrimitive(ASN1Identifier.UTF8_STRING, cn.getBytes("UTF-8"));
        
        ASN1Node atavSeq = createConstructed(ASN1Identifier.SEQUENCE, Arrays.asList(commonNameOID, commonNameValue));
        ASN1Node rdnSet = createConstructed(ASN1Identifier.SET, Arrays.asList(atavSeq));
        ASN1Node rdnSequence = createConstructed(ASN1Identifier.SEQUENCE, Arrays.asList(rdnSet));
        
        PKIX1Explicit_2009_Name subject = new PKIX1Explicit_2009_Name(rdnSequence);
        ASN1Node subjectPKInfo = DERParser.parse(kp.getPublic().getEncoded());
        
        // Attributes [0] IMPLICIT SET
        DERWriter attrWriter = new DERWriter();
        attrWriter.writeConstructed(new ASN1Identifier(0, TagClass.ContextSpecific), w -> {}); 
        ASN1Node attributes = DERParser.parse(attrWriter.toByteArray());

        PKCS_10_CertificationRequestInfo info = new PKCS_10_CertificationRequestInfo(version, subject, subjectPKInfo, attributes);
        byte[] infoBytes = info.serialize();

        java.security.Signature sig = java.security.Signature.getInstance("SHA384withECDSA");
        sig.initSign(kp.getPrivate());
        sig.update(infoBytes);
        byte[] signatureBytes = sig.sign();
        
        // 1.2.840.10045.4.3.3
        ASN1Node algIdOID = createPrimitive(ASN1Identifier.OBJECT_IDENTIFIER, new byte[]{0x2A, (byte)0x86, 0x48, (byte)0xCE, 0x3D, 0x04, 0x03, 0x03});
        AuthenticationFramework_AlgorithmIdentifier sigAlg = new AuthenticationFramework_AlgorithmIdentifier(createConstructed(ASN1Identifier.SEQUENCE, Arrays.asList(algIdOID))); 

        DERWriter sigWriter = new DERWriter();
        byte[] bitStringContent = new byte[signatureBytes.length + 1];
        bitStringContent[0] = 0; 
        System.arraycopy(signatureBytes, 0, bitStringContent, 1, signatureBytes.length);
        sigWriter.writePrimitive(ASN1Identifier.BIT_STRING, bitStringContent);
        ASN1Node signature = DERParser.parse(sigWriter.toByteArray());

        return new PKCS_10_CertificationRequest(info, sigAlg, signature);
    }

    private static byte[] getBytes(ASN1Node node) {
        if (node.content instanceof ASN1Node.Primitive) {
            return ((ASN1Node.Primitive) node.content).data;
        }
        throw new RuntimeException("Node is not primitive");
    }



    private static byte[] readAllBytes(java.io.InputStream is) throws IOException {
        java.io.ByteArrayOutputStream buffer = new java.io.ByteArrayOutputStream();
        int nRead;
        byte[] data = new byte[1024];
        while ((nRead = is.read(data, 0, data.length)) != -1) {
            buffer.write(data, 0, nRead);
        }
        return buffer.toByteArray();
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
            Path path = Path.of("clean.der"); 
            if (!Files.exists(path)) {
                File f = new File("../../../../../test_certs/clean.der"); 
                System.out.println("clean.der not found in current dir. Please provide a DER file to test parsing.");
                return;
            }

            byte[] data = Files.readAllBytes(path);
            System.out.println("Read " + data.length + " bytes from " + path);

            AuthenticationFramework_Certificate cert = AuthenticationFramework_Certificate.parse(data);
            System.out.println("Parsed Certificate: " + cert.getClass().getSimpleName());

            byte[] encoded = cert.serialize();
            Files.write(Path.of("saved_cert.der"), encoded);
            System.out.println("Saved " + encoded.length + " bytes to saved_cert.der");

            AuthenticationFramework_Certificate parsedCert = AuthenticationFramework_Certificate.parse(encoded);
            System.out.println("Parsed Back Serialized Certificate: " + parsedCert.getClass().getSimpleName());

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
