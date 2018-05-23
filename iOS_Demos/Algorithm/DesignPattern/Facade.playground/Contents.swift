
protocol Facade {
    func simpleMethod()
}

class LegacyCode {
    func someMethod1() { }
    func someMethod2() { }
}

extension LegacyCode: Facade {
    func simpleMethod() {
        someMethod1()
        someMethod2()
    }
}

class Client {
    let f: Facade = LegacyCode()
}

let c = Client()
c.f.simpleMethod()
//为子系统中的一组接口提供一个一致的界面，外观模式定义了一个高层接口，这个接口使得这一子系统更加容易使用。
//在谈起外观模式的时候，常常是指对一个复杂的(旧)代码库在不改变其内在的情况下，包装一层易于调用的表层API。
//
//外观模式不会采用继承，而是用接口和组合。

