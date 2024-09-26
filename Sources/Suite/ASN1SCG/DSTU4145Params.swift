// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct DSTU4145Params: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var definition: DSTU4145Params_definition_Choice
    @usableFromInline var dke: ASN1OctetString?
    @inlinable init(definition: DSTU4145Params_definition_Choice, dke: ASN1OctetString?) {
        self.definition = definition
        self.dke = dke
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let definition: DSTU4145Params_definition_Choice = try DSTU4145Params_definition_Choice(derEncoded: &nodes)
            let dke: ASN1OctetString? = try ASN1OctetString(derEncoded: &nodes)
            return DSTU4145Params(definition: definition, dke: dke)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(definition)
            if let dke = self.dke { try coder.serialize(dke) }
        }
    }
}
