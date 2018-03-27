## 错误处理操作（Error Handling Operators）

> 错误处理操作符可以用来帮助我们对 **Observable** 发出的 **error** 事件做出响应，或者从错误中恢复。
> 这里我们先自定义一个错误枚举供后面使用：

```
enum MyError: Error {
    case A
    case B
}
```

### 1，catchErrorJustReturn
#### （1）基本介绍
* 当遇到 **error** 事件的时候，就返回指定的值，然后结束。

#### （2）使用样例

```
let disposeBag = DisposeBag()
 
let sequenceThatFails = PublishSubject<String>()
 
sequenceThatFails
    .catchErrorJustReturn("错误")
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
 
sequenceThatFails.onNext("a")
sequenceThatFails.onNext("b")
sequenceThatFails.onNext("c")
sequenceThatFails.onError(MyError.A)
sequenceThatFails.onNext("d")
```

运行结果如下：


```
a
b
c
错误
```

### 2，catchError
#### （1）基本介绍
* 该方法可以捕获 **error**，并对其进行处理。
* 同时还能返回另一个 **Observable** 序列进行订阅（切换到新的序列）。


```
let disposeBag = DisposeBag()
 
let sequenceThatFails = PublishSubject<String>()
let recoverySequence = Observable.of("1", "2", "3")
 
sequenceThatFails
    .catchError {
        print("Error:", $0)
        return recoverySequence
    }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
 
sequenceThatFails.onNext("a")
sequenceThatFails.onNext("b")
sequenceThatFails.onNext("c")
sequenceThatFails.onError(MyError.A)
sequenceThatFails.onNext("d")
```

运行结果如下：


```
a
b
c
error: A
1
2
3
```

### 3，retry
#### （1）基本介绍
* 使用该方法当遇到错误的时候，会重新订阅该序列。比如遇到网络请求失败时，可以进行重新连接。
* **retry()** 方法可以传入数字表示重试次数。不传的话只会重试一次。



```
let disposeBag = DisposeBag()
var count = 1
 
let sequenceThatErrors = Observable<String>.create { observer in
    observer.onNext("a")
    observer.onNext("b")
     
    //让第一个订阅时发生错误
    if count == 1 {
        observer.onError(MyError.A)
        print("Error encountered")
        count += 1
    }
     
    observer.onNext("c")
    observer.onNext("d")
    observer.onCompleted()
     
    return Disposables.create()
}
 
sequenceThatErrors
    .retry(2)  //重试2次（参数为空则只重试一次）
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)运行结果如下：
```

运行结果如下：



```
a
b
error encountered
a
b
c
d
```

