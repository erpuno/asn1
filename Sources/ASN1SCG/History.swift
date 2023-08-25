// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import ASN1SCG
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct History: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var nickname: ASN1OctetString
    @usableFromInline var feed: History_feed_Choice
    @usableFromInline var size: ArraySlice<UInt8>
    @usableFromInline var entity_id: ArraySlice<UInt8>
    @usableFromInline var data: [Message]
    @usableFromInline var status: HistoryStatus
    @inlinable init(nickname: ASN1OctetString, feed: History_feed_Choice, size: ArraySlice<UInt8>, entity_id: ArraySlice<UInt8>, data: [Message], status: HistoryStatus) {
        self.nickname = nickname
        self.feed = feed
        self.size = size
        self.entity_id = entity_id
        self.data = data
        self.status = status
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let nickname = try ASN1OctetString(derEncoded: &nodes)
            let feed = try History_feed_Choice(derEncoded: &nodes)
            let size = try ArraySlice<UInt8>(derEncoded: &nodes)
            let entity_id = try ArraySlice<UInt8>(derEncoded: &nodes)
            let data = try DER.sequence(of: Message.self, identifier: .sequence, nodes: &nodes)
            let status = try HistoryStatus(derEncoded: &nodes)
            return History(nickname: nickname, feed: feed, size: size, entity_id: entity_id, data: data, status: status)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.nickname)
            try coder.serialize(self.feed)
            try coder.serialize(self.size)
            try coder.serialize(self.entity_id)
            try coder.serializeSequenceOf(data)
            try coder.serialize(self.status)
        }
    }
}
