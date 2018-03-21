protocol Component {
    var cost: Int { get }
}

protocol Decorator: Component {
    var component: Component { get }
    init(_ component: Component)
}

struct Coffee: Component {
    var cost: Int
}

struct Sugar: Decorator {
    var cost: Int {
        return component.cost + 1
    }
    var component: Component
    init(_ component: Component) {
        self.component = component
    }
}

struct Milk: Decorator {
    var cost: Int {
        return component.cost + 2
    }
    var component: Component
    init(_ component: Component) {
        self.component = component
    }
}

Milk(Sugar(Coffee(cost: 19))).cost

//当你的需求是零散的不断给“主菜加点佐料”的时候，并且这些佐料会经常变化，那么这个模式就可以有效的解决排列组合产生的类爆炸
//理解的一个关键点就是区分组件Component和装饰者Decorator两个角色，单纯组件的实现者（咖啡）是被装饰的对象，他不再能装饰别人。
//这个模式没有一个集中的计算器，每一个装饰者都参与了部分计算并输出当下的结果。

