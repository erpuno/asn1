import SwiftASN1

@usableFromInline
final class Box<T>: @unchecked Sendable {
    @usableFromInline var value: T

    @usableFromInline init(_ value: T) {
        self.value = value
    }
}

extension Box: Hashable {
    @usableFromInline static func == (lhs: Box<T>, rhs: Box<T>) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    @usableFromInline func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Box: DERSerializable where T: DERSerializable {
    @usableFromInline func serialize(into coder: inout DER.Serializer) throws {
        try self.value.serialize(into: &coder)
    }
}

extension Box: DERImplicitlyTaggable where T: DERImplicitlyTaggable {
    @usableFromInline static var defaultIdentifier: ASN1Identifier { T.defaultIdentifier }

    @usableFromInline convenience init(derEncoded node: ASN1Node, withIdentifier identifier: ASN1Identifier) throws {
        self.init(try T(derEncoded: node, withIdentifier: identifier))
    }

    @usableFromInline func serialize(into coder: inout DER.Serializer, withIdentifier identifier: ASN1Identifier) throws {
        try self.value.serialize(into: &coder, withIdentifier: identifier)
    }
}

extension Box: DERParseable where T: DERParseable {
    @usableFromInline convenience init(derEncoded node: ASN1Node) throws {
        self.init(try T(derEncoded: node))
    }
}
