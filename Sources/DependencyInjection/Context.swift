import SwiftUI

/// Scope aka runtime
public enum Scope {
    case prototype
    case singleton
}

/// Initialisable is class with init
public protocol Initialisable : AnyObject { init() }

/// Most basic injectable has to be Initialisable
public protocol Injectable : Initialisable {}

// Wrapper around reference types (aka classes) passed as weak references from @propertyWrapper
public final class WeakObjectWrapper<T: AnyObject> {
    
    public weak var value: T?
    
    public init(){}
}

/// inject property wrapper
@propertyWrapper
public struct Inject<Value> {
    
    var name: String?
    
    var weakObjectWrapper = WeakObjectWrapper<AnyObject>()
    
    public init() {}
    
    public init(name: String?) {
        self.name = name
    }
    
    public var wrappedValue: Value {
        
        var returnValue : Value
        
        // If Class wrap in weak ownership
        if isClass(Value.self) {
            if weakObjectWrapper.value.nil {
                weakObjectWrapper.value = Context.instance.resolve(name: name)
            }
            returnValue = weakObjectWrapper.value! as! Value
        
        // if struct return value (aka copy)
        } else {
            returnValue = Context.instance.resolve(name: name)
        }
        
        return returnValue
    }
}

public typealias DependencyInjection = Context

public final class Context {
    
    fileprivate init() {}
    
    fileprivate var assembly = Assembly()
    
    public static var instance = Context()
    
    @discardableResult
    public func register(_ assembly:Assembly) -> Context {
        self.assembly.merge(assembly:assembly)
        return self
    }
    
    public func resolve<T>(name: String? = nil) -> T {
        return assembly.resolve(name: name)
    }
    
    public func weakResolve<T>(name: String? = nil) -> T? where T : AnyObject {
        weak var value : T? = assembly.resolve(name: name)
        return value
    }
    
    @available(iOS 14.0, *)
    public func resolveStateObject<T>(name: String? = nil) -> StateObject<T> where T : ObservableObject {
        let weakObjectWrapper = WeakObjectWrapper<AnyObject>()
        weakObjectWrapper.value = resolve(name:name) as T
        return StateObject(wrappedValue:weakObjectWrapper.value! as! T)
    }
    
    @available(iOS 14.0, *)
    public func resolveObservedObject<T>(name: String? = nil) -> ObservedObject<T> where T : ObservableObject {
        let weakObjectWrapper = WeakObjectWrapper<AnyObject>()
        weakObjectWrapper.value = resolve(name:name) as T
        return ObservedObject(wrappedValue:weakObjectWrapper.value! as! T)
    }
    
    deinit {
        assembly.empty()
    }
    
}

public final class AssemblyBuilder  {
    
    fileprivate init() {}
    
    public static var instance = AssemblyBuilder()
    
    fileprivate var assembly = Assembly()
    
    public func add<F>(factory: @escaping () -> F, bindingName: String? = nil, scope: Scope? = .prototype) -> AssemblyBuilder {
        assembly.add(factory: factory, bindingName: bindingName, scope: scope)
        return self
    }
    
    public func add<F, I>(factory: @escaping () -> F, protocol: I.Type, bindingName: String? = nil, scope: Scope? = .prototype) -> AssemblyBuilder {
        assembly.add(factory: factory, protocol: `protocol`, bindingName: bindingName, scope:scope)
        return self
    }
    
    public  func add<T>(_ type: T.Type, bindingName: String? = nil, scope: Scope? = .prototype) -> AssemblyBuilder where T : Injectable {
        assembly.add(type: type, bindingName: bindingName, scope:scope)
        return self
    }
    
    public func add<T, I>(_ type: T.Type, protocol: I.Type, bindingName: String? = nil, scope: Scope? = .prototype) -> AssemblyBuilder where T : Injectable {
        assembly.add(type: type, protocol:`protocol`, bindingName: bindingName, scope:scope)
        return self
    }
    
    public func build() -> Assembly {
        let currentAssembly = self.assembly
        self.assembly = Assembly()
        return currentAssembly
    }
    
    deinit {
        assembly.empty()
    }
}

public struct Assembly {
    
