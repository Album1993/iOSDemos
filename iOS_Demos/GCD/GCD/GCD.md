## GCD


> **GCD**（**Grand Central Dispatch**是苹果为多核并行运算提出的**C**语言并发技术框架。 GCD会自动利用更多的CPU内核； 会自动管理线程的生命周期（**创建线程，调度任务，销毁线程**等）； 程序员只需要告诉**GCD**想要如何执行什么任务，不需要编写任何线程管理代码。




### GCD底层实现

> 我们使用的**GCD**的**API**是**C**语言函数，全部包含在**LIBdispatch**库中，**DispatchQueue**通过结构体和链表被实现为**FIFO**的队列；
> 而**FIFO**的队列是由**dispatch_async**等函数追加的**Block**来管理的；
> **Block**不是直接加入**FIFO**队列，而是先加入**Dispatch Continuation**结构体，然后在加入**FIFO**队列，
> **Dispatch Continuation**用于记忆**Block**所属的**Dispatch Group**和其他一些信息（相当于上下文）。
> **Dispatch Queue**可通过**dispatch_set_target_queue()**设定，可以设定执行该**Dispatch Queue**处理的**Dispatch Queue**为目标。
> 该目标可像串珠子一样，设定多个连接在一起的**Dispatch Queue**,但是在连接串的最后必须设定**Main Dispatch Queue**，或各种优先级的**Global Dispatch Queue**,或是准备用于**Serial Dispatch Queue**的**Global Dispatch Queue**


**Global Dispatch Queue的8种优先级：**

* `.High priority `
* `.Default Priority` 
* `.Low Priority` 
* `.Background Priority `
* `.High Overcommit Priority` 
* `.Default Overcommit Priority` 
* `.Low Overcommit Priority`
* `.Background Overcommit Priority`




附有**Overcommit**的**Global Dispatch Queue**使用在**Serial Dispatch Queue**中，不管系统状态如何，都会强制生成线程的 **Dispatch Queue**。 这8种**Global Dispatch Queue**各使用**1**个**pthread_workqueue**



### GCD初始化


> **GCD**初始化时，使用**pthread_workqueue_create_np**函数生成**pthread_workqueue**。**pthread_workqueue**包含在**Libc**提供的**pthreads**的**API**中，他使用**bsthread_register**和**workq_open**系统调用，在初始化**XNU**内核的**workqueue**之后获取**workqueue**信息。



其中**XNU**有四种**workqueue**：

* **WORKQUEUE_HIGH_PRIOQUEUE**
* **WORKQUEUE_DEFAULT_PRIOQUEUE** 
* **WORKQUEUE_LOW_PRIOQUEUE** 
* **WORKQUEUE_BG_PRIOQUEUE**

这四种**workqueue**与**Global Dispatch Queue**的执行优先级相同
	
### Dispatch Queue执行block的过程

1、当在**Global Dispatch Queue**中执行**Block**时，**libdispatch**从**Global Dispatch Queue**自身的**FIFO**中取出**Dispatch Continuation**，调用**pthread_workqueue_additem_np**函数，将该**Global Dispatch Queue**、符合其优先级的**workqueue**信息以及执行**Dispatch Continuation**的回调函数等传递给**pthread_workqueue_additem_np**函数的参数。

2、**thread_workqueue_additem_np()**使用**workq_kernreturn**系统调用，通知**workqueue**增加应当执行的项目.

3、根据该通知，**XUN**内核基于系统状态判断是否要生成线程，如果是**Overcommit**优先级的**Global Dispatch Queue**，**workqueue**则始终生成线程。

4、**workqueue**的线程执行**pthread_workqueue()**,该函数用**libdispatch**的回调函数，在回调函数中执行执行加入到**Dispatch Continuatin**的**Block**。

5、**Block**执行结束后，进行通知**Dispatch Group**结束，释放**Dispatch Continuation**等处理，开始准备执行加入到**Dispatch Continuation**中的下一个**Block**。



### 六中组合方式区别通过显示如下


区别 | 并发队列 | 串行队列 | 主队列
------- | ------- | -------| ------
同步执行 | 没有开启新线程，串行执行任务 | 没有开启新线程，串行执行任务 | 主线程调用：死锁卡住不执行  其他线程调用：没有开启新线程，串行执行任务
异步执行 |有开启新线程，并发执行任务 | 有开启新线程(1条)，串行执行任务 | 没有开启新线程，串行执行任务


 


