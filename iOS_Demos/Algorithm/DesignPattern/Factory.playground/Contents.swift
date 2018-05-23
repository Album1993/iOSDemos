//: Playground - noun: a place where people can play

protocol Product {}
class ConcreteProductA: Product {}
class ConcreteProductB: Product {}

//无工厂 Non-Factory
//从代码和UML可以看出，为了得到产品A，调用者Client要同时依赖Product, ConcreteProductA和ConcreteProductB，并亲自写一个创建产品的方法。
//每当需求新增一个产品，就要改动到调用方Client。如果这一堆创建代码如果可以抽离出去就好了，于是简单工厂出现了。

class Client {
    func createProduct(type: Int) -> Product {
        if type == 0 {
            return ConcreteProductA()
        } else {
            return ConcreteProductB()
        }
    }
}

let c = Client()
c.createProduct(type: 0) // get ConcreteProductA


//简单工厂 Simple Factory
//Factory代替了Client对具体Product的依赖，那么当需求变化的时候，我们不再需要改动调用方。这固然有所进步，但无法避免的是，每次变动都要在createProduct的方法内部新增一个if-else分支，这显然违背了开闭原则。
//为了解决这个问题，我们引入另一个模式。

protocol Product2 {}
class ConcreteProductA2: Product2 {}
class ConcreteProductB2: Product2 {}

class Client2 {
    let s = Factory2()
}

class Factory2 {
    func createProduct(type: Int) -> Product2 {
        if type == 0 {
            return ConcreteProductA2()
        } else {
            return ConcreteProductB2()
        }
    }
}

let c2 = Client2()
c2.s.createProduct(type: 0) // get ConcreteProductA



//工厂方法 Factory Method
//对于工厂方法的实现，有众多不同的解法，比如Factory只保留一个createProduct让子类实现，让Client来选择生成哪个具体工厂实例；或是引入一个FactoryMaker的中间层，作为生产工厂的“简单工厂”。我这里采用的方式是Factory既作为工厂父类，让具体工厂决定生产生么产品，又作为接口类，让Client可以通过依赖注入选择特定工厂。我这样做的目的是，在不引入新的中间层的情况下，最小化Client的依赖。
//工厂方法在简单工厂的基础上做了两件事：
//
//多了一层抽象，把生产产品的工作延迟到子类执行。
//把“选择如何生产产品的工作”转化为“选择让哪个具体工厂生产”。
//
//工厂方法的贡献在于，这样做虽然不能完美避免对一个if-else的扩展，但是这个扩展规模被极大限制住了（只需要new一个类）。
//工厂方法着重点是解决了单一产品线的派生问题。那如果有多个相关产品线呢？

protocol Product3 {}
class ConcreteProductA3: Product3 {}
class ConcreteProductB3: Product3 {}

class Client3 {
    let f = Factory3()
}

class Factory3 {
    func createProduct() -> Product3? { return nil } // 用于继承
    func createProduct(type: Int) -> Product3? { // 用于调用
        if type == 0 {
            return ConcreteFactoryA3().createProduct()
        } else {
            return ConcreteFactoryB3().createProduct()
        }
    }
}

class ConcreteFactoryA3: Factory3 {
    override func createProduct() -> Product3? {
        // ... 产品加工过程
        return ConcreteProductA3()
    }
}

class ConcreteFactoryB3: Factory3 {
    override func createProduct() -> Product3? {
        // ... 产品加工过程
        return ConcreteProductB3()
    }
}

let c3 = Client3()
c3.f.createProduct(type: 0) // get ConcreteProductA


// 抽象工厂 Abstract Factory
//当我们有两个相关的产品线ProductA和ProductB, 例如螺丝和螺母，他们派生出ProductA1，ProductB1 和 ProductA2，ProductB2，前者我们由工厂ConcreteFactory1来制作，后者由 ConcreteFactory2来制作。
//对于Client来说，他只需要知道有一个抽象的工厂能同时生产ProductA和ProductB就行了，那就是图中的Factory。
//重点来了，这个抽象的Factory是通过“工厂方法”模式把构造过程延迟到子类执行的，也就是说，抽象工厂是建立在工厂方法的基础上的模式。
//所以抽象工厂，换句话说，就是多个产品线需要绑定在一起，形成一个抽象的综合工厂，由具体的综合工厂来批量实现“工厂方法”的一种更“高级”的模式。
//总结
//有点绕，说完这些感觉我已经中文十级了。总之，我想表达的观点是：这些工厂模式并不是割裂的存在，而是一个递进的思想。


protocol ProductA4 {}
class ConcreteProductA14: ProductA4 {}
class ConcreteProductA24: ProductA4 {}

protocol ProductB4 {}
class ConcreteProductB14: ProductB4 {}
class ConcreteProductB24: ProductB4 {}

class Client4 {
    let f = Factory4()
}

class Factory4 {
    func createProductA4() -> ProductA4? { return nil } // 用于继承
    func createProductB4() -> ProductB4? { return nil } // 用于继承
    func createProductA4(type: Int) -> ProductA4? { // 用于调用
        if type == 0 {
            return ConcreteFactory14().createProductA4()
        } else {
            return ConcreteFactory24().createProductA4()
        }
    }
    func createProductB4(type: Int) -> ProductB4? { // 用于调用
        if type == 0 {
            return ConcreteFactory14().createProductB4()
        } else {
            return ConcreteFactory24().createProductB4()
        }
    }
}

class ConcreteFactory14: Factory4 {
    override func createProductA4() -> ProductA4? {
        // ... 产品加工过程
        return ConcreteProductA14()
    }
    override func createProductB4() -> ProductB4? {
        // ... 产品加工过程
        return ConcreteProductB14()
    }
}

class ConcreteFactory24: Factory4 {
    override func createProductA4() -> ProductA4? {
        // ... 产品加工过程
        return ConcreteProductA24()
    }
    override func createProductB4() -> ProductB4? {
        // ... 产品加工过程
        return ConcreteProductB24()
    }
}

let c4 = Client4()
c4.f.createProductA4(type: 0) // get ConcreteProductA1
c4.f.createProductA4(type: 1) // get ConcreteProductA2
c4.f.createProductB4(type: 0) // get ConcreteProductB1
c4.f.createProductB4(type: 1) // get ConcreteProductB2




