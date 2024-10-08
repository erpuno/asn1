// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline indirect enum CHATProtocol: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .enumerated }
    case register(Register)
    case auth(Auth)
    case feature(Feature)
    case service(Service)
    case message(Message)
    case profile(Profile)
    case room(Room)
    case member(Member)
    case search(Search)
    case file(FileDesc)
    case typing(Typing)
    case friend(Friend)
    case presence(Presence)
    case history(History)
    case roster(Roster)
    @inlinable init(derEncoded rootNode: ASN1Node, withIdentifier: ASN1Identifier) throws {
        switch rootNode.identifier {
            case ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific):
                self = .register(try Register(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific):
                self = .auth(try Auth(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific):
                self = .feature(try Feature(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 3, tagClass: .contextSpecific):
                self = .service(try Service(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 4, tagClass: .contextSpecific):
                self = .message(try Message(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 5, tagClass: .contextSpecific):
                self = .profile(try Profile(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 6, tagClass: .contextSpecific):
                self = .room(try Room(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 7, tagClass: .contextSpecific):
                self = .member(try Member(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 8, tagClass: .contextSpecific):
                self = .search(try Search(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 9, tagClass: .contextSpecific):
                self = .file(try FileDesc(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 10, tagClass: .contextSpecific):
                self = .typing(try Typing(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 11, tagClass: .contextSpecific):
                self = .friend(try Friend(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 12, tagClass: .contextSpecific):
                self = .presence(try Presence(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 13, tagClass: .contextSpecific):
                self = .history(try History(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 14, tagClass: .contextSpecific):
                self = .roster(try Roster(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier: ASN1Identifier) throws {
        switch self {
            case .register(let register):
                try coder.serializeOptionalImplicitlyTagged(register, withIdentifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific))
                //try coder.appendConstructedNode(
                //identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific),
                //{ coder in try coder.serialize(register, explicitlyTaggedWithIdentifier: withIdentifier) })
            case .auth(let auth):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific),
                { coder in try coder.serialize(auth) })
            case .feature(let feature):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific),
                { coder in try coder.serialize(feature) })
            case .service(let service):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 3, tagClass: .contextSpecific),
                { coder in try coder.serialize(service) })
            case .message(let message):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 4, tagClass: .contextSpecific),
                { coder in try coder.serialize(message) })
            case .profile(let profile):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 5, tagClass: .contextSpecific),
                { coder in try coder.serialize(profile) })
            case .room(let room):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 6, tagClass: .contextSpecific),
                { coder in try coder.serialize(room) })
            case .member(let member):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 7, tagClass: .contextSpecific),
                { coder in try coder.serialize(member) })
            case .search(let search):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 8, tagClass: .contextSpecific),
                { coder in try coder.serialize(search) })
            case .file(let file):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 9, tagClass: .contextSpecific),
                { coder in try coder.serialize(file) })
            case .typing(let typing):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 10, tagClass: .contextSpecific),
                { coder in try coder.serialize(typing) })
            case .friend(let friend):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 11, tagClass: .contextSpecific),
                { coder in try coder.serialize(friend) })
            case .presence(let presence):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 12, tagClass: .contextSpecific),
                { coder in try coder.serialize(presence) })
            case .history(let history):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 13, tagClass: .contextSpecific),
                { coder in try coder.serialize(history) })
            case .roster(let roster):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 14, tagClass: .contextSpecific),
                { coder in try coder.serialize(roster) })
        }
    }

}