### asyncAfter延迟执行

很多时候我们希望延迟执行某个任务，这个时候使用`DispatchQueue.main.asyncAfter`是很方便的。 这个方法并不是立马执行的，延迟执行也不是绝对准确，可以看到，他是在延迟时间过后，把任务追加到主队列，如果主队列有其他耗时任务，这个延迟任务，相对的也要等待任务完成。



```
@IBAction func onThread() {
    //打印当前线程
    print("currentThread---", Thread.current)
    print("代码块------begin")
    
    //主线程延迟执行
    let delay = DispatchTime.now() + .seconds(3)
    DispatchQueue.main.asyncAfter(deadline: delay) {
        print("asyncAfter---", Thread.current)
    }
}

```

### DispatchWorkItem


**DispatchWorkItem**是一个代码块，它可以在任意一个队列上被调用，因此它里面的代码可以在后台运行，也可以在主线程运行。 它的使用真的很简单，就是一堆可以直接调用的代码，而不用像之前一样每次都写一个代码块。我们也可以使用它的通知完成回调任务。
做多线程的业务的时候，经常会有需求，当我们在做耗时操作的时候完成的时候发个通知告诉我这个任务做完了。


```
@IBAction func onThread() {
    //打印当前线程
    print("currentThread---", Thread.current)
    print("代码块------begin")
    
    //创建workItem
    let workItem = DispatchWorkItem.init {
        for _ in 0..<2 {
            print("任务workItem---", Thread.current)
        }
    }
    
    //全局队列(并发队列)执行workItem
    DispatchQueue.global().async {
        workItem.perform()
    }
    
    //执行完之后通知
    workItem.notify(queue: DispatchQueue.main) {
        print("任务workItem完成---", Thread.current)
    }
    
    print("代码块------结束")
}

```

可以看到我们使用全局队列异步执行了workItem，任务执行完，收到了通知。


### DispatchGroup队列组

有些复杂的业务可能会有这个需求，几个队列执行任务，然后把这些队列都放到一个组**Group**里，当组里所有队列的任务都完成了之后，**Group**发出通知，回到主队列完成其他任务。


```
@IBAction func onThread() {
    //打印当前线程
    print("currentThread---", Thread.current)
    print("代码块------begin")
    
    //创建 DispatchGroup
    let group =  DispatchGroup()

    group.enter()
    //全局队列(并发队列)执行任务
    DispatchQueue.global().async {
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("任务1------", Thread.current)//打印线程
        }
        
        group.leave()
    }
    
    //如果需要上个队列完成后再执行可以用wait
    group.wait()
    group.enter()
    //自定义并发队列执行任务
    DispatchQueue.init(label: "com.jackyshan.thread").async {
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("任务2------", Thread.current)//打印线程
        }
        
        group.leave()
    }
    
    //全部执行完后回到主线程刷新UI
    group.notify(queue: DispatchQueue.main) {
        print("任务执行完毕------", Thread.current)//打印线程
    }
    
    print("代码块------结束")
}


```

两个队列，一个执行默认的全局队列，一个是自己自定义的并发队列，两个队列都完成之后，**group**得到了通知。 如果把**group.wait()**注释掉，我们会看到两个队列的任务会交替执行。


### dispatch_barrier_async栅栏方法


`dispatch_barrier_async`是**oc**的实现，**Swift**的实现`que.async(flags: .barrier)`这样。


```
@IBAction func onThread() {
    //打印当前线程
    print("currentThread---", Thread.current)
    print("代码块------begin")
    
    //创建并发队列
    let que = DispatchQueue.init(label: "com.jackyshan.thread", attributes: .concurrent)

    //并发异步执行任务
    que.async {
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("任务0------", Thread.current)//打印线程
        }
    }

    //并发异步执行任务
    que.async {
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("任务1------", Thread.current)//打印线程
        }
    }
    
    //栅栏方法：等待队列里前面的任务执行完之后执行
    que.async(flags: .barrier) {
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("任务2------", Thread.current)//打印线程
        }
        //执行完之后执行队列后面的任务
    }
    
    //并发异步执行任务
    que.async {
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("任务3------", Thread.current)//打印线程
        }
    }
    
    print("代码块------结束")
}


```

可以看到由于**任务2**执行的**barrier**的操作，**任务0和1**交替执行，**任务2**等待**0和1**执行完才执行，**任务3**也是等待**任务2**执行完毕。 也可以看到由于**barrier**的操作，并没有开启新的线程去跑任务。

