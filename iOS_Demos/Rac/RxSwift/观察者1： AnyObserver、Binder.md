## 一、观察者（Observer）介绍

观察者（**Observer**）的作用就是监听事件，然后对这个事件做出响应。或者说任何响应事件的行为都是观察者。比如：
* 		当我们点击按钮，弹出一个提示框。那么这个“弹出一个提示框”就是观察者 `Observer<Void>`
* 		当我们请求一个远程的 **json** 数据后，将其打印出来。那么这个“打印 **json** 数据”就是观察者 `Observer<JSON>`

## 二、直接在 subscribe、bind 方法中创建观察者

### 1，在 **subscribe** 方法中创建
（1）创建观察者最直接的方法就是在 **Observable** 的 **subscribe** 方法后面描述当事件发生时，需要如何做出响应。
（2）比如下面的样例，观察者就是由后面的 **onNext**，**onError**，**onCompleted** 这些闭包构建出来的。

```
let observable = Observable.of("A", "B", "C")
          
observable.subscribe(onNext: { element in
    print(element)
}, onError: { error in
    print(error)
}, onCompleted: {
    print("completed")
})
```
运行结果如下：

```
A
B
C
completed
```

### 2，在 bind 方法中创建
（1）下面代码我们创建一个定时生成索引数的 **Observable** 序列，并将索引数不断显示在 **label** 标签上：

```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    @IBOutlet weak var label: UILabel!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
         
        //Observable序列（每隔1秒钟发出一个索引数）
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
 
        observable
            .map { "当前索引数：\($0 )"}
            .bind { [weak self](text) in
                //收到发出的索引数后显示到label上
                self?.label.text = text
            }
            .disposed(by: disposeBag)
    }
}
```

（2）运行结果如下：

```
	当前索引：3
```

## 三、使用 AnyObserver 创建观察者
**AnyObserver** 可以用来描叙任意一种观察者。

### 1，配合 subscribe 方法使用
比如上面第一个样例我们可以改成如下代码：

```
//观察者
let observer: AnyObserver<String> = AnyObserver { (event) in
    switch event {
    case .next(let data):
        print(data)
    case .error(let error):
        print(error)
    case .completed:
        print("completed")
    }
}
 
let observable = Observable.of("A", "B", "C")
observable.subscribe(observer)
```

### 2，配合 bindTo 方法使用
也可配合 **Observable** 的数据绑定方法（**bindTo**）使用。比如上面的第二个样例我可以改成如下代码：


```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    @IBOutlet weak var label: UILabel!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
         
        //观察者
        let observer: AnyObserver<String> = AnyObserver { [weak self] (event) in
            switch event {
            case .next(let text):
                //收到发出的索引数后显示到label上
                self?.label.text = text
            default:
                break
            }
        }
         
        //Observable序列（每隔1秒钟发出一个索引数）
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        observable
            .map { "当前索引数：\($0 )"}
            .bind(to: observer)
            .disposed(by: disposeBag)
    }
}
```
运行结果如下：

```
	当前索引：3
```

## 四、使用 Binder 创建观察者
### 1，基本介绍
（1）相较于 **AnyObserver** 的大而全，**Binder** 更专注于特定的场景。**Binder** 主要有以下两个特征：
* 		不会处理错误事件
* 		确保绑定都是在给定 **Scheduler** 上执行（默认 **MainScheduler**）
（2）一旦产生错误事件，在调试环境下将执行 **fatalError**，在发布环境下将打印错误信息。


### 2，使用样例
（1）在上面序列数显示样例中，**label** 标签的文字显示就是一个典型的 UI 观察者。它在响应事件时，只会处理 **next** 事件，而且更新 **UI** 的操作需要在主线程上执行。那么这种情况下更好的方案就是使用 **Binder**。
（2）上面的样例我们改用 **Binder** 会简单许多：

```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    @IBOutlet weak var label: UILabel!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
                 
        //观察者
        let observer: Binder<String> = Binder(label) { (view, text) in
            //收到发出的索引数后显示到label上
            view.text = text
        }
         
        //Observable序列（每隔1秒钟发出一个索引数）
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        observable
            .map { "当前索引数：\($0 )"}
            .bind(to: observer)
            .disposed(by: disposeBag)
    }
}
```
运行结果如下：

```
	当前索引：3
```

