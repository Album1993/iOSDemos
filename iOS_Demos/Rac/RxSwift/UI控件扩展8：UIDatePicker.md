## 八、UIDatePicker


### 1，日期选择响应
#### （1）效果图
当日期选择器里面的时间改变后，将时间格式化显示到 **label** 中。


#### （2）样例代码


```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
 
    @IBOutlet weak var datePicker: UIDatePicker!
     
    @IBOutlet weak var label: UILabel!
     
    //日期格式化器
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter
    }()
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        datePicker.rx.date
            .map { [weak self] in
                "当前选择时间: " + self!.dateFormatter.string(from: $0)
            }
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}

```

### 2，倒计时功能


#### （1）效果图
* 通过上方的 **datepicker** 选择需要倒计时的时间后，点击“开始”按钮即可开始倒计时。
* 倒计时过程中，**datepicker** 和按钮都不可用。且按钮标题变成显示倒计时剩余时间。

#### （2）样例代码

> 高亮部分代码说明：
> * **<->** 是自定义的双向绑定符号，具体可以查看我之前的文章：**Swift - RxSwift的使用详解27（双向绑定：<->）**
> * 加 `DispatchQueue.main.async `是为了解决第一次拨动表盘不触发值改变事件的问题（这个是 iOS 的 bug）



```
import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    //倒计时时间选择控件
    var ctimer:UIDatePicker!
     
    //开始按钮
    var btnstart:UIButton!
     
    //剩余时间（必须为 60 的整数倍，比如设置为100，值自动变为 60）
    let leftTime = Variable(TimeInterval(180))
     
    //当前倒计时是否结束
    let countDownStopped = Variable(true)
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //初始化datepicker
        ctimer = UIDatePicker(frame:CGRect(x:0, y:80, width:320, height:200))
        ctimer.datePickerMode = UIDatePickerMode.countDownTimer
        self.view.addSubview(ctimer)
         
        //初始化button
        btnstart =  UIButton(type: .system)
        btnstart.frame = CGRect(x:0, y:300, width:320, height:30);
        btnstart.setTitleColor(UIColor.red, for: .normal)
        btnstart.setTitleColor(UIColor.darkGray, for:.disabled)
        self.view.addSubview(btnstart)
         
        //剩余时间与datepicker做双向绑定
        DispatchQueue.main.async{
            _ = self.ctimer.rx.countDownDuration <-> self.leftTime
        }
         
        //绑定button标题
        Observable.combineLatest(leftTime.asObservable(), countDownStopped.asObservable()) {
            leftTimeValue, countDownStoppedValue in
            //根据当前的状态设置按钮的标题
            if countDownStoppedValue {
                return "开始"
            }else{
                return "倒计时开始，还有 \(Int(leftTimeValue)) 秒..."
            }
            }.bind(to: btnstart.rx.title())
            .disposed(by: disposeBag)
         
        //绑定button和datepicker状态（在倒计过程中，按钮和时间选择组件不可用）
        countDownStopped.asDriver().drive(ctimer.rx.isEnabled).disposed(by: disposeBag)
        countDownStopped.asDriver().drive(btnstart.rx.isEnabled).disposed(by: disposeBag)
         
        //按钮点击响应
        btnstart.rx.tap
            .bind { [weak self] in
                self?.startClicked()
            }
            .disposed(by: disposeBag)
    }
     
    //开始倒计时
    func startClicked() {
        //开始倒计时
        self.countDownStopped.value = false
         
        //创建一个计时器
        Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .takeUntil(countDownStopped.asObservable().filter{ $0 }) //倒计时结束时停止计时器
            .subscribe { event in
                //每次剩余时间减1
                self.leftTime.value -= 1
                // 如果剩余时间小于等于0
                if(self.leftTime.value == 0) {
                    print("倒计时结束！")
                    //结束倒计时
                    self.countDownStopped.value = true
                    //重制时间
                    self.leftTime.value = 180
                }
            }.disposed(by: disposeBag)
    }
}

```

