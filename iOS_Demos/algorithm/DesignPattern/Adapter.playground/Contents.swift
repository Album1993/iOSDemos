

//一个类能称之为适配器，就是指它能把另一个类进行某种变形，让其能和实际需求对接。 比如一个底层数据模型，可以通过不同的UI适配器，对应不同的展现需要。
protocol Target {
    var value: String { get }
}

struct Adapter: Target {
    let adaptee: Adaptee
    var value: String {
        return "\(adaptee.value)"
    }
    init(_ adaptee: Adaptee) {
        self.adaptee = adaptee
    }
}

struct Adaptee {
    var value: Int
}

Adapter(Adaptee(value: 1)).value // "1"


