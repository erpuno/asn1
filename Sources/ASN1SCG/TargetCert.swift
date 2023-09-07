// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct TargetCert: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var targetCertificate: IssuerSerial
    @usableFromInline var targetName: GeneralName?
    @usableFromInline var certDigestInfo: ObjectDigestInfo?
    @inlinable init(targetCertificate: IssuerSerial, targetName: GeneralName?, certDigestInfo: ObjectDigestInfo?) {
        self.targetCertificate = targetCertificate
        self.targetName = targetName
        self.certDigestInfo = certDigestInfo
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let targetCertificate: IssuerSerial = try IssuerSerial(derEncoded: &nodes)
            let targetName: GeneralName? = try GeneralName(derEncoded: &nodes)
            let certDigestInfo: ObjectDigestInfo? = try ObjectDigestInfo(derEncoded: &nodes)
            return TargetCert(targetCertificate: targetCertificate, targetName: targetName, certDigestInfo: certDigestInfo)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(targetCertificate)
            if let targetName = self.targetName { try coder.serialize(targetName) }
            if let certDigestInfo = self.certDigestInfo { try coder.serialize(certDigestInfo) }
        }
    }
}
