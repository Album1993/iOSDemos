## 条件和布尔操作符（Conditional and Boolean Operators）


条件和布尔操作会根据条件发射或变换 **Observables**，或者对他们做布尔运算。

### 1，amb
#### （1）基本介绍

* 当传入多个 **Observables** 到 **amb** 操作符时，它将取第一个发出元素或产生事件的 **Observable**，然后只发出它的元素。并忽略掉其他的 **Observables**。（哪一个Observable先发出数据，就就收哪一个observable，其他的都忽略）

#### （2）使用样例


```
let disposeBag = DisposeBag()
 
let subject1 = PublishSubject<Int>()
let subject2 = PublishSubject<Int>()
let subject3 = PublishSubject<Int>()
 
subject1
    .amb(subject2)
    .amb(subject3)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
 
subject2.onNext(1)
// 之后只接收subject2的信号了
subject1.onNext(20)
subject2.onNext(2)
subject1.onNext(40)
subject3.onNext(0)
subject2.onNext(3)
subject1.onNext(60)
subject3.onNext(0)
subject3.onNext(0)
```

### 2，takeWhile

#### 1）基本介绍

该方法依次判断 **Observable** 序列的每一个值是否满足给定的条件。 当第一个不满足条件的值出现时，它便自动完成。（和map不一样的地方就是，会直接结束）

#### （2）使用样例

```
let disposeBag = DisposeBag()
 
Observable.of(2, 3, 4, 5, 6)
    .takeWhile { $0 < 4 }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
```

运行结果如下：


```
2
3
```


### 3，takeUntil

#### （1）基本介绍
* 除了订阅源 **Observable** 外，通过 **takeUntil** 方法我们还可以监视另外一个 **Observable**， 即 **notifier**。
* 如果 **notifier** 发出值或 **complete** 通知，那么源 **Observable** 便自动完成，停止发送事件。


#### （2）使用样例


```
let disposeBag = DisposeBag()
 
let source = PublishSubject<String>()
let notifier = PublishSubject<String>()
 
source
    .takeUntil(notifier)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
 
source.onNext("a")
source.onNext("b")
source.onNext("c")
source.onNext("d")
 
//停止接收消息
notifier.onNext("z")
 
source.onNext("e")
source.onNext("f")
source.onNext("g")

```

运行结果如下：



```
a
b
c
d

```

### 4，skipWhile

#### （1）基本介绍

* 该方法用于跳过前面所有满足条件的事件。
* 一旦遇到不满足条件的事件，之后就不会再跳过了。


#### （2）使用样例


```
let disposeBag = DisposeBag()
 
Observable.of(2, 3, 4, 5, 6)
    .skipWhile { $0 < 4 }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
    }
}

```

运行结果如下：



```

4
5
6

```


### 5，skipUntil


#### （1）基本介绍
* 同上面的 **takeUntil** 一样，**skipUntil** 除了订阅源 **Observable** 外，通过 **skipUntil** 方法我们还可以监视另外一个 **Observable**， 即 **notifier** 。
* 与 **takeUntil** 相反的是。源 **Observable** 序列事件默认会一直跳过，直到 **notifier** 发出值或 **complete** 通知。

#### （2）使用样例


```
let disposeBag = DisposeBag()
 
let source = PublishSubject<Int>()
let notifier = PublishSubject<Int>()
 
source
    .skipUntil(notifier)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
 
source.onNext(1)
source.onNext(2)
source.onNext(3)
source.onNext(4)
source.onNext(5)
 
//开始接收消息
notifier.onNext(0)
 
source.onNext(6)
source.onNext(7)
source.onNext(8)
 
//仍然接收消息
notifier.onNext(0)
 
source.onNext(9)

```
运行结果如下：


```
6
7
8
9
```


