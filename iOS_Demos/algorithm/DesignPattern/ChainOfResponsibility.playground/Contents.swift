protocol ChainTouchable {
    var next: ChainTouchable? { get }
    func touch()
}

class ViewA: ChainTouchable {
    var next: ChainTouchable? = ViewB()
    func touch() {
        next?.touch()
    }
}

class ViewB: ChainTouchable {
    var next: ChainTouchable? = ViewC()
    func touch() {
        next?.touch()
    }
}

class ViewC: ChainTouchable {
    var next: ChainTouchable? = nil
    func touch() {
        print("C")
    }
}

let a = ViewA()
a.touch() // OUTPUT: C

//UIKit的touch事件就应用了责任链模式
//
//这个模式的实现就是既实现一个接口，又组合这个接口，这样自己执行完毕后就可以调用下一个执行者。

