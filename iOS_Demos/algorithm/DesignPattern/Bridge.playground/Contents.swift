//: Playground - noun: a place where people can play

protocol 开关能力 {
    func turnOn(_ on: Bool)
}

class 设备 {
    let obj: 开关能力
    func turnOn(_ on: Bool) {
        obj.turnOn(on)
    }
    init(_ obj: 开关能力) {
        self.obj = obj
    }
}

class 电视: 开关能力 {
    func turnOn(_ on: Bool) {
        if on {
            // 打开电视
        } else {
            // 关闭电视
        }
    }
}

class 空调: 开关能力 {
    func turnOn(_ on: Bool) {
        if on {
            // 打开空调
        } else {
            // 关闭空调
        }
    }
}

let tv = 设备(电视())
tv.turnOn(true) // 打开电视

let aircon = 设备(空调())
aircon.turnOn(false) // 关闭空调

//在把抽象的设备应用到具体的业务的时候，这个模式采用的是组合了一个实现了开关能力接口的实例，而没用继承。
//最终调用的时候，是由统一的设备作为接入点的，而不是电视，空调这些具体类，具体的实现是通过组合的方式注入到设备里的。

//没错，它把需要变化的代码通过接口代理出去，而避免了继承。
//
//但是，桥接模式的桥在哪里？
//不同在于适配器的关注点是如何让两个不兼容的类对接， 而桥接模式关注点是解耦。



