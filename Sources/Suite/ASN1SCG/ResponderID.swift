// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline indirect enum ResponderID: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .enumerated }
    case byName(Name)
    case byKey(ASN1OctetString)
    @inlinable init(derEncoded rootNode: ASN1Node, withIdentifier: ASN1Identifier) throws {
        switch rootNode.identifier {
            case ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific):
                self = .byName(try Name(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific):
                self = .byKey(try ASN1OctetString(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier: ASN1Identifier) throws {
        switch self {
            case .byName(let byName):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific),
                { coder in try coder.serialize(byName) })
            case .byKey(let byKey):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific),
                { coder in try coder.serialize(byKey) })
        }
    }

}