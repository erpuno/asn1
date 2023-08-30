// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline indirect enum History_feed_Choice: DERParseable, DERSerializable, Hashable, Sendable {
    case p2p(P2P)
    case muc(MUC)
    @inlinable init(derEncoded rootNode: ASN1Node) throws {
        switch rootNode.identifier {
            case ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific):
                self = .p2p(try P2P(derEncoded: rootNode))
            case ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific):
                self = .muc(try MUC(derEncoded: rootNode))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer) throws {
        switch self {
            case .p2p(let p2p):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific),
                { coder in try coder.serialize(p2p) })
            case .muc(let muc):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific),
                { coder in try coder.serialize(muc) })
        }
    }

}