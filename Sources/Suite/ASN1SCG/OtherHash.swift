// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline indirect enum OtherHash: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .enumerated }
    case sha1Hash(ASN1OctetString)
    case otherHash(OtherHashAlgAndValue)
    @inlinable init(derEncoded rootNode: ASN1Node, withIdentifier: ASN1Identifier) throws {
        switch rootNode.identifier {
            case ASN1OctetString.defaultIdentifier:
                self = .sha1Hash(try ASN1OctetString(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            case OtherHashAlgAndValue.defaultIdentifier:
                self = .otherHash(try OtherHashAlgAndValue(derEncoded: rootNode, withIdentifier: rootNode.identifier))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier: ASN1Identifier) throws {
        switch self {
            case .sha1Hash(let sha1Hash): try coder.serialize(sha1Hash)
            case .otherHash(let otherHash): try coder.serialize(otherHash)
        }
    }

}
