 很多情况下，表格里的数据不是一开始就准备好的、或者固定不变的。可能我们需要先向服务器请求数据，再将获取到的内容显示在表格中。
    要重新加载表格数据，过去的做法就是调用 **tableView** 的 `reloadData()` 方法。本文介绍在使用 **RxSwift** 的情况下，应该如何刷新数据。



## 三、数据刷新

### 1，效果图
##### （1）界面初始化完毕后，tableView 默认会加载一些随机数据。
##### （2）点击右上角的刷新按钮，tableView 会重新加载并显示一批新数据。
##### （3）为方便演示，每次获取数据不是真的去发起网络请求。而是在本地生成后延迟 2 秒返回，模拟这种异步请求的情况。


### 2，样例代码


```
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class ViewController: UIViewController {
     
    //刷新按钮
    @IBOutlet weak var refreshButton: UIBarButtonItem!
     
    //表格
    var tableView:UITableView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self,
                                 forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
         
        //随机的表格数据
        let randomResult = refreshButton.rx.tap.asObservable()
            .startWith(()) //加这个为了让一开始就能自动请求一次数据
            .flatMapLatest(getRandomResult)
            .share(replay: 1)
         
        //创建数据源
        let dataSource = RxTableViewSectionedReloadDataSource
            <SectionModel<String, Int>>(configureCell: {
                (dataSource, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
                return cell
            })
         
        //绑定单元格数据
        randomResult
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
     
    //获取随机数据
    func getRandomResult() -> Observable<[SectionModel<String, Int>]> {
        print("正在请求数据......")
        let items = (0 ..< 5).map {_ in
            Int(arc4random())
        }
        let observable = Observable.just([SectionModel(model: "S", items: items)])
        return observable.delay(2, scheduler: MainScheduler.instance)
    }
}

```

### 3，防止表格多次刷新的说明

#### （1）flatMapLatest 的作用是当在短时间内（上一个请求还没回来）连续点击多次“刷新”按钮，虽然仍会发起多次请求，但表格只会接收并显示最后一次请求。避免表格出现连续刷新的现象。


```
//随机的表格数据
let randomResult = refreshButton.rx.tap.asObservable()
    .startWith(()) //加这个为了让一开始就能自动请求一次数据
    .flatMapLatest(getRandomResult)
    .share(replay: 1)

```

#### （2）我们也对源头进行限制下。即通过 throttle 设置个阀值（比如 1 秒），如果在1秒内有多次点击则只取最后一次，那么自然也就只发送一次数据请求。


```
//随机的表格数据
let randomResult = refreshButton.rx.tap.asObservable()
    .throttle(1, scheduler: MainScheduler.instance) //在主线程中操作，1秒内值若多次改变，取最后一次
    .startWith(()) //加这个为了让一开始就能自动请求一次数据
    .flatMapLatest(getRandomResult)
    .share(replay: 1)

```

## 附：停止数据请求

    在实际项目中我们可能会需要对一个未完成的网络请求进行中断操作。比如切换页面或者分类时，如果上一次的请求还未完成就要将其取消掉。下面通过样例演示如何实现该功能。

### 1，效果图
这里我们在前面样例的基础上增加了个“停止”按钮。当发起请求且数据还未返回时（2 秒内），按下该按钮后便会停止对结果的接收处理，即表格不加载显示这次的请求数据。


### 2，样例代码

该功能简单说就是通过 **takeUntil** 操作符实现。当 **takeUntil** 中的 **Observable** 发送一个值时，便会结束对应的 **Observable**。



```
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class ViewController: UIViewController {
     
    //刷新按钮
    @IBOutlet weak var refreshButton: UIBarButtonItem!
     
    //停止按钮
    @IBOutlet weak var cancelButton: UIBarButtonItem!
     
    //表格
    var tableView:UITableView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self,
                                 forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
         
        //随机的表格数据
        let randomResult = refreshButton.rx.tap.asObservable()
            .startWith(()) //加这个为了让一开始就能自动请求一次数据
            .flatMapLatest{
                self.getRandomResult().takeUntil(self.cancelButton.rx.tap)
            }
            .share(replay: 1)
         
        //创建数据源
        let dataSource = RxTableViewSectionedReloadDataSource
            <SectionModel<String, Int>>(configureCell: {
                (dataSource, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
                return cell
            })
         
        //绑定单元格数据
        randomResult
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
     
    //获取随机数据
    func getRandomResult() -> Observable<[SectionModel<String, Int>]> {
        print("正在请求数据......")
        let items = (0 ..< 5).map {_ in
            Int(arc4random())
        }
        let observable = Observable.just([SectionModel(model: "S", items: items)])
        return observable.delay(2, scheduler: MainScheduler.instance)
    }
}

```

