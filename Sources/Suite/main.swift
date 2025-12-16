import SwiftASN1
import Foundation

exit(Console.suite())

extension String: Error { }

public class Console {

  public static func exists(f: String) -> Bool { return FileManager.default.fileExists(atPath: f) }

  public static func showName(data: Array<UInt8>) throws {
     let name: Name? = try Name(derEncoded: data)
     var serializer = DER.Serializer()
     try name!.serialize(into: &serializer)
     print(": Name.DER \(data)")
     print(": Name ⟼ \(name!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> Name lacks equality properties." }
  }

  public static func showGeneralName(data: Array<UInt8>) throws {
     let name: GeneralName? = try GeneralName(derEncoded: data)
     var serializer = DER.Serializer()
     try name!.serialize(into: &serializer)
     print(": GeneralName.DER \(data)")
     print(": GeneralName ⟼ \(name!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> GeneralName lacks equality properties." }
  }

  public static func showDirectoryString(data: Array<UInt8>) throws {
     let ds: DirectoryString? = try DirectoryString(derEncoded: data)
     var serializer = DER.Serializer()
     try ds!.serialize(into: &serializer)
     print(": DirectoryString.DER \(data)")
     print(": DirectoryString ⟼ \(ds!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> DirectoryString lacks equality properties." }
  }

  public static func showLDAPMessage(data: Array<UInt8>) throws {
     let msg: LDAPMessage? = try LDAPMessage(derEncoded: data)
     var serializer = DER.Serializer()
     try msg!.serialize(into: &serializer)
     print(": LDAPMessage.DER \(data)")
     print(": LDAPMessage ⟼ \(msg!)\n")
     if (data != serializer.serializedBytes) { throw "DER <-> LDAPMessage lacks equality properties." }
  }

  public static func showCHATMessage(data: Array<UInt8>) throws {
     let msg: CHATMessage? = try CHATMessage(derEncoded: data)
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
         let cert = try Certificate(derEncoded: Array(data)) // display TBSCertificate envelop from DSTU.asn1
         print(": Certificate ⟼ \(cert)\n")
     }
  }

  public static func showContentInfo(file: String) throws {
     let url = URL(fileURLWithPath: file)
     if (!Console.exists(f: url.path)) { print(": CI file not found.") } else {
         let data = try Data(contentsOf: url)
         var cert = try ContentInfo(derEncoded: Array(data))
         var serializer = DER.Serializer()
         try cert.content.serialize(into: &serializer)
         var signedData = try SignedData(derEncoded: Array(serializer.serializedBytes))
         let content: String? = try String(bytes: signedData.encapContentInfo.eContent!.bytes, encoding: .utf8)
         cert.content = try ASN1Any(erasing: ASN1Null())
         signedData.encapContentInfo.eContent = nil
         print(": SignedData ⟼ \(signedData)\n ") // display SignedData envelope from KEP.asn1
         print(": signedData.encapContentInfo.eContent := \(content!)\n") // display signed content

         print(": ContentInfo.DER \(data)")
         print(": ContentInfo ⟼ \(cert)\n")
     }
  }


  public static func verifyX509(file: String) throws {
     let url = URL(fileURLWithPath: file)
     if (!Console.exists(f: url.path)) { print(": X509 file not found.") } else {
         let data = try Data(contentsOf: url)
         let cert = try Certificate(derEncoded: Array(data))
         var serializer = DER.Serializer()
         try cert.serialize(into: &serializer)
         let outputUrl = URL(fileURLWithPath: "verified.der")
         try Data(serializer.serializedBytes).write(to: outputUrl)
         print(": X509 Certificate read and re-written to verified.der")
         print(": X509 Certificate ⟼ \(cert)\n")
         if (Array(data) != serializer.serializedBytes) { 
            print(": [WARN] DER <-> Certificate round trip differs.") 
         } else {
            print(": [OK] DER <-> Certificate round trip matches.")
         }
     }
  }



  public static func suite() -> Int32 {
     do {
       try showCertificate(file: "ca.crt")
       try showContentInfo(file: "data.bin")
       try showDirectoryString(data: [19,3,49,50,51])
       try showLDAPMessage(data: [48,16,2,1,1,96,9,2,1,1,4,0,128,2,49,50,160,0])
       try showCHATMessage(data: [48,27,2,1,1,48,0,160,20,4,3,53,72,84,4,7,53,72,84,46,99,115,114,4,4,48,48,48,48])
       try showName(data: [48,13,49,11,48,9,6,3,85,4,6,19,2,85,65])
       try showName(data: [48,0])
       try showGeneralName(data: [164,2,48,0])
       try verifyX509(file: "ca.crt")
       print(": PASSED")
       return 0
     } catch {
       print(": EXCEPTION \(error)")
       print(": FAILED")
       return -1
     }
  }

}
