// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct PrivateKeyUsagePeriod: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var notBefore: GeneralizedTime?
    @usableFromInline var notAfter: GeneralizedTime?
    @inlinable init(notBefore: GeneralizedTime?, notAfter: GeneralizedTime?) {
        self.notBefore = notBefore
        self.notAfter = notAfter
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let notBefore: GeneralizedTime? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific))
            let notAfter: GeneralizedTime? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific))
            return PrivateKeyUsagePeriod(notBefore: notBefore, notAfter: notAfter)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            if let notBefore = self.notBefore { try coder.serializeOptionalImplicitlyTagged(notBefore, withIdentifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)) }
            if let notAfter = self.notAfter { try coder.serializeOptionalImplicitlyTagged(notAfter, withIdentifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)) }
        }
    }
}
