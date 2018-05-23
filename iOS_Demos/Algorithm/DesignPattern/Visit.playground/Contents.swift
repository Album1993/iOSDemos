protocol Visitor {
    func visit(_ c: ComponentA)
    func visit(_ c: ComponentB)
}

struct ConcreteVisitor: Visitor {
    func visit(_ c: ComponentA) {
        c.featureA()
    }
    func visit(_ c: ComponentB) {
        c.featureB()
    }
}

protocol Component {
    func accept(_ v: Visitor)
}

struct ComponentA: Component {
    func featureA() {
        print("Feature A")
    }
    func accept(_ v: Visitor) {
        v.visit(self)
    }
}

struct ComponentB: Component {
    func featureB() {
        print("Feature B")
    }
    func accept(_ v: Visitor) {
        v.visit(self)
    }
}

let components: [Component] = [ComponentA(), ComponentB()]
components.forEach {
    $0.accept(ConcreteVisitor())
}

protocol Event {}
class BlueEvent: Event {}
class RedEvent: Event {}

class Handler {
    func handle(_ e: Event) {
        print("Event")
    }
    func handle(_ r: RedEvent) {
        print("RedEvent")
    }
    func handle(_ b: BlueEvent) {
        print("BlueEvent")
    }
}

let b = BlueEvent()
let r = RedEvent()
let c = Handler()

c.handle(b) // OUTPUT: BlueEvent
c.handle(r) // OUTPUT: RedEvent
//验证发现，Swift是支持双重派发的。
//那什么是双重派发（Double Dispatch）？
//要解释这个，要先搞清楚什么是派发（Dispatch）。
//派发或者说Single Dispatch，Dynamic Dispatch，wiki是这样解释的：
//
//In most object-oriented systems, the concrete function that is called from a function call in the code depends on the dynamic type of a single object and therefore they are known as single dispatch calls, or simply virtual function calls.
//抓要点说，就是多态的情况下，在运行时，虚方法是由哪个具体实现执行了，这样的绑定动作就是派发。
//
//那什么虚方法？
//看一下wiki的解释：
//
//In short, a virtual function defines a target function to be executed, but the target might not be known at compile time.
//虚方法就是编译期还没确定实现的方法，我们可以理解成接口中声明的方法。
//
//好，我们现在知道了一次虚方法的绑定就是派发，双重派发就是两次绑定操作。
//那双重派发的代码是如何触发派发的呢？
//
//overload 重载
//重载产生的多态引起一次派发
//override 重写
//接口实现的多态引起第二次派发
//
//理解这些就知道这个模式在折腾什么了。
//当然他也有另外的好处，就是可以让具体的业务类可以丢到集合里批量的执行accept visitor。



