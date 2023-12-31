// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline indirect enum ExtendedNetworkAddress: DERParseable, DERSerializable, Hashable, Sendable {
    case e163_4_address(ExtendedNetworkAddress_e163_4_address_Sequence)
    case psap_address(PresentationAddress)
    @inlinable init(derEncoded rootNode: ASN1Node) throws {
        switch rootNode.identifier {
            case ExtendedNetworkAddress_e163_4_address_Sequence.defaultIdentifier:
                self = .e163_4_address(try ExtendedNetworkAddress_e163_4_address_Sequence(derEncoded: rootNode))
            case ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific):
                self = .psap_address(try PresentationAddress(derEncoded: rootNode))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer) throws {
        switch self {
            case .e163_4_address(let e163_4_address): try coder.serialize(e163_4_address)
            case .psap_address(let psap_address):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific),
                { coder in try coder.serialize(psap_address) })
        }
    }

}
