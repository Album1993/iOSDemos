-----

1 支持元素类型为 **Optional** 的集合比较，或者底层类型为 **Optional** 的 **Optional** 比较，只要内层 **Optional** 的底层类型实现了 **Equatable** 协议。**[SE-0143]**


 以前optional 不行
```
let array1 = [1, nil, 2, nil, 3, nil]
let array2 = [1, nil, 2, nil, 3, nil]
array1 == array2        // true

let optional1: Optional<Optional<Int>> = 1
let optional2: Optional<Optional<Int>> = 1
optional1 == optional2  // true
```


```
var left: [String?] = ["Andrew", "Lizzie", "Sophie"]
var right: [String?] = ["Charlotte", "Paul", "John"]
left == right
```


--------

If you uncomment the encoder.encode(people) line, Swift will refuse to build your code because you're trying to encode a struct that doesn't conform to Codable.

However, that code compiled cleanly with Swift 4.0, then threw a fatal error at runtime because Person doesn’t conform to Codable.

-------

```
protocol Purchaseable {
   func buy()
}

struct Book: Purchaseable {
   func buy() {
      print("You bought a book")
   }
}

extension Array: Purchaseable where Element: Purchaseable {
   func buy() {
      for item in self {
         item.buy()
      }
   }
}

```
As you can see, conditional conformances let us constrain the way our extensions are applied more precisely than was possible before.

----------
2 支持多维数组直接比较，只要底层类型实现了 **Equatable** 协议。[SE-0143]



```
let arrayOfArray1 = [[1, 2, 3]]
let arrayOfArray2 = [[1, 2, 3]]
arrayOfArray1 == arrayOfArray2  // true
```


```
struct Person: Equatable {
   var firstName: String
   var lastName: String
   var age: Int
}

let paul = Person(firstName: "Paul", lastName: "Hudson", age: 38)
let joanne = Person(firstName: "Joanne", lastName: "Rowling", age: 52)

if paul == joanne {
   print("These people match")
} else {
   print("No match")
}
```

------------------
3 如果集合(**Array, Dictionary, Set**)和 **Optional** 的元素符合 **Codable** 协议，则集合和 **Optional** 本身也符合 **Codable** 协议。


```
import Foundation

let jsonString = """
 [
    {
       "name": "MacBook Pro",
       "screen_size": 15,
       "cpu_count": 4
    },
    {
       "name": "iMac Pro",
       "screen_size": 27,
       "cpu_count": 18
    }
 ]
 """

 let jsonData = Data(jsonString.utf8)
 
 
 struct Mac: Codable {
    var name: String
    var screenSize: Int
    var cpuCount: Int
 }
 
 
 let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase

do {
     // now we have an array to work with, convert it back into JSON
   let encoder = JSONEncoder()
   encoder.keyEncodingStrategy = .convertToSnakeCase
   let encoded = try encoder.encode(macs)
   print(encoded.count)
} catch {
   print(error.localizedDescription)
}
```

```
struct Student: Codable, Hashable {
    let firstName: String
    let grade: Int
}

let cosmin = Student(firstName: "Cosmin", grade: 10)
let george = Student(firstName: "George", grade: 9)
let encoder = JSONEncoder()

let students = [cosmin, george]
do {
    try encoder.encode(students)
} catch {
    print("Failed encoding students array: \(error)")
}
```

以前这样可以通过编译， 但是运行时会崩溃
```
import Foundation

struct Person {
   var name = "Taylor"
}

var people = [Person()]
var encoder = JSONEncoder()
// try encoder.encode(people)
```


----------
4 在 **JSON** 编解码时，可以在 `对象/结构体`的 `Camel Case` 格式的属性名和 **JSON** 的 `Snake Case` 格式的 **key** 之间转换，只需要设置编解码对象的 **keyEncodingStrategy** 属性。


```
struct Student: Codable, Hashable {
    let firstName: String
    let grade: Int
}

let cosmin = Student(firstName: "Cosmin", grade: 10)
let george = Student(firstName: "George", grade: 9)
let encoder = JSONEncoder()

let students = [cosmin, george]

var jsonData = Data()
encoder.keyEncodingStrategy = .convertToSnakeCase
encoder.outputFormatting = .prettyPrinted

do {
    jsonData = try encoder.encode(students)
} catch {
    print(error)
}

if let jsonString = String(data: jsonData, encoding: .utf8) {
    print(jsonString)
}

//[
//    {
//        "grade" : 10,
//        "first_name" : "Cosmin"
//    },
//    {
//        "grade" : 9,
//        "first_name" : "George"
//    }
//]
```

将 **JSON** 字符串解码为对象/结构体时，也有类似的操作。


------------------


5 **struct** 如果要符合 **Equatable** 和 **Hashable** 协议，则编辑器会默认为 **struct** 合成 **Equatable** 和 **Hashable** 的代码，只要其所有的属性都符合 **Equatable** 和 **Hashable** 协议，不再需要我们去写一大堆的模板代码，减少了我们的代码量。**[SE-0185]**


```
struct Country: Hashable {
    let name: String
    let capital: String

    // 默认实现了 static func ==(lhs: Country, rhs: Country) -> Bool 和  var hashValue: Int
    // 不再需要我们自己写代码
}
```


-------------

