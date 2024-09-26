// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct Roster: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var id: ASN1OctetString
    @usableFromInline var nickname: ASN1OctetString
    @usableFromInline var update: ArraySlice<UInt8>
    @usableFromInline var contacts: [Contact]
    @usableFromInline var topics: [Room]
    @usableFromInline var status: RosterStatus
    @inlinable init(id: ASN1OctetString, nickname: ASN1OctetString, update: ArraySlice<UInt8>, contacts: [Contact], topics: [Room], status: RosterStatus) {
        self.id = id
        self.nickname = nickname
        self.update = update
        self.contacts = contacts
        self.topics = topics
        self.status = status
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let id: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let nickname: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let update: ArraySlice<UInt8> = try ArraySlice<UInt8>(derEncoded: &nodes)
            let contacts: [Contact] = try DER.sequence(of: Contact.self, identifier: .sequence, nodes: &nodes)
            let topics: [Room] = try DER.sequence(of: Room.self, identifier: .sequence, nodes: &nodes)
            let status: RosterStatus = try RosterStatus(derEncoded: &nodes)
            return Roster(id: id, nickname: nickname, update: update, contacts: contacts, topics: topics, status: status)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(id)
            try coder.serialize(nickname)
            try coder.serialize(update)
            try coder.serializeSequenceOf(contacts)
            try coder.serializeSequenceOf(topics)
            try coder.serialize(status)
        }
    }
}
