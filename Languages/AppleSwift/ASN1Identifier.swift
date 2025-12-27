import SwiftASN1
import Foundation

extension ASN1Identifier {
    public static let sequenceOf         = ASN1Identifier(tagWithNumber: 0x10, tagClass: ASN1Identifier.TagClass.universal)
    public static let setOf              = ASN1Identifier(tagWithNumber: 0x11, tagClass: ASN1Identifier.TagClass.universal)
}


