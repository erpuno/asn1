// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline indirect enum Time: DERParseable, DERSerializable, Hashable, Sendable {
    case utcTime(UTCTime)
    case generalTime(GeneralizedTime)
    @inlinable init(derEncoded rootNode: ASN1Node) throws {
        switch rootNode.identifier {
            case UTCTime.defaultIdentifier:
                self = .utcTime(try UTCTime(derEncoded: rootNode))
            case GeneralizedTime.defaultIdentifier:
                self = .generalTime(try GeneralizedTime(derEncoded: rootNode))
            default: throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer) throws {
        switch self {
            case .utcTime(let utcTime): try coder.serialize(utcTime)
            case .generalTime(let generalTime): try coder.serialize(generalTime)
        }
    }

}
