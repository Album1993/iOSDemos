#  CADisplayLink

### 1 和NSTimer的区别

定时对**View**进行定时重绘可能会第一时间想到使用**NSTimer**，但是这样的动画实现起来是不流畅的，因为在**timer**所处的**runloop**中要处理多种不同的输入，导致**timer**的最小周期是在**50**到**100**毫秒之间，一秒钟之内最多只能跑**20**次左右。

但如果我们希望在屏幕上看到流畅的动画，我们就要维持60帧的刷新频率，也就意味着每一帧的间隔要在**0.016**秒左右，**NSTimer**是无法实现的。所以要用到**Core Animation**的另一个**timer**，**CADisplayLink**。

在**CADisplayLink**的头文件中，我们可以看到它的使用方法跟**NSTimer**是十分类似的，其同样也是需要注册到**RunLoop**中，但不同于**NSTimer**的是， _它在屏幕需要进行重绘时就会让**RunLoop**调用**CADisplayLink**指定的**selector**，用于准备下一帧显示的数据。而**NSTimer**是需要在上一次**RunLoop**整个完成之后才会调用制定的**selector**，所以在调用频率与上比**NSTimer**要频繁得多。_

另外和**NSTimer**不同的是，**NSTimer**可以指定**timeInterval**，对应的是**selector**调用的间隔，但如果**NSTimer**触发的时间到了，而**RunLoop**处于阻塞状态，其触发时间就会推迟到下一个**RunLoop**。而**CADisplayLink**的**timer**间隔是不能调整的，固定就是一秒钟发生60次，不过可以通过设置其**frameInterval**属性，设置调用一次**selector**之间的间隔帧数。 _另外需要注意的是如果**selector**执行的代码超过了**frameInterval**的持续时间，那么**CADisplayLink**就会直接忽略这一帧，在下一次的更新时候再接着运行。_

### 配置 RunLoop

在创建**CADisplayLink**的时候，我们需要指定一个**RunLoop**和**RunLoopMode**，通常**RunLoop**我们都是选择使用主线程的**RunLoop**，因为所有UI更新的操作都必须放到主线程来完成， _而在模式的选择就可以用**NSDefaultRunLoopMode**，但是不能保证动画平滑的运行，所以就可以用**NSRunLoopCommonModes**来替代。但是要小心，因为如果动画在一个高帧率情况下运行，会导致一些别的类似于定时器的任务或者类似于滑动的其他iOS动画会暂停，直到动画结束。_


```

private func setup() {
	_displayLink = CADisplayLink(target: self, selector: #selector(update))
	_displayLink?.isPaused = true
	_displayLink?.add(to: RunLoop.main, forMode: .commonModes)
}

```