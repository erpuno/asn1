// Generated by ASN1SCG Compiler, Copyright © 2023 Namdak Tonpa.
import ASN1SCG
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct AddRequest: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var entry: ASN1OctetString
    @usableFromInline var attributes: [PartialAttribute]
    @inlinable init(entry: ASN1OctetString, attributes: [PartialAttribute]) {
        self.entry = entry
        self.attributes = attributes
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let entry = try ASN1OctetString(derEncoded: &nodes)
            let attributes = try DER.sequence(of: PartialAttribute.self, identifier: .sequence, nodes: &nodes)
            return AddRequest(entry: entry, attributes: attributes)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.entry)
            try coder.serializeSequenceOf(attributes)
        }
    }
}
