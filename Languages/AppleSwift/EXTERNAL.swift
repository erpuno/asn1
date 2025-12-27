// EXTERNAL type definition for ASN.1 DER encoding/decoding
// Based on ITU-T X.680/X.690 specification
// EXTERNAL ::= [UNIVERSAL 8] IMPLICIT SEQUENCE {
//     direct-reference       OBJECT IDENTIFIER OPTIONAL,
//     indirect-reference     INTEGER OPTIONAL,
//     data-value-descriptor  ObjectDescriptor OPTIONAL,
//     encoding               CHOICE {
//         single-ASN1-type   [0] EXPLICIT ANY,
//         octet-aligned      [1] IMPLICIT OCTET STRING,
//         arbitrary          [2] IMPLICIT BIT STRING
//     }
// }

import SwiftASN1
import Foundation

/// The encoding choice within an EXTERNAL type
@usableFromInline indirect enum EXTERNAL_Encoding: DERImplicitlyTaggable, DERParseable, DERSerializable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .enumerated }
    
    case singleASN1Type(ASN1Any)
    case octetAligned(ASN1OctetString)
    case arbitrary(ASN1BitString)
    
    @inlinable init(derEncoded rootNode: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        switch rootNode.identifier {
        case ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific):
            // [0] EXPLICIT ANY - need to unwrap the explicit tag
            guard case .constructed(let nodes) = rootNode.content else {
                throw ASN1Error.invalidASN1Object(reason: "Expected constructed node for single-ASN1-type")
            }
            var iterator = nodes.makeIterator()
            guard let innerNode = iterator.next() else {
                throw ASN1Error.invalidASN1Object(reason: "Empty single-ASN1-type encoding")
            }
            self = .singleASN1Type(ASN1Any(derEncoded: innerNode))
        case ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific):
            // [1] IMPLICIT OCTET STRING
            self = .octetAligned(try ASN1OctetString(derEncoded: rootNode, withIdentifier: rootNode.identifier))
        case ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific):
            // [2] IMPLICIT BIT STRING
            self = .arbitrary(try ASN1BitString(derEncoded: rootNode, withIdentifier: rootNode.identifier))
        default:
            throw ASN1Error.unexpectedFieldType(rootNode.identifier)
        }
    }
    
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        switch self {
        case .singleASN1Type(let value):
            try coder.appendConstructedNode(identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)) { coder in
                try coder.serialize(value)
            }
        case .octetAligned(let value):
            try value.serialize(into: &coder, withIdentifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific))
        case .arbitrary(let value):
            try value.serialize(into: &coder, withIdentifier: ASN1Identifier(tagWithNumber: 2, tagClass: .contextSpecific))
        }
    }
}

/// ASN.1 EXTERNAL type - used to embed data encoded with different ASN.1 types or non-ASN.1 data
@usableFromInline struct EXTERNAL: DERImplicitlyTaggable, Hashable, Sendable {
    /// The EXTERNAL type uses UNIVERSAL tag 8
    @inlinable static var defaultIdentifier: ASN1Identifier {
        ASN1Identifier(tagWithNumber: 0x08, tagClass: .universal)
    }
    
    /// An OID identifying the type of the external data
    @usableFromInline var directReference: ASN1ObjectIdentifier?
    
    /// An integer used as an indirect reference (presentation context identifier)
    @usableFromInline var indirectReference: Int?
    
    /// A human-readable description of the data
    @usableFromInline var dataValueDescriptor: ASN1UTF8String?
    
    /// The actual encoding of the external data
    @usableFromInline var encoding: EXTERNAL_Encoding
    
    @inlinable init(
        directReference: ASN1ObjectIdentifier? = nil,
        indirectReference: Int? = nil,
        dataValueDescriptor: ASN1UTF8String? = nil,
        encoding: EXTERNAL_Encoding
    ) {
        self.directReference = directReference
        self.indirectReference = indirectReference
        self.dataValueDescriptor = dataValueDescriptor
        self.encoding = encoding
    }
    
    @inlinable init(derEncoded root: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            // Parse optional direct-reference (OBJECT IDENTIFIER)
            let directReference: ASN1ObjectIdentifier? = try DER.optionalImplicitlyTagged(&nodes, tag: .objectIdentifier)
            
            // Parse optional indirect-reference (INTEGER)
            let indirectReference: Int? = try DER.optionalImplicitlyTagged(&nodes, tag: .integer)
            
            // Parse optional data-value-descriptor (ObjectDescriptor, which is a restricted character string)
            // ObjectDescriptor has UNIVERSAL tag 7
            let dataValueDescriptor: ASN1UTF8String? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 7, tagClass: .universal))
            
            // Parse encoding (CHOICE - required)
            guard let encodingNode = nodes.next() else {
                throw ASN1Error.invalidASN1Object(reason: "Missing encoding in EXTERNAL")
            }
            let encoding = try EXTERNAL_Encoding(derEncoded: encodingNode, withIdentifier: encodingNode.identifier)
            
            return EXTERNAL(
                directReference: directReference,
                indirectReference: indirectReference,
                dataValueDescriptor: dataValueDescriptor,
                encoding: encoding
            )
        }
    }
    
    @inlinable func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            if let directReference = self.directReference {
                try coder.serialize(directReference)
            }
            if let indirectReference = self.indirectReference {
                try coder.serialize(indirectReference)
            }
            if let dataValueDescriptor = self.dataValueDescriptor {
                // Serialize as ObjectDescriptor (UNIVERSAL tag 7)
                try dataValueDescriptor.serialize(into: &coder, withIdentifier: ASN1Identifier(tagWithNumber: 7, tagClass: .universal))
            }
            try encoding.serialize(into: &coder, withIdentifier: .enumerated)
        }
    }
}
