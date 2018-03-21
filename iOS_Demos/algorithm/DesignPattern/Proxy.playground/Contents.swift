protocol Subject {
    mutating func operation()
}

struct SecretObject: Subject {
    func operation() {
        // real implementation
    }
}

struct PublicObject: Subject {
    private lazy var s = SecretObject()
    mutating func operation() {
        s.operation()
    }
}

var p = PublicObject()
p.operation()

//有两种常见的代理场景：
//
//Protection proxy： 出于安全考虑，通过一个表层的类间接调用底层的类。
//Virtual proxy：出于性能考虑，通过一个低耗的类延迟调用一个高耗的类。
//但他们的实现是类似的：
//外观是类内部的
//proxy是另一个类

