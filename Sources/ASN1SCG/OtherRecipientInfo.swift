// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct OtherRecipientInfo: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var oriType: ASN1ObjectIdentifier
    @usableFromInline var oriValue: ASN1Any
    @inlinable init(oriType: ASN1ObjectIdentifier, oriValue: ASN1Any) {
        self.oriType = oriType
        self.oriValue = oriValue
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let oriType: ASN1ObjectIdentifier = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let oriValue: ASN1Any = try ASN1Any(derEncoded: &nodes)
            return OtherRecipientInfo(oriType: oriType, oriValue: oriValue)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(oriType)
            try coder.serialize(oriValue)
        }
    }
}