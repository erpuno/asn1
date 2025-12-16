import SwiftASN1
import Foundation

exit(Console.suite())

extension String: @retroactive Error { }

public class Console {

  public static func exists(f: String) -> Bool { return FileManager.default.fileExists(atPath: f) }

  public static func showName(data: Array<UInt8>) throws {
     print("Debug: showName")
     let name: DSTU_Name? = try DSTU_Name(derEncoded: data)
     var serializer = DER.Serializer()
     try name!.serialize(into: &serializer)
     print(": Name.DER \(data)")
     print(": Name ⟼ \(name!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> Name lacks equality properties." }
  }

  public static func showGeneralName(data: Array<UInt8>) throws {
     print("Debug: showGeneralName")
     let name: KEP_GeneralName? = try KEP_GeneralName(derEncoded: data)
     var serializer = DER.Serializer()
     try name!.serialize(into: &serializer)
     print(": GeneralName.DER \(data)")
     print(": GeneralName ⟼ \(name!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> GeneralName lacks equality properties." }
  }

  public static func showDirectoryString(data: Array<UInt8>) throws {
     print("Debug: showDirectoryString")
     let ds: DSTU_DirectoryString? = try DSTU_DirectoryString(derEncoded: data)
     var serializer = DER.Serializer()
     try ds!.serialize(into: &serializer)
     print(": DirectoryString.DER \(data)")
     print(": DirectoryString ⟼ \(ds!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> DirectoryString lacks equality properties." }
  }

  // Commented out - LDAP types were in deleted XSeries
  // public static func showLDAPMessage(data: Array<UInt8>) throws {
  //    let msg: LDAP_LDAPMessage? = try LDAP_LDAPMessage(derEncoded: data)
  //    var serializer = DER.Serializer()
  //    try msg!.serialize(into: &serializer)
  //    print(": LDAPMessage.DER \(data)")
  //    print(": LDAPMessage ⟼ \(msg!)\n")
  //    if (data != serializer.serializedBytes) { throw "DER <-> LDAPMessage lacks equality properties." }
  // }

  public static func showCHATMessage(data: Array<UInt8>) throws {
     let msg: CHAT_CHATMessage? = try CHAT_CHATMessage(derEncoded: data)
     var serializer = DER.Serializer()
     try msg!.serialize(into: &serializer)
     print(": CHATMessage.DER \(data)")
     print(": CHATMessage ⟼ \(msg!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> CHATMessage lacks equality properties." }
  }

  public static func showCertificate(file: String) throws {
     let url = URL(fileURLWithPath: file)
     if (!Console.exists(f: url.path)) { print(": CERT file not found.") } else {
         let data = try Data(contentsOf: url)
         let cert = try DSTU_Certificate(derEncoded: Array(data)) // display TBSCertificate envelop from DSTU.asn1
         print(": Certificate ⟼ \(cert)\n")
     }
  }

  public static func verifyX509(file: String, output: String = "verified.der") throws {
     let url = URL(fileURLWithPath: file)
     if (!Console.exists(f: url.path)) { print(": X509 file not found.") } else {
         let data = try Data(contentsOf: url)
         let cert = try DSTU_Certificate(derEncoded: Array(data))
         var serializer = DER.Serializer()
         try cert.serialize(into: &serializer)
         let outputUrl = URL(fileURLWithPath: output)
         try Data(serializer.serializedBytes).write(to: outputUrl)
         print(": X509 Certificate read and re-written to \(output)")
         print(": X509 Certificate ⟼ \(cert)\n")
         if (Array(data) != serializer.serializedBytes) { 
            print(": [WARN] DER <-> Certificate round trip differs.") 
         } else {
            print(": [OK] DER <-> Certificate round trip matches.")
         }
     }
  }

  public static func showContentInfo(file: String) throws {
     let url = URL(fileURLWithPath: file)
     if (!Console.exists(f: url.path)) { print(": CI file not found.") } else {
         let data = try Data(contentsOf: url)
         var cert = try KEP_ContentInfo(derEncoded: Array(data))
         var serializer = DER.Serializer()
         try cert.content.serialize(into: &serializer)
         var signedData = try KEP_SignedData(derEncoded: Array(serializer.serializedBytes))
         let content: String? = try String(bytes: signedData.encapContentInfo.eContent!.bytes, encoding: .utf8)
         cert.content = try ASN1Any(erasing: ASN1Null())
         signedData.encapContentInfo.eContent = nil
         print(": SignedData ⟼ \(signedData)\n ") // display SignedData envelope from KEP.asn1
         print(": signedData.encapContentInfo.eContent := \(content!)\n") // display signed content

         print(": ContentInfo.DER \(data)")
         print(": ContentInfo ⟼ \(cert)\n")
     }
  }

