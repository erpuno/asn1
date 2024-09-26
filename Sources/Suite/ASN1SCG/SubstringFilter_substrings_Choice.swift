// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline indirect enum SubstringFilter_substrings_Choice: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .enumerated }
    case initial(ASN1OctetString)
    case any(ASN1OctetString)
    case final(ASN1OctetString)
    @inlinable init(derEncoded rootNode: ASN1Node, withIdentifier: ASN1Identifier) throws {
        switch rootNode.identifier {
            case ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific):
                self = .initial(try ASN1OctetString(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific):
                self = .any(try ASN1OctetString(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific):
                self = .final(try ASN1OctetString(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier: ASN1Identifier) throws {
        switch self {
            case .initial(let initial):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific),
                { coder in try coder.serialize(initial) })
            case .any(let any):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific),
                { coder in try coder.serialize(any) })
            case .final(let final):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific),
                { coder in try coder.serialize(final) })
        }
    }

}
