// Generated by ASN1SCG Compiler, Copyright © 2023 Namdak Tonpa.
import ASN1SCG
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct ExtendedResponse: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var resultCode: LDAPResult_resultCode_Enum
    @usableFromInline var matchedDN: ASN1OctetString
    @usableFromInline var diagnosticMessage: ASN1OctetString
    @usableFromInline var referral: [ASN1OctetString]
    @usableFromInline var responseName: ASN1OctetString
    @usableFromInline var responseValue: ASN1OctetString
    @inlinable init(resultCode: LDAPResult_resultCode_Enum, matchedDN: ASN1OctetString, diagnosticMessage: ASN1OctetString, referral: [ASN1OctetString], responseName: ASN1OctetString, responseValue: ASN1OctetString) {
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
            let resultCode = try LDAPResult_resultCode_Enum(derEncoded: &nodes)
            let matchedDN = try ASN1OctetString(derEncoded: &nodes)
            let diagnosticMessage = try ASN1OctetString(derEncoded: &nodes)
            let referral = try DER.sequence(of: ASN1OctetString.self, identifier: .sequence, nodes: &nodes)
            let responseName = try ASN1OctetString(derEncoded: &nodes)
            let responseValue = try ASN1OctetString(derEncoded: &nodes)
            return ExtendedResponse(resultCode: resultCode, matchedDN: matchedDN, diagnosticMessage: diagnosticMessage, referral: referral, responseName: responseName, responseValue: responseValue)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.resultCode)
            try coder.serialize(self.matchedDN)
            try coder.serialize(self.diagnosticMessage)
            try coder.serializeSequenceOf(referral)
            try coder.serialize(self.responseName)
            try coder.serialize(self.responseValue)
        }
    }
}
