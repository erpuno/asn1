// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct ExtensionAttribute: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var extension_attribute_type: ArraySlice<UInt8>
    @usableFromInline var extension_attribute_value: ASN1Any
    @inlinable init(extension_attribute_type: ArraySlice<UInt8>, extension_attribute_value: ASN1Any) {
        self.extension_attribute_type = extension_attribute_type
        self.extension_attribute_value = extension_attribute_value
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let extension_attribute_type: ArraySlice<UInt8> = (try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)))!
            let extension_attribute_value: ASN1Any = try DER.explicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) { node in return try ASN1Any(derEncoded: node) }
            return ExtensionAttribute(extension_attribute_type: extension_attribute_type, extension_attribute_value: extension_attribute_value)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serializeOptionalImplicitlyTagged(extension_attribute_type, withIdentifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific))
            try coder.serialize(explicitlyTaggedWithTagNumber: 1, tagClass: .contextSpecific) { codec in try codec.serialize(extension_attribute_value) }
        }
    }
}