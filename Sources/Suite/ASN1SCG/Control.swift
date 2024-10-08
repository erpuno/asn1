// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct Control: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var controlType: ASN1OctetString
    @usableFromInline var criticality: Bool
    @usableFromInline var controlValue: ASN1OctetString?
    @inlinable init(controlType: ASN1OctetString, criticality: Bool, controlValue: ASN1OctetString?) {
        self.controlType = controlType
        self.criticality = criticality
        self.controlValue = controlValue
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let controlType: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let criticality: Bool = try DER.decodeDefault(&nodes, defaultValue: false)
            let controlValue: ASN1OctetString? = try ASN1OctetString(derEncoded: &nodes)
            return Control(controlType: controlType, criticality: criticality, controlValue: controlValue)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(controlType)
            try coder.serialize(criticality)
            if let controlValue = self.controlValue { try coder.serialize(controlValue) }
        }
    }
}
