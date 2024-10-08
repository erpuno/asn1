// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct CHATMessage: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var no: ArraySlice<UInt8>
    @usableFromInline var headers: [ASN1OctetString]
    @usableFromInline var body: CHATProtocol
    @inlinable init(no: ArraySlice<UInt8>, headers: [ASN1OctetString], body: CHATProtocol) {
        self.no = no
        self.headers = headers
        self.body = body
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let no: ArraySlice<UInt8> = try ArraySlice<UInt8>(derEncoded: &nodes)
            let headers: [ASN1OctetString] = try DER.sequence(of: ASN1OctetString.self, identifier: .sequence, nodes: &nodes)
            let body: CHATProtocol = try CHATProtocol(derEncoded: &nodes)
            return CHATMessage(no: no, headers: headers, body: body)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(no)
            try coder.serializeSequenceOf(headers)
            try coder.serialize(body)
        }
    }
}
