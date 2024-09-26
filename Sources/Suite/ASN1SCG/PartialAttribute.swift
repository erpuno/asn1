// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct PartialAttribute: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var type: ASN1OctetString
    @usableFromInline var vals: [ASN1OctetString]
    @inlinable init(type: ASN1OctetString, vals: [ASN1OctetString]) {
        self.type = type
        self.vals = vals
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let type: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let vals: [ASN1OctetString] = try DER.set(of: ASN1OctetString.self, identifier: .set, nodes: &nodes)
            return PartialAttribute(type: type, vals: vals)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(type)
            try coder.serializeSetOf(vals)
        }
    }
}
