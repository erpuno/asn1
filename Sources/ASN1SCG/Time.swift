// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Foundation

@usableFromInline indirect enum Time: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .enumerated }
    case utcTime(UTCTime)
    case generalTime(GeneralizedTime)
    @inlinable init(derEncoded rootNode: ASN1Node, withIdentifier: ASN1Identifier) throws {
        switch rootNode.identifier {
            case UTCTime.defaultIdentifier:
                self = .utcTime(try UTCTime(derEncoded: rootNode))
            case GeneralizedTime.defaultIdentifier:
                self = .generalTime(try GeneralizedTime(derEncoded: rootNode))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier: ASN1Identifier) throws {
        switch self {
            case .utcTime(let utcTime): try coder.serialize(utcTime)
            case .generalTime(let generalTime): try coder.serialize(generalTime)
        }
    }

}