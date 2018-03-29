**线程安全解决方案：**可以给线程加锁，在一个线程执行该操作的时候，不允许其他线程进行操作。**iOS** 实现线程加锁有很多种方式。

* **@synchronized**
* **NSLock**
* **NSRecursiveLock**
* **NSCondition**
* **NSConditionLock**
* **pthread_mutex**
* **dispatch_semaphore**
* **dispatch_barrier_async**
* **OSSpinLock**
* **atomic(property)**
* **set/get**



### 1.@synchronized

在**Objective-C**中，我们可以用**@synchronized**关键字来修饰一个对象，并为其自动加上和解除互斥锁。 但是在**Swift**中，没有与之对应的方法，即**@synchronized**在**Swift**中已经（或者是暂时）不存在了。其实**@synchronized**在幕后做的事情是调用了**objc_sync**中的`objc_sync_enter`和`objc_sync_exit`方法，我可以直接调用这两个方法去实现。


```
var tickets: [Int] = [Int]()
    
@IBAction func onThread() {
    let que = DispatchQueue.init(label: "com.jk.thread", attributes: .concurrent)
    
    //生成100张票
    for i in 0..<100 {
        tickets.append(i)
    }
    
    //北京卖票窗口
    que.async {
        self.saleTicket()
    }
    
    //上海卖票窗口
    que.async {
        self.saleTicket()
    }
}

func saleTicket() {
    while true {
        //加锁，关门，执行任务
        objc_sync_enter(self)
        
        if tickets.count > 0 {
            print("剩余票数", tickets.count, "卖票窗口", Thread.current)
            tickets.removeLast()
            Thread.sleep(forTimeInterval: 0.2)
        }
        else {
            print("票已经卖完了")
            
            //开锁，开门，让其他任务可以执行
            objc_sync_exit(self)
            
            break
        }
        
        //开锁，开门，让其他任务可以执行
        objc_sync_exit(self)
    }
}

```
	
### 2.NSLock

> 锁的概念，锁是最常用的同步工具。一段代码段在同一个时间只能允许被一个线程访问，比如一个线程A进入加锁代码之后由于已经加锁，另一个线程B就无法访问，只有等待前一个线程A执行完加锁代码后解锁，B线程才能访问加锁代码。 不要将过多的其他操作代码放到里面，否则一个线程执行的时候另一个线程就一直在等待，就无法发挥多线程的作用了。

在**Cocoa**程序中**NSLock**中实现了一个简单的互斥锁，实现了**NSLocking Protocol**。实现代码如下：


```
var tickets: [Int] = [Int]()

@IBAction func onThread() {
    let que = DispatchQueue.init(label: "com.jk.thread", attributes: .concurrent)
    
    //生成100张票
    for i in 0..<100 {
        tickets.append(i)
    }
    
    //北京卖票窗口
    que.async {
        self.saleTicket()
    }
    
    //上海卖票窗口
    que.async {
        self.saleTicket()
    }
}

//生成一个锁
let lock = NSLock.init()

func saleTicket() {
    while true {
        //关门，执行任务
        lock.lock()
        
        if tickets.count > 0 {
            print("剩余票数", tickets.count, "卖票窗口", Thread.current)
            tickets.removeLast()
            Thread.sleep(forTimeInterval: 0.2)
        }
        else {
            print("票已经卖完了")
            
            //开门，让其他任务可以执行
            lock.unlock()
            
            break
        }
        
        //开门，让其他任务可以执行
        lock.unlock()
    }
}

```


