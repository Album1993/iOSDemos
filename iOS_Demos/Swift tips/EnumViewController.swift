//
//  EnumViewController.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 12/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import UIKit

class EnumViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    enum Movement{
        case Left
        case Right
        case Top
        case Bottom
    }
    
    func f1()  {
        let aMovement = Movement.Left
        
        // switch 分情况处理
        switch aMovement{
        case .Left: print("left")
        default:()
        }
        
        // 明确的case情况
        if case .Left = aMovement{
            print("left")
        }
        
        if aMovement == .Left { print("left") }
    }
    
    // 映射到整型
    enum Movement2: Int {
        case Left = 0
        case Right = 1
        case Top = 2
        case Bottom = 3
    }
    
    // 同样你可以与字符串一一对应
    enum House: String {
        case Baratheon = "Ours is the Fury"
        case Greyjoy = "We Do Not Sow"
        case Martell = "Unbowed, Unbent, Unbroken"
        case Stark = "Winter is Coming"
        case Tully = "Family, Duty, Honor"
        case Tyrell = "Growing Strong"
    }
    
    // 或者float double都可以(同时注意枚举中的花式unicode)
    enum Constants: Double {
        case π = 3.14159
        case e = 2.71828
        case φ = 1.61803398874
        case λ = 1.30357
    }
    
    // Mercury = 1, Venus = 2, ... Neptune = 8
    enum Planet: Int {
        case Mercury = 1, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune
    }
    
    // North = "North", ... West = "West"
    // 译者注: 这个是swift2.0新增语法
    enum CompassPoint: String {
        case North, South, East, West
    }
    
    //    Swift枚举中支持以下四种关联值类型:
    //
    //    整型(Integer)
    //    浮点数(Float Point)
    //    字符串(String)
    //    布尔类型(Boolean)
    
    //    let bestHouse = House.Stark
    //    print(bestHouse.rawValue)
    
    //    enum Movement: Int {
    //        case Left = 0
    //        case Right = 1
    //        case Top = 2
    //        case Bottom = 3
    //    }
    //    // 创建一个movement.Right 用例,其raw value值为1
    //    let rightMovement = Movement(rawValue: 1)
    
    //    enum VNodeFlags : UInt32 {
    //        case Delete = 0x00000001
    //        case Write = 0x00000002
    //        case Extended = 0x00000004
    //        case Attrib = 0x00000008
    //        case Link = 0x00000010
    //        case Rename = 0x00000020
    //        case Revoke = 0x00000040
    //        case None = 0x00000080
    //    }
    
    //MAKR: 嵌套枚举(Nesting Enums)
    
    enum Character {
        enum Weapon {
            case Bow
            case Sword
            case Lance
            case Dagger
        }
        enum Helmet {
            case Wooden
            case Iron
            case Diamond
        }
        case Thief
        case Warrior
        case Knight
    }
    
    let character = Character.Thief
    let weapon = Character.Weapon.Bow
    let helmet = Character.Helmet.Iron
    
    // MARK: 包含枚举(Containing Enums)
    
    struct Character2 {
        enum CharacterType {
            case Thief
            case Warrior
            case Knight
        }
        enum Weapon {
            case Bow
            case Sword
            case Lance
            case Dagger
        }
        let type: CharacterType
        let weapon: Weapon
    }
    
    let warrior = Character2(type: .Warrior, weapon: .Sword)
    
    //    关联值(Associated Value)
    //
    //    关联值是将额外信息附加到enum case中的一种极好的方式。打个比方，你正在开发一款交易引擎，可能存在买和卖两种不同的交易类型。
    //    除此之外每手交易还要制定明确的股票名称和交易数量:
    
    enum Trade {
        case Buy
        case Sell
    }
    func trade(tradeType: Trade, stock: String, amount: Int) {}
    
    enum Trade2 {
        case Buy(stock: String, amount: Int)
        case Sell(stock: String, amount: Int)
    }
    func trade2(type: Trade2) {}
    
    //    模式匹配(Pattern Mathching)
    //
    //    如果你想要访问这些值，模式匹配再次救场:
    func testPatternMatching() {
        let trade = Trade2.Buy(stock: "APPL", amount: 500)
        if case let Trade2.Buy(stock, amount) = trade {
            print("buy \(amount) of \(stock)")
        }
    }
    
    //    标签(Labels)
    //    enum Trade {
    //        case Buy(String, Int)
    //        case Sell(String, Int)
    //    }
    
    typealias Config = (RAM: Int, CPU: String, GPU: String)
    
    // Each of these takes a config and returns an updated config
    func selectRAM(_ config: Config) -> Config {return (RAM: 32, CPU: config.CPU, GPU: config.GPU)}
    func selectCPU(_ config: Config) -> Config {return (RAM: config.RAM, CPU: "3.2GHZ", GPU: config.GPU)}
    func selectGPU(_ config: Config) -> Config {return (RAM: config.RAM, CPU: "3.2GHZ", GPU: "NVidia")}
    
    enum Desktop {
        case Cube(Config)
        case Tower(Config)
        case Rack(Config)
    }
    
    //    配置的每个步骤均通过递交元组到enum中进行内容更新。倘若我们从函数式编程2中获得启发，这将变得更好。
    
    //    infix operator <^> { associativity left }
    //
    //    func <^>(a: Config, f: (Config) -> Config) -> Config {
    //        return f(a)
    //    }
    //    let config = (0, "", "") <^> selectRAM  <^> selectCPU <^> selectGPU
    
    
    func testTuple() {
        let aTower = Desktop.Tower(selectGPU(selectCPU(selectRAM((0, "", "") as Config))))
        
    }
    
}




