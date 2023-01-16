import Foundation

public extension Optional {
    var some: Bool { self != nil }
    var `nil`: Bool { self == nil }
}
