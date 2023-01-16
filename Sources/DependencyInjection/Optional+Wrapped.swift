import Foundation

public protocol OptionalWrapped {
    static var wrappedType: Any.Type { get }
}

extension Optional : OptionalWrapped {
    public static var wrappedType: Any.Type { return Wrapped.self }
}
