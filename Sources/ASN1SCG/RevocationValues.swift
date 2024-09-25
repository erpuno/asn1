// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Foundation

@usableFromInline struct RevocationValues: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var crlVals: [CertificateList]?
    @usableFromInline var ocspVals: [BasicOCSPResponse]?
    @usableFromInline var otherRevVals: OtherRevVals?
    @inlinable init(crlVals: [CertificateList]?, ocspVals: [BasicOCSPResponse]?, otherRevVals: OtherRevVals?) {
        self.crlVals = crlVals
        self.ocspVals = ocspVals
        self.otherRevVals = otherRevVals
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let crlVals: [CertificateList] = try DER.sequence(of: CertificateList.self, identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific), nodes: &nodes)
            let ocspVals: [BasicOCSPResponse] = try DER.sequence(of: BasicOCSPResponse.self, identifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific), nodes: &nodes)
            let otherRevVals: OtherRevVals? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific))
            return RevocationValues(crlVals: crlVals, ocspVals: ocspVals, otherRevVals: otherRevVals)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            if let crlVals = self.crlVals { try coder.serializeSequenceOf(crlVals, identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)) }
            if let ocspVals = self.ocspVals { try coder.serializeSequenceOf(ocspVals, identifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)) }
            if let otherRevVals = self.otherRevVals { try coder.serializeOptionalImplicitlyTagged(otherRevVals, withIdentifier: ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific)) }
        }
    }
}
