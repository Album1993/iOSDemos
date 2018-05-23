//: Playground - noun: a place where people can play
class Singleton {
    static var singleton: Singleton? = nil
    private init() {}
    static func sharedInstance() -> Singleton {
        if singleton == nil {
            singleton = Singleton()
        }
        return singleton!
    }
}

let s = Singleton.sharedInstance()
//let s2 = Singleton() // ERROR: initializer is inaccessible due to 'private' protection level


