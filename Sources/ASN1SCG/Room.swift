// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import ASN1SCG
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct Room: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var id: ASN1OctetString
    @usableFromInline var name: ASN1OctetString
    @usableFromInline var links: [ASN1OctetString]
    @usableFromInline var description: ASN1OctetString
    @usableFromInline var settings: [Feature]
    @usableFromInline var members: [Member]
    @usableFromInline var admins: [Member]
    @usableFromInline var data: [FileDesc]
    @usableFromInline var type: RoomType
    @usableFromInline var tos: ASN1OctetString
    @usableFromInline var tos_update: ArraySlice<UInt8>
    @usableFromInline var unread: ArraySlice<UInt8>
    @usableFromInline var mentions: [ArraySlice<UInt8>]
    @usableFromInline var last_msg: Message
    @usableFromInline var update: ArraySlice<UInt8>
    @usableFromInline var created: ArraySlice<UInt8>
    @usableFromInline var status: RoomStatus
    @inlinable init(id: ASN1OctetString, name: ASN1OctetString, links: [ASN1OctetString], description: ASN1OctetString, settings: [Feature], members: [Member], admins: [Member], data: [FileDesc], type: RoomType, tos: ASN1OctetString, tos_update: ArraySlice<UInt8>, unread: ArraySlice<UInt8>, mentions: [ArraySlice<UInt8>], last_msg: Message, update: ArraySlice<UInt8>, created: ArraySlice<UInt8>, status: RoomStatus) {
        self.id = id
        self.name = name
        self.links = links
        self.description = description
        self.settings = settings
        self.members = members
        self.admins = admins
        self.data = data
        self.type = type
        self.tos = tos
        self.tos_update = tos_update
        self.unread = unread
        self.mentions = mentions
        self.last_msg = last_msg
        self.update = update
        self.created = created
        self.status = status
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let id = try ASN1OctetString(derEncoded: &nodes)
            let name = try ASN1OctetString(derEncoded: &nodes)
            let links = try DER.sequence(of: ASN1OctetString.self, identifier: .sequence, nodes: &nodes)
            let description = try ASN1OctetString(derEncoded: &nodes)
            let settings = try DER.sequence(of: Feature.self, identifier: .sequence, nodes: &nodes)
            let members = try DER.sequence(of: Member.self, identifier: .sequence, nodes: &nodes)
            let admins = try DER.sequence(of: Member.self, identifier: .sequence, nodes: &nodes)
            let data = try DER.sequence(of: FileDesc.self, identifier: .sequence, nodes: &nodes)
            let type = try RoomType(derEncoded: &nodes)
            let tos = try ASN1OctetString(derEncoded: &nodes)
            let tos_update = try ArraySlice<UInt8>(derEncoded: &nodes)
            let unread = try ArraySlice<UInt8>(derEncoded: &nodes)
            let mentions = try DER.sequence(of: ArraySlice<UInt8>.self, identifier: .sequence, nodes: &nodes)
            let last_msg = try Message(derEncoded: &nodes)
            let update = try ArraySlice<UInt8>(derEncoded: &nodes)
            let created = try ArraySlice<UInt8>(derEncoded: &nodes)
            let status = try RoomStatus(derEncoded: &nodes)
            return Room(id: id, name: name, links: links, description: description, settings: settings, members: members, admins: admins, data: data, type: type, tos: tos, tos_update: tos_update, unread: unread, mentions: mentions, last_msg: last_msg, update: update, created: created, status: status)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.id)
            try coder.serialize(self.name)
            try coder.serializeSequenceOf(links)
            try coder.serialize(self.description)
            try coder.serializeSequenceOf(settings)
            try coder.serializeSequenceOf(members)
            try coder.serializeSequenceOf(admins)
            try coder.serializeSequenceOf(data)
            try coder.serialize(self.type)
            try coder.serialize(self.tos)
            try coder.serialize(self.tos_update)
            try coder.serialize(self.unread)
            try coder.serializeSequenceOf(mentions)
            try coder.serialize(self.last_msg)
            try coder.serialize(self.update)
            try coder.serialize(self.created)
            try coder.serialize(self.status)
        }
    }
}
