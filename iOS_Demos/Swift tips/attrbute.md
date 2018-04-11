## @IBOutlet

If you mark a property with the **@IBOutlet** attribute, the `Interface Builder (IB)` will recognize that variable and you'll be able to connect your source with your visuals through the provided "**outlet**" mechanism.



```
@IBOutlet weak var textLabel: UILabel!
```

## @IBAction


Similarly, `@IBAction` is an attribute that makes possible connecting actions sent from Interface Builder. So the marked method will directly receive the event fired up by the user interface. 🔥


```
@IBaction func buttonTouchedAction(_ sender: UIButton) {}
```

## @IBInspectable, @GKInspectable


Marking an `NSCodable` property with the `@IBInspectable` attribute will make it easily editable from the Interface Builder’s inspector panel. Using `@GKInspectablehas` the same behavior as `@IBInspectable`, but the property will be exposed for the SpriteKit editor UI instead of IB. 🎮



```
@IBInspectable var borderColor: UIColor = .black
@GKInspectable var mass: Float = 1.21
```

## @IBDesignable



When applied to a **UIView** or **NSView** subclass, the `@IBDesignable` attribute lets Interface Builder know that it should display the exact view hierarchy. So basically anything that you draw inside your view will be rendered into the IB canvas. 会被storyboard中显示


```
@IBDesignable class MyCustomView: UIView { /*...*/ }
```

## @UIApplicationMain, @NSApplicationMain
With this attribute you can mark a class as the application's delegate. Usually this is already there in every AppDelegate.swift file that you'll ever create, however you can provide a main.swift file and call the `[UI|NS]ApplicationMain `method by hand. #pleasedontdoit 😅


## @available


With the` @available` attribute you can mark types available, deprecated, unavailable, etc. for specific platforms. I'm not going into the details there are some great posts about how to use the attribute with availability checkings in Swift.


```
@available(swift 4.1)
@available(iOS 11, *) 
func avaialbleMethod() { /*...*/ }
```

## @NSCopying


You can mark a property with this attribute to make a copy of it instead of the value of the property iself. Obviously this can be really helpful when you copy reference types.



```
class Example: NSOBject {
    @NSCopying var objectToCopy: NSObject
}
```

## @NSManaged


If you are using Core Data entities (usually NSManagedObject subclasses), you can mark stored variables or instance methods as `@NSManaged` to indicate that the Core Data framework will dynamically provide the implementation at runtime.


```
class Person: NSManagedObject {
    @NSManaged var name: NSString
}

```

## @objcMembers

It's basically a convenience attribute for marking multiple attributes available for Objective-C. It's legacy stuff for Objective-C dinosaurs, with performance caveats. 🦕



```
@objcMembers class Person {
    var firstName: String?
    var lastName: String?
}
```

## @escaping


You can mark closure parameters as **@escaping**, if you want to indicate that the value can be stored for later execution, so in other words the value is allowed to outlive the lifetime of the call. 💀


```
var completionHandlers: [() -> Void] = []

func add(_ completionHandler: @escaping () -> Void) {
    completionHandlers.append(completionHandler)
}
```

## @discardableResult


By default the compiler raises a warning when a function returns with something, but that returned value is never used. You can suppress the warning by marking the return value discardable with this Swift language attribute. ⚠️


```
@discardableResult func logAdd(_ a: Int, _ b: Int) -> Int {
    let c = a + b
    print(c)
    return c
}
logAdd(1, 2)

```


### @autoclosure


This attribute can magically turn a function with a closure parameter that has no arguments, but a return type, into a function with a parameter type of that original closure return type, so you can call it much more easy. 🤓 


```
func log(_ closure: @autoclosure () -> String) {
    print(closure())
}

log("b") // it's like func log(_ value: String) { print(value) }

```

## @testable


If you mark an imported module with the **@testable** attribute all the internal access-level entities will be visible (available) for testing purposes. 👍


```
@testable import CoreKit

```

## @objc


This attribute tells the compiler that a declaration is available to use in Objective-C code. Optionally you can provide a single identifier that'll be the name of the Objective-C representation of the original entity. 🦖



```
@objc(LegacyClass)
class ExampleClass: NSObject {

    @objc private var store: Bool = false

    @objc var enabled: Bool {
        @objc(isEnabled) get {
            return self.store
        }
        @objc(setEnabled:) set {
            self.store = newValue
        }
    }

    @objc(setLegacyEnabled:)
    func set(enabled: Bool) {
        self.enabled = enabled
    }
}

```

## @nonobjc


Use this attribute to supress an implicit objc attribute. The @nonobjc attribute tells the compiler to make the declaration unavailable in Objective-C code, even though it’s possible to represent it in Objective-C. 😎


```
@nonobjc static let test = "test"
```

## @convention


This attribute indicate function calling conventions. It can have one parameter which indicates Swift function reference (swift), Objective-C compatible block reference (block) or C function reference (c).


```
// private let sysBind: @convention(c) (CInt, UnsafePointer<sockaddr>?, socklen_t) -> CInt = bind

// typealias LeagcyBlock = @convention(block) () -> Void
// let objcBlock: AnyObject = ... // get real ObjC object from somewhere
// let block: (() -> Void) = unsafeBitCast(objcBlock, to: LeagcyBlock.self)
// block()

func a(a: Int) -> Int {
    return a
}
let exampleSwift: @convention(swift) (Int) -> Int = a
exampleSwift(10)

```

# Private attributes

Private Swift language attributes should only be used by the creators of the language, or hardcore developers. They usually provide extra (compiler) functionality that is still work in progress, so please be very careful... 😳

