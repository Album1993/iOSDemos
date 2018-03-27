## 二、RxDataSources
### 1，RxDataSources 介绍
#### （1）如果我们的 tableview 需要显示多个 section、或者更加复杂的编辑功能时，可以借助 RxDataSource 这个第三方库帮我们完成。
#### （2）RxDataSource 的本质就是使用 **RxSwift** 对 **UITableView** 和 **UICollectionView** 的数据源做了一层包装。使用它可以大大减少我们的工作量。


### 2，安装配置
##### （1）首先将 **RxDataSources** 下载到本地，并引入到项目中来。

* **GitHub** 主页：**https://github.com/RxSwiftCommunity/RxDataSources**


##### （2）然后在代码中将其 import 进来即可。


```
import RxDataSources
```

### 3，单分区的 TableView
##### （1）假设我们要实现如下效果：


##### （2）可以有如下两种写法：
> 注意：**RxDataSources** 是以 **section** 来做为数据结构的。所以不管我们的 **tableView** 是单分区还是多分区，在使用 **RxDataSources** 的过程中，都需要返回一个 **section** 的数组。


* 方式一：使用自带的**Section**



```
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class ViewController: UIViewController {
     
    var tableView:UITableView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
         
        //初始化数据
        let items = Observable.just([
            SectionModel(model: "", items: [
                "UILable的用法",
                "UIText的用法",
                "UIButton的用法"
                ])
            ])
         
        //创建数据源
        let dataSource = RxTableViewSectionedReloadDataSource
            <SectionModel<String, String>>(configureCell: {
                (dataSource, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "\(indexPath.row)：\(element)"
                return cell
            })
         
        //绑定单元格数据
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

```

* 方式二：使用自定义的Section 


```
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class ViewController: UIViewController {
     
    var tableView:UITableView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
         
        //初始化数据
        let sections = Observable.just([
            MySection(header: "", items: [
                "UILable的用法",
                "UIText的用法",
                "UIButton的用法"
                ])
            ])
         
        //创建数据源
        let dataSource = RxTableViewSectionedAnimatedDataSource<MySection>(
            //设置单元格
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")
                    ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.textLabel?.text = "\(ip.row)：\(item)"
                 
                return cell
        })
         
        //绑定单元格数据
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
 
//自定义Section
struct MySection {
    var header: String
    var items: [Item]
}
 
extension MySection : AnimatableSectionModelType {
    typealias Item = String
     
    var identity: String {
        return header
    }
     
    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}

```

### 4，多分区的 TableView

#### 同样有如下两种写法：
	
* 方式一：使用自带的**Section**


```
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class ViewController: UIViewController {
     
    var tableView:UITableView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
         
        //初始化数据
        let items = Observable.just([
            SectionModel(model: "基本控件", items: [
                "UILable的用法",
                "UIText的用法",
                "UIButton的用法"
                ]),
            SectionModel(model: "高级控件", items: [
                "UITableView的用法",
                "UICollectionViews的用法"
                ])
            ])
         
        //创建数据源
        let dataSource = RxTableViewSectionedReloadDataSource
            <SectionModel<String, String>>(configureCell: {
            (dataSource, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(indexPath.row)：\(element)"
            return cell
        })
         
        //设置分区头标题
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model
        }
         
        //设置分区尾标题
        //dataSource.titleForFooterInSection = { ds, index in
        //    return "footer"
        //}
         
        //绑定单元格数据
        items
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

```


* 方式二：使用自定义的**Section** 


```
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class ViewController: UIViewController {
     
    var tableView:UITableView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
         
        //初始化数据
        let sections = Observable.just([
            MySection(header: "基本控件", items: [
                "UILable的用法",
                "UIText的用法",
                "UIButton的用法"
                ]),
            MySection(header: "高级控件", items: [
                "UITableView的用法",
                "UICollectionViews的用法"
                ])
            ])
         
        //创建数据源
        let dataSource = RxTableViewSectionedAnimatedDataSource<MySection>(
            //设置单元格
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")
                    ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.textLabel?.text = "\(ip.row)：\(item)"
                 
                return cell
            },
            //设置分区头标题
            titleForHeaderInSection: { ds, index in
                return ds.sectionModels[index].header
            }
        )
         
        //绑定单元格数据
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
 
//自定义Section
struct MySection {
    var header: String
    var items: [Item]
}
 
extension MySection : AnimatableSectionModelType {
    typealias Item = String
     
    var identity: String {
        return header
    }
     
    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}

```

