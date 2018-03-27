## 一、UICollectionView 的基本用法

### 1，单个分区的集合视图
#### （1）首先自定义一个单元格类：


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

#### （2）主视图控制器代码如下：


```
import UIKit
import RxSwift
import RxCocoa
 
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
            "Swift",
            "PHP",
            "Ruby",
            "Java",
            "C++",
            ])
         
        //设置单元格数据（其实就是对 cellForItemAt 的封装）
        items
            .bind(to: collectionView.rx.items) { (collectionView, row, element) in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                for: indexPath) as! MyCollectionViewCell
                cell.label.text = "\(row)：\(element)"
                return cell
            }
            .disposed(by: disposeBag)
    }
}

```

### 2，单元格选中事件响应
#### （1）当我们点击某个单元格时将其索引位置，以及对应的标题打印出来。


#### （2）如果业务代码直接放在响应方法内部，可以这么写：


```
//获取选中项的索引
collectionView.rx.itemSelected.subscribe(onNext: { indexPath in
    print("选中项的indexPath为：\(indexPath)")
}).disposed(by: disposeBag)
 
 
//获取选中项的内容
collectionView.rx.modelSelected(String.self).subscribe(onNext: { item in
    print("选中项的标题为：\(item)")
}).disposed(by: disposeBag)
```


#### （3）或者也可以在响应中调用外部的方法：


```
//获取选中项的索引
collectionView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
    self?.showMessage("选中项的indexPath为：\(indexPath)")
}).disposed(by: disposeBag)
 
//获取选中项的内容
collectionView.rx.modelSelected(String.self).subscribe(onNext: {[weak self] item in
    self?.showMessage("选中项的标题为：\(item)")
}).disposed(by: disposeBag)

```
#### （4）如果想要同时获取选中项的索引，以及内容可以这么写：


```
Observable.zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(String.self))
    .bind { [weak self] indexPath, item in
        self?.showMessage("选中项的indexPath为：\(indexPath)")
        self?.showMessage("选中项的标题为：\(item)")
    }
    .disposed(by: disposeBag)

```

### 3，单元格取消选中事件响应
#### （1）我们可以分别获取被取消项的索引及内容：


```
//获取被取消选中项的索引
collectionView.rx.itemDeselected.subscribe(onNext: { [weak self] indexPath in
    self?.showMessage("被取消选中项的indexPath为：\(indexPath)")
}).disposed(by: disposeBag)
 
//获取被取消选中项的内容
collectionView.rx.modelDeselected(String.self).subscribe(onNext: {[weak self] item in
    self?.showMessage("被取消选中项的的标题为：\(item)")
}).disposed(by: disposeBag)

```


#### （2）也可以同时获取：

```
Observable
    .zip(collectionView.rx.itemDeselected, collectionView.rx.modelDeselected(String.self))
    .bind { [weak self] indexPath, item in
        self?.showMessage("被取消选中项的indexPath为：\(indexPath)")
        self?.showMessage("被取消选中项的的标题为：\(item)")
    }
    .disposed(by: disposeBag)

```

### 4，单元格高亮完成后的事件响应


```
//获取选中并高亮完成后的索引
collectionView.rx.itemHighlighted.subscribe(onNext: { indexPath in
    print("高亮单元格的indexPath为：\(indexPath)")
}).disposed(by: disposeBag)

```

### 5，高亮转成非高亮完成的事件响应

```
//获取高亮转成非高亮完成后的索引
collectionView.rx.itemUnhighlighted.subscribe(onNext: { indexPath in
    print("失去高亮的单元格的indexPath为：\(indexPath)")
}).disposed(by: disposeBag)

```


### 6，单元格将要显示出来的事件响应

```
//单元格将要显示出来的事件响应
collectionView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
    print("将要显示单元格indexPath为：\(indexPath)")
    print("将要显示单元格cell为：\(cell)\n")
}).disposed(by: disposeBag)

```


### 7，分区头部或尾部将要显示出来的事件响应



```
//分区头部、尾部将要显示出来的事件响应
collectionView.rx.willDisplaySupplementaryView.subscribe(onNext: { view, kind, indexPath in
    print("将要显示分区indexPath为：\(indexPath)")
    print("将要显示的是头部还是尾部：\(kind)")
    print("将要显示头部或尾部视图：\(view)\n")
}).disposed(by: disposeBag)

```

