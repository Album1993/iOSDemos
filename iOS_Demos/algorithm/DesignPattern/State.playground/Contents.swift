//状态模式很像策略模式，但是他封装的不是算法，而是一个一个本体下的不同状态。


protocol State {
    func operation()
}

class ConcreteStateA: State {
    func operation() {
        print("A")
    }
}

class ConcreteStateB: State {
    func operation() {
        print("B")
    }
}

class Context {
    var state: State = ConcreteStateA()
    func someMethod() {
        state.operation()
    }
}

let c = Context()
c.someMethod() // OUTPUT: A
c.state = ConcreteStateB() // switch state
c.someMethod() // OUTPUT: B

