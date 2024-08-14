![Dependency Injection](https://github.com/denismurphy/dependency-injection/blob/main/_graph.svg?raw=true&version=1)

# Dependency Injection 🚀

## This package provides a simple and easy-to-use Dependency Injection (DI) solution for Swift projects. It is inspired by JSR-330 and uses a property wrapper named @Inject to inject dependencies into properties of classes, structs, and protocols.

## ✨ Features

- 🔄 Support for both `prototype` and `singleton` scopes
  
- 🏗️ `Initialisable` protocol for classes with an `init` method
  
- 💉 `Injectable` protocol for objects conforming to `Initialisable`
  
- 🔗 `WeakObjectWrapper` class for wrapping reference types as weak references
  
- 🎁 `Inject` struct for property wrapper, enabling dependency injection into properties
  
- 🧠 `Context` class for managing dependency registration and resolution
  
- 🛠️ `AssemblyBuilder` class for creating and configuring dependency assemblies

## 🚀 Usage

1. Import the `DependencyInjection` module in your project.

2. Use the `@Inject` property wrapper on properties in your classes, structs, and protocols:

```swift
class MyClass {
    @Inject var dependency: MyDependency
}```

3. Utilize the `AssemblyBuilder` to register dependencies and configure their scope:

```swift
let assembly = AssemblyBuilder.instance
    .add(factory: { MyDependency() }, bindingName: "MyDependency", scope: .singleton)
    .build()```

4. Use the `Context` class to register the assembly and resolve dependencies (e.g., in AppDelegate):

```swift
Context.instance.register(assembly)
```

## 🔧 Compatibility

This library requires Swift 5.3 or later.

## 📦 Installation

Install `DependencyInjection` using the Swift Package Manager by adding it as a dependency in your `Package.swift` file or directly in your Xcode project.

## 🤝 Contributing

We welcome contributions and suggestions to improve this library! If you encounter a bug or have an idea for a new feature, please open an issue or submit a pull request.

## 👨‍💻 Authors

- **Denis Murphy**

## 📄 License

This code is licensed under the MIT License.
