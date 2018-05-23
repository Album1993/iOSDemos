
protocol WeaponBehavior {
    func use()
}

class SwordBehavior: WeaponBehavior {
    func use() { print("sword") }
}

class BowBehavior: WeaponBehavior {
    func use() { print("bow") }
}

class Character {
    var weapon: WeaponBehavior?
    func attack() {  weapon?.use() }
}

class Knight: Character {
    override init() {
        super.init()
        weapon = SwordBehavior()
    }
}

class Archer: Character {
    override init() {
        super.init()
        weapon = BowBehavior()
    }
}

///////////////////////////////////

Knight().attack() // output: sword
Archer().attack() // output: bow

//这个模式主要还是在解决一个稳定的继承树当遇到需求变化时的狼狈。他把变化的几种情况分门别类的封装好，然后把自己变化的部分隔离成一个接口实例(interface/protocol)，让子类继承后来做选择题。
//一个需要转变的思维就是：建模一个类的时候不能只局限于物体（object），也可以是行为（behavior）的封装。
//用继承来替换interface实现多态的behavior也是理论可行的。
//这个模式还有一个强大之处：他是动态的。就是至于子类选择了什么行为，不见得是写代码的时候写死的；也可以是类似用户点击一下切换了算法。

