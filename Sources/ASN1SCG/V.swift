// Generated by ASN1SCG Compiler, Copyright © 2023 Namdak Tonpa.
import ASN1SCG
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct V: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var a: ArraySlice<UInt8>
    @usableFromInline var b: Bool
    @usableFromInline var c: ArraySlice<UInt8>
    @usableFromInline var d: V_d_Sequence
    @inlinable init(a: ArraySlice<UInt8>, b: Bool, c: ArraySlice<UInt8>, d: V_d_Sequence) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let a = try ArraySlice<UInt8>(derEncoded: &nodes)
            let b = try Bool(derEncoded: &nodes)
            let c = try ArraySlice<UInt8>(derEncoded: &nodes)
            let d = try V_d_Sequence(derEncoded: &nodes)
            return V(a: a, b: b, c: c, d: d)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.a)
            try coder.serialize(self.b)
            try coder.serialize(self.c)
            try coder.serialize(self.d)
        }
    }
}
