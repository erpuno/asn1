// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct OtherRevVals: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var otherRevValType: ASN1ObjectIdentifier
    @inlinable init(otherRevValType: ASN1ObjectIdentifier) {
        self.otherRevValType = otherRevValType
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let otherRevValType: ASN1ObjectIdentifier = try ASN1ObjectIdentifier(derEncoded: &nodes)
            return OtherRevVals(otherRevValType: otherRevValType)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(otherRevValType)
        }
    }
}
