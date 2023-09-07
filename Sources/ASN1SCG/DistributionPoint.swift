// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct DistributionPoint: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var distributionPoint: DistributionPointName?
    @usableFromInline var reasons: ASN1BitString?
    @usableFromInline var cRLIssuer: [GeneralName]?
    @inlinable init(distributionPoint: DistributionPointName?, reasons: ASN1BitString?, cRLIssuer: [GeneralName]?) {
        self.distributionPoint = distributionPoint
        self.reasons = reasons
        self.cRLIssuer = cRLIssuer
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            nodes.next()
            let distributionPoint: DistributionPointName? = try DistributionPointName(derEncoded: &nodes)
            let reasons: ASN1BitString? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific))
            let cRLIssuer: [GeneralName] = try DER.sequence(of: GeneralName.self, identifier: ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific), nodes: &nodes)
            return DistributionPoint(distributionPoint: distributionPoint, reasons: reasons, cRLIssuer: cRLIssuer)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            if let distributionPoint = self.distributionPoint { 
                try coder.appendConstructedNode(
                identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific),
                { coder in try coder.serialize(distributionPoint) })
            }
            if let reasons = self.reasons { try coder.serializeOptionalImplicitlyTagged(reasons, withIdentifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)) }
            if let cRLIssuer = self.cRLIssuer { try coder.serializeSequenceOf(cRLIssuer, identifier: ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific)) }
        }
    }
}
