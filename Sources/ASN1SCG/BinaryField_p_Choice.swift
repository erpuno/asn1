// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Foundation

@usableFromInline indirect enum BinaryField_p_Choice: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .enumerated }
    case t(ArraySlice<UInt8>)
    case p(Pentanomial)
    @inlinable init(derEncoded rootNode: ASN1Node, withIdentifier: ASN1Identifier) throws {
        switch rootNode.identifier {
            case ArraySlice<UInt8>.defaultIdentifier:
                self = .t(try ArraySlice<UInt8>(derEncoded: rootNode))
            case Pentanomial.defaultIdentifier:
                self = .p(try Pentanomial(derEncoded: rootNode))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier: ASN1Identifier) throws {
        switch self {
            case .t(let t): try coder.serialize(t)
            case .p(let p): try coder.serialize(p)
        }
    }

}