// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Foundation

public struct HistoryStatus: DERImplicitlyTaggable, Hashable, Sendable, RawRepresentable {
    public static var defaultIdentifier: ASN1Identifier { .enumerated }
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.rawValue = try .init(derEncoded: rootNode, withIdentifier: identifier)
    }
    public func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try self.rawValue.serialize(into: &coder, withIdentifier: identifier)
    }
    static let updated = HistoryStatus(rawValue: 1)
    static let get = HistoryStatus(rawValue: 2)
    static let update = HistoryStatus(rawValue: 3)
    static let last_loaded = HistoryStatus(rawValue: 4)
    static let last_msg = HistoryStatus(rawValue: 5)
    static let get_reply = HistoryStatus(rawValue: 6)
    static let double_get = HistoryStatus(rawValue: 7)
    static let delete = HistoryStatus(rawValue: 8)
    static let image = HistoryStatus(rawValue: 9)
    static let video = HistoryStatus(rawValue: 10)
    static let file = HistoryStatus(rawValue: 11)
    static let link = HistoryStatus(rawValue: 12)
    static let audio = HistoryStatus(rawValue: 13)
    static let contact = HistoryStatus(rawValue: 14)
    static let location = HistoryStatus(rawValue: 15)
    static let text = HistoryStatus(rawValue: 16)
}