### Quality Of Service（QoS）和优先级

> 在使用 **GCD** 与 **dispatch queue** 时，我们经常需要告诉系统，应用程序中的哪些任务比较重要，需要更高的优先级去执行。当然，由于主队列总是用来处理 **UI** 以及界面的响应，所以在主线程执行的任务永远都有最高的优先级。不管在哪种情况下，只要告诉系统必要的信息，**iOS** 就会根据你的需求安排好队列的优先级以及它们所需要的资源（比如说所需的 **CPU** 执行时间）。虽然所有的任务最终都会完成，但是，重要的区别在于哪些任务更快完成，哪些任务完成得更晚。



> 在使用 **GCD** 与 **dispatch queue** 时，我们经常需要告诉系统，应用程序中的哪些任务比较重要，需要更高的优先级去执行。当然，由于主队列总是用来处理 **UI** 以及界面的响应，所以在主线程执行的任务永远都有最高的优先级。不管在哪种情况下，只要告诉系统必要的信息，**iOS** 就会根据你的需求安排好队列的优先级以及它们所需要的资源（比如说所需的 **CPU** 执行时间）。虽然所有的任务最终都会完成，但是，重要的区别在于哪些任务更快完成，哪些任务完成得更晚。



* userInteractive
* userInitiated
* default
* utility
* background
* unspecified

创建两个队列，优先级都是**userInteractive**，看看效果：


```
@IBAction func onThread() {
    //打印当前线程
    print("currentThread---", Thread.current)
    print("代码块------begin")
    
    //创建并发队列1
    let que1 = DispatchQueue.init(label: "com.jackyshan.thread1", qos: .userInteractive, attributes: .concurrent)

    //创建并发队列2
    let que2 = DispatchQueue.init(label: "com.jackyshan.thread2", qos: .userInteractive, attributes: .concurrent)
    
    que1.async {
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("任务1------", Thread.current)//打印线程
        }
    }
    
    que2.async {
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("任务2------", Thread.current)//打印线程
        }
    }

    print("代码块------结束")
}


```

两个队列的优先级一样，任务也是交替执行，这和我们预测的一样。

下面把**queue1**的优先级改为**background**，看看效果：


```
@IBAction func onThread() {
    //打印当前线程
    print("currentThread---", Thread.current)
    print("代码块------begin")
    
    //创建并发队列1
    let que1 = DispatchQueue.init(label: "com.jackyshan.thread1", qos: .background, attributes: .concurrent)

    //创建并发队列2
    let que2 = DispatchQueue.init(label: "com.jackyshan.thread2", qos: .userInteractive, attributes: .concurrent)
    
    que1.async {
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("任务1------", Thread.current)//打印线程
        }
    }
    
    que2.async {
        for _ in 0..<2 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("任务2------", Thread.current)//打印线程
        }
    }

    print("代码块------结束")
}


```

可以看到**queue1**的优先级调低为**background**，**queue2**的任务就优先执行了。

### DispatchSemaphore信号量

> **GCD** 中的信号量是指 **Dispatch Semaphore**，是持有计数的信号。类似于过高速路收费站的栏杆。可以通过时，打开栏杆，不可以通过时，关闭栏杆。在 **Dispatch Semaphore** 中，使用计数来完成这个功能，计数为0时等待，不可通过。计数为1或大于1时，计数减1且不等待，可通过。


* `DispatchSemaphore(value: )`：用于创建信号量，可以指定初始化信号量计数值，这里我们默认1.
* `semaphore.wait()`：会判断信号量，如果为1，则往下执行。如果是0，则等待。
* `semaphore.signal()`：代表运行结束，信号量加1，有等待的任务这个时候才会继续执行。


可以使用**DispatchSemaphore**实现线程同步，保证线程安全。
加入有一个票池，同时几个线程去卖票，我们要保证每个线程获取的票池是一致的。 使用**DispatchSemaphore**和刚才讲的**DispatchWorkItem**来实现，我们看看效果。



