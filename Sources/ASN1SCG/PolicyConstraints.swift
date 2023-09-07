// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct PolicyConstraints: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var requireExplicitPolicy: ArraySlice<UInt8>?
    @usableFromInline var inhibitPolicyMapping: ArraySlice<UInt8>?
    @inlinable init(requireExplicitPolicy: ArraySlice<UInt8>?, inhibitPolicyMapping: ArraySlice<UInt8>?) {
        self.requireExplicitPolicy = requireExplicitPolicy
        self.inhibitPolicyMapping = inhibitPolicyMapping
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let requireExplicitPolicy: ArraySlice<UInt8>? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific))
            let inhibitPolicyMapping: ArraySlice<UInt8>? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific))
            return PolicyConstraints(requireExplicitPolicy: requireExplicitPolicy, inhibitPolicyMapping: inhibitPolicyMapping)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            if let requireExplicitPolicy = self.requireExplicitPolicy { try coder.serializeOptionalImplicitlyTagged(requireExplicitPolicy, withIdentifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)) }
            if let inhibitPolicyMapping = self.inhibitPolicyMapping { try coder.serializeOptionalImplicitlyTagged(inhibitPolicyMapping, withIdentifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)) }
        }
    }
}