  public static func verifyOID() throws {
      print("Debug: verifyOID")
      print(": KEP_id_data ⟼ \(KEP_id_data)")
      if (KEP_id_data.description != "1.2.840.113549.1.7.1") {
         throw "KEP_id_data value mismatch. Expected 1.2.840.113549.1.7.1, got \(KEP_id_data)"
      }
      print(": PASSED\n")
  }

  public static func showPentanomial(data: Array<UInt8>) throws {
     print("Debug: showPentanomial")
     let val: DSTU_Pentanomial? = try DSTU_Pentanomial(derEncoded: data)
     var serializer = DER.Serializer()
     try val!.serialize(into: &serializer)
     print(": Pentanomial.DER \(data)")
     print(": Pentanomial ⟼ \(val!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> Pentanomial lacks equality properties." }
  }

  // Commented out - LDAP types were in deleted XSeries
  // public static func showAttributeValueAssertion(data: Array<UInt8>) throws {
  //    print("Debug: showAttributeValueAssertion")
  //    let val: LDAP_AttributeValueAssertion? = try LDAP_AttributeValueAssertion(derEncoded: data)
  //    var serializer = DER.Serializer()
  //    try val!.serialize(into: &serializer)
  //    print(": AttributeValueAssertion.DER \(data)")
  //    print(": AttributeValueAssertion ⟼ \(val!)\n")
  //    if (data != serializer.serializedBytes) { throw "DER <-> AttributeValueAssertion lacks equality properties." }
  // }


  public static func showIntMatrix(data: Array<UInt8>) throws {
     print("Debug: showIntMatrix")
     let val: Nested_IntMatrix? = try Nested_IntMatrix(derEncoded: data)
     var serializer = DER.Serializer()
     try val!.serialize(into: &serializer)
     print(": IntMatrix.DER \(data)")
     print(": IntMatrix ⟼ \(val!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> IntMatrix lacks equality properties." }
  }

  public static func showCertificateData(data: Array<UInt8>) throws {
     print("Debug: showCertificateData")
     let val: DSTU_Certificate? = try DSTU_Certificate(derEncoded: data)
     var serializer = DER.Serializer()
     try val!.serialize(into: &serializer)
     print(": Certificate.DER \(data)")
     print(": Certificate ⟼ \(val!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> Certificate lacks equality properties." }
  }

  public static func generateX509() throws {
     print("Debug: generateX509")
     
     // 1. Construct Issuer/Subject Name: CN=Test
     // 2.5.4.3 (commonName)
     let cnOID = try ASN1ObjectIdentifier(dotRepresentation: "2.5.4.3")
     // PrintableString "Test" -> Tag 0x13, Length 0x04, Bytes "Test"
     let cnValueDer: [UInt8] = [0x13, 0x04, 0x54, 0x65, 0x73, 0x74] 
     let cnValue = try ASN1Any(derEncoded: cnValueDer)
     
     let atav = DSTU_AttributeTypeAndValue(type: cnOID, value: cnValue)
     let rdn = DSTU_RelativeDistinguishedName([atav])
     let name = DSTU_Name.rdnSequence(DSTU_RDNSequence([rdn]))
     
     // 2. Validity (Now to Now + 1 year)
     let now = Date()
     let later = Date(timeIntervalSinceNow: 3600 * 24 * 365)
     
     let calendar = Calendar(identifier: .gregorian)
     let nowComps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
     let laterComps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: later)
     
     let notBefore = try DSTU_Time.utcTime(UTCTime(year: nowComps.year!, month: nowComps.month!, day: nowComps.day!, hours: nowComps.hour!, minutes: nowComps.minute!, seconds: nowComps.second!))
     let notAfter = try DSTU_Time.utcTime(UTCTime(year: laterComps.year!, month: laterComps.month!, day: laterComps.day!, hours: laterComps.hour!, minutes: laterComps.minute!, seconds: laterComps.second!))
     
     let validity = DSTU_Validity(notBefore: notBefore, notAfter: notAfter)
     
     // 3. Algorithm: 1.2.840.113549.1.1.1 (rsaEncryption)
     let algoOID = try ASN1ObjectIdentifier(dotRepresentation: "1.2.840.113549.1.1.1")
     // Parameters: NULL
     let nullParams = try ASN1Any(erasing: ASN1Null())
     let algo = DSTU_AlgorithmIdentifier(algorithm: algoOID, parameters: nullParams)
     
