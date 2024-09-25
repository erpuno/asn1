import SwiftASN1
import Foundation

@usableFromInline public struct ASN1VisibleString: DERImplicitlyTaggable, BERImplicitlyTaggable {

    @inlinable
    public static var defaultIdentifier: ASN1Identifier {
        .visibleString
    }

    @inlinable
    public init(derEncoded node: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        guard node.identifier == identifier else {
            throw ASN1Error.unexpectedFieldType(node.identifier)
        }

        guard case .primitive(let content) = node.content else {
            preconditionFailure("ASN.1 parser generated primitive node with constructed content")
        }

        self.bytes = content
    }

}

extension ASN1Identifier {
    public static let boolean            = ASN1Identifier(shortIdentifier: 0x01)
    public static let integer            = ASN1Identifier(shortIdentifier: 0x02)
    public static let bitString          = ASN1Identifier(shortIdentifier: 0x03)
    public static let octetString        = ASN1Identifier(shortIdentifier: 0x04)
    public static let null               = ASN1Identifier(shortIdentifier: 0x05)
    public static let objectIdentifier   = ASN1Identifier(shortIdentifier: 0x06)
    public static let objectDescriptor   = ASN1Identifier(shortIdentifier: 0x07)
    public static let external           = ASN1Identifier(shortIdentifier: 0x08)
    public static let real               = ASN1Identifier(shortIdentifier: 0x09)
    public static let enumerated         = ASN1Identifier(shortIdentifier: 0x0a)
    public static let embedded           = ASN1Identifier(shortIdentifier: 0x0b)
    public static let utf8String         = ASN1Identifier(shortIdentifier: 0x0c)
    public static let relativeIdentifier = ASN1Identifier(shortIdentifier: 0x0d)
    public static let time               = ASN1Identifier(shortIdentifier: 0x0e)
    public static let sequenceOf         = ASN1Identifier(shortIdentifier: 0x10)
    public static let setOf              = ASN1Identifier(shortIdentifier: 0x11)
    public static let numericString      = ASN1Identifier(shortIdentifier: 0x12)
    public static let printableString    = ASN1Identifier(shortIdentifier: 0x13)
    public static let teletexString      = ASN1Identifier(shortIdentifier: 0x14)
    public static let videotexString     = ASN1Identifier(shortIdentifier: 0x15)
    public static let ia5String          = ASN1Identifier(shortIdentifier: 0x16)
    public static let utcTime            = ASN1Identifier(shortIdentifier: 0x17)
    public static let generalizedTime    = ASN1Identifier(shortIdentifier: 0x18)
    public static let graphicString      = ASN1Identifier(shortIdentifier: 0x19)
    public static let visibleString      = ASN1Identifier(shortIdentifier: 0x1a)
    public static let generalString      = ASN1Identifier(shortIdentifier: 0x1b)
    public static let universalString    = ASN1Identifier(shortIdentifier: 0x1c)
    public static let bmpString          = ASN1Identifier(shortIdentifier: 0x1e)
    public static let sequence           = ASN1Identifier(shortIdentifier: 0x30)
    public static let set                = ASN1Identifier(shortIdentifier: 0x31)
}