    fileprivate var factories = [TypeKey:()->Any]()
    fileprivate var references = [TypeKey:Any]()
    fileprivate var singletons = [TypeKey:Bool]()
    
    fileprivate mutating func merge(assembly:Assembly) {
        factories = factories.merging(assembly.factories) { (_, new) in new }
        references = references.merging(assembly.references) { (_, new) in new }
        singletons = singletons.merging(assembly.singletons) { (_, new) in new }
    }
    
    fileprivate mutating func add<F>(typeKey:TypeKey,factory: @escaping () -> F,scope: Scope? = .prototype) {
        factories[typeKey] = factory
        if scope == .singleton {
            singletons[typeKey] = true
        }
    }
    
    fileprivate mutating func add<F>(factory: @escaping () -> F,
                                     bindingName: String? = nil,
                                     scope: Scope? = .prototype) {
        var key = String.empty
        setKey(bindingName, &key, bindingType: F.self )
        let typeKey = TypeKey(key:key,type:TypeHelper.getTypeAsString(F.self))
        add(typeKey: typeKey, factory: factory, scope: scope)
    }
    
    fileprivate mutating func add<F,I>(factory: @escaping () -> F,protocol : I.Type,bindingName: String? = nil,scope: Scope? = .prototype) {
        var key = String.empty
        setKey(bindingName, &key, bindingType: `protocol` )
        let typeKey = TypeKey(key:key,type:TypeHelper.getTypeAsString(`protocol`))
        add(typeKey: typeKey, factory: factory, scope: scope)
    }
    
    fileprivate mutating func add<T>(type: T.Type,bindingName: String? = nil,scope: Scope? = .prototype) where T : Injectable {
        var key = String.empty
        setKey(bindingName, &key, bindingType: type )
        let typeKey = TypeKey(key:key,type:TypeHelper.getTypeAsString(type))
        add(typeKey: typeKey, factory: { return createInstance(type:type) }, scope: scope)
    }
    
    fileprivate mutating func add<T,I>(type: T.Type, protocol : I.Type,bindingName: String? = nil,scope: Scope? = .prototype) where T : Injectable {
        var key = String.empty
        setKey(bindingName, &key, bindingType: `protocol` )
        let typeKey = TypeKey(key:key,type:TypeHelper.getTypeAsString(`protocol`))
        add(typeKey: typeKey, factory: { return createInstance(type:type) }, scope: scope)
    }
    
    fileprivate mutating func resolve<T>(name: String? = nil) -> T {
        
        var key = String.empty
        
        setKey(name, &key, bindingType: T.self )
        
        let typeKey = TypeKey(key:key,type:TypeHelper.getTypeAsString(T.self))
        
        var value : T
        
        var singleton = false
        
        if singletons[typeKey] != nil {
            singleton = singletons[typeKey]!
        }
        
        if references[typeKey] != nil {
            value = (references[typeKey] as? T)!
        } else if factories[typeKey] != nil {
            
            if singleton {
                references[typeKey] = (factories[typeKey]?() as? T)!
                value = (references[typeKey] as? T)!
                factories.removeValue(forKey: typeKey)
            } else {
                value = (factories[typeKey]?() as? T)!
            }
            
        } else {
            fatalError("Can't resolve type '\(T.self)'")
        }
        
        return value
    }
    
    fileprivate mutating func empty() {
        factories.removeAll()
        references.removeAll()
        singletons.removeAll()
    }
}

fileprivate struct TypeKey : Hashable, Equatable {
    var key: String?
    var type: String
    
    static func == (lhs: TypeKey, rhs: TypeKey) -> Bool {
        return lhs.key == rhs.key
        && lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key.hashValue)
        hasher.combine(type.hashValue)
    }
}

fileprivate func createInstance<T>(type:T.Type) -> T where T:Initialisable {
    return type.init()
}

fileprivate func setKey<I>(_ bindingName: String?, _ key: inout String, bindingType : I.Type? = nil) {
    if bindingName != nil  {
        key = bindingName!
    } else if bindingType != nil {
        key = TypeHelper.getTypeAsString(bindingType!)
    }
}

/// Define empty string literal
fileprivate extension String {
    static var empty : String {
        return ""
    }
}