```
打印结果： 剩余票数 100 卖票窗口 <NSThread: 0x1c0472e40>{number = 6, name = (null)} 
剩余票数 99 卖票窗口 <NSThread: 0x1c027b540>{number = 4, name = (null)} 
剩余票数 98 卖票窗口 <NSThread: 0x1c0472e40>{number = 6, name = (null)} 
剩余票数 97 卖票窗口 <NSThread: 0x1c027b540>{number = 4, name = (null)} 
剩余票数 96 卖票窗口 <NSThread: 0x1c0472e40>{number = 6, name = (null)} 
剩余票数 95 卖票窗口 <NSThread: 0x1c027b540>{number = 4, name = (null)} 
................. 
剩余票数 4 卖票窗口 <NSThread: 0x1c0472e40>{number = 6, name = (null)} 
剩余票数 3 卖票窗口 <NSThread: 0x1c027b540>{number = 4, name = (null)} 
剩余票数 2 卖票窗口 <NSThread: 0x1c0472e40>{number = 6, name = (null)} 
剩余票数 1 卖票窗口 <NSThread: 0x1c027b540>{number = 4, name = (null)} 
票已经卖完了 票已经卖完了

```

### 3.NSRecursiveLock


### 4.NSCondition


### 5.NSConditionLock


### 6.pthread_mutex
> POSIX互斥锁在很多程序里面很容易使用。为了新建一个互斥锁，你声明并初始化一个`pthread_mutex_t`的结构。为了锁住和解锁一个互斥锁，你可以使用`pthread_mutex_lock`和`pthread_mutex_unlock`函数。列表4-2显式了要初始化并使用一个**POSIX**线程的互斥锁的基础代码。当你用完一个锁之后，只要简单的调用`pthread_mutex_destroy`来释放该锁的数据结构。



```
var tickets: [Int] = [Int]()

@IBAction func onThread() {
    let que = DispatchQueue.init(label: "com.jk.thread", attributes: .concurrent)
    
    mutex()
    
    //生成100张票
    for i in 0..<100 {
        tickets.append(i)
    }
    
    //北京卖票窗口
    que.async {
        self.saleTicket()
    }
    
    //上海卖票窗口
    que.async {
        self.saleTicket()
    }
}

//生成一个锁
var lock = pthread_mutex_t.init()

func mutex() {
    //设置属性
    var attr: pthread_mutexattr_t = pthread_mutexattr_t()
    pthread_mutexattr_init(&attr)
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
    let err = pthread_mutex_init(&self.lock, &attr)
    pthread_mutexattr_destroy(&attr)
    
    switch err {
    case 0:
        // Success
        break
        
    case EAGAIN:
        fatalError("Could not create mutex: EAGAIN (The system temporarily lacks the resources to create another mutex.)")
        
    case EINVAL:
        fatalError("Could not create mutex: invalid attributes")
        
    case ENOMEM:
        fatalError("Could not create mutex: no memory")
        
    default:
        fatalError("Could not create mutex, unspecified error \(err)")
    }
}


func saleTicket() {
    while true {
        //关门，执行任务
        pthread_mutex_lock(&lock)
        
        if tickets.count > 0 {
            print("剩余票数", tickets.count, "卖票窗口", Thread.current)
            tickets.removeLast()
            Thread.sleep(forTimeInterval: 0.2)
        }
        else {
            print("票已经卖完了")
            
            //开门，让其他任务可以执行
            pthread_mutex_unlock(&lock)
            
            break
        }
        
        //开门，让其他任务可以执行
        pthread_mutex_unlock(&lock)
    }
}

deinit {
    pthread_mutex_destroy(&lock)
}


```

### 7.dispatch_semaphore
> **GCD**中信号量，也可以解决资源抢占问题，支持信号通知和信号等待。每当发送一个信号通知，则信号量**+1**；每当发送一个等待信号时信号量**-1**；如果信号量为**0**则信号会处于等待状态，直到信号量大于**0**开始执行。

简单地说就是洗手间只有一个坑位，外面进来一个人把门关上，其他人排队，这个人把门打开出去之后，可以再进来一个人。代码例子如下。


