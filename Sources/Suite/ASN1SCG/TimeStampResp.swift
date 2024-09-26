// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023—2024 Namdak Tönpa.
import SwiftASN1
import Foundation

@usableFromInline struct TimeStampResp: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var status: PKIStatusInfo
    @usableFromInline var timeStampToken: ContentInfo?
    @inlinable init(status: PKIStatusInfo, timeStampToken: ContentInfo?) {
        self.status = status
        self.timeStampToken = timeStampToken
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let status: PKIStatusInfo = try PKIStatusInfo(derEncoded: &nodes)
            let timeStampToken: ContentInfo? = try ContentInfo(derEncoded: &nodes)
            return TimeStampResp(status: status, timeStampToken: timeStampToken)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            try coder.serialize(status)
            if let timeStampToken = self.timeStampToken { try coder.serialize(timeStampToken) }
        }
    }
}
