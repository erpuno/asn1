// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

public struct ObjectDigestInfo_digestedObjectType_Enum: DERImplicitlyTaggable, Hashable, Sendable, RawRepresentable {
    public static var defaultIdentifier: ASN1Identifier { .enumerated }
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.rawValue = try .init(derEncoded: rootNode, withIdentifier: identifier)
    }
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try self.rawValue.serialize(into: &coder, withIdentifier: identifier)
    }
    static let publicKey = ObjectDigestInfo_digestedObjectType_Enum(rawValue: 0)
    static let publicKeyCert = ObjectDigestInfo_digestedObjectType_Enum(rawValue: 1)
    static let otherObjectTypes = ObjectDigestInfo_digestedObjectType_Enum(rawValue: 2)
}
