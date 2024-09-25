// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Foundation

@usableFromInline struct P2P: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var src: ASN1OctetString
    @usableFromInline var dst: ASN1OctetString
    @inlinable init(src: ASN1OctetString, dst: ASN1OctetString) {
        self.src = src
        self.dst = dst
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let src: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let dst: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            return P2P(src: src, dst: dst)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(src)
            try coder.serialize(dst)
        }
    }
}
