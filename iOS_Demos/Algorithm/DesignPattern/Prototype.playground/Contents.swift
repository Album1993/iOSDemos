//: Playground - noun: a place where people can play

//原型模式很简单，你只要实现一个返回你自己的新对象的方法即可。这里我采用的实现还不是最简单的，这个interface并不是必须的。
//
//原型模式实现了深拷贝。
protocol Prototype {
    func clone() -> Prototype
}

struct Product: Prototype {
    var title: String
    func clone() -> Prototype {
        return Product(title: title)
    }
}

let p1 = Product(title: "p1")
let p2 = p1.clone()
(p2 as? Product)?.title // OUTPUT: p1


