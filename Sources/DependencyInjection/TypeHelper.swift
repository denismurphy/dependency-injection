import Foundation

public class TypeHelper {
    
    public static func getTypeAsString<T>(_ type:T.Type) -> String {
        let trueType = getType(type)
        let value = String(describing:Swift.type(of:trueType))
        return value
    }
    
    public static func getType<T>(_ type:T.Type) -> Any.Type {
        var trueType : Any.Type
        if isOptionalType(type) {
            trueType = wrappedTypeFromOptionalType(type)!
        } else {
            trueType = type
        }
        return trueType
    }
    
    
    public static func isOptionalType(_ type: Any.Type) -> Bool {
        return type is OptionalWrapped.Type
    }
    
    public static func wrappedTypeFromOptionalType(_ type: Any.Type) -> Any.Type? {
        return (type as? OptionalWrapped.Type)?.wrappedType
    }
}
