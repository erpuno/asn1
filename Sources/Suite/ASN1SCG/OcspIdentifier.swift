// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct OcspIdentifier: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var ocspResponderID: ResponderID
    @usableFromInline var producedAt: GeneralizedTime
    @inlinable init(ocspResponderID: ResponderID, producedAt: GeneralizedTime) {
        self.ocspResponderID = ocspResponderID
        self.producedAt = producedAt
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let ocspResponderID: ResponderID = try ResponderID(derEncoded: &nodes)
            let producedAt: GeneralizedTime = try GeneralizedTime(derEncoded: &nodes)
            return OcspIdentifier(ocspResponderID: ocspResponderID, producedAt: producedAt)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(ocspResponderID)
            try coder.serialize(producedAt)
        }
    }
}
