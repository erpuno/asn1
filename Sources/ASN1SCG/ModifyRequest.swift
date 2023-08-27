// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct ModifyRequest: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var object: ASN1OctetString
    @usableFromInline var changes: [ModifyRequest_changes_Sequence]
    @inlinable init(object: ASN1OctetString, changes: [ModifyRequest_changes_Sequence]) {
        self.object = object
        self.changes = changes
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let object: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let changes: [ModifyRequest_changes_Sequence] = try DER.sequence(of: ModifyRequest_changes_Sequence.self, identifier: .sequence, nodes: &nodes)
            return ModifyRequest(object: object, changes: changes)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(object)
            try coder.appendConstructedNode(identifier: .sequence) { codec in for x in changes { try codec.serialize(x) } }
        }
    }
}
