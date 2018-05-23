
//组合模式就像一个公司的组织架构，存在基层员工(Leaf)和管理者(Composite)，
//他们都实现了组件(Component)的work方法，这种树状结构的每一级都是一个功能完备的个体。

//这个组合模式不是“组合优于继承”的那种“组合”，这里是狭义的指代一种特定场景，就是如配图描述的一种树状结构。
//理解这个模式要知道三个设定：
//
//Component：一个有功能性的组件。
//Leaf：它实现了组件。
//Composite：它既实现了组件，他又包含多个组件。
//这个模式的精髓就是Composite这个角色，事实上Leaf可以看做一个特殊的Compostie。由于他即可以是一个功能执行者，又可以包含其它节点，这个特性可以派生出泛用度很高的树状结构。

protocol Component {
    func someMethod()
}

class Leaf: Component {
    func someMethod() {
        // Leaf
    }
}

class Composite: Component {
    var components = [Component]()
    func someMethod() {
        // Composite
    }
}

let leaf = Leaf()
let composite = Composite()
composite.components += [leaf]

composite.someMethod()
leaf.someMethod()




