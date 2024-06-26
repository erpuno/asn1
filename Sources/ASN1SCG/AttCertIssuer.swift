// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline indirect enum AttCertIssuer: DERParseable, DERSerializable, Hashable, Sendable {
    case v1Form([GeneralName])
    case v2Form(V2Form)
    @inlinable init(derEncoded rootNode: ASN1Node) throws {
        switch rootNode.identifier {
            case [GeneralName].defaultIdentifier:
                self = .v1Form(try [GeneralName](derEncoded: rootNode))
            case ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific):
                self = .v2Form(try V2Form(derEncoded: rootNode))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer) throws {
        switch self {
            case .v1Form(let v1Form): try coder.serialize(v1Form)
            case .v2Form(let v2Form):
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific),
                { coder in try coder.serialize(v2Form) })
        }
    }

}
