
typealias Memento = [String: String] // chatper: level
protocol MementoConvertible {
    var memento: Memento { get }
    init?(memento: Memento)
}

class GameState: MementoConvertible {
    var memento: Memento {
        return [chapter: level]
    }
    var chapter: String
    var level: String
    
    required init?(memento: Memento) {
        self.chapter = memento.keys.first ?? ""
        self.level = memento.values.first ?? ""
    }
    init(chapter: String, level: String) {
        self.chapter = chapter
        self.level = level
    }
}

protocol CaretakerConvertible {
    static func save(memonto: Memento, for key: String)
    static func loadMemonto(for key: String) -> Memento?
}

class Caretaker: CaretakerConvertible {
    static func save(memonto: Memento, for key: String) {
//        let defaults = UserDefaults.standard
//        defaults.set(memonto, forKey: key)
//        defaults.synchronize()
    }
    
    static func loadMemonto(for key: String) -> Memento? {
//        let defaults = UserDefaults.standard
//        return defaults.object(forKey: key) as? Memento
        return nil
    }
    
}

let g = GameState(chapter: "Prologue", level: "0")
// after a while
g.chapter = "Second"
g.level = "20"
// want a break
Caretaker.save(memonto: g.memento, for: "gamename")
// load game
let gameState = Caretaker.loadMemonto(for: "gamename") // ["Second": "20"]

//在不破坏封装性的前提下，捕获一个对象的内部状态，并在该对象之外保存这个状态。
//这个模式有两个角色，一个是要存储的类型本身(Memento)和执行存储操作的保管人(Caretaker)。




