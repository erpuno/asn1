// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct EncapsulatedContentInfo: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var eContentType: ASN1ObjectIdentifier
    @usableFromInline var eContent: ASN1OctetString?
    @inlinable init(eContentType: ASN1ObjectIdentifier, eContent: ASN1OctetString?) {
        self.eContentType = eContentType
        self.eContent = eContent
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let eContentType: ASN1ObjectIdentifier = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let eContent: ASN1OctetString? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in return try ASN1OctetString(derEncoded: node) }
            return EncapsulatedContentInfo(eContentType: eContentType, eContent: eContent)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(eContentType)
            if let eContent = self.eContent { try coder.serialize(explicitlyTaggedWithTagNumber: 0, tagClass: .contextSpecific) { codec in try codec.serialize(eContent) } }
        }
    }
}
