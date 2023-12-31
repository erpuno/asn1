// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct TeletexDomainDefinedAttribute: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var type: ASN1TeletexString
    @usableFromInline var value: ASN1TeletexString
    @inlinable init(type: ASN1TeletexString, value: ASN1TeletexString) {
        self.type = type
        self.value = value
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let type: ASN1TeletexString = try ASN1TeletexString(derEncoded: &nodes)
            let value: ASN1TeletexString = try ASN1TeletexString(derEncoded: &nodes)
            return TeletexDomainDefinedAttribute(type: type, value: value)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(type)
            try coder.serialize(value)
        }
    }
}
