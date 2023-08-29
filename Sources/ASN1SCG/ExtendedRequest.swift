// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct ExtendedRequest: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var requestName: ASN1OctetString
    @usableFromInline var requestValue: ASN1OctetString?
    @inlinable init(requestName: ASN1OctetString, requestValue: ASN1OctetString?) {
        self.requestName = requestName
        self.requestValue = requestValue
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let requestName: ASN1OctetString = (try DER.optionalImplicitlyTagged(&nodes, tagNumber: 0, tagClass: .contextSpecific) { node in return try ASN1OctetString(derEncoded: node) })!
            let requestValue: ASN1OctetString? = try DER.optionalImplicitlyTagged(&nodes, tagNumber: 1, tagClass: .contextSpecific) { node in return try ASN1OctetString(derEncoded: node) }
            return ExtendedRequest(requestName: requestName, requestValue: requestValue)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serializeOptionalImplicitlyTagged(requestName, withIdentifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific))
            if let requestValue = self.requestValue { try coder.serializeOptionalImplicitlyTagged(requestValue, withIdentifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)) }
        }
    }
}
