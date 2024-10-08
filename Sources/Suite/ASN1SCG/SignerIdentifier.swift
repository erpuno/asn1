// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline indirect enum SignerIdentifier: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .enumerated }
    case issuerAndSerialNumber(IssuerAndSerialNumber)
    case subjectKeyIdentifier(ASN1OctetString)
    @inlinable init(derEncoded rootNode: ASN1Node, withIdentifier: ASN1Identifier) throws {
        switch rootNode.identifier {
            case IssuerAndSerialNumber.defaultIdentifier:
                self = .issuerAndSerialNumber(try IssuerAndSerialNumber(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific):
                self = .subjectKeyIdentifier(try ASN1OctetString(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier: ASN1Identifier) throws {
        switch self {
            case .issuerAndSerialNumber(let issuerAndSerialNumber): try coder.serialize(issuerAndSerialNumber)
            case .subjectKeyIdentifier(let subjectKeyIdentifier):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific),
                { coder in try coder.serialize(subjectKeyIdentifier) })
        }
    }

}