```
@IBAction func onThread() {
    let que = DispatchQueue.init(label: "com.jk.thread", attributes: .concurrent)
    
    //生成100张票
    for i in 0..<100 {
        tickets.append(i)
    }
    
    //北京卖票窗口
    que.async {
        self.saleTicket()
    }
    
    //上海卖票窗口
    que.async {
        self.saleTicket()
    }
}

//存在一个坑位
let semp = DispatchSemaphore.init(value: 1)

func saleTicket() {
    while true {
        //占坑，坑位减一
        semp.wait()
        
        if tickets.count > 0 {
            print("剩余票数", tickets.count, "卖票窗口", Thread.current)
            tickets.removeLast()
            Thread.sleep(forTimeInterval: 0.2)
        }
        else {
            print("票已经卖完了")
            
            //释放占坑，坑位加一
            semp.signal()
            
            break
        }
        
        //释放占坑，坑位加一
        semp.signal()
    }
}


```


```
打印结果： 剩余票数 100 卖票窗口 <NSThread: 0x1c0472e40>{number = 6, name = (null)} 
剩余票数 99 卖票窗口 <NSThread: 0x1c027b540>{number = 4, name = (null)} 
剩余票数 98 卖票窗口 <NSThread: 0x1c0472e40>{number = 6, name = (null)} 
剩余票数 97 卖票窗口 <NSThread: 0x1c027b540>{number = 4, name = (null)} 
剩余票数 96 卖票窗口 <NSThread: 0x1c0472e40>{number = 6, name = (null)} 
剩余票数 95 卖票窗口 <NSThread: 0x1c027b540>{number = 4, name = (null)} 
................. 
剩余票数 4 卖票窗口 <NSThread: 0x1c0472e40>{number = 6, name = (null)} 
剩余票数 3 卖票窗口 <NSThread: 0x1c027b540>{number = 4, name = (null)} 
剩余票数 2 卖票窗口 <NSThread: 0x1c0472e40>{number = 6, name = (null)} 
剩余票数 1 卖票窗口 <NSThread: 0x1c027b540>{number = 4, name = (null)} 
票已经卖完了 票已经卖完了

```


在不使用信号量的情况下，运行一段时间就会崩溃，这是多线程同事操作**tickets**票池的**removeLast**去库存的方法引起的，这样显然不符合我们的需求，所以我们需要考虑线程安全问题。


### 8.dispatch_barrier_async

> 我们有时需要异步执行两组操作，而且第一组操作执行完之后，才能开始执行第二组操作。这样我们就需要一个相当于 **栅栏** 一样的一个方法将两组异步执行的操作组给分割起来，当然这里的操作组里可以包含一个或多个任务。这就需要用到`dispatch_barrier_async`方法在两个操作组间形成栅栏。 `dispatch_barrier_async`函数会等待前边追加到并发队列中的任务全部执行完毕之后，再将指定的任务追加到该异步队列中。然后在`dispatch_barrier_async`函数追加的任务执行完毕之后，异步队列才恢复为一般动作，接着追加任务到该异步队列并开始执行。


```
var tickets: [Int] = [Int]()

@IBAction func onThread() {
    let que = DispatchQueue.init(label: "com.jk.thread", attributes: .concurrent)
    
    //生成100张票
    for i in 0..<100 {
        tickets.append(i)
    }
    
    for _ in 0..<51 {
        //北京卖票窗口
        que.async {
            self.saleTicket()
        }
        
        //GCD 栅栏方法，同步去库存
        que.async(flags: .barrier) {
            if self.tickets.count > 0 {
                self.tickets.removeLast()
            }
        }
        
        //上海卖票窗口
        que.async {
            self.saleTicket()
        }
        
        //GCD 栅栏方法，同步去库存
        que.async(flags: .barrier) {
            if self.tickets.count > 0 {
                self.tickets.removeLast()
            }
        }
    }
}

func saleTicket() {
    if tickets.count > 0 {
        print("剩余票数", tickets.count, "卖票窗口", Thread.current)
        Thread.sleep(forTimeInterval: 0.2)
    }
    else {
        print("票已经卖完了")
    }
}

```

### 9.OSSpinLock


### 10.atomic(property)


### 11.set/get



