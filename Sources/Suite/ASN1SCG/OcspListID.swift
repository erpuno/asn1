// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct OcspListID: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var ocspResponses: [OcspResponsesID]
    @inlinable init(ocspResponses: [OcspResponsesID]) {
        self.ocspResponses = ocspResponses
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let ocspResponses: [OcspResponsesID] = try DER.sequence(of: OcspResponsesID.self, identifier: .sequence, nodes: &nodes)
            return OcspListID(ocspResponses: ocspResponses)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serializeSequenceOf(ocspResponses)
        }
    }
}