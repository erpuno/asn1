@usableFromInline
final class Box<T>: Hashable, Sendable where T: Hashable & Sendable {
    @usableFromInline var value: T
    @usableFromInline init(_ value: T) { self.value = value }
    @usableFromInline static func == (lhs: Box<T>, rhs: Box<T>) -> Bool { lhs.value == rhs.value }
    @usableFromInline func hash(into hasher: inout Hasher) { hasher.combine(value) }
}
