// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct IssuerSerial: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var issuer: [GeneralName]
    @usableFromInline var serial: ArraySlice<UInt8>
    @usableFromInline var issuerUID: ASN1BitString?
    @inlinable init(issuer: [GeneralName], serial: ArraySlice<UInt8>, issuerUID: ASN1BitString?) {
        self.issuer = issuer
        self.serial = serial
        self.issuerUID = issuerUID
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let issuer: [GeneralName] = try DER.sequence(of: GeneralName.self, identifier: .sequence, nodes: &nodes)
            let serial: ArraySlice<UInt8> = try ArraySlice<UInt8>(derEncoded: &nodes)
            let issuerUID: ASN1BitString? = try ASN1BitString(derEncoded: &nodes)
            return IssuerSerial(issuer: issuer, serial: serial, issuerUID: issuerUID)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serializeSequenceOf(issuer)
            try coder.serialize(serial)
            if let issuerUID = self.issuerUID { try coder.serialize(issuerUID) }
        }
    }
}
