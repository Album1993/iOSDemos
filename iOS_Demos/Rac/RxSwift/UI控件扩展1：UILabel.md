   **RxSwift** 是一个用于与 **Swift** 语言交互的框架，但它只是基础，并不能用来进行用户交互、网络请求等。
    
    而 **RxCocoa** 是让 **Cocoa APIs** 更容易使用响应式编程的一个框架。**RxCocoa** 能够让我们方便地进行响应式网络请求、响应式的用户交互、绑定数据模型到 **UI** 控件等等。而且大多数的 **UIKit** 控件都有响应式扩展，它们都是通过 **rx** 属性进行使用。
   
    在接下来的系列文章中，我将通过样例演示 **RxCocoa** 下各个 **UI** 控件的用法。


### 一、UILabel
#### 1，将数据绑定到 text 属性上（普通文本）
（1）下面样例当程序启动时就开始计时，同时将已过去的时间格式化后显示在 **label** 标签上。


#### （2）样例代码

```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
         
        //创建文本标签
        let label = UILabel(frame:CGRect(x:20, y:40, width:300, height:100))
        self.view.addSubview(label)
         
        //创建一个计时器（每0.1秒发送一个索引数）
        let timer = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
         
        //将已过去的时间格式化成想要的字符串，并绑定到label上
        timer.map{ String(format: "%0.2d:%0.2d.%0.1d",
                          arguments: [($0 / 600) % 600, ($0 % 600 ) / 10, $0 % 10]) }
        .bind(to: label.rx.text)
        .disposed(by: disposeBag)
    }
}
```


#### 2，将数据绑定到 attributedText 属性上（富文本）
##### （1）这个样例功能和前面样例是一样的，不过我们修改了分和秒这部分的文字样式，以及背景色。



##### （2）样例代码

```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
         
        //创建文本标签
        let label = UILabel(frame:CGRect(x:20, y:40, width:300, height:100))
        self.view.addSubview(label)
         
        //创建一个计时器（每0.1秒发送一个索引数）
        let timer = Observable<Int>.interval(0.1, scheduler: MainScheduler.instance)
         
        //将已过去的时间格式化成想要的字符串，并绑定到label上
        timer.map(formatTimeInterval)
        .bind(to: label.rx.attributedText)
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


