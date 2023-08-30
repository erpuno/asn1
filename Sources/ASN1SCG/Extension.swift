// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct Extension: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var extnID: ASN1ObjectIdentifier
    @usableFromInline var critical: Bool
    @usableFromInline var extnValue: ASN1OctetString
    @inlinable init(extnID: ASN1ObjectIdentifier, critical: Bool, extnValue: ASN1OctetString) {
        self.extnID = extnID
        self.critical = critical
        self.extnValue = extnValue
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let extnID: ASN1ObjectIdentifier = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let critical: Bool = try Bool(derEncoded: &nodes)
            let extnValue: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            return Extension(extnID: extnID, critical: critical, extnValue: extnValue)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(extnID)
            try coder.serialize(critical)
            try coder.serialize(extnValue)
        }
    }
}