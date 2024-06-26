// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct EDIPartyName: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var nameAssigner: DirectoryString?
    @usableFromInline var partyName: DirectoryString
    @inlinable init(nameAssigner: DirectoryString?, partyName: DirectoryString) {
        self.nameAssigner = nameAssigner
        self.partyName = partyName
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let nameAssigner: DirectoryString? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific))
            let partyName: DirectoryString = (try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)))!
            return EDIPartyName(nameAssigner: nameAssigner, partyName: partyName)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            if let nameAssigner = self.nameAssigner { try coder.serializeOptionalImplicitlyTagged(nameAssigner, withIdentifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)) }
            try coder.serializeOptionalImplicitlyTagged(partyName, withIdentifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific))
        }
    }
}
