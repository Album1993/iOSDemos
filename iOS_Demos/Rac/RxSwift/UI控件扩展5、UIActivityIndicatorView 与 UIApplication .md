### 1，UIActivityIndicatorView（活动指示器）
**UIActivityIndicatorView** 又叫状态指示器，它会通过一个旋转的“菊花”来表示当前的活动状态。 

#### （1）效果图 
* 通过开关我们可以控制活动指示器是否显示旋转。


#### （2）样例代码

```
mySwitch.rx.value
    .bind(to: activityIndicator.rx.isAnimating)
    .disposed(by: disposeBag)
```


### 2，UIApplication
**RxSwift** 对 **UIApplication** 增加了一个名为 **isNetworkActivityIndicatorVisible** 绑定属性，我们通过它可以设置是否显示联网指示器（网络请求指示器）。

#### （1）效果图
* 当开关打开时，顶部状态栏上会有个菊花状的联网指示器。
* 当开关关闭时，联网指示器消失。


```
mySwitch.rx.value
    .bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
    .disposed(by: disposeBag)

```