## @_exported

If you want to import an external module for your whole module you can use the **@_exported** keyword before your import. From now the imported module will be available everywhere. Remember PCH files? 🙃



```
@_exported import UIKit

```

## @inline


With the **@inline** attribute you explicitly tell the compiler the function inliningbehavior. For example if a function is small enough or it's only getting called a few times the compiler is maybe going to inline it, unless you disallow it explicitly.


```
@inline(never) func a() -> Int {
    return 1
}

@inline(__always) func b() -> Int {
    return 2
}

@_inlineable public func c() {
    print("c")
}
c()

```

## @effects

> The **@effects** attribute describes how a function affects "the state of the world". More practically how the optimizer can modify the program based on information that is provided by the attribute.



```
@effects(readonly) func foo() { /*...*/ }

```
The **@effects **attribute supports the following tags:

### readnone

function has no side effects and no dependencies on the state of the program. It always returns an identical result given identical inputs. Calls to readnone functions can be eliminated, reordered, and folded arbitrarily.

### readonly

function has no side effects, but is dependent on the global state of the program. Calls to readonly functions can be eliminated, but cannot be reordered or folded in a way that would move calls to the readnone function across side effects.

### releasenone

function has side effects, it can read or write global state, or state reachable from its arguments. It can however be assumed that no externally visible release has happened (i.e it is allowed for a releasenone function to allocate and destruct an object in its implementation as long as this is does not cause an release of an object visible outside of the implementation). Here are some examples:


```
class SomeObject {
  final var x: Int = 3
}

var global = SomeObject()

class SomeOtherObject {
  var x: Int = 2
  deinit {
    global = SomeObject()
  }
}

@effects(releasenone)
func validReleaseNoneFunction(x: Int) -> Int {
  global.x = 5
  return x + 2
}

@effects(releasenone)
func validReleaseNoneFunction(x: Int) -> Int {
  var notExternallyVisibleObject = SomeObject()
  return x +  notExternallyVisibleObject.x
}

func notAReleaseNoneFunction(x: Int, y: SomeObject) -> Int {
  return x + y.x
}

func notAReleaseNoneFunction(x: Int) -> Int {
  var releaseExternallyVisible = SomeOtherObject()
  return x + releaseExternallyVisible.x
}

```

### readwrite

function has side effects and the optimizer can't assume anything.



## @_transparent


Basically you can force inlining with the @_transparent attribute, but please read the unofficial documentation for more info.


```
@_transparent
func example() {
    print("example")
}
```

Semantically, `@_transparent` means something like **"treat this operation as if it were a primitive operation"**. The name is meant to imply that both the compiler and the compiled program will **"see through"** the operation to its implementation.

This has several consequences:

* Any calls to a function marked `@_transparent` MUST be inlined prior to doing `dataflow-related` diagnostics, even under `-Onone`. This may be necessary to catch dataflow errors.
* Because of this, a `@_transparent` function is inherently **"fragile"**, in that changing its implementation most likely will not affect callers in existing compiled binaries.
* Because of this, a `@_transparent` function MUST only reference public symbols, and MUST not be optimized based on knowledge of the module it's in. [This is not currently implemented or enforced.]
* Debug info SHOULD skip over the inlined operations when single-stepping through the calling function.

This is all that `@_transparent` means.


### When should you use **@_transparent**?



* Does the implementation of this function ever have to change? Then you can't allow it to be inlined.
* Does the implementation need to call private things---either true-private functions, or internal functions that might go away in the next release? Then you can't allow it to be inlined. (Well, you can for now for internal, but it'll break once we have libraries that aren't shipped with apps.)
* Is it okay if the function is not inlined? You'd just prefer that it were? Then you should use [the attribute we haven't designed yet], rather than @_transparent. (If you really need this right now, try @inline(__always).)
* Is it a problem if the function is inlined even under -Onone? Then you're really in the previous case. Trust the compiler.
* Is it a problem if you can't step through the function that's been inlined? Then you don't want @_transparent; you just want @inline(__always).
* Is it okay if the inlining happens after all the dataflow diagnostics? Then you don't want @_transparent; you just want @inline(__always).

If you made it this far, it sounds like @_transparent is the right choice.


## @_specialize

With the `@_specialize` Swift attribute you can give hints for the compiler by listing concrete types for the generic signature. More detailed docs are here.



```
struct S<T> {
  var x: T
  @_specialize(where T == Int, U == Float)
  mutating func exchangeSecond<U>(_ u: U, _ t: T) -> (U, T) {
    x = t
    return (u, x)
  }
}

// Substitutes: <T, U> with <Int, Float> producing:
// S<Int>::exchangeSecond<Float>(u: Float, t: Int) -> (Float, Int)

```

## @_semantics

The Swift optimizer can detect code in the standard library if it is marked with special attributes @_semantics, that identifies the functions.


```
@_semantics("array.count")
func getCount() -> Int {
    return _buffer.count
}

```

## @_silgen_name

This attribute specifies the name that a declaration will have at link time.


```
@_silgen_name("_destroyTLS")
internal func _destroyTLS(_ ptr: UnsafeMutableRawPointer?) {
  // ... implementation ...
}
```

## @_cdecl

Swift compiler comes with a built-in libFuzzer integration, which you can use with the help of the @_cdecl annotation. You can learn more about libFuzzer here.


```
@_cdecl("LLVMFuzzerTestOneInput") public func fuzzMe(Data: UnsafePointer<CChar>, Size: CInt) -> CInt{
    // Test our code using provided Data.
  }
}

```

