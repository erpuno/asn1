// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import ASN1SCG
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct Register: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var nickname: ASN1OctetString
    @usableFromInline var csr: ASN1OctetString
    @usableFromInline var password: ASN1OctetString
    @inlinable init(nickname: ASN1OctetString, csr: ASN1OctetString, password: ASN1OctetString) {
        self.nickname = nickname
        self.csr = csr
        self.password = password
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let nickname = try ASN1OctetString(derEncoded: &nodes)
            let csr = try ASN1OctetString(derEncoded: &nodes)
            let password = try ASN1OctetString(derEncoded: &nodes)
            return Register(nickname: nickname, csr: csr, password: password)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.nickname)
            try coder.serialize(self.csr)
            try coder.serialize(self.password)
        }
    }
}
