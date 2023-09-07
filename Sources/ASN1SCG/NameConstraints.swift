// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct NameConstraints: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var permittedSubtrees: [GeneralSubtree]?
    @usableFromInline var excludedSubtrees: [GeneralSubtree]?
    @inlinable init(permittedSubtrees: [GeneralSubtree]?, excludedSubtrees: [GeneralSubtree]?) {
        self.permittedSubtrees = permittedSubtrees
        self.excludedSubtrees = excludedSubtrees
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let permittedSubtrees: [GeneralSubtree] = try DER.sequence(of: GeneralSubtree.self, identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific), nodes: &nodes)
            let excludedSubtrees: [GeneralSubtree] = try DER.sequence(of: GeneralSubtree.self, identifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific), nodes: &nodes)
            return NameConstraints(permittedSubtrees: permittedSubtrees, excludedSubtrees: excludedSubtrees)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            if let permittedSubtrees = self.permittedSubtrees { try coder.serializeSequenceOf(permittedSubtrees, identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)) }
            if let excludedSubtrees = self.excludedSubtrees { try coder.serializeSequenceOf(excludedSubtrees, identifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)) }
        }
    }
}
