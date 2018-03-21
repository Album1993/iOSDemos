struct TargetObject {
    var title: String?
    func printTitle() {
        print(title)
    }
}

class Cache {
    var targetObjects = [String: TargetObject]()
    func lookup(key: String) -> TargetObject {
        if targetObjects.index(forKey: key) == nil {
            return TargetObject()
        }
        return targetObjects[key]!
    }
}

let c = Cache()
c.targetObjects["Test"] = TargetObject(title: "Test")
c.lookup(key: "123").printTitle() // nil
c.lookup(key: "Test").printTitle() // Test

//运用共享技术有效地支持大量细粒度的对象。
//
//享元模式其实就是指一套缓存系统。 显然他是一种复合模式，使用工厂模式来创造实例。 适用场景是系统中存在重复的对象创建过程。 好处是节省了内存加快了速度。

