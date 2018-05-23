protocol Command {
    var operation: () -> Void { get }
    var backup: String { get }
    func undo()
}

struct ConcreteCommand: Command {
    var backup: String
    var operation: () -> Void
    func undo() {
        print(backup)
    }
}

struct Invoker {
    var command: Command
    func execute() {
        command.operation()
    }
    func undo() {
        command.undo()
    }
}

let printA = ConcreteCommand(backup: "Default A") {
    print("A")
}
let i1 = Invoker(command: printA)
i1.execute() // OUTPUT: A

let printB = ConcreteCommand(backup: "Default B") {
    print("B")
}
let i2 = Invoker(command: printB)
i2.execute() // OUTPUT: B
i2.undo() // OUTPUT: Default B

//命令模式有两个特征：
//
//命令逻辑对象化，这个命令对象可以从外界通过参数传入，也可内部实现。
//支持undo，因为每个命令对象自己知道如何撤销（反命令），所以可以封装到命令对象内部。

