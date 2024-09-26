import SwiftASN1
import Foundation

try Console.loop()

public class Console {

  public static func exists(f: String) -> Bool { return FileManager.default.fileExists(atPath: f) }

  public static func showName(data: Array<UInt8>) throws {
     let name: Name? = try Name(derEncoded: data)
     if let name { print(": Name \(name)") }
     var serializer = DER.Serializer()
     try name!.serialize(into: &serializer)
     print(": DER.name \(serializer.serializedBytes)")
  }

  public static func showDirectoryString(data: Array<UInt8>) throws {
     let ds: DirectoryString? = try DirectoryString(derEncoded: data)
     if let ds { print(": DirectoryString \(ds)") }
     var serializer = DER.Serializer()
     try ds!.serialize(into: &serializer)
     print(": DER.name \(serializer.serializedBytes)")
  }

  public static func showCertificate(file: String) throws {
     let url = URL(fileURLWithPath: file)
     if (!Console.exists(f: url.path)) { print(": CERT file not found.") } else {
         let data = try Data(contentsOf: url)
         let cert = try Certificate(derEncoded: Array(data))
         print(": Certificate \(cert)")
     }
  }

  public static func loop() throws {
     try showName(data: [48,13,49,11,48,9,6,3,85,4,6,19,2,85,65])
     try showDirectoryString(data: [19,3,49,50,51])
     try showCertificate(file: "ca.crt")
     print(": PASSED")
  }

}
