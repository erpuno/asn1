import SwiftASN1
import Foundation

exit(Console.suite())

public class Console {

  public static func exists(f: String) -> Bool { return FileManager.default.fileExists(atPath: f) }

  public static func showName(data: Array<UInt8>) throws {
     let name: Name? = try Name(derEncoded: data)
     if let name { print(": Name \(name)") }
     var serializer = DER.Serializer()
     try name!.serialize(into: &serializer)
     print(": Name.DER \(data)")
     print(": DER.Name \(serializer.serializedBytes)")
  }

  public static func showGeneralName(data: Array<UInt8>) throws {
     let name: GeneralName? = try GeneralName(derEncoded: data)
     if let name { print(": GeneralName \(name)") }
     var serializer = DER.Serializer()
     try name!.serialize(into: &serializer)
     print(": GeneralName.DER \(data)")
     print(": DER.GeneralName \(serializer.serializedBytes)")
  }

  public static func showDirectoryString(data: Array<UInt8>) throws {
     let ds: DirectoryString? = try DirectoryString(derEncoded: data)
     if let ds { print(": DirectoryString \(ds)") }
     var serializer = DER.Serializer()
     try ds!.serialize(into: &serializer)
     print(": DirectoryString.DER \(data)")
     print(": DER.DirectoryString \(serializer.serializedBytes)")
  }

  public static func showLDAPMessage(data: Array<UInt8>) throws {
     let msg: LDAPMessage? = try LDAPMessage(derEncoded: data)
     if let msg { print(": LDAPMessage \(msg)") }
     var serializer = DER.Serializer()
     try msg!.serialize(into: &serializer)
     print(": LDAPMessage.DER \(data)")
     print(": DER.LDAPMessage \(serializer.serializedBytes)")
  }

  public static func showCertificate(file: String) throws {
     let url = URL(fileURLWithPath: file)
     if (!Console.exists(f: url.path)) { print(": CERT file not found.") } else {
         let data = try Data(contentsOf: url)
         let cert = try Certificate(derEncoded: Array(data))
         print(": Certificate \(cert)")
     }
  }

  public static func showContentInfo(file: String) throws {
     let url = URL(fileURLWithPath: file)
     if (!Console.exists(f: url.path)) { print(": CI file not found.") } else {
         let data = try Data(contentsOf: url)
         var cert = try ContentInfo(derEncoded: Array(data))
         var serializer = DER.Serializer()
         try cert.content.serialize(into: &serializer)
         let signedData = try SignedData(derEncoded: Array(serializer.serializedBytes))
         print(": SignedData \(signedData)")
         cert.content = try ASN1Any(erasing: ASN1Null())
         print(": ContentInfo \(cert)")
     }
  }

  public static func suite() -> Int32 {
     do {
       try showCertificate(file: "ca.crt")
       try showContentInfo(file: "data.bin")
       try showDirectoryString(data: [19,3,49,50,51])
       try showLDAPMessage(data: [48,16,2,1,1,96,9,2,1,1,4,0,128,2,49,50,160,0])
       try showName(data: [48,13,49,11,48,9,6,3,85,4,6,19,2,85,65])
       try showName(data: [48,0])
       try showGeneralName(data: [164,2,48,0])
       print(": PASSED")
       return 0
     } catch {
       print(": EXCEPTION \(error)")
       print(": FAILED")
       return -1
     }
  }

}
