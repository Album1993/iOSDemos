## 二、RxDataSources 


### 1，准备工作
首先是 **RxDataSources** 的安装配置，这个我在之前关于 **UITableView** 文章中已经讲过（点击下方链接查看），这里就不再重复说明了。
* Swift - RxSwift的使用详解31（UITableView的使用2：RxDataSources）

### 2，单分区的 **CollectionView**
#### （1）假设我们要实现如下效果：

#### （2）首先自定义一个单元格类（MyCollectionViewCell），供后面使用。



```
import UIKit
 
class MyCollectionViewCell: UICollectionViewCell {
     
    var label:UILabel!
     
    override init(frame: CGRect) {
        super.init(frame: frame)
         
        //背景设为橙色
        self.backgroundColor = UIColor.orange
         
        //创建文本标签
        label = UILabel(frame: frame)
        label.textColor = UIColor.white
        label.textAlignment = .center
        self.contentView.addSubview(label)
    }
     
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

```

#### （3）主视图控制器里的功能实现有如下两种写法：


> 注意：**RxDataSources** 是以 **section** 来做为数据结构的。所以不管我们的 **collectionView** 是单分区还是多分区，在使用 **RxDataSources** 的过程中，都需要返回一个 **section** 的数组。

* 方式一：使用自带的 **Section**


```
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class ViewController: UIViewController {
     
    var collectionView:UICollectionView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //定义布局方式以及单元格大小
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 70)
         
        //创建集合视图
        self.collectionView = UICollectionView(frame: self.view.frame,
                                               collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.white
         
        //创建一个重用的单元格
        self.collectionView.register(MyCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(self.collectionView!)
         
        //初始化数据
        let items = Observable.just([
            SectionModel(model: "", items: [
                "Swift",
                "PHP",
                "Python",
                "Java",
                "javascript",
                "C#"
                ])
            ])
         
        //创建数据源
        let dataSource = RxCollectionViewSectionedReloadDataSource
            <SectionModel<String, String>>(
            configureCell: { (dataSource, collectionView, indexPath, element) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                for: indexPath) as! MyCollectionViewCell
                cell.label.text = "\(element)"
                return cell}
        )
         
        //绑定单元格数据
        items
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

```

* 方式二：使用自定义的 Section 


```
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class ViewController: UIViewController {
     
    var collectionView:UICollectionView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //定义布局方式以及单元格大小
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 70)
         
        //创建集合视图
        self.collectionView = UICollectionView(frame: self.view.frame,
                                               collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.white
         
        //创建一个重用的单元格
        self.collectionView.register(MyCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(self.collectionView!)
         
        //初始化数据
        let sections = Observable.just([
            MySection(header: "", items: [
                "Swift",
                "PHP",
                "Python",
                "Java",
                "javascript",
                "C#"
                ])
            ])
         
        //创建数据源
        let dataSource = RxCollectionViewSectionedReloadDataSource<MySection>(
            configureCell: { (dataSource, collectionView, indexPath, element) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                for: indexPath) as! MyCollectionViewCell
                cell.label.text = "\(element)"
                return cell}
        )
         
        //绑定单元格数据
        sections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
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

### 3，多分区的 CollectionView

#### （1）假设我们要实现如下效果：

#### （2）除了上面的自定义单元格类（MyCollectionViewCell）外，还需要自定义一个分区头类（MySectionHeader），供后面使用。

```
import UIKit
 
class MySectionHeader: UICollectionReusableView {
    var label:UILabel!
     
    override init(frame: CGRect) {
        super.init(frame: frame)
         
        //背景设为黑色
        self.backgroundColor = UIColor.black
         
        //创建文本标签
        label = UILabel(frame: frame)
        label.textColor = UIColor.white
        label.textAlignment = .center
        self.addSubview(label)
    }
     
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```


#### （3）主视图控制器里的功能实现同样有如下两种写法：
* 方式一：使用自带的 Section




```
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class ViewController: UIViewController {
     
    var collectionView:UICollectionView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //定义布局方式以及单元格大小
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 70)
        flowLayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 40)
         
        //创建集合视图
        self.collectionView = UICollectionView(frame: self.view.frame,
                                               collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.white
         
        //创建一个重用的单元格
        self.collectionView.register(MyCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "Cell")
        //创建一个重用的分区头
        self.collectionView.register(MySectionHeader.self,
                    forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                     withReuseIdentifier: "Section")
        self.view.addSubview(self.collectionView!)
         
 
        //初始化数据
        let items = Observable.just([
            SectionModel(model: "脚本语言", items: [
                "Python",
                "javascript",
                "PHP",
                ]),
            SectionModel(model: "高级语言", items: [
                "Swift",
                "C++",
                "Java",
                "C#"
                ])
            ])
         
        //创建数据源
        let dataSource = RxCollectionViewSectionedReloadDataSource
            <SectionModel<String, String>>(
            configureCell: { (dataSource, collectionView, indexPath, element) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                for: indexPath) as! MyCollectionViewCell
                cell.label.text = "\(element)"
                return cell},
            configureSupplementaryView: {
                (ds ,cv, kind, ip) in
                let section = cv.dequeueReusableSupplementaryView(ofKind: kind,
                            withReuseIdentifier: "Section", for: ip) as! MySectionHeader
                section.label.text = "\(ds[ip.section].model)"
                return section
        })
         
        //绑定单元格数据
        items
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
```

* 方式二：使用自定义的 Section 



```
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class ViewController: UIViewController {
     
    var collectionView:UICollectionView!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //定义布局方式以及单元格大小
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 70)
        flowLayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 40)
         
        //创建集合视图
        self.collectionView = UICollectionView(frame: self.view.frame,
                                               collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.white
         
        //创建一个重用的单元格
        self.collectionView.register(MyCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "Cell")
        //创建一个重用的分区头
        self.collectionView.register(MySectionHeader.self,
                    forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                     withReuseIdentifier: "Section")
        self.view.addSubview(self.collectionView!)
         
 
        //初始化数据
        let sections = Observable.just([
            MySection(header: "脚本语言", items: [
                "Python",
                "javascript",
                "PHP",
                ]),
            MySection(header: "高级语言", items: [
                "Swift",
                "C++",
                "Java",
                "C#"
                ])
            ])
         
        //创建数据源
        let dataSource = RxCollectionViewSectionedReloadDataSource<MySection>(
            configureCell: { (dataSource, collectionView, indexPath, element) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                for: indexPath) as! MyCollectionViewCell
                cell.label.text = "\(element)"
                return cell},
            configureSupplementaryView: {
                (ds ,cv, kind, ip) in
                let section = cv.dequeueReusableSupplementaryView(ofKind: kind,
                            withReuseIdentifier: "Section", for: ip) as! MySectionHeader
                section.label.text = "\(ds[ip.section].header)"
                return section
        })
         
        //绑定单元格数据
        sections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
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