//MARK: example
// 拥有不同值的用例
enum UserAction {
    case OpenURL(url: NSURL)
    case SwitchProcess(processId: UInt32)
    case Restart(time: NSDate?, intoCommandLine: Bool)
}

// 假设你在实现一个功能强大的编辑器，这个编辑器允许多重选择，
// 正如 Sublime Text : https://www.youtube.com/watch?v=i2SVJa2EGIw
enum Selection {
    case None
    case Single(Range<Int>)
    case Multiple([Range<Int>])
}

// 或者映射不同的标识码
enum Barcode {
    case UPCA(numberSystem: Int, manufacturer: Int, product: Int, check: Int)
    case QRCode(productCode: String)
}

// 又或者假设你在封装一个 C 语言库，正如 Kqeue BSD/Darwin 通知系统:
// https://www.freebsd.org/cgi/man.cgi?query=kqueue&sektion=2
enum KqueueEvent {
    case UserEvent(identifier: UInt, fflags: [UInt32], data: Int)
    case ReadFD(fd: UInt, data: Int)
    case WriteFD(fd: UInt, data: Int)
    case VnodeFD(fd: UInt, fflags: [UInt32], data: Int)
    case ErrorEvent(code: UInt, message: String)
}

// 最后, 一个 RPG 游戏中的所有可穿戴装备可以使用一个枚举来进行映射，
// 可以为一个装备增加重量和持久两个属性
// 现在可以仅用一行代码来增加一个"钻石"属性，如此一来我们便可以增加几件新的镶嵌钻石的可穿戴装备
enum Wearable {
    enum Weight: Int {
        case Light = 1
        case Mid = 4
        case Heavy = 10
    }
    enum Armor: Int {
        case Light = 2
        case Strong = 8
        case Heavy = 20
    }
    case Helmet(weight: Weight, armor: Armor)
    case Breastplate(weight: Weight, armor: Armor)
    case Shield(weight: Weight, armor: Armor)
}
let woodenHelmet = Wearable.Helmet(weight: .Light, armor: .Light)

//MARK: 方法和属性(Methods and properties)

enum Wearable2 {
    enum Weight: Int {
        case Light = 1
    }
    enum Armor: Int {
        case Light = 2
    }
    case Helmet(weight: Weight, armor: Armor)
    func attributes() -> (weight: Int, armor: Int) {
        switch self {
        case .Helmet(let w, let a): return (weight: w.rawValue * 2, armor: w.rawValue * 4)
        }
    }
}
let woodenHelmetProps = Wearable2.Helmet(weight: .Light, armor: .Light).attributes()
//print (woodenHelmetProps)
// prints "(2, 4)"

//枚举中的方法为每一个enum case而“生”。所以倘若想要在特定情况执行特定代码的话，你需要分支处理或采用switch语句来明确正确的代码路径。

