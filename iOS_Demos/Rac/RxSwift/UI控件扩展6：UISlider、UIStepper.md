## 六、UISlider、UIStepper
### 1，UISlider（滑块）
#### （1）效果图
当我们拖动滑块时，在控制台中实时输出 **slider** 当前值。

#### （2）样例代码


```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    @IBOutlet weak var slider: UISlider!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        slider.rx.value.asObservable()
            .subscribe(onNext: {
                print("当前值为：\($0)")
            })
            .disposed(by: disposeBag)
    }
}

```

### 2，UIStepper（步进器）


#### （1）下面样例当 stepper 值改变时，在控制台中实时输出当前值。


```
stepper.rx.value.asObservable()
    .subscribe(onNext: {
        print("当前值为：\($0)")
    })
    .disposed(by: disposeBag)

```


#### （2）下面样例我们使用滑块（slider）来控制 stepper 的步长。


```
slider.rx.value
    .map{ Double($0) }  //由于slider值为Float类型，而stepper的stepValue为Double类型，因此需要转换
    .bind(to: stepper.rx.stepValue)
    .disposed(by: disposeBag)

```

