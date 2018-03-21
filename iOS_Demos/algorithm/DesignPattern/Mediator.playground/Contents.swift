protocol Sender {
    func send(message: String, to receiver: Receiver)
}

protocol Receiver {
    func receive(message: String)
}

struct ConcreteSender: Sender {
    func send(message: String, to receiver: Receiver) {
        receiver.receive(message: message)
    }
}

struct ConcreteReceiver: Receiver {
    var name: String
    func receive(message: String) {
        print(name, " receive: ", message)
    }
}

let sender = ConcreteSender()
let receiverA = ConcreteReceiver(name: "A")
let receiverB = ConcreteReceiver(name: "B")

// without mediator

sender.send(message: "hello", to: receiverA) // A  receive:  hello
sender.send(message: "hello", to: receiverB) // B  receive:  hello

// with mediator

protocol Mediator {
    func notify(message: String)
    func addReceiver(_ receiver: Receiver)
}

class ConcreteMediator: Mediator {
    var recipients = [Receiver]()
    func notify(message: String) {
        recipients.forEach { $0.receive(message: message) }
    }
    func addReceiver(_ receiver: Receiver) {
        recipients.append(receiver)
    }
}

protocol Component: Receiver {
    var mediator: Mediator { get }
}

struct ConcreteComponent: Component {
    var mediator: Mediator
    var name: String
    func receive(message: String) {
        print(name, " receive: ", message)
    }
}

var mediator = ConcreteMediator()

let c1 = ConcreteComponent(mediator: mediator, name: "c1")
let c2 = ConcreteComponent(mediator: mediator, name: "c2")
let c3 = ConcreteComponent(mediator: mediator, name: "c3")

mediator.addReceiver(c1)
mediator.addReceiver(c2)
mediator.addReceiver(c3)

//c1  receive:  hi
//c2  receive:  hi
//c3  receive:  hi
c1.mediator.notify(message: "hi")

//它和观察者模式很像，区别在于观察者是不关心接受方的广播，中介者是介入两个（或多个）对象之间的定点消息传递。