enum Device {
    case iPad, iPhone, AppleTV, AppleWatch
    func introduced() -> String {
        switch self {
        case .AppleTV: return "\(self) was introduced 2006"
        case .iPhone: return "\(self) was introduced 2007"
        case .iPad: return "\(self) was introduced 2010"
        case .AppleWatch: return "\(self) was introduced 2014"
        }
    }
}
//print (Device.iPhone.introduced())
// prints: "iPhone was introduced 2007"

//MARK: 属性(Properties)

enum Device2 {
    case iPad2, iPhone2
    var year: Int {
        switch self {
        case .iPhone2: return 2007
        case .iPad2: return 2010
        }
    }
}

//MARK: 静态方法(Static Methods)
enum Device3 {
    case AppleWatch3
    static func fromSlang(term: String) -> Device3? {
        if term == "iWatch" {
            return .AppleWatch3
        }
        return nil
    }
}
//print (Device3.fromSlang(term: "iWatch"))


// MARK:
//方法可以声明为mutating。这样就允许改变隐藏参数self的case值了3。


enum TriStateSwitch {
    case Off, Low, High
    mutating func next() {
        switch self {
        case .Off:
            self = .Low
        case .Low:
            self = .High
        case .High:
            self = .Off
        }
    }
}
var ovenLight = TriStateSwitch.Low
//ovenLight.next()
// ovenLight 现在等于.On
//ovenLight.next()
// ovenLight 现在等于.Off


// MARK: 现在我们已经对这个定义更加清晰了。确实，如果我们添加关联值和嵌套，enum就看起来就像一个封闭的、简化的struct。相比较struct，前者优势体现在能够为分类与层次结构编

// Struct Example
struct Point {
    let x: Int
    let y: Int
}

struct Rect {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}

// Enum Example
enum GeometricEntity {
    case Point(x: Int, y: Int)
    case Rect(x: Int, y: Int, width: Int, height: Int)
}


//方法和静态方法的添加允许我们为enum附加功能，这意味着无须依靠额外函数就能实现4。
// C-Like example
//enum Trade {
//    case Buy
//    case Sell
//}
//func order(trade: Trade)

// Swift Enum example
//enum Trade {
//    case Buy
//    case Sell
//    func order()
//}

//MARK:枚举进阶(Advanced Enum Usage）

protocol CustomStringConvertible {
    var description: String { get }
}

enum Trade: CustomStringConvertible {
    case Buy, Sell
    var description: String {
        switch self {
        case .Buy: return "We're buying something"
        case .Sell: return "We're selling something"
        }
    }
}

let action = Trade.Buy
//print("this action is \(action)")
// prints: this action is We're buying something

protocol AccountCompatible {
    var remainingFunds: Int { get }
    mutating func addFunds(amount: Int) throws
    mutating func removeFunds(amount: Int) throws
}

//你也许会简单地拿struct实现这个协议，但是考虑应用的上下文，
//enum是一个更明智的处理方法。不过你无法添加一个存储属性到enum中，
//就像var remainingFuns:Int。那么你会如何构造呢？答案灰常简单，你可以使用关联值完美解决:

//enum Account {
//    case Empty
//    case Funds(remaining: Int)
//
//    enum Error: ErrorType {
//        case Overdraft(amount: Int)
//    }
//
//    var remainingFunds: Int {
//        switch self {
//        case .Empty: return 0
//        case .Funds(let remaining): return remaining
//        }
//    }
//}

//extension Account: AccountCompatible {
//
//    mutating func addFunds(amount: Int) throws {
//        var newAmount = amount
//        if case let .Funds(remaining) = self {
//            newAmount += remaining
//        }
//        if newAmount < 0 {
//            throw Error.Overdraft(amount: -newAmount)
//        } else if newAmount == 0 {
//            self = .Empty
//        } else {
//            self = .Funds(remaining: newAmount)
//        }
//    }
//
//    mutating func removeFunds(amount: Int) throws {
//        try self.addFunds(amount * -1)
//    }
//
////}
//var account = Account.Funds(remaining: 20)
//print("add: ", try? account.addFunds(10))
//print ("remove 1: ", try? account.removeFunds(15))
//print ("remove 2: ", try? account.removeFunds(55))
// prints:
// : add:  Optional(())
// : remove 1:  Optional(())
// : remove 2:  nil

//扩展(Extensions)
enum Entities {
    case Soldier(x: Int, y: Int)
    case Tank(x: Int, y: Int)
    case Player(x: Int, y: Int)
}
extension Entities {
    mutating func move(dist: CGVector) {}
    mutating func attack() {}
}

//extension Entities: CustomStringConvertible {
//    var description: String {
//        switch self {
//        case let .Soldier(x, y): return "\(x), \(y)"
//        case let .Tank(x, y): return "\(x), \(y)"
//        case let .Player(x, y): return "\(x), \(y)"
//        }
//    }
//}


// 枚举范型
//let aValue = Optional<Int>.Some(5)
//let noValue = Optional<Int>.None
//if noValue == Optional.None { print("No value") }

//这是Optional最直接的用例，并未使用任何语法糖，
//但是不可否认Swift中语法糖的加入使得你的工作更简单。
//如果你观察上面的实例代码，你恐怕已经猜到Optional内部实现是这样的5:

// Simplified implementation of Swift's Optional
//enum MyOptional<T> {
//    case Some(T)
//    case None
//}

//enum Either<T1, T2> {
//    case Left(T1)
//    case Right(T2)
//}

//最后，Swift中所有在class和struct中奏效的类型约束，在enum中同样适用。
//enum Bag<T: SequenceType where T.Generator.Element==Equatable> {
//    case Empty
//    case Full(contents: T)
//}

//MARK:递归 / 间接(Indirect)类型

//此处的 indrect 关键字告诉编译器间接地处理这个枚举的 case。也可以对整个枚举类型使用这个关键字。作为例子，我们来定义一个二叉树:

enum FileNode {
    case File(name: String)
    indirect case Folder(name: String, files: [FileNode])
}

indirect enum Tree<Element: Comparable> {
    case Empty
    case Node(Tree<Element>,Element,Tree<Element>)
}

// MARK: 使用自定义类型作为枚举的值

//如果我们忽略关联值，则枚举的值就只能是整型，浮点型，字符串和布尔类型。
//如果想要支持别的类型，则可以通过实现 StringLiteralConvertible 协议来完成，
//这可以让我们通过对字符串的序列化和反序列化来使枚举支持自定义类型。
//
//作为一个例子，假设我们要定义一个枚举来保存不同的 iOS 设备的屏幕尺寸：
//enum Devices: CGSize {
//    case iPhone3GS = CGSize(width: 320, height: 480)
//    case iPhone5 = CGSize(width: 320, height: 568)
//    case iPhone6 = CGSize(width: 375, height: 667)
//    case iPhone6Plus = CGSize(width: 414, height: 736)
//}

//然而，这段代码不能通过编译。因为 CGPoint 并不是一个常量，
//不能用来定义枚举的值。我们需要为想要支持的自定义类型增加一个扩展，
//让其实现 StringLiteralConvertible 协议。这个协议要求我们实现三个构造方法，
//这三个方法都需要使用一个String类型的参数，并且我们需要将这个字符串转换成我们需要的类型(此处是CGSize)。

extension CGSize: StringLiteralConvertible {
    public init(stringLiteral value: String) {
        let size = CGSizeFromString(value)
        self.init(width: size.width, height: size.height)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        let size = CGSizeFromString(value)
        self.init(width: size.width, height: size.height)
    }
    
    public init(unicodeScalarLiteral value: String) {
        let size = CGSizeFromString(value)
        self.init(width: size.width, height: size.height)
    }
}

//现在就可以来实现我们需要的枚举了，
//不过这里有一个缺点：初始化的值必须写成字符串形式，
//因为这就是我们定义的枚举需要接受的类型(记住，我们实现了 StringLiteralConvertible，因此String可以转化成CGSize类型)

enum Devices: CGSize {
    case iPhone3GS = "{320, 480}"
    case iPhone5 = "{320, 568}"
    case iPhone6 = "{375, 667}"
    case iPhone6Plus = "{414, 736}"
}

//终于，我们可以使用 CGPoint 类型的枚举了。
//需要注意的是，当要获取真实的 CGPoint 的值的时候，我们需要访问枚举的是 rawValue 属性。
let a = Devices.iPhone5
let b = a.rawValue
//print("the phone size string is \(a), width is \(b.width), height is \(b.height)")
// prints : the phone size string is iPhone5, width is 320.0, height is 568.0

//MARK:对枚举的关联值进行比较

//enum Trade {
//    case Buy(stock: String, amount: Int)
//    case Sell(stock: String, amount: Int)
//}
//func ==(lhs: Trade, rhs: Trade) -> Bool {
//    switch (lhs, rhs) {
//    case let (.Buy(stock1, amount1), .Buy(stock2, amount2))
//        where stock1 == stock2 && amount1 == amount2:
//        return true
//    case let (.Sell(stock1, amount1), .Sell(stock2, amount2))
//        where stock1 == stock2 && amount1 == amount2:
//        return true
//    default: return false
//    }
//}

//自定义构造方法

//在 静态方法 一节当中我们已经提到它们可以作为从不同数据构造枚举的方便形式。在之前的例子里也展示过，对出版社经常误用的苹果设备名返回正确的名字：

//enum Device {
//    case AppleWatch
//    static func fromSlang(term: String) -> Device? {
//        if term == "iWatch" {
//            return .AppleWatch
//        }A
//        return nil
//    }
//}
//我们也可以使用自定义构造方法来替换静态方法。枚举与结构体和类的构造方法最大的不同在于，枚举的构造方法需要将隐式的 self 属性设置为正确的 case。
//
//enum Device {
//    case AppleWatch
//    init?(term: String) {
//        if term == "iWatch" {
//            self = .AppleWatch
//        }
//        return nil
//    }
//}
//在这个例子中，我们使用了可失败(failable)的构造方法。但是，普通的构造方法也可以工作得很好：
//
//enum NumberCategory {
//    case Small
//    case Medium
//    case Big
//    case Huge
//    init(number n: Int) {
//        if n < 10000 { self = .Small }
//        else if n < 1000000 { self = .Medium }
//        else if n < 100000000 { self = .Big }
//        else { self = .Huge }
//    }
//}
//let aNumber = NumberCategory(number: 100)
//print(aNumber)
// prints: "Small"


//MARK:对 Objective-C 的支持

//基于整型的枚举，如 enum Bit: Int { case Zero = 0; case One = 1 } 可以通过 @objc 标识来将其桥接到 Objective-C 当中。然而，一旦使用整型之外的类型(如 String)或者开始使用关联值，我们就无法在 Objective-C 当中使用这些枚举了。
//
//有一个名为_ObjectiveCBridgeable的隐藏协议，可以让规范我们以定义合适的方法，如此一来，Swift 便可以正确地将枚举转成 Objective-C 类型，但我猜这个协议被隐藏起来一定是有原因的。然而，从理论上来讲，这个协议还是允许我们将枚举(包括其实枚举值)正确地桥接到 Objective-C 当中。
//
//但是，我们并不一定非要使用上面提到的这个方法。为枚举添加两个方法，使用 @objc 定义一个替代类型，如此一来我们便可以自由地将枚举进行转换了，并且这种方式不需要遵守私有协议：

//enum Trade {
//    case Buy(stock: String, amount: Int)
//    case Sell(stock: String, amount: Int)
//}
//
//// 这个类型也可以定义在 Objective-C 的代码中
//@objc class OTrade: NSObject {
//    var type: Int
//    var stock: String
//    var amount: Int
//    init(type: Int, stock: String, amount: Int) {
//        self.type = type
//        self.stock = stock
//        self.amount = amount
//    }
//}
//
//extension Trade  {
//
//    func toObjc() -> OTrade {
//        switch self {
//        case let .Buy(stock, amount):
//            return OTrade(type: 0, stock: stock, amount: amount)
//        case let .Sell(stock, amount):
//            return OTrade(type: 1, stock: stock, amount: amount)
//        }
//    }
//
//    static func fromObjc(source: OTrade) -> Trade? {
//        switch (source.type) {
//        case 0: return Trade.Buy(stock: source.stock, amount: source.amount)
//        case 1: return Trade.Sell(stock: source.stock, amount: source.amount)
//        default: return nil
//        }
//    }
//}


//MARK:错误处理

//说到枚举的实践使用，当然少不了在 Swift 2.0 当中新推出的错误处理。标记为可抛出的函数可以抛出任何遵守了 ErrorType 空协议的类型。正如 Swift 官方文档中所写的：
//
//Swift 的枚举特别适用于构建一组相关的错误状态，可以通过关联值来为其增加额外的附加信息。
//
//作为一个示例，我们来看下流行的JSON解析框架 Argo。当 JSON 解析失败的时候，它有可能是以下两种主要原因：
//
//JSON 数据缺少某些最终模型所需要的键(比如你的模型有一个 username 的属性，但是 JSON 中缺少了)
//存在类型不匹配，比如说 username 需要的是 String 类型，而 JSON 中包含的是 NSNull6。
//除此之外，Argo 还为不包含在上述两个类别中的错误提供了自定义错误。它们的 ErrorType 枚举是类似这样的：
//
//enum DecodeError: ErrorType {
//    case TypeMismatch(expected: String, actual: String)
//    case MissingKey(String)
//    case Custom(String)
//}
//所有的 case 都有一个关联值用来包含关于错误的附加信息。

//MARK:一个更加通用的用于完整 HTTP / REST API 错误处理的ErrorType应该是类似这样的：

//enum APIError : ErrorType {
//    // Can't connect to the server (maybe offline?)
//    case ConnectionError(error: NSError)
//    // The server responded with a non 200 status code
//    case ServerError(statusCode: Int, error: NSError)
//    // We got no data (0 bytes) back from the server
//    case NoDataError
//    // The server response can't be converted from JSON to a Dictionary
//    case JSONSerializationError(error: ErrorType)
//    // The Argo decoding Failed
//    case JSONMappingError(converstionError: DecodeError)
//}
//这个 ErrorType 实现了完整的 REST 程序栈解析有可能出现的错误，包含了所有在解析结构体与类时会出现的错误。
//
//如果你看得够仔细，会发现在JSONMappingError中，我们将Argo中的DecodeError封装到了我们的APIError类型当中，因为我们会用 Argo 来作实际的 JSON 解析。
//
//更多关于ErrorType以及此种枚举类型的示例可以参看官方文档。

//MARK:观察者模式

//在 Swift 当中，有许多方法来构建观察模式。如果使用 @objc 兼容标记，则我们可以使用 NSNotificationCenter 或者 KVO。即使不用这个标记，didSet语法也可以很容易地实现简单的观察模式。在这里可以使用枚举，它可以使被观察者的变化更加清晰明了。设想我们要对一个集合进行观察。如果我们稍微思考一下就会发现这只有几种可能的情况：一个或多个项被插入，一个或多个项被删除，一个或多个项被更新。这听起来就是枚举可以完成的工作：
//
//enum Change {
//    case Insertion(items: [Item])
//    case Deletion(items: [Item])
//    case Update(items: [Item])
//}
//之后，观察对象就可以使用一个很简洁的方式来获取已经发生的事情的详细信息。这也可以通过为其增加 oldValue 和 newValue 的简单方法来扩展它的功能。

//MARK:状态码

//如果我们正在使用一个外部系统，而这个系统使用了状态码(或者错误码)来传递错误信息，类似 HTTP 状态码，这种情况下枚举就是一种很明显并且很好的方式来对信息进行封装7 。
//
//enum HttpError: String {
//    case Code400 = "Bad Request"
//    case Code401 = "Unauthorized"
//    case Code402 = "Payment Required"
//    case Code403 = "Forbidden"
//    case Code404 = "Not Found"
//}
//结果类型映射(Map Result Types)

//MARK:枚举也经常被用于将 JSON 解析后的结果映射成 Swift 的原生类型。这里有一个简短的例子：

//enum JSON {
//    case JSONString(Swift.String)
//    case JSONNumber(Double)
//    case JSONObject([String : JSONValue])
//    case JSONArray([JSONValue])
//    case JSONBool(Bool)
//    case JSONNull
//}
//类似地，如果我们解析了其它的东西，也可以使用这种方式将解析结果转化我们 Swift 的类型。

//MARK:UIKit 标识

//枚举可以用来将字符串类型的重用标识或者 storyboard 标识映射为类型系统可以进行检查的类型。假设我们有一个拥有很多原型 Cell 的 UITableView：
//
//enum CellType: String {
//    case ButtonValueCell = "ButtonValueCell"
//    case UnitEditCell = "UnitEditCell"
//    case LabelCell = "LabelCell"
//    case ResultLabelCell = "ResultLabelCell"
//}

//MARK:单位

//单位以及单位转换是另一个使用枚举的绝佳场合。可以将单位及其对应的转换率映射起来，然后添加方法来对单位进行自动的转换。以下是一个相当简单的示例：
//
//enum Liquid: Float {
//    case ml = 1.0
//    case l = 1000.0
//    func convert(amount amount: Float, to: Liquid) -> Float {
//        if self.rawValue < to.rawValue {
//            return (self.rawValue / to.rawValue) * amount
//        } else {
//            return (self.rawValue * to.rawValue) * amount
//        }
//    }
//}
//// Convert liters to milliliters
//print (Liquid.l.convert(amount: 5, to: Liquid.ml))
//另一个示例是货币的转换。以及数学符号(比如角度与弧度)也可以从中受益。

//MARK:游戏

//游戏也是枚举中的另一个相当好的用例，屏幕上的大多数实体都属于一个特定种族的类型(敌人，障碍，纹理，...)。相对于本地的 iOS 或者 Mac 应用，游戏更像是一个白板。即开发游戏我们可以使用全新的对象以及全新的关联创造一个全新的世界，而 iOS 或者 OSX 需要使用预定义的 UIButtons，UITableViews，UITableViewCells 或者 NSStackView.
//
//不仅如此，由于枚举可以遵守协议，我们可以利用协议扩展和基于协议的编程为不同为游戏定义的枚举增加功能。这里是一个用来展示这种层级的的简短示例：
//
//enum FlyingBeast { case Dragon, Hippogriff, Gargoyle }
//enum Horde { case Ork, Troll }
//enum Player { case Mage, Warrior, Barbarian }
//enum NPC { case Vendor, Blacksmith }
//enum Element { case Tree, Fence, Stone }
//
//protocol Hurtable {}
//protocol Killable {}
//protocol Flying {}
//protocol Attacking {}
//protocol Obstacle {}
//
//extension FlyingBeast: Hurtable, Killable, Flying, Attacking {}
//extension Horde: Hurtable, Killable, Attacking {}
//extension Player: Hurtable, Obstacle {}
//extension NPC: Hurtable {}
//extension Element: Obstacle {}
//字符串类型化
//
//在一个稍微大一点的 Xcode 项目中，我们很快就会有一大堆通过字符串来访问的资源。在前面的小节中，我们已经提过重用标识和 storyboard 的标识，但是除了这两样，还存在很多资源：图像，Segues，Nibs，字体以及其它资源。通常情况下，这些资源都可以分成不同的集合。如果是这样的话，一个类型化的字符串会是一个让编译器帮我们进行类型检查的好方法。
//
//enum DetailViewImages: String {
//    case Background = "bg1.png"
//    case Sidebar = "sbg.png"
//    case ActionButton1 = "btn1_1.png"
//    case ActionButton2 = "btn2_1.png"
//}
//对于 iOS 开发者，R.swift这个第三方库可以为以上提到的情况自动生成结构体。但是有些时候你可能需要有更多的控制(或者你可能是一个Mac开发者8)。

//MARK:API 端点
//
//Rest API 是枚举的绝佳用例。它们都是分组的，它们都是有限的 API 集合，并且它们也可能会有附加的查询或者命名的参数，而这可以使用关联值来实现。
//
//这里有个 Instagram API 的简化版：
//
//enum Instagram {
//    enum Media {
//        case Popular
//        case Shortcode(id: String)
//        case Search(lat: Float, min_timestamp: Int, lng: Float, max_timestamp: Int, distance: Int)
//    }
//    enum Users {
//        case User(id: String)
//        case Feed
//        case Recent(id: String)
//    }
//}
//Ash Furrow的Moya框架就是基本这个思想，使用枚举对 rest 端点进行映射。

//MARK:链表

