
protocol AbstractIterator {
    func hasNext() -> Bool
    func next() -> Int?
}

class ConcreteIterator: AbstractIterator {
    private var currentIndex = 0
    var elements = [Int]()
    
    
    func next() -> Int? {
        guard currentIndex < elements.count else { currentIndex = 0; return nil }
        defer { currentIndex += 1 }
        return elements[currentIndex]
    }
    
    func hasNext() -> Bool {
        guard currentIndex < elements.count else { currentIndex = 0; return false }
        return elements[currentIndex] != nil
    }
}

protocol AbstractCollection {
    func makeIterator() -> AbstractIterator
}

class ConcreteCollection: AbstractCollection {
    let iterator = ConcreteIterator()
    func add(_ e: Int) {
        iterator.elements.append(e)
    }
    func makeIterator() -> AbstractIterator {
        return iterator
    }
}

let c = ConcreteCollection()
c.add(1)
c.add(2)
c.add(3)

let iterator = c.makeIterator()
while iterator.hasNext() {
    print(iterator.next() as Any)
}
//迭代器就是能用hasNext和Next来遍历的一种集合元素。
//他很像责任链，但是责任链是一个随时可断的链条（有可能在某一个节点不再把责任下放），他不强调一次完整的遍历。迭代器更像一次次的循环，每次循环都强调完整性，所以更适合集合的场景。
//还有一个区别是迭代器是提供元素，而责任链在每一个经手人那做业务。


