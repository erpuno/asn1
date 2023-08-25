// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

public struct RoomStatus: DERImplicitlyTaggable, Hashable, RawRepresentable {
    public static var defaultIdentifier: ASN1Identifier { .enumerated }
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.rawValue = try .init(derEncoded: rootNode, withIdentifier: identifier)
    }
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try self.rawValue.serialize(into: &coder, withIdentifier: identifier)
    }
    static let create = RoomStatus(rawValue: 1)
    static let leave = RoomStatus(rawValue: 2)
    static let add = RoomStatus(rawValue: 3)
    static let remove = RoomStatus(rawValue: 4)
    static let removed = RoomStatus(rawValue: 5)
    static let join = RoomStatus(rawValue: 6)
    static let joined = RoomStatus(rawValue: 7)
    static let info = RoomStatus(rawValue: 8)
    static let patch = RoomStatus(rawValue: 9)
    static let get = RoomStatus(rawValue: 10)
    static let delete = RoomStatus(rawValue: 11)
    static let last_msg = RoomStatus(rawValue: 12)
    static let mute = RoomStatus(rawValue: 13)
    static let unmute = RoomStatus(rawValue: 14)

}
