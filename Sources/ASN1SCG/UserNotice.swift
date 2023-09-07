// Generated by ASN1.ERP.UNO Compiler, Copyright © 2023 Namdak Tonpa.
import SwiftASN1
import Crypto
import Foundation

@usableFromInline struct UserNotice: DERImplicitlyTaggable, Hashable, Sendable {
    @inlinable static var defaultIdentifier: ASN1Identifier { .sequence }
    @usableFromInline var noticeRef: NoticeReference?
    @usableFromInline var explicitText: DisplayText?
    @inlinable init(noticeRef: NoticeReference?, explicitText: DisplayText?) {
        self.noticeRef = noticeRef
        self.explicitText = explicitText
    }
    @inlinable init(derEncoded root: ASN1Node,
        withIdentifier identifier: ASN1Identifier) throws {
        self = try DER.sequence(root, identifier: identifier) { nodes in
            let noticeRef: NoticeReference? = try NoticeReference(derEncoded: &nodes)
            let explicitText: DisplayText? = try DisplayText(derEncoded: &nodes)
            return UserNotice(noticeRef: noticeRef, explicitText: explicitText)
        }
    }
    @inlinable func serialize(into coder: inout DER.Serializer,
        withIdentifier identifier: ASN1Identifier) throws {
        try coder.appendConstructedNode(identifier: identifier) { coder in
            if let noticeRef = self.noticeRef { try coder.serialize(noticeRef) }
            if let explicitText = self.explicitText { try coder.serialize(explicitText) }
        }
    }
}
