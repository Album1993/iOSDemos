### 五、ControlProperty


#### 1，基本介绍
##### （1）**ControlProperty** 是专门用来描述 **UI** 控件属性，拥有该类型的属性都是被观察者（**Observable**）。
##### （2）**ControlProperty** 具有以下特征：

* 不会产生 **error** 事件
* 一定在 **MainScheduler** 订阅（主线程订阅）
* 一定在 **MainScheduler** 监听（主线程监听）
* 共享状态变化

#### 2，使用样例
##### （1）其实在 **RxCocoa** 下许多 **UI** 控件属性都是被观察者（可观察序列）。比如我们查看源码（**UITextField+Rx.swift**），可以发现 **UITextField** 的 **rx.text** 属性类型便是 **ControlProperty<String?>：**

```
import RxSwift
import UIKit
 
extension Reactive where Base: UITextField {
 
    public var text: ControlProperty<String?> {
        return value
    }
 
    public var value: ControlProperty<String?> {
        return base.rx.controlPropertyWithDefaultEvents(
            getter: { textField in
                textField.text
        },
            setter: { textField, value in
                if textField.text != value {
                    textField.text = value
                }
        }
        )
    }
     
    //......
}
```

##### （2）那么我们如果想让一个 textField 里输入内容实时地显示在另一个 label 上，即前者作为被观察者，后者作为观察者。可以这么写：

```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    @IBOutlet weak var textField: UITextField!
     
    @IBOutlet weak var label: UILabel!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
         
        //将textField输入的文字绑定到label上
        textField.rx.text
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}
 
extension UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}
```


### 六 、ControlEvent


#### 1，基本介绍
##### （1）ControlEvent 是专门用于描述 UI 所产生的事件，拥有该类型的属性都是被观察者（Observable）。
##### （2）ControlEvent 和 ControlProperty 一样，都具有以下特征：

* 不会产生 **error** 事件
* 一定在 **MainScheduler** 订阅（主线程订阅）
* 一定在 **MainScheduler** 监听（主线程监听）
* 共享状态变化

#### 2，使用样例
##### （1）同样地，在 RxCocoa 下许多 UI 控件的事件方法都是被观察者（可观察序列）。比如我们查看源码（UIButton+Rx.swift），可以发现 UIButton 的 rx.tap 方法类型便是 ControlEvent<Void>：

```
import RxSwift
import UIKit
 
extension Reactive where Base: UIButton {
    public var tap: ControlEvent<Void> {
        return controlEvent(.touchUpInside)
    }
}
```

##### （2）那么我们如果想实现当一个 button 被点击时，在控制台输出一段文字。即前者作为被观察者，后者作为观察者。可以这么写：

```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    @IBOutlet weak var button: UIButton!
     
    override func viewDidLoad() {
         
        //订阅按钮点击事件
        button.rx.tap
            .subscribe(onNext: {
                print("欢迎访问hangge.com")
            }).disposed(by: disposeBag)
    }
}
```


