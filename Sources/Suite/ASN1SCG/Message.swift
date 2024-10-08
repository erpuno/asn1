// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct Message: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var id: ASN1OctetString
    @usableFromInline var feed_id: Message_feed_id_Choice
    @usableFromInline var signature: ASN1OctetString
    @usableFromInline var from: ASN1OctetString
    @usableFromInline var to: ASN1OctetString
    @usableFromInline var created: ArraySlice<UInt8>
    @usableFromInline var files: [FileDesc]
    @usableFromInline var type: MessageType
    @usableFromInline var link: ArraySlice<UInt8>
    @usableFromInline var seenby: ASN1OctetString
    @usableFromInline var repliedby: ASN1OctetString
    @usableFromInline var mentioned: [ASN1OctetString]
    @usableFromInline var status: MessageStatus
    @inlinable init(id: ASN1OctetString, feed_id: Message_feed_id_Choice, signature: ASN1OctetString, from: ASN1OctetString, to: ASN1OctetString, created: ArraySlice<UInt8>, files: [FileDesc], type: MessageType, link: ArraySlice<UInt8>, seenby: ASN1OctetString, repliedby: ASN1OctetString, mentioned: [ASN1OctetString], status: MessageStatus) {
        self.id = id
        self.feed_id = feed_id
        self.signature = signature
        self.from = from
        self.to = to
        self.created = created
        self.files = files
        self.type = type
        self.link = link
        self.seenby = seenby
        self.repliedby = repliedby
        self.mentioned = mentioned
        self.status = status
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let id: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let feed_id: Message_feed_id_Choice = try Message_feed_id_Choice(derEncoded: &nodes)
            let signature: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let from: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let to: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let created: ArraySlice<UInt8> = try ArraySlice<UInt8>(derEncoded: &nodes)
            let files: [FileDesc] = try DER.sequence(of: FileDesc.self, identifier: .sequence, nodes: &nodes)
            let type: MessageType = try MessageType(derEncoded: &nodes)
            let link: ArraySlice<UInt8> = try ArraySlice<UInt8>(derEncoded: &nodes)
            let seenby: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let repliedby: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let mentioned: [ASN1OctetString] = try DER.sequence(of: ASN1OctetString.self, identifier: .sequence, nodes: &nodes)
            let status: MessageStatus = try MessageStatus(derEncoded: &nodes)
            return Message(id: id, feed_id: feed_id, signature: signature, from: from, to: to, created: created, files: files, type: type, link: link, seenby: seenby, repliedby: repliedby, mentioned: mentioned, status: status)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(id)
            try coder.serialize(feed_id)
            try coder.serialize(signature)
            try coder.serialize(from)
            try coder.serialize(to)
            try coder.serialize(created)
            try coder.serializeSequenceOf(files)
            try coder.serialize(type)
            try coder.serialize(link)
            try coder.serialize(seenby)
            try coder.serialize(repliedby)
            try coder.serializeSequenceOf(mentioned)
            try coder.serialize(status)
        }
    }
}
