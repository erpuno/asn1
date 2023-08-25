// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import ASN1SCG
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct Presence: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var nickname: ASN1OctetString
    @usableFromInline var status: PresenceType
    @inlinable init(nickname: ASN1OctetString, status: PresenceType) {
        self.nickname = nickname
        self.status = status
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let nickname = try ASN1OctetString(derEncoded: &nodes)
            let status = try PresenceType(derEncoded: &nodes)
            return Presence(nickname: nickname, status: status)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(self.nickname)
            try coder.serialize(self.status)
        }
    }
}
