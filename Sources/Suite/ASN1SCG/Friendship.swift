// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

public struct Friendship: DERImplicitlyTaggable, Hashable, Sendable, RawRepresentable {
    public static var defaultIdentifier: ASN1Identifier { .enumerated }
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.rawValue = try .init(derEncoded: rootNode, withIdentifier: identifier)
    }
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try self.rawValue.serialize(into: &coder, withIdentifier: identifier)
    }
    static let request = Friendship(rawValue: 1)
    static let confirm = Friendship(rawValue: 2)
    static let update = Friendship(rawValue: 3)
    static let ignore = Friendship(rawValue: 4)
    static let ban = Friendship(rawValue: 5)
    static let unban = Friendship(rawValue: 6)
}
