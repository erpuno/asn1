// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct List: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var data: ASN1OctetString
    @usableFromInline var next: List_next_Choice
    @inlinable init(data: ASN1OctetString, next: List_next_Choice) {
        self.data = data
        self.next = next
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let data: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let next: List_next_Choice = try List_next_Choice(derEncoded: &nodes)
            return List(data: data, next: next)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(data)
            try coder.serialize(next)
        }
    }
}
