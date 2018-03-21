
class Soldier {
    func attack() {} // <-- Template Method
    private init() {} // <-- avoid creation
}

class Paladin: Soldier {
    override func attack() {
        print("hammer")
    }
}

class Archer: Soldier {
    override func attack() {
        print("bow")
    }
}

//定义一个操作中的算法的骨架，而将一些步骤延迟到子类中。模板方法使得子类可以不改变一个算法的结构即可重定义该算法的某些特定步骤。
//模板方法指的就是存在在抽象类中的方法声明，由子类具体实现。这样这套方法产生了一套模具不同产品的派生效果。
//
//通过抽象类和子类实现多态。
//
//很可惜Swift/Objective-C都没有抽象类, 所以用一般的class来实现

