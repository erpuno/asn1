// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct OtherCertificateFormat: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var otherCertFormat: ASN1ObjectIdentifier
    @usableFromInline var otherCert: ASN1Any
    @inlinable init(otherCertFormat: ASN1ObjectIdentifier, otherCert: ASN1Any) {
        self.otherCertFormat = otherCertFormat
        self.otherCert = otherCert
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let otherCertFormat: ASN1ObjectIdentifier = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let otherCert: ASN1Any = try ASN1Any(derEncoded: &nodes)
            return OtherCertificateFormat(otherCertFormat: otherCertFormat, otherCert: otherCert)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(otherCertFormat)
            try coder.serialize(otherCert)
        }
    }
}