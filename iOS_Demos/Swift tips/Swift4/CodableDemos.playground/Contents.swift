//: Playground - noun: a place where people can play

import UIKit

struct Cat {
    let name: String
    let age: Int
    
    func toDictionary() -> [String: Any] {
        return ["name": name, "age": age]
    }
}

let kitten = Cat(name: "kitten", age: 2)
kitten.toDictionary()
// ["name": "kitten", "age": 2]

//显然这是很蠢的做法：
//
//对于每一个需要处理的类型，我们都需要 toDictionary() 这样的模板代码；
//每次进行属性的更改或增删，都要维护该方法的内容；
//字典的 key 只是普通字符串，很可能出现 typo 错误或者没有及时根据类型定义变化进行更新的情况。
//对于一个有所追求的项目来说，解决这部分遗留问题具有相当的高优先级。



//在 Swift 4 引入 Codable 之后，我们有更优秀的方式来做这件事：那就是将 Cat 声明为 Codable
//(或者至少声明为 Encodable - 记住 Codable 其实就是 Decodable & Encodable)，
//然后使用相关的 encoder 来进行编码。不过 Swift 标准库中并没有直接将一个对象编码为字典的编码器，我们可以进行一些变通，
//先将需要处理的类型声明为 Codable，然后使用 JSONEncoder 将其转换为 JSON 数据，最后再从 JSON 数据中拿到对应的字典：

struct CatC: Codable {
    let name: String
    let age: Int
}

let kittenC = CatC(name: "kitten", age: 2)
let encoder = JSONEncoder()

do {
    let data = try encoder.encode(kittenC)
    let dictionary = try JSONSerialization.jsonObject(with: data, options: [])
    // ["name": "kitten", "age": 2]
} catch {
    print(error)
}

//我们只需要将 encoder 在全局进行统一的配置，然后用它来对任意 Codable 进行编码即可。
//唯一美中不足的是，JSONEncoder 本身其实在内部就是先编码为字典，然后再从字典转换为数据的。
//在这里我们又“多此一举”地将数据转换回字典，稍显浪费。但是在非瓶颈的代码路径上，这一点性能损失完全可以接受的。


//Mirror
//Codable 的解决方案已经够好了，不过“好用的方式千篇一律，有趣的解法万万千千”，就这样解决问题也实在有些无聊，我们有没有一些更 hacky 更 cool 更 for fun 一点的做法呢？
//
//当然有，在 review P-R 的时候第一想到的就是 Mirror。使用 Mirror 类型，可以让我们在运行时一窥某个类型的实例的内容，它也是 Swift 中为数不多的与运行时特性相关的手段。Mirror 的最基本的用法如下，你也可以在官方文档中查看它的一些其他定义：


do {
    struct Cat {
        let name: String
        let age: Int
    }
    
    let kitten = Cat(name: "kitten", age: 2)
    let mirror = Mirror(reflecting: kitten)
    for child in mirror.children {
        print("\(child.label!) - \(child.value)")
    }
    // 输出：
    // name - kitten
    // age - 2
//    通过访问实例中 mirror.children 的每一个 child，我们就可以得到所有的存储属性的 label 和 value。以 label 为字典键，value 为字典值，我们就能从任意类型构建出对应的字典了。
}

protocol DictionaryValue {
    var value: Any { get }
}

extension Int: DictionaryValue { var value: Any { return self } }
extension Float: DictionaryValue { var value: Any { return self } }
extension String: DictionaryValue { var value: Any { return self } }
extension Bool: DictionaryValue { var value: Any { return self } }
//严格来说，我们还需要对像是 Int16，Double 之类的其他数字类型进行 DictionaryValue 适配。不过对于一个「概念验证」的 demo 来说，上面的定义就足够了。

extension DictionaryValue {
    var value: Any {
        let mirror = Mirror(reflecting: self)
        var result = [String: Any]()// 这个是初始化方法
        for child in mirror.children {
            // 如果无法获得正确的 key，报错
            guard let key = child.label else {
                fatalError("Invalid key in child: \(child)")
            }
            // 如果 value 无法转换为 DictionaryValue，报错
            if let value = child.value as? DictionaryValue {
                result[key] = value.value
            } else {
                fatalError("Invalid value in child: \(child)")
            }
        }
        return result
    }
}

do {
    struct Cat: DictionaryValue {
        let name: String
        let age: Int
    }
    
    let kitten = Cat(name: "kitten", age: 2)
    print(kitten.value)
// ["name": "kitten", "age": 2]}
    
    
//对于嵌套自定义 DictionaryValue 值的其他类型，字典转换也可以正常工作：
    struct Wizard: DictionaryValue {
        let name: String
        let cat: Cat
    }
    
    let wizard = Wizard(name: "Hermione", cat: kitten)
    print(wizard.value)
    // ["name": "Hermione", "cat": ["name": "kitten", "age": 2]]
}

extension Array: DictionaryValue {
    var value: Any { return map { ($0 as! DictionaryValue).value } }
}
extension Dictionary: DictionaryValue {
    var value: Any { return mapValues { ($0 as! DictionaryValue).value } }
}

do {
    struct Cat: DictionaryValue {
        let name: String
        let age: Int
    }
    
    struct Wizard: DictionaryValue {
        let name: String
        let cat: Cat
    }
    
    struct Gryffindor: DictionaryValue {
        let wizards: [Wizard]
    }
    
    let crooks = Cat(name: "Crookshanks", age: 2)
    let hermione = Wizard(name: "Hermione", cat: crooks)
    
    let hedwig = Cat(name: "hedwig", age: 3)
    let harry = Wizard(name: "Harry", cat: hedwig)
    
    let gryffindor = Gryffindor(wizards: [harry, hermione])
    
    print(gryffindor.value)
    
    print([2,1].value)
    // ["wizards":
    //   [
    //     ["name": "Harry", "cat": ["name": "hedwig", "age": 3]],
    //     ["name": "Hermione", "cat": ["name": "Crookshanks", "age": 2]]
    //   ]
    // ]
    
}



