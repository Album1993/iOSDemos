## UI控件扩展2：UITextField、UITextView

### 1，监听单个 textField 内容的变化（textView 同理）
#### （1）下面样例中我们将 **textField** 里输入的内容实时地显示到控制台中。

#### （2）样例代码


> 注意：`.orEmpty` 可以将 **String?** 类型的 **ControlProperty** 转成 **String**，省得我们再去解包。



```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
         
        //创建文本输入框
        let textField = UITextField(frame: CGRect(x:10, y:80, width:200, height:30))
        textField.borderStyle = UITextBorderStyle.roundedRect
        self.view.addSubview(textField)
         
        //当文本框内容改变时，将内容输出到控制台上
        textField.rx.text.orEmpty.asObservable()
            .subscribe(onNext: {
                print("您输入的是：\($0)")
            })
            .disposed(by: disposeBag)
    }
}

```

#### （3）当然我们直接使用 change 事件效果也是一样的。


```
//当文本框内容改变时，将内容输出到控制台上
textField.rx.text.orEmpty.changed
    .subscribe(onNext: {
        print("您输入的是：\($0)")
    })
    .disposed(by: disposeBag)

```

### 2，将内容绑定到其他控件上


#### （1）效果图
* 我们将第一个 **textField** 里输入的内容实时地显示到第二个 **textField** 中。
* 同时 **label** 中还会实时显示当前的字数。
* 最下方的“提交”按钮会根据当前的字数决定是否可用（字数超过 5 个字才可用）

#### （2）样例代码
> **Throttling** 的作用：
> **Throttling** 是 **RxSwift** 的一个特性。因为有时当一些东西改变时，通常会做大量的逻辑操作。而使用 **Throttling** 特性，不会产生大量的逻辑操作，而是以一个小的合理的幅度去执行。比如做一些实时搜索功能时，这个特性很有用。


```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
         
        //创建文本输入框
        let inputField = UITextField(frame: CGRect(x:10, y:80, width:200, height:30))
        inputField.borderStyle = UITextBorderStyle.roundedRect
        self.view.addSubview(inputField)
         
        //创建文本输出框
        let outputField = UITextField(frame: CGRect(x:10, y:150, width:200, height:30))
        outputField.borderStyle = UITextBorderStyle.roundedRect
        self.view.addSubview(outputField)
         
        //创建文本标签
        let label = UILabel(frame:CGRect(x:20, y:190, width:300, height:30))
        self.view.addSubview(label)
         
        //创建按钮
        let button:UIButton = UIButton(type:.system)
        button.frame = CGRect(x:20, y:230, width:40, height:30)
        button.setTitle("提交", for:.normal)
        self.view.addSubview(button)
         
         
        //当文本框内容改变
        let input = inputField.rx.text.orEmpty.asDriver() // 将普通序列转换为 Driver
            .throttle(0.3) //在主线程中操作，0.3秒内值若多次改变，取最后一次
         
        //内容绑定到另一个输入框中
        input.drive(outputField.rx.text)
            .disposed(by: disposeBag)
         
        //内容绑定到文本标签中
        input.map{ "当前字数：\($0.count)" }
            .drive(label.rx.text)
            .disposed(by: disposeBag)
         
        //根据内容字数决定按钮是否可用
        input.map{ $0.count > 5 }
            .drive(button.rx.isEnabled)#
             .disposed(by: disposeBag)
    }
}

```


### 3，同时监听多个 textField 内容的变化（textView 同理）


#### （1）效果图
* 界面上有两个输入框分别用于填写电话的区号和号码。
* 无论那一个输入框内容发生变化，都会将它们拼成完整的号码并显示在 **label** 中。

#### （2）样例代码



```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var label: UILabel!
     
    override func viewDidLoad() {
         
        Observable.combineLatest(textField1.rx.text.orEmpty, textField2.rx.text.orEmpty) {
            textValue1, textValue2 -> String in
            return "你输入的号码是：\(textValue1)-\(textValue2)"
            }
            .map { $0 }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}

```

### 4，事件监听


#### （1）通过 rx.controlEvent 可以监听输入框的各种事件，且多个事件状态可以自由组合。除了各种 UI 控件都有的 touch 事件外，输入框还有如下几个独有的事件：
* **editingDidBegin**：开始编辑（开始输入内容）
* **editingChanged**：输入内容发生改变
* **editingDidEnd**：结束编辑
* **editingDidEndOnExit**：按下 **return** 键结束编辑
* **allEditingEvents**：包含前面的所有编辑相关事件

#### （2）下面代码监听输入框开始编辑事件（获取到焦点）并做相应的响应。



```
textField.rx.controlEvent([.editingDidBegin]) //状态可以组合
    .asObservable()
    .subscribe(onNext: { _ in
        print("开始编辑内容!")
    }).disposed(by: disposeBag)

```

#### （3）下面代码我们在界面上添加两个输入框分别用于输入用户名和密码：
* 如果当前焦点在用户名输入框时，按下 **return** 键时焦点自动转移到密码输入框上。
* 如果当前焦点在密码输入框时，按下 **return** 键时自动移除焦点。



```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
 
    //用户名输入框
    @IBOutlet weak var username: UITextField!
     
    //密码输入框
    @IBOutlet weak var password: UITextField!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //在用户名输入框中按下 return 键
        username.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {
            [weak self] (_) in
            self?.password.becomeFirstResponder()
        }).disposed(by: disposeBag)
         
         //在密码输入框中按下 return 键
        password.rx.controlEvent(.editingDidEndOnExit).subscribe(onNext: {
            [weak self] (_) in
            self?.password.resignFirstResponder()
        }).disposed(by: disposeBag)
    }
}

```

## 附：UITextView 独有的方法


### （1）UITextView 还封装了如下几个委托回调方法：
* **didBeginEditing**：开始编辑
* **didEndEditing**：结束编辑
* **didChange**：编辑内容发生改变
* **didChangeSelection**：选中部分发生变化


### (2) 使用样例


```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    @IBOutlet weak var textView: UITextView!
     
    override func viewDidLoad() {
         
        //开始编辑响应
        textView.rx.didBeginEditing
            .subscribe(onNext: {
                print("开始编辑")
            })
            .disposed(by: disposeBag)
         
        //结束编辑响应
        textView.rx.didEndEditing
            .subscribe(onNext: {
                print("结束编辑")
            })
            .disposed(by: disposeBag)
         
        //内容发生变化响应
        textView.rx.didChange
            .subscribe(onNext: {
                print("内容发生改变")
            })
            .disposed(by: disposeBag)
         
        //选中部分变化响应
        textView.rx.didChangeSelection
            .subscribe(onNext: {
                print("选中部分发生变化")
            })
            .disposed(by: disposeBag)
    }
}

```

