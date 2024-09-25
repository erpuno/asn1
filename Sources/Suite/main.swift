import SwiftASN1
import Foundation

try Console.loop()

public class Console {

  public static func exists(f: String) -> Bool { return FileManager.default.fileExists(atPath: f) }

  public static func showName(data: Array<UInt8>) throws {
     let name: Name? = try Name(derEncoded: data)
     if let name { print(": name \(name)") }
     var serializer = DER.Serializer()
     try name!.serialize(into: &serializer)
     print(": DER.name \(serializer.serializedBytes)")
  }

  public static func showCertificate(file: String) throws {
     let url = URL(fileURLWithPath: file)
     if (!Console.exists(f: url.path)) { print(": CERT file not found.") } else {
         let data = try Data(contentsOf: url)
         let cert = try Certificate(derEncoded: Array(data))
         print(": \(cert)")
     }
  }

  public static func loop() throws {
     try showName(data: [48,13,49,11,48,9,6,3,85,4,6,19,2,85,65])
     try showCertificate(file: "ca.crt")
     print(": PASSED")
  }

}
