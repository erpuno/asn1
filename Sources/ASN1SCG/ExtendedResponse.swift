// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct ExtendedResponse: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var resultCode: LDAPResult_resultCode_Enum
    @usableFromInline var matchedDN: ASN1OctetString
    @usableFromInline var diagnosticMessage: ASN1OctetString
    @usableFromInline var referral: [ASN1OctetString]?
    @usableFromInline var responseName: ASN1OctetString?
    @usableFromInline var responseValue: ASN1OctetString?
    @inlinable init(resultCode: LDAPResult_resultCode_Enum, matchedDN: ASN1OctetString, diagnosticMessage: ASN1OctetString, referral: [ASN1OctetString]?, responseName: ASN1OctetString?, responseValue: ASN1OctetString?) {
        self.resultCode = resultCode
        self.matchedDN = matchedDN
        self.diagnosticMessage = diagnosticMessage
        self.referral = referral
        self.responseName = responseName
        self.responseValue = responseValue
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let resultCode: LDAPResult_resultCode_Enum = try LDAPResult_resultCode_Enum(derEncoded: &nodes)
            let matchedDN: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let diagnosticMessage: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let referral: [ASN1OctetString]? = try DER.optionalExplicitlyTagged(&nodes, tagNumber: 3, tagClass: .contextSpecific) { node in try DER.sequence(of: ASN1OctetString.self, identifier: .sequence, rootNode: node) }
            let responseName: ASN1OctetString? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 10, tagClass: .contextSpecific))
            let responseValue: ASN1OctetString? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 11, tagClass: .contextSpecific))
            return ExtendedResponse(resultCode: resultCode, matchedDN: matchedDN, diagnosticMessage: diagnosticMessage, referral: referral, responseName: responseName, responseValue: responseValue)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(resultCode)
            try coder.serialize(matchedDN)
            try coder.serialize(diagnosticMessage)
            if let referral = self.referral { try coder.serialize(explicitlyTaggedWithTagNumber: 3, tagClass: .contextSpecific) { codec in try codec.serializeSequenceOf(referral) } }
            if let responseName = self.responseName { try coder.serializeOptionalImplicitlyTagged(responseName, withIdentifier: ASN1Identifier(tagWithNumber: 10, tagClass: .contextSpecific)) }
            if let responseValue = self.responseValue { try coder.serializeOptionalImplicitlyTagged(responseValue, withIdentifier: ASN1Identifier(tagWithNumber: 11, tagClass: .contextSpecific)) }
        }
    }
}
