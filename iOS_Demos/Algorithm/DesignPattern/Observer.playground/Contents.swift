//: Playground - noun: a place where people can play


//观察者模式定义了对象之间的一对多依赖，这样一来，当一个对象改变状态时，它的所有依赖者都会收到通知并自动更新。
//观察者模式适用在一个被观察者（数据源）要通知多个观察者的场景。
//这个模式主要通过添加一层接口，来把观察者的具体类型擦除，从何实现松耦合。（针对接口编程，而非实现）
//观察者模式一个最重要的特点就是它是一种推模型(PUSH)，在很多情况下比拉模型更高效和即时。


protocol Observable {
    var observers: [Observer] { get }
    func add(observer: Observer)
    func remove(observer: Observer)
    func notifyObservers()
}

class ConcreteObservable: Observable {
    var observers = [Observer]()
    func add(observer: Observer) {
        observers.append(observer)
    }
    func remove(observer: Observer) {
        if let index = observers.index(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    func notifyObservers() {
        observers.forEach { $0.update() }
    }
}

protocol Observer: class {
    func update()
}

class ConcreteObserverA: Observer {
    func update() { print("A") }
}

class ConcreteObserverB: Observer {
    func update() { print("B") }
}

//////////////////////////////////

let observable = ConcreteObservable()
let a = ConcreteObserverA()
let b = ConcreteObserverB()
observable.add(observer: a)
observable.add(observer: b)
observable.notifyObservers() // output: A B

observable.remove(observer: b)
observable.notifyObservers() // output: A


