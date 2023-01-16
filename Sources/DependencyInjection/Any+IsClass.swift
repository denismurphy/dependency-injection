import Foundation

public func isClass<T>(_ value: T) -> Bool {
    return type(of:value.self) is AnyClass
}