//Airspeed Velocity有一篇极好的文章说明了如何使用枚举来实现一个链表。那篇文章中的大多数代码都超出了枚举的知识，并涉及到了大量其它有趣的主题9，但是，链表最基本的定义是类似这样的(我对其进行了一些简化)：
//
//enum List {
//    case End
//    indirect case Node(Int, next: List)
//}
//每一个节点(Node) case 都指向了下一个 case， 通过使用枚举而非其它类型，我们可以避免使用一个可选的 next 类型以用来表示链表的结束。
//
//Airspeed Velocity 还写过一篇超赞的博客，关于如何使用 Swift 的间接枚举类型来实现红黑树，所以如果你已经阅读过关于链表的博客，你可能想继续阅读这篇关于红黑树的博客。

//MARK:设置字典(Setting Dictionaries)

//这是 Erica Sadun 提出的非常非常机智的解决方案。简单来讲，就是任何我们需要用一个属性的字典来对一个项进行设置的时候，都应该使用一系列有关联值的枚举来替代。使用这方法，类型检查系统可以确保配置的值都是正确的类型。
//
//关于更多的细节，以及合适的例子，可以阅读下她的文章。

//MARK:局限

//与之前类似，我将会用一系列枚举的局限性来结束本篇文章。

//提取关联值
//
//David Owens写过一篇文章，他觉得当前的关联值提取方式是很笨重的。我墙裂推荐你去看一下他的原文，在这里我对它的要旨进行下说明：为了从一个枚举中获取关联值，我们必须使用模式匹配。然而，关联值就是关联在特定枚举 case 的高效元组。而元组是可以使用更简单的方式来获取它内部值，即 .keyword 或者 .0。
//
//// Enums
//enum Ex { case Mode(ab: Int, cd: Int) }
//if case Ex.Mode(let ab, let cd) = Ex.Mode(ab: 4, cd: 5) {
//    print(ab)
//}
//// vs tuples:
//let tp = (ab: 4, cd: 5)
//print(tp.ab)
//如果你也同样觉得我们应该使用相同的方法来对枚举进行解构(deconstruct)，这里有个 rdar: rdar://22704262 (译者注：一开始我不明白 rdar 是啥意思，后来我 google 了下，如果你也有兴趣，也可以自己去搜索一下)

//MARK:相等性

//拥有关联值的枚举没有遵守 equatable 协议。这是一个遗憾，因为它为很多事情增加了不必要的复杂和麻烦。深层的原因可能是因为关联值的底层使用是使用了元组，而元组并没有遵守 equatable 协议。然而，对于限定的 case 子集，如果这些关联值的类型都遵守了 equatable 类型，我认为编译器应该默认为其生成 equatable 扩展。
//
//// Int 和 String 是可判等的, 所以 Mode 应该也是可判等的
//enum Ex { case Mode(ab: Int, cd: String) }
//
//// Swift 应该能够自动生成这个函数
//func == (lhs: Ex.Mode, rhs: Ex.Mode) -> Bool {
//    switch (lhs, rhs) {
//    case (.Mode(let a, let b), .Mode(let c, let d)):
//        return a == c && b == d
//    default:
//        return false
//    }
//}

//MARK:元组(Tuples)

//最大的问题就是对元组的支持。我喜欢使用元组，它们可以使很多事情变得更简单，但是他们目前还处于无文档状态并且在很多场合都无法使用。在枚举当中，我们无法使用元组作为枚举的值：
//
//enum Devices: (intro: Int, name: String) {
//    case iPhone = (intro: 2007, name: "iPhone")
//    case AppleTV = (intro: 2006, name: "Apple TV")
//    case AppleWatch = (intro: 2014, name: "Apple Watch")
//}
//这似乎看起来并不是一个最好的示例，但是我们一旦开始使用枚举，就会经常陷入到需要用到类似上面这个示例的情形中。
//
//迭代枚举的所有case
//
//这个我们已经在前面讨论过了。目前还没有一个很好的方法来获得枚举中的所有 case 的集合以使我们可以对其进行迭代。

//MARK:默认关联值

//另一个会碰到的事是枚举的关联值总是类型，但是我们却无法为这些类型指定默认值。假设有这样一种情况:
//
//enum Characters {
//    case Mage(health: Int = 70, magic: Int = 100, strength: Int = 30)
//    case Warrior(health: Int = 100, magic: Int = 0, strength: Int = 100)
//    case Neophyte(health: Int = 50, magic: Int = 20, strength: Int = 80)
//}
//我们依然可以使用不同的值创建新的 case，但是角色的默认设置依然会被映射。





