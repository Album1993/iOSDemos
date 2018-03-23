## Subjects 介绍

>     从前面的几篇文章可以发现，当我们创建一个 **Observable** 的时候就要预先将要发出的数据都准备好，等到有人订阅它时再将数据通过 **Event** 发出去。
>     但有时我们希望 **Observable** 在运行时能动态地“**获得**”或者说“**产生**”出一个新的数据，再通过 **Event** 发送出去。比如：订阅一个输入框的输入内容，当用户每输入一个字后，这个输入框关联的 **Observable** 就会发出一个带有输入内容的 Event，通知给所有订阅者。
>     这个就可以使用下面将要介绍的 **Subjects** 来实现。

### 1，Subjects 基本介绍
#### （1）Subjects 既是订阅者，也是 Observable：

* 说它是订阅者，是因为它能够动态地接收新的值。
* 说它又是一个 **Observable**，是因为当 **Subjects** 有了新的值之后，就会通过 Event 将新值发出给他的所有订阅者。

#### （2）一共有四种 **Subjects**，分别为：**PublishSubject**、**BehaviorSubject**、**ReplaySubject**、**Variable**。他们之间既有各自的特点，也有相同之处：	
* 首先他们都是 **Observable**，他们的订阅者都能收到他们发出的新的 **Event**。
* 直到 **Subject** 发出 `.complete` 或者 `.error` 的 **Event** 后，该 **Subject** 便终结了，同时它也就不会再发出 `.next` 事件。
* 对于那些在 **Subject** 终结后再订阅他的订阅者，也能收到 **subject** 发出的一条 `.complete` 或`.error` 的 **event**，告诉这个新的订阅者它已经终结了。
* 他们之间最大的区别只是在于：当一个新的订阅者刚订阅它的时候，能不能收到 **Subject** 以前发出过的旧 **Event**，如果能的话又能收到多少个。

#### （3）Subject 常用的几个方法：
* `onNext(:)`：是` on(.next(:))` 的简便写法。该方法相当于 **subject** 接收到一个 .next 事件。
* `onError(:)`：是 `on(.error(:))` 的简便写法。该方法相当于 **subject** 接收到一个` .error `事件。
* `onCompleted()`：是 `on(.completed)` 的简便写法。该方法相当于 **subject** 接收到一个 **.completed** 事件。

<br><br>
### 2，PublishSubject
#### （1）基本介绍
* **PublishSubject** 是最普通的 **Subject**，它不需要初始值就能创建。
* **PublishSubject** 的订阅者从他们开始订阅的时间点起，可以收到订阅后 **Subject** 发出的新 **Event**，而不会收到他们在订阅前已发出的 **Event**。

#### （2）时序图
* 最上面一条是 **PublishSubject**。
* 下面两条分别表示两个新的订阅，它们订阅的时间点不同，可以发现 **PublishSubject** 的订阅者只能收到他们订阅后的 **Event**。


```

PublishSubject: --a-----b-----c-------d---------->
				  | 	|	  |
				  |		|     |
			    --a-----b-----c-------d---------->
			    			  |
			                  c---------->
			    
```


 


