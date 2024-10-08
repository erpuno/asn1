// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct TSTInfo: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var version: TSTInfo_version_IntEnum
    @usableFromInline var policy: ASN1ObjectIdentifier
    @usableFromInline var messageImprint: MessageImprint
    @usableFromInline var serialNumber: ArraySlice<UInt8>
    @usableFromInline var genTime: GeneralizedTime
    @usableFromInline var accuracy: Accuracy?
    @usableFromInline var nonce: ArraySlice<UInt8>?
    @usableFromInline var tsa: GeneralName?
    @usableFromInline var extensions: [Extension]?
    @inlinable init(version: TSTInfo_version_IntEnum, policy: ASN1ObjectIdentifier, messageImprint: MessageImprint, serialNumber: ArraySlice<UInt8>, genTime: GeneralizedTime, accuracy: Accuracy?, nonce: ArraySlice<UInt8>?, tsa: GeneralName?, extensions: [Extension]?) {
        self.version = version
        self.policy = policy
        self.messageImprint = messageImprint
        self.serialNumber = serialNumber
        self.genTime = genTime
        self.accuracy = accuracy
        self.nonce = nonce
        self.tsa = tsa
        self.extensions = extensions
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let version = try TSTInfo_version_IntEnum(rawValue: Int(derEncoded: &nodes))
            let policy: ASN1ObjectIdentifier = try ASN1ObjectIdentifier(derEncoded: &nodes)
            let messageImprint: MessageImprint = try MessageImprint(derEncoded: &nodes)
            let serialNumber: ArraySlice<UInt8> = try ArraySlice<UInt8>(derEncoded: &nodes)
            let genTime: GeneralizedTime = try GeneralizedTime(derEncoded: &nodes)
            let accuracy: Accuracy? = try Accuracy(derEncoded: &nodes)
            let nonce: ArraySlice<UInt8>? = try ArraySlice<UInt8>(derEncoded: &nodes)
            let tsa: GeneralName? = try DER.optionalImplicitlyTagged(&nodes, tag: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific))
            let extensions: [Extension] = try DER.sequence(of: Extension.self, identifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific), nodes: &nodes)
            return TSTInfo(version: version, policy: policy, messageImprint: messageImprint, serialNumber: serialNumber, genTime: genTime, accuracy: accuracy, nonce: nonce, tsa: tsa, extensions: extensions)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(version.rawValue)
            try coder.serialize(policy)
            try coder.serialize(messageImprint)
            try coder.serialize(serialNumber)
            try coder.serialize(genTime)
            if let accuracy = self.accuracy { try coder.serialize(accuracy) }
            if let nonce = self.nonce { try coder.serialize(nonce) }
            if let tsa = self.tsa { try coder.serializeOptionalImplicitlyTagged(tsa, withIdentifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)) }
            if let extensions = self.extensions { try coder.serializeSequenceOf(extensions, identifier: ASN1Identifier(tagWithNumber: 1, tagClass: .contextSpecific)) }
        }
    }
}