```
@IBAction func onThread() {
    //打印当前线程
    print("currentThread---", Thread.current)
    print("代码块------begin")
    
    //创建票池
    var tickets = [Int]()
    for i in 0..<38 {
        tickets.append(i)
    }
    
    //创建一个初始计数值为1的信号
    let semaphore = DispatchSemaphore(value: 1)
    
    let workItem = DispatchWorkItem.init {
        semaphore.wait()
        
        if tickets.count > 0 {
            Thread.sleep(forTimeInterval: 0.2)//耗时操作
            print("剩余票数", tickets.count, Thread.current)
            
            tickets.removeLast()//去票池库存
        }
        else {
            print("票池没票了")
        }
        
        semaphore.signal()
    }

    //创建并发队列1
    let que1 = DispatchQueue.init(label: "com.jackyshan.thread1", qos: .background, attributes: .concurrent)

    //创建并发队列2
    let que2 = DispatchQueue.init(label: "com.jackyshan.thread2", qos: .userInteractive, attributes: .concurrent)
    
    que1.async {
        for _ in 0..<20 {
            workItem.perform()
        }
    }
    
    que2.async {
        for _ in 0..<20 {
            workItem.perform()
        }
    }

    print("代码块------结束")
}


```

### DispatchSource

> DispatchSource provides an interface for monitoring low-level system objects such as Mach ports, Unix descriptors, Unix signals, and VFS nodes for activity and submitting event handlers to dispatch queues for asynchronous processing when such activity occurs. 
> 
> **DispatchSource**提供了一组接口，用来提交**hander**监测底层的事件，这些事件包括**Mach** **ports，Unix descriptors，Unix signals，VFS nodes**。



**Tips:** **DispatchSource**这个**class**很好的体现了**Swift**是一门面向协议的语言。这个类是一个工厂类，用来实现各种**source**。比如**DispatchSourceTimer**（本身是个协议）表示一个定时器。
	

`DispatchSourceProtocol`


基础协议，所有的用到的`DispatchSource`都实现了这个协议。这个协议的提供了公共的方法和属性： 由于不同的`source`是用到的属性和方法不一样，这里只列出几个公共的方法

* `activate` //激活
* `suspend` //挂起
* `resume` //继续
* `cancel` //取消(异步的取消，会保证当前eventHander执行完)
* `setEventHandler` //事件处理逻辑
* `setCancelHandler` //取消时候的清理逻辑
* `DispatchSourceTimer`


在**Swift 3**中，可以方便的用**GCD**创建一个**Timer**(新特性)。**DispatchSourceTimer**本身是一个协议。 比如，写一个**timer**，1秒后执行，然后10秒后自动取消，允许10毫秒的误差


```
PlaygroundPage.current.needsIndefiniteExecution = true

public let timer = DispatchSource.makeTimerSource()

timer.setEventHandler {
    //这里要注意循环引用，[weak self] in
    print("Timer fired at \(NSDate())")
}

timer.setCancelHandler {
    print("Timer canceled at \(NSDate())" )
}

timer.scheduleRepeating(deadline: .now() + .seconds(1), interval: 2.0, leeway: .microseconds(10))

print("Timer resume at \(NSDate())")

timer.resume()

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute:{
    timer.cancel()
})

```


**deadline**表示开始时间，**leeway**表示能够容忍的误差。


**DispatchSourceTimer**也支持只调用一次。

```
func scheduleOneshot(deadline: DispatchTime, leeway: DispatchTimeInterval = default)
```

### UserData

**DispatchSource**中**UserData**部分也是强有力的工具，这部分包括两个协议，两个协议都是用来合并数据的变化，只不过一个是按照**+(加)**的方式，一个是**按照|(位与)**的方式。

* **DispatchSourceUserDataAdd** 
* **DispatchSourceUserDataOr**


> 在使用这两种**Source**的时候，**GCD**会帮助我们自动的将这些改变合并，然后在适当的时候（**target queue空闲**）的时候，去回调**EventHandler**,从而避免了频繁的回调导致**CPU**占用过多。


```
let userData = DispatchSource.makeUserDataAddSource()

var globalData:UInt = 0

userData.setEventHandler {
    let pendingData = userData.data
    globalData = globalData + pendingData
    print("Add \(pendingData) to global and current global is \(globalData)")
}

userData.resume()

let serialQueue = DispatchQueue(label: "com")

serialQueue.async {
    for var index in 1...1000 {
        userData.add(data: 1)
    }

    for var index in 1...1000 {
        userData.add(data: 1)
    }
}


```


```
Add 32 to global and current global is 32
Add 1321 to global and current global is 1353
Add 617 to global and current global is 1970
Add 30 to global and current global is 2000

```

