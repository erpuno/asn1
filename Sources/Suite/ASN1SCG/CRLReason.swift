// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

public struct CRLReason: DERImplicitlyTaggable, Hashable, Sendable, RawRepresentable {
    public static var defaultIdentifier: ASN1Identifier { .enumerated }
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.rawValue = try .init(derEncoded: rootNode, withIdentifier: identifier)
    }
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try self.rawValue.serialize(into: &coder, withIdentifier: identifier)
    }
    static let unspecified = CRLReason(rawValue: 0)
    static let keyCompromise = CRLReason(rawValue: 1)
    static let cACompromise = CRLReason(rawValue: 2)
    static let affiliationChanged = CRLReason(rawValue: 3)
    static let superseded = CRLReason(rawValue: 4)
    static let cessationOfOperation = CRLReason(rawValue: 5)
    static let certificateHold = CRLReason(rawValue: 6)
    static let removeFromCRL = CRLReason(rawValue: 8)
    static let privilegeWithdrawn = CRLReason(rawValue: 9)
    static let aACompromise = CRLReason(rawValue: 10)
}
