// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

public struct RosterStatus: DERImplicitlyTaggable, Hashable, Sendable, RawRepresentable {
    public static var defaultIdentifier: ASN1Identifier { .enumerated }
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.rawValue = try .init(derEncoded: rootNode, withIdentifier: identifier)
    }
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try self.rawValue.serialize(into: &coder, withIdentifier: identifier)
    }
    static let get = RosterStatus(rawValue: 1)
    static let create = RosterStatus(rawValue: 2)
    static let del = RosterStatus(rawValue: 3)
    static let remove = RosterStatus(rawValue: 4)
    static let nick = RosterStatus(rawValue: 5)
    static let search = RosterStatus(rawValue: 6)
    static let contact = RosterStatus(rawValue: 7)
    static let add = RosterStatus(rawValue: 8)
    static let update = RosterStatus(rawValue: 9)
    static let list = RosterStatus(rawValue: 10)
    static let patch = RosterStatus(rawValue: 11)
    static let last_msg = RosterStatus(rawValue: 12)
}
