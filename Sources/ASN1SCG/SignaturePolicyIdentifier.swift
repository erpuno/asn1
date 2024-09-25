// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Foundation

@usableFromInline indirect enum SignaturePolicyIdentifier: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .enumerated }
    case signaturePolicy(SignaturePolicyId)
    @inlinable init(derEncoded rootNode: ASN1Node, withIdentifier: ASN1Identifier) throws {
        switch rootNode.identifier {
            case SignaturePolicyId.defaultIdentifier:
                self = .signaturePolicy(try SignaturePolicyId(derEncoded: rootNode))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier: ASN1Identifier) throws {
        switch self {
            case .signaturePolicy(let signaturePolicy): try coder.serialize(signaturePolicy)
        }
    }

}