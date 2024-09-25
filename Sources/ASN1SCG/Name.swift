// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline indirect enum Name: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    case rdnSequence([[AttributeTypeAndValue]])
    @inlinable
    public static var defaultIdentifier: ASN1Identifier {
        .set
    }
    @inlinable init(derEncoded root: ASN1Node, withIdentifier: ASN1Identifier) throws {
        switch root.identifier {
            case .sequence:
                self = .rdnSequence(try DER.sequence<[[AttributeTypeAndValue]]>(root, identifier: .sequence) { nodes in
                    var rdnSequenceAcc: [[AttributeTypeAndValue]] = []
                    while let rdnSequenceInner = nodes.next() {
                        rdnSequenceAcc.append(try DER.sequence(of: AttributeTypeAndValue.self, identifier: .sequence, rootNode: rdnSequenceInner))
                    }
                    return rdnSequenceAcc
                })
            default: throw ASN1Error.unexpectedFieldType(root.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier: ASN1Identifier) throws {
        switch self {
            case .rdnSequence(let rdnSequence):
            try coder.appendConstructedNode(identifier: ASN1Identifier.sequence) { codec in
                for element in rdnSequence {
                    try codec.serializeSequenceOf(element)
                }
            }
        }
    }
}
