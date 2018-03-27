## 四、UISwitch 与 UISegmentedControl
这两个控件的用法其实差不多。

### 1，UISwitch（开关按钮）
#### （1）假设我们想实现当 switch 开关状态改变时，输出当前值。


```
switch1.rx.isOn.asObservable()
    .subscribe(onNext: {
        print("当前开关状态：\($0)")
    })
    .disposed(by: disposeBag)

```

#### （2）下面样例当我们切换 switch 开关时，button 会在可用和不可用的状态间切换。


```

switch1.rx.isOn
    .bind(to: button1.rx.isEnabled)
    .disposed(by: disposeBag)

```


### 2，UISegmentedControl（分段选择控件）

#### （1）我们想实现当 UISegmentedControl 选中项改变时，输出当前选中项索引值。


```
segmented.rx.selectedSegmentIndex.asObservable()
    .subscribe(onNext: {
        print("当前项：\($0)")
    })
    .disposed(by: disposeBag)

```


#### （2）下面样例当 segmentedControl 选项改变时，imageView 会自动显示相应的图片。


```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    //分段选择控件
    @IBOutlet weak var segmented: UISegmentedControl!
    //图片显示控件
    @IBOutlet weak var imageView: UIImageView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        //创建一个当前需要显示的图片的可观察序列
        let showImageObservable: Observable<UIImage> =
            segmented.rx.selectedSegmentIndex.asObservable().map {
                let images = ["js.png", "php.png", "react.png"]
                return UIImage(named: images[$0])!
        }
         
        //把需要显示的图片绑定到 imageView 上
        showImageObservable.bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
    }
}

```


