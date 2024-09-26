// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct CrlOcspRef: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var crlids: CRLListID?
    @usableFromInline var ocspids: OcspListID?
    @usableFromInline var otherRev: OtherRevRefs?
    @inlinable init(crlids: CRLListID?, ocspids: OcspListID?, otherRev: OtherRevRefs?) {
        self.crlids = crlids
        self.ocspids = ocspids
        self.otherRev = otherRev
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let crlids: CRLListID? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific))
            let ocspids: OcspListID? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific))
            let otherRev: OtherRevRefs? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific))
            return CrlOcspRef(crlids: crlids, ocspids: ocspids, otherRev: otherRev)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            if let crlids = self.crlids { try coder.serializeOptionalImplicitlyTagged(crlids, withIdentifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)) }
            if let ocspids = self.ocspids { try coder.serializeOptionalImplicitlyTagged(ocspids, withIdentifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)) }
            if let otherRev = self.otherRev { try coder.serializeOptionalImplicitlyTagged(otherRev, withIdentifier: ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific)) }
        }
    }
}
