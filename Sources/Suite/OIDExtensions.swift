
import SwiftASN1
import Foundation

extension ASN1ObjectIdentifier {
    /// Appends an array of integers to an existing OID.
    /// This allows syntax like `BaseOID + [1, 2, 3]`.
    public static func + (lhs: ASN1ObjectIdentifier, rhs: [Int]) -> ASN1ObjectIdentifier {
        let suffix = rhs.map { String($0) }.joined(separator: ".")
        // If lhs is empty? OIDs shouldn't be empty usually.
        // description gives "1.2.3".
        let newString = lhs.description + "." + suffix
        // Initialize from string. Force unwrap as we assume valid generation.
        return try! ASN1ObjectIdentifier(oidString: newString)
    }
    
    public static func + (lhs: ASN1ObjectIdentifier, rhs: [UInt]) -> ASN1ObjectIdentifier {
        let suffix = rhs.map { String($0) }.joined(separator: ".")
        let newString = lhs.description + "." + suffix
        return try! ASN1ObjectIdentifier(oidString: newString)
    }

    /// Appends a single integer.
    public static func + (lhs: ASN1ObjectIdentifier, rhs: Int) -> ASN1ObjectIdentifier {
        return lhs + [rhs]
    }
}