     // 4. SubjectPublicKeyInfo
     let pubKeyBitString = ASN1BitString(bytes: [0x01, 0x02, 0x03, 0x04])
     let spki = DSTU_SubjectPublicKeyInfo(algorithm: algo, subjectPublicKey: pubKeyBitString)
     
     // 5. TBSCertificate
     let serial: ArraySlice<UInt8> = [0x01]
     let tbs = DSTU_TBSCertificate(
        version: .v3,
        serialNumber: serial,
        signature: algo,
        issuer: name,
        validity: validity,
        subject: name,
        subjectPublicKeyInfo: spki,
        issuerUniqueID: nil,
        subjectUniqueID: nil,
        extensions: nil
     )
     
     // 6. Certificate
     let sigValue = ASN1BitString(bytes: [0xFF, 0xEE, 0xDD])
     let cert = DSTU_Certificate(tbsCertificate: tbs, signatureAlgorithm: algo, signatureValue: sigValue)
     
     print(": Generated Certificate ⟼ \(cert)\n")
     
     var serializer = DER.Serializer()
     try cert.serialize(into: &serializer)
     
     let url = URL(fileURLWithPath: "generated.crt")
     try Data(serializer.serializedBytes).write(to: url)
     print(": Written to generated.crt")
  }

  public static func suite() -> Int32 {
     do {
       try verifyOID()
       try showPentanomial(data: [48, 9, 2, 1, 1, 2, 1, 2, 2, 1, 3])
       // try showAttributeValueAssertion(data: [48, 14, 4, 2, 99, 110, 4, 8, 74, 111, 104, 110, 32, 68, 111, 101])
       try showIntMatrix(data: [48, 22, 48, 9, 2, 1, 1, 2, 1, 2, 2, 1, 3, 48, 9, 2, 1, 4, 2, 1, 5, 2, 1, 6])
       // Generated test vector for dummy Certificate
       try showCertificateData(data: [48, 129, 129, 48, 107, 160, 3, 2, 1, 2, 2, 3, 1, 226, 64, 48, 10, 6, 8, 42, 134, 72, 206, 61, 4, 3, 2, 48, 13, 49, 11, 48, 9, 6, 3, 85, 4, 3, 19, 2, 67, 65, 48, 30, 23, 13, 50, 51, 48, 49, 48, 49, 49, 50, 48, 48, 48, 48, 90, 23, 13, 51, 48, 48, 49, 48, 49, 49, 50, 48, 48, 48, 48, 90, 48, 15, 49, 13, 48, 11, 6, 3, 85, 4, 3, 19, 4, 85, 115, 101, 114, 48, 19, 48, 9, 6, 7, 42, 134, 72, 206, 61, 2, 1, 3, 6, 0, 4, 0, 0, 0, 0, 48, 10, 6, 8, 42, 134, 72, 206, 61, 4, 3, 2, 3, 6, 0, 1, 2, 3, 4, 5])


       try showCertificate(file: "ca.crt")
       try verifyX509(file: "ca.crt", output: "verified.der")
       try generateX509()
       try verifyX509(file: "generated.crt", output: "generated_verified.der")
       try showContentInfo(file: "data.bin")
       try showDirectoryString(data: [19,3,49,50,51])
       // try showLDAPMessage(data: [48,16,2,1,1,96,9,2,1,1,4,0,128,2,49,50,160,0])
       try showCHATMessage(data: [48,27,2,1,1,48,0,160,20,4,3,53,72,84,4,7,53,72,84,46,99,115,114,4,4,48,48,48,48])
       try showName(data: [48,13,49,11,48,9,6,3,85,4,6,19,2,85,65])
       try showName(data: [48,0])

       // existing test (directoryName [4] EXPLICIT empty sequence)
       try showGeneralName(data: [164,2,48,0])

       // dNSName [2] IMPLICIT IA5String("example.com")
       // Tag [2] -> 0x82 (Context S. Primitive 2)
       // "example.com" ascii -> 65 78 61 6D 70 6C 65 2E 63 6F 6D (11 bytes)
       try showGeneralName(data: [0x82, 11, 0x65, 0x78, 0x61, 0x6D, 0x70, 0x6C, 0x65, 0x2E, 0x63, 0x6F, 0x6D])

       // registeredID [8] IMPLICIT OBJECT IDENTIFIER(1.2.840.113549.1.7.1)
       // Tag [8] -> 0x88 (Context S. Primitive 8)
       // OID bytes: 2A 86 48 86 F7 0D 01 07 01 (9 bytes)
       try showGeneralName(data: [0x88, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x07, 0x01])

       print(": PASSED")
       return 0
     } catch {
       print(": EXCEPTION \(error)")
       print(": FAILED")
       return 1
     }
  }

}
