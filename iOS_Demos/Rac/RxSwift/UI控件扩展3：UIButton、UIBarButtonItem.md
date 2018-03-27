## 三、UIButton 与 UIBarButtonItem
### 1，按钮点击响应
#### （1）假设我们想实现点击按钮后，弹出一个消息提示框。

#### （2）点击响应我们可以这么写：

```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    @IBOutlet weak var button: UIButton!
     
    override func viewDidLoad() {
        //按钮点击响应
        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showMessage("按钮被点击")
            })
            .disposed(by: disposeBag)
    }
     
    //显示消息提示框
    func showMessage(_ text: String) {
        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

```
#### （3）或者这么写也行：

```
//按钮点击响应
button.rx.tap
    .bind { [weak self] in
        self?.showMessage("按钮被点击")
    }
    .disposed(by: disposeBag)
```

### 2，按钮标题（title）的绑定
#### （1）下面样例当程序启动时就开始计数，同时将拼接后的最新文本作为 button 的标题。


#### （2）代码如下，其中 rx.title 为 setTitle(_:for:) 的封装。

```
//创建一个计时器（每1秒发送一个索引数）
let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
 
//根据索引数拼接最新的标题，并绑定到button上
timer.map{"计数\($0)"}
    .bind(to: button.rx.title(for: .normal))
    .disposed(by: disposeBag)

```

### 3，按钮富文本标题（attributedTitle）的绑定
#### （1）下面样例当程序启动时就开始计时，同时将已过去的时间格式化，并设置好文字样式后显示在 button 标签上。


#### （2）代码如下，其中 rx.attributedTitle 为 setAttributedTitle(_:controlState:) 的封装。

```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    @IBOutlet weak var button: UIButton!
     
    override func viewDidLoad() {
        //创建一个计时器（每1秒发送一个索引数）
        let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
         
        //将已过去的时间格式化成想要的字符串，并绑定到button上
        timer.map(formatTimeInterval)
            .bind(to: button.rx.attributedTitle())
            .disposed(by: disposeBag)
    }
     
    //将数字转成对应的富文本
    func formatTimeInterval(ms: NSInteger) -> NSMutableAttributedString {
        let string = String(format: "%0.2d:%0.2d.%0.1d",
                            arguments: [(ms / 600) % 600, (ms % 600 ) / 10, ms % 10])
        //富文本设置
        let attributeString = NSMutableAttributedString(string: string)
        //从文本0开始6个字符字体HelveticaNeue-Bold,16号
        attributeString.addAttribute(NSAttributedStringKey.font,
                                     value: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
                                     range: NSMakeRange(0, 5))
        //设置字体颜色
        attributeString.addAttribute(NSAttributedStringKey.foregroundColor,
                                     value: UIColor.white, range: NSMakeRange(0, 5))
        //设置文字背景颜色
        attributeString.addAttribute(NSAttributedStringKey.backgroundColor,
                                     value: UIColor.orange, range: NSMakeRange(0, 5))
        return attributeString
    }
}

```


### 4，按钮图标（image）的绑定

#### （1）下面样例当程序启动时就开始计数，根据奇偶数选择相应的图片作为 button 的图标。

#### （2）代码如下，其中 rx.image 为 setImage(_:for:) 的封装。

```
//创建一个计时器（每1秒发送一个索引数）
let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
 
//根据索引数选择对应的按钮图标，并绑定到button上
timer.map({
    let name = $0%2 == 0 ? "back" : "forward"
    return UIImage(named: name)!
})
.bind(to: button.rx.image())
.disposed(by: disposeBag)
```


### 5，按钮背景图片（backgroundImage）的绑定

#### （1）下面样例当程序启动时就开始计数，根据奇偶数选择相应的图片作为 button 的背景。


#### （2）代码如下，其中 rx.backgroundImage 为 setBackgroundImage(_:for:) 的封装。

```
//创建一个计时器（每1秒发送一个索引数）
let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
 
//根据索引数选择对应的按钮背景图，并绑定到button上
timer.map{ UIImage(named: "\($0%2)")! }
    .bind(to: button.rx.backgroundImage())
    .disposed(by: disposeBag)
```


### 6，按钮是否可用（isEnabled）的绑定
#### （1）下面样例当我们切换开关（UISwitch）时，button 会在可用和不可用的状态间切换。

#### （2）代码如下：

```
switch1.rx.isOn
    .bind(to: button1.rx.isEnabled)
    .disposed(by: disposeBag)
```


### 7，按钮是否选中（isSelected）的绑定
#### （1）下面样例中三个按钮只有一个按钮处于选中状态。即点击选中任意一个按钮，另外两个按钮则变为未选中状态。


### （2）代码如下：

```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    @IBOutlet weak var button1: UIButton!
     
    @IBOutlet weak var button2: UIButton!
     
    @IBOutlet weak var button3: UIButton!
     
    override func viewDidLoad() {
        //默认选中第一个按钮
        button1.isSelected = true
         
        //强制解包，避免后面还需要处理可选类型
        let buttons = [button1, button2, button3].map { $0! }
         
        //创建一个可观察序列，它可以发送最后一次点击的按钮（也就是我们需要选中的按钮）
        let selectedButton = Observable.from(
            buttons.map { button in button.rx.tap.map { button } }
            ).merge()
         
        //对于每一个按钮都对selectedButton进行订阅，根据它是否是当前选中的按钮绑定isSelected属性
        for button in buttons {
            selectedButton.map { $0 == button }
                .bind(to: button.rx.isSelected)
                .disposed(by: disposeBag)
        }
    }
}
```


