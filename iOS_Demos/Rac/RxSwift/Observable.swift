//
//  Observable.swift
//  iOS_Demos
//
//  Created by 张一鸣 on 23/03/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import Foundation

/**
1，Observable<T>
Observable<T> 这个类就是 Rx 框架的基础，我们可以称它为可观察序列。它的作用就是可以异步地产生一系列的 Event（事件），即一个 Observable<T> 对象会随着时间推移不定期地发出 event(element : T) 这样一个东西。
而且这些 Event 还可以携带数据，它的泛型 <T> 就是用来指定这个 Event 携带的数据的类型。
有了可观察序列，我们还需要有一个 Observer（订阅者）来订阅它，这样这个订阅者才能收到 Observable<T> 不时发出的 Event。


2，Event
查看 RxSwift 源码可以发现，事件 Event 的定义如下：

public enum Event<Element> {
    /// Next element is produced.
    case next(Element)

    /// Sequence terminated with an error.
    case error(Swift.Error)

    /// Sequence completed successfully.
    case completed
}

可以看到 Event 就是一个枚举，也就是说一个 Observable 是可以发出 3 种不同类型的 Event 事件：
next：next 事件就是那个可以携带数据 <T> 的事件，可以说它就是一个“最正常”的事件。

 -----> 1 ---------> 2 ---------> 3-------->
 
 error：error 事件表示一个错误，它可以携带具体的错误内容，
 一旦 Observable 发出了 error event，则这个 Observable 就等于终止了，以后它再也不会发出 event 事件了。
 
 
  -----> 1 ---------> 2 ---------> x-------->
 
 completed：completed 事件表示 Observable 发出的事件正常地结束了，跟 error 一样，一旦 Observable 发出了 completed event，则这个 Observable 就等于终止了，以后它再也不会发出 event 事件了。
 
  -----> 1 ---------> 2 ---------> 3----|---->
 
 
 3，Observable 与 Sequence比较
 （1）为更好地理解，我们可以把每一个 Observable 的实例想象成于一个 Swift 中的 Sequence：
 即一个 Observable（ObservableType）相当于一个序列 Sequence（SequenceType）。
 ObservableType.subscribe(_:) 方法其实就相当于 SequenceType.generate()
 
 （2）但它们之间还是有许多区别的：
 Swift 中的 SequenceType 是同步的循环，而 Observable 是异步的。
 Observable 对象会在有任何 Event 时候，自动将 Event 作为一个参数通过 ObservableType.subscribe(_:) 发出，并不需要使用 next 方法。

 四、创建 Observable 序列
 我们可以通过如下几种方法来创建一个 Observable 序列
 
 1，just() 方法
 （1）该方法通过传入一个默认值来初始化。
 （2）下面样例我们显式地标注出了 observable 的类型为 Observable<Int>，即指定了这个 Observable 所发出的事件携带的数据类型必须是 Int 类型的。

 let observable = Observable<Int>.just(5)
 
 2，of() 方法
 （1）该方法可以接受可变数量的参数（必需要是同类型的）
 （2）下面样例中我没有显式地声明出 Observable 的泛型类型，Swift 也会自动推断类型。
 
 let observable = Observable.of("A", "B", "C")
 
 3，from() 方法
 （1）该方法需要一个数组参数。
 （2）下面样例中数据里的元素就会被当做这个 Observable 所发出 event 携带的数据内容，最终效果同上面饿 of() 样例是一样的。
 
 let observable = Observable.from(["A", "B", "C"])
 
 4，empty() 方法
 该方法创建一个空内容的 Observable 序列。
 
 let observable = Observable<Int>.empty()
 
 5，never() 方法
 该方法创建一个永远不会发出 Event（也不会终止）的 Observable 序列。
 
 let observable = Observable<Int>.never()
 
 6，error() 方法
 该方法创建一个不做任何操作，而是直接发送一个错误的 Observable 序列。

 enum MyError: Error {
 case A
 case B
 }
 
 let observable = Observable<Int>.error(MyError.A)
 
 7，range() 方法
 （1）该方法通过指定起始和结束数值，创建一个以这个范围内所有值作为初始值的 Observable 序列。
 （2）下面样例中，两种方法创建的 Observable 序列都是一样的。

 //使用range()
 let observable = Observable.range(start: 1, count: 5)
 
 //使用of()
 let observable = Observable.of(1, 2, 3 ,4 ,5)
 
 8，repeatElement() 方法
 该方法创建一个可以无限发出给定元素的 Event 的 Observable 序列（永不终止）。
 
 let observable = Observable.repeatElement(1)
 
 9，generate() 方法
 （1）该方法创建一个只有当提供的所有的判断条件都为 true 的时候，才会给出动作的 Observable 序列。
 （2）下面样例中，两种方法创建的 Observable 序列都是一样的。

 //使用generate()方法
 let observable = Observable.generate(
 initialState: 0,
 condition: { $0 <= 10 },
 iterate: { $0 + 2 }
 )
 
 //使用of()方法
 let observable = Observable.of(0 , 2 ,4 ,6 ,8 ,10)
 
 10，create() 方法
 （1）该方法接受一个 block 形式的参数，任务是对每一个过来的订阅进行处理。
 （2）下面是一个简单的样例。为方便演示，这里增加了订阅相关代码（关于订阅我之后会详细介绍的）。

 
 //这个block有一个回调参数observer就是订阅这个Observable对象的订阅者
 //当一个订阅者订阅这个Observable对象的时候，就会将订阅者作为参数传入这个block来执行一些内容
 let observable = Observable<String>.create{observer in
 //对订阅者发出了.next事件，且携带了一个数据"hangge.com"
 observer.onNext("hangge.com")
 //对订阅者发出了.completed事件
 observer.onCompleted()
 //因为一个订阅行为会有一个Disposable类型的返回值，所以在结尾一定要returen一个Disposable
 return Disposables.create()
 }
 
 //订阅测试
 observable.subscribe {
 print($0)
 }
 运行结果如下：
**/
