// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct CRLListID: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var crls: [CrlValidatedID]
    @inlinable init(crls: [CrlValidatedID]) {
        self.crls = crls
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let crls: [CrlValidatedID] = try DER.sequence(of: CrlValidatedID.self, identifier: .sequence, nodes: &nodes)
            return CRLListID(crls: crls)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serializeSequenceOf(crls)
        }
    }
}
