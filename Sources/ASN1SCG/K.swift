// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct K: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var version: K_version_IntEnum
    @usableFromInline var x: ArraySlice<UInt8>
    @usableFromInline var y: K_y_Sequence
    @inlinable init(version: K_version_IntEnum, x: ArraySlice<UInt8>, y: K_y_Sequence) {
        self.version = version
        self.x = x
        self.y = y
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let version = try K_version_IntEnum(rawValue: Int(derEncoded: &nodes))
            let x: ArraySlice<UInt8> = try ArraySlice<UInt8>(derEncoded: &nodes)
            let y: K_y_Sequence = try K_y_Sequence(derEncoded: &nodes)
            return K(version: version, x: x, y: y)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(version.rawValue)
            try coder.serialize(x)
            try coder.serialize(y)
        }
    }
}