6 枚举类型如果要符合 **Equatable** 和 **Hashable** 协议，编译器也会默认合成了 **Equatable** 和 **Hashable** 的实现，同上。**[SE-0185]**


-----------

7 扩展 **Key-path** 表达式在标准库中的使用范围。让标准库中所有的索引类型都符合 **Hashable** 协议，这样，**[Int]、String** 和所有其它标准集合使用 **key-path** 下标时，表现都是一样的。**[SE-0188]**


```
let cos = "Cosmin"
let newPath = \String.[cos.startIndex]
let initial = cos[keyPath: newPath]     // C

```

----------

8 支持协议中关联类型的递归约束。**[SE-0157]**


```
protocol Phone {
    associatedtype Version
    associatedtype SmartPhone: Phone where SmartPhone.Version == Version, SmartPhone.SmartPhone == SmartPhone
}
```


```
protocol Employee {
   associatedtype Manager: Employee
   var manager: Manager? { get set }
}


class BoardMember: Employee {
   var manager: BoardMember?
}

class SeniorDeveloper: Employee {
   var manager: BoardMember?
}

class JuniorDeveloper: Employee {
   var manager: SeniorDeveloper?
}

```

---------
9 移除了协议中的 **weak** 和 **unowned**。[SE-0186]


```
class Key {}
class Pitch {}

// Swift 4
protocol Tune {
    unowned var key: Key { get set }
    weak var pitch: Pitch? { get set }
}
// Swift 4.1
protocol Tune {
    var key: Key { get set }
    var pitch: Pitch? { get set }
}
```
如果在** 4.1** 中仍然像** 4** 那样使用，编辑器会给出警告信息。

------

10 弃用标准库中 **Collection** 协议的 **IndexDistance** 关联类型，统一修改为 **Int** 类型。**[SE-0191]**


```
protocol Collection {
    var count: Int { get }
    func index(_ i: Index, offsetBy n: Int) -> Index
    func index(_ i: Index, offsetBy n: Int, limitedBy limit: Index) -> Index?
    func distance(from start: Index, to end: Index) -> Int
}
```

---------

11 新增新的优化模式 **-Osize (Optimize for Size)** 来专门优化以减少代码大小。这一模式可以减少 **5% ~ 30%** 不等的代码大小。不过使用这一模式没有兼得减小代码大小和运行速度。如果对运行性能要求高，**-O** 模式还是首选。

-----------

12 新增 **canImport(Framework)** 来判断是否可以导入某个 **Framework**。[SE-0075]



```
#if canImport(SpriteKit)
   // this will be true for iOS, macOS, tvOS, and watchOS
#else
   // this will be true for other platforms, such as Linux
#endif
```

Previously you would have had to use inclusive or exclusive tests by operating system, like this:


```
#if !os(Linux)
   // Matches macOS, iOS, watchOS, tvOS, and any other future platforms
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
   // Matches only Apple platforms, but needs to be kept up to date as new platforms are added
#endif
/*:
 The new `canImport` condition lets us focus on the functionality we care about rather than what platform we're compiling for, thus avoiding a variety of problems.

 &nbsp;

 [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
 */

```

-------

13 新增 `targetEnvironment(target)` 来判断目标环境。[SE-0190]



```
import UIKit

class TestViewController: UIViewController, UIImagePickerControllerDelegate {
   // a method that does some sort of image processing
   func processPhoto(_ img: UIImage) {
       // process photo here
   }

   // a method that loads a photo either using the camera or using a sample
   func takePhoto() {
      #if targetEnvironment(simulator)
         // we're building for the simulator; use the sample photo
         if let img = UIImage(named: "sample") {
            processPhoto(img)
         } else {
            fatalError("Sample image failed to load")
         }
      #else
         // we're building for a real device; take an actual photo
         let picker = UIImagePickerController()
         picker.sourceType = .camera
         vc.allowsEditing = true
         picker.delegate = self
         present(picker, animated: true)
      #endif
   }

   // this is called if the photo was taken successfully
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      // hide the camera
      picker.dismiss(animated: true)

      // attempt to retrieve the photo they took
      guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
         // that failed; bail out
         return
      }

      // we have an image, so we can process it
      processPhoto(image)
   }
}
```


-------

14 重命名` Sequence.flatMap(_:)` 为 `Sequence.compactMap(_:)`，以让这个操作的含义更清晰和唯一。**[SE-0187]**


```
let pets = ["Sclip", nil, "Nori", nil]
pets.flatMap {$0}   // Warning: 'flatMap' is deprecated
pets.compactMap {$0}
```

-----------

15 可以直接使用 **UnsafeMutableBufferPointer**，使用方式与 **UnsafeBufferPointer** 一样。**[SE-184]**


```
// Swift 4.1
let buffer = UnsafeMutableBufferPointer<Int>.allocate(capacity: 10)
let mutableBuffer = UnsafeMutableBufferPointer(mutating: UnsafeBufferPointer(buffer))

// Swift 4
let buffer1 = UnsafeMutableBufferPointer<Int>(start: UnsafeMutablePointer<Int>.allocate(capacity: 10), count: 10)
let mutableBuffer1 = UnsafeMutableBufferPointer(start: UnsafeMutablePointer(mutating: buffer.baseAddress), count: buffer.count)
```

