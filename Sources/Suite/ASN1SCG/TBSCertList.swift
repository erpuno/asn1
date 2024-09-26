// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct TBSCertList: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var version: Int?
    @usableFromInline var signature: AlgorithmIdentifier
    @usableFromInline var issuer: Name
    @usableFromInline var thisUpdate: Time
    @usableFromInline var nextUpdate: Time?
    @usableFromInline var revokedCertificates: [TBSCertList_revokedCertificates_Sequence]?
    @usableFromInline var crlExtensions: [Extension]?
    @inlinable init(version: Int?, signature: AlgorithmIdentifier, issuer: Name, thisUpdate: Time, nextUpdate: Time?, revokedCertificates: [TBSCertList_revokedCertificates_Sequence]?, crlExtensions: [Extension]?) {
        self.version = version
        self.signature = signature
        self.issuer = issuer
        self.thisUpdate = thisUpdate
        self.nextUpdate = nextUpdate
        self.revokedCertificates = revokedCertificates
        self.crlExtensions = crlExtensions
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let version: Int? = try Int(derEncoded: &nodes)
            let signature: AlgorithmIdentifier = try AlgorithmIdentifier(derEncoded: &nodes)
            let issuer: Name = try Name(derEncoded: &nodes)
            let thisUpdate: Time = try Time(derEncoded: &nodes)
            let nextUpdate: Time? = try Time(derEncoded: &nodes)
            let revokedCertificates: [TBSCertList_revokedCertificates_Sequence]? = try DER.sequence(of: TBSCertList_revokedCertificates_Sequence.self, identifier: .sequence, nodes: &nodes)
            let crlExtensions: [Extension] = try DER.sequence(of: Extension.self, identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific), nodes: &nodes)
            return TBSCertList(version: version, signature: signature, issuer: issuer, thisUpdate: thisUpdate, nextUpdate: nextUpdate, revokedCertificates: revokedCertificates, crlExtensions: crlExtensions)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            if let version = self.version { try coder.serialize(version) }
            try coder.serialize(signature)
            try coder.serialize(issuer)
            try coder.serialize(thisUpdate)
            if let nextUpdate = self.nextUpdate { try coder.serialize(nextUpdate) }
            if let revokedCertificates = self.revokedCertificates { try coder.serializeSequenceOf(revokedCertificates) }
            if let crlExtensions = self.crlExtensions { try coder.serializeSequenceOf(crlExtensions, identifier: ASN1Identifier(tagWithNumber: 0, tagClass: .contextSpecific)) }
        }
    }
}