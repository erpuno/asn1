// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct BindRequest: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var version: ArraySlice<UInt8>
    @usableFromInline var name: ASN1OctetString
    @usableFromInline var authentication: AuthenticationChoice
    @inlinable init(version: ArraySlice<UInt8>, name: ASN1OctetString, authentication: AuthenticationChoice) {
        self.version = version
        self.name = name
        self.authentication = authentication
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let version: ArraySlice<UInt8> = try ArraySlice<UInt8>(derEncoded: &nodes)
            let name: ASN1OctetString = try ASN1OctetString(derEncoded: &nodes)
            let authentication: AuthenticationChoice = try AuthenticationChoice(derEncoded: &nodes)
            return BindRequest(version: version, name: name, authentication: authentication)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .application)) { coder in
            try coder.serialize(version)
            try coder.serialize(name)
            try coder.serialize(authentication)
        }
    }
}
