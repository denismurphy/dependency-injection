
# Dependency Injection

This package provides a simple and easy-to-use Dependency Injection (DI) solution for Swift projects. It is inspired by JSR-330 and uses a property wrapper named `@Inject` to inject dependencies into properties of classes, structs, and protocols.

## Features

-   Support for both `prototype` and `singleton` scopes
-   `Initialisable` protocol for classes with an `init` method
-   `Injectable` protocol for objects that conform to `Initialisable`
-   `WeakObjectWrapper` class for wrapping reference types as weak references
-   `Inject` struct for property wrapper, allowing for the injection of dependencies into properties
-   `Context` class for managing the registration and resolution of dependencies
-   `AssemblyBuilder` class for creating and configuring an `Assembly` of dependencies

## Usage


1.  Import the `DependencyInjection` module in your project.
    
2.  Use the `@Inject` property wrapper on properties in your classes, structs, and protocols.
    
```
class MyClass {
    @Inject var dependency: MyDependency
}
```

3.  Use the `AssemblyBuilder` to register your dependencies and configure the scope.

```
`let assembly = AssemblyBuilder.instance
    .add(factory: { MyDependency() }, bindingName: "MyDependency", scope: .singleton)
    .build()
```

4.  Use the `Context` class to register the assembly and resolve the dependencies (in AppDelegate for example)

```
Context.instance.register(assembly)
```

## Compatibility

This library requires Swift 5.3 or later.

## Installation

You can install `DependencyInjection` using the Swift Package Manager by adding it as a dependency in your `Package.swift` file or adding it to your Xcode project.

## Contributing

I welcome contributions and suggestions for improvements to this library. If you find a bug or want to propose a new feature, please open an issue or submit a pull request.

## Authors

-   **Denis Murphy**

## License
This code is licensed under the MIT License.


