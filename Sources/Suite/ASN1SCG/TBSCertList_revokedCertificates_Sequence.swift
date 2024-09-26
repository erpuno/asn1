// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct TBSCertList_revokedCertificates_Sequence: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var userCertificate: ArraySlice<UInt8>
    @usableFromInline var revocationDate: Time
    @usableFromInline var crlEntryExtensions: [Extension]?
    @inlinable init(userCertificate: ArraySlice<UInt8>, revocationDate: Time, crlEntryExtensions: [Extension]?) {
        self.userCertificate = userCertificate
        self.revocationDate = revocationDate
        self.crlEntryExtensions = crlEntryExtensions
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let userCertificate: ArraySlice<UInt8> = try ArraySlice<UInt8>(derEncoded: &nodes)
            let revocationDate: Time = try Time(derEncoded: &nodes)
            let crlEntryExtensions: [Extension]? = try DER.sequence(of: Extension.self, identifier: .sequence, nodes: &nodes)
            return TBSCertList_revokedCertificates_Sequence(userCertificate: userCertificate, revocationDate: revocationDate, crlEntryExtensions: crlEntryExtensions)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(userCertificate)
            try coder.serialize(revocationDate)
            if let crlEntryExtensions = self.crlEntryExtensions { try coder.serializeSequenceOf(crlEntryExtensions) }
        }
    }
}
