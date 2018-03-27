## 四、数据搜索过滤


### 1，效果图
#### （1）同前文一样，程序启动后 tableView 会默认会加载一些随机数据。而点击右上角的刷新按钮，tableView 会重新加载并显示一批新数据。
#### （2）不同的是，我们在 tableView 的表头上增加了一个搜索框。tableView 会根据搜索框里输入的内容实时地筛选并显示出符合条件的数据（包含有输入文字的数据条目）

> 注意：这个实时搜索是对已获取到的数据进行过滤，即每次输入文字时不会重新发起请求。

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
     
    //搜索栏
    var searchBar:UISearchBar!
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
         
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self,
                                 forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
         
        //创建表头的搜索栏
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0,
                            width: self.view.bounds.size.width, height: 56))
        self.tableView.tableHeaderView =  self.searchBar
         
        //随机的表格数据
        let randomResult = refreshButton.rx.tap.asObservable()
            .startWith(()) //加这个为了让一开始就能自动请求一次数据
            .flatMapLatest(getRandomResult) //获取数据
            .flatMap(filterResult) //筛选数据
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
     
    //过滤数据
    func filterResult(data:[SectionModel<String, Int>])
        -> Observable<[SectionModel<String, Int>]> {
        return self.searchBar.rx.text.orEmpty
            //.debounce(0.5, scheduler: MainScheduler.instance) //只有间隔超过0.5秒才发送
            .flatMapLatest{
                query -> Observable<[SectionModel<String, Int>]> in
                print("正在筛选数据（条件为：\(query)）")
                //输入条件为空，则直接返回原始数据
                if query.isEmpty{
                    return Observable.just(data)
                }
                //输入条件为不空，则只返回包含有该文字的数据
                else{
                    var newData:[SectionModel<String, Int>] = []
                    for sectionModel in data {
                        let items = sectionModel.items.filter{ "\($0)".contains(query) }
                        newData.append(SectionModel(model: sectionModel.model, items: items))
                    }
                    return Observable.just(newData)
                }
        }
    }
}

```

