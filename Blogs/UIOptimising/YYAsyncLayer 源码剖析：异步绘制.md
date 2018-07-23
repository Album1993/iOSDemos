# 一、框架概述

**YYAsyncLayer** 库代码很清晰，就几个文件：

```
YYAsyncLayer.h (.m)
YYSentinel.h (.m)
YYTransaction.h (.m)
```

* YYAsyncLayer 类继承自 CALayer ，不同的是作者封装了异步绘制的逻辑便于使用。
* YYSentinel 类是一个计数的类，是为了记录最新的布局请求标识，便于及时的放弃多余的绘制逻辑以减少开销。
* YYTransaction 类是事务类，捕获主线程 runloop 的某个时机回调，用于处理异步绘制事件。

可能有些读者会迷糊，不过没关系，后文会详细剖析代码细节，这里只需要对框架有个大致的认识就可以了。

浏览一下源码便可以知道，该框架的用法不过是使用一个 CALayer 的子类 —— YYAsyncLayer。（需要实现 YYAsyncLayer 类指定的代理方法，对整个绘制流程做管理，详细使用方法可以看看框架的 README）

# 二、为什么需要异步绘制?

## 1、界面卡顿的实质

iOS 设备显示器每绘制完一帧画面，复位时就会发送一个 VSync (垂直同步信号) ，并且此时切换帧缓冲区 (iOS 设备是双缓存+垂直同步)；在读取经 GPU 渲染完成的帧缓冲区数据进行绘制的同时，还会通过 CADisplayLink 等机制通知 APP 内部可以提交结果到另一个空闲的帧缓冲区了；接着 CPU 就开始计算 APP 布局，计算完成交由 GPU 渲染，渲染完成提交到帧缓冲区；当 VSync 再一次到来的时候，切换帧缓冲区......
（ps: 上面这段描述是笔者的理解，参考 iOS 保持界面流畅的技巧 ）

当 VSync 到来准备切换帧缓冲区时，若空闲的帧缓存区并未收到来自 GPU 的提交，此次切换就会作罢，设备显示系统会放弃此次绘制，从而引起掉帧。

由此可知，不管是 CPU 还是 GPU 哪一个出现问题导致不能及时的提交渲染结果到帧缓冲区，都会导致掉帧。优化界面流畅程度，实际上就是减少掉帧（iOS设备上大致是 60 FPS），也就是减小 CPU 和 GPU 的压力提高性能。

## 2、UIKit 性能瓶颈

有些 UIKit 组件的绘制是在主线程进行，需要 CPU 来进行绘制，当同一时刻过多组件需要绘制时，必然会给 CPU 带来压力，这个时候就很容易掉帧（主要是文本控件，大量文本内容的计算量和绘制过程都相当繁琐）。

## 3、UIKit 替代方案：CoreAnimation 或 CoreGraphics

当然，首选优化方案是 CoreAnimation 框架。CALayer 的大部分属性都是由 GPU 绘制的 (硬件层面)，不需要 CPU (软件层面) 做任何绘制。CA 框架下的 CAShapeLayer (多边形绘制)、CATextLayer(文本绘制)、CAGradientLayer (渐变绘制) 等都有较高的效率，非常实用。

再来看一下 CoreGraphics 框架，实际上它是依托于 CPU 的软件绘制。在实现CALayerDelegate 协议的 -drawLayer:inContext: 方法时（等同于UIView 二次封装的 -drawRect:方法），需要分配一个内存占用较高的上下文context，与此同时，CALayer 或者其子类需要创建一个等大的寄宿图contents，当基于 CPU 的软件绘制完成，还需要通过 IPC (进程间通信) 传递给设备显示系统，值得注意的是：当重绘时需要抹除这个上下文重新分配内存。

不管是创建上下文、重绘带来的二次内存开销、等大寄宿图的创建、IPC 都会带来性能上的很大开销。所以 CoreGraphics 的性能比较差，日常开发中要尽量避免直接使用。通常情况下，直接给 CALayer 的 contents 赋值 CGImage 图片或者使用 CALayer 的衍生类就能实现大部分需求，还能充分利用硬件支持，图像处理交给 GPU 当然更加放心。

##### 4、多核设备带来的可能性

通过以上分析，可以确定 CoreGraphics 较为糟糕的性能。然而可喜的是，市面上的设备都已经不是单核了，这就意味着可以通过后台线程处理耗时任务，主线程只需要负责调度显示。

ps：关于多核设备的线程性能问题，后面分析源码会讲到

CoreGraphics 框架可以通过图片上下文将绘制内容制作为一张图片，并且这个操作可以在非主线程执行。那么，当有 n 个绘制任务时，可以开辟多个线程在后台异步绘制，绘制成功拿到图片回到主线程赋值给 CALayer 的寄宿图属性。

这就是 YYAsyncLayer 框架的核心思想，不过该框架还有其他的亮点后文慢慢阐述。

虽然多个线程异步绘制会消耗可观的内存，但是对于性能敏感界面的用户体验提升有很大帮助，优化很多时候就是空间换时间，所谓鱼和熊掌不可兼得。这也说明了一个问题，实际开发中要做有针对性的优化，不可盲目跟风。

# 三、YYSentinel

该类非常简单：

```
.h
@interface YYSentinel : NSObject
@property (readonly) int32_t value;
- (int32_t)increase;
@end

.m
@implementation YYSentinel { int32_t _value; }
- (int32_t)value { return _value; }
- (int32_t)increase { return OSAtomicIncrement32(&_value); }
@end
```

一看便知，该类扮演的是计数的角色，值得注意的是，-increase方法是使用 OSAtomicIncrement32() 方法来对value执行自增。

OSAtomicIncrement32()是原子自增方法，线程安全。在日常开发中，若需要保证整形数值变量的线程安全，可以使用 OSAtomic 框架下的方法，它往往性能比使用各种“锁”更为优越，并且代码优雅。

至于该类的实际作用后文会解释。

#### 四、YYTransaction

YYTransaction 貌似和系统的 CATransaction 很像，他们同为“事务”，但实际上很不一样。通过 CATransaction 的嵌套用法猜测 CATransaction 对任务的管理是使用的一个栈结构，而 YYTransaction 是使用的集合来管理任务。

YYTransaction 做的事情就是记录一系列事件，并且在合适的时机调用这些事件。至于为什么这么做，需要先了解 YYTransaction 做了些什么，最终你会恍然大悟😁。

## 1、提交任务

YYTransaction 有两个属性：
```
@interface YYTransaction()
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@end
static NSMutableSet *transactionSet = nil;
```

很简单，方法接收者 (target) 和方法 (selector)，实际上一个 YYTransaction 就是一个任务，而 transactionSet 集合就是用来存储这些任务。提交方法- (void)commit;不过是初始配置并且将任务装入集合。

## 2、合适的回调时机

```
static void YYTransactionSetup() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [NSMutableSet new];
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer;
        observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,      // repeat
                                           0xFFFFFF,  // after CATransaction(2000000)
                                           YYRunLoopObserverCallBack, NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}

```
这里在主线程的 RunLoop 中添加了一个 oberver 监听，回调的时机是 kCFRunLoopBeforeWaiting 和 kCFRunLoopExit ，即是主线程 RunLoop 循环即将进入休眠或者即将退出的时候。而该 oberver 的优先级是 0xFFFFFF，优先级在 CATransaction 的后面（至于 CATransaction 的优先级为什么是 2000000，应该在主线程 RunLoop 启动的源代码中可以查到，笔者并没有找到暴露出来的信息）。

从这里可以看出，作者使用一个“低姿态”侵入主线程 RunLoop，在处理完重要逻辑（特别是 CoreAnimation 框架逻辑）之后做异步绘制的事情，这也是作者对优先级的权衡考虑。

下面看看回调里面做了些什么：

```
static void YYRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if (transactionSet.count == 0) return;
    NSSet *currentSet = transactionSet;
    transactionSet = [NSMutableSet new];
    [currentSet enumerateObjectsUsingBlock:^(YYTransaction *transaction, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [transaction.target performSelector:transaction.selector];
#pragma clang diagnostic pop
    }];
}

```
一目了然，只是将集合中的任务分别执行。

## 3、自定义 hash 算法

YYTransaction 类重写了 hash 算法：

```
- (NSUInteger)hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    return v1 ^ v2;
}
```

NSObject 类默认的 hash 值为 10 进制的内存地址，这里作者将_selector和_target的内存地址进行一个位异或处理，意味着只要_selector和_target地址都相同时，hash 值就相同。

这么做的意义是什么呢？

上面有提到一个集合：

```
static NSMutableSet *transactionSet = nil;

```
和其他编程语言一样 NSSet 是基于 hash 的集合，它是不能有重复元素的，而判断是否重复毫无疑问是使用 hash。这里将 YYTransaction 的 hash 值依托于_selector和_target的内存地址，那就意味着两点：

1. 同一个 YYTransaction 实例，_selector和_target只要有一个内存地址不同，就会在集合中体现为两个值。
2. 不同的 YYTransaction 实例，_selector和_target的内存地址都相同，在集合中的体现为一个值。

熟悉 hash 的读者应该一点即通，那么这么做对于业务的目的是什么呢？

哈哈，很简单，这样可以避免重复的方法调用。加入 transactionSet 中的事件会在 Runloop 即将进入休眠或者即将退出时遍历执行，相同的方法接收者和相同的方法，可以视为重复调用（这里的主要场景是避免重复绘制浪费性能）。

举一个实际的例子：
当使用绘制来制作一个文本时，Font、Text等属性的改变都意味着要重绘，使用 YYTransaction 延迟了绘制的调用时机，并且它们在同一个 RunLoop 循环中，装入NSSet将直接合并为一个绘制任务，避免了重复的绘制。

# 五、YYAsyncLayer

```
@interface YYAsyncLayer : CALayer
@property BOOL displaysAsynchronously;
@end
```

YYAsyncLayer 继承自 CALayer，对外暴露了一个方法可开闭是否异步绘制。

## 1、初始化配置
```
- (instancetype)init {
    self = [super init];
    static CGFloat scale; //global
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    self.contentsScale = scale;
    _sentinel = [YYSentinel new];
    _displaysAsynchronously = YES;
    return self;
}

```
这里设置了YYAsyncLayer的contentsScale为屏幕的scale，该属性是 物理像素 / 逻辑像素，这样可以充分利用不同设备的显示器分辨率，绘制更清晰的图像。但是若contentsGravity设置了可拉伸的类型，CoreAnimation 将会优先满足，而忽略掉contentsScale。

同时，初始化函数创建了一个YYSentinel实例。

##### @2x和@3x图

实际上 iPhone4 及其以上的 iPhone 设备scale都是 2 及以上，也就是说至少都是每个逻辑像素长度对应两个物理像素长度。所以很多美工会只切 @2x 和 @3x 图给你，而不切一倍图。

@2x和@3x图是苹果一个优化显示效果的机制，当 iPhone 设备scale为 2 时会优先读取 @2x 图，当scale为 3 时会优先读取 @3x 图，这就意味着，CALayer的contentsScale要和设备的scale对应才能达到预期的效果（不同设备显示相同的逻辑像素大小）。

幸运的是，UIView和UIImageView默认处理了它们内部CALayer的contentsScale，所以除非是直接使用CALayer及其衍生类，都不用显式的配置contentsScale。

##### 重写绘制方法
```
- (void)setNeedsDisplay {
    [self _cancelAsyncDisplay];
    [super setNeedsDisplay];
}
- (void)display {
    super.contents = super.contents;
    [self _displayAsync:_displaysAsynchronously];
}
```

可以看到两个方法，_cancelAsyncDisplay是取消绘制，稍后解析实现逻辑；_displayAsync是异步绘制的核心方法。

## 2、YYAsyncLayerDelegate 代理
```
@protocol YYAsyncLayerDelegate <NSObject>
@required
- (YYAsyncLayerDisplayTask *)newAsyncDisplayTask;
@end
@interface YYAsyncLayerDisplayTask : NSObject
@property (nullable, nonatomic, copy) void (^willDisplay)(CALayer *layer);
@property (nullable, nonatomic, copy) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));
@property (nullable, nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);
@end
```

YYAsyncLayerDisplayTask是绘制任务管理类，可以通过willDisplay和didDisplay回调将要绘制和结束绘制时机，最重要的是display，需要实现这个代码块，在代码块里面写业务绘制逻辑。

这个代理实际上就是框架和业务交互的桥梁，不过这个设计笔者个人认为有一些冗余，这里如果直接通过代理方法与业务交互而不使用中间类可能看起来更舒服。

## 3、异步绘制的核心逻辑

删减了部分代码：

```
- (void)_displayAsync:(BOOL)async {
    __strong id<YYAsyncLayerDelegate> delegate = self.delegate;
    YYAsyncLayerDisplayTask *task = [delegate newAsyncDisplayTask];
    ...
        dispatch_async(YYAsyncLayerGetDisplayQueue(), ^{
            if (isCancelled()) return;
            UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
            CGContextRef context = UIGraphicsGetCurrentContext();
            task.display(context, size, isCancelled);
            if (isCancelled()) {
                UIGraphicsEndImageContext();
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.didDisplay) task.didDisplay(self, NO);
                });
                return;
            }
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (isCancelled()) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.didDisplay) task.didDisplay(self, NO);
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCancelled()) {
                    if (task.didDisplay) task.didDisplay(self, NO);
                } else {
                    self.contents = (__bridge id)(image.CGImage);
                    if (task.didDisplay) task.didDisplay(self, YES);
                }
            });
        });
    ...
}

```
先不用管 YYAsyncLayerGetDisplayQueue()方法如何获取的异步队列，也先不用管isCancelled()判断做的一些提前结束绘制的逻辑，这些后面会讲。

那么，实际上核心代码可以更少：
```
- (void)_displayAsync:(BOOL)async {
    ...
    dispatch_async(YYAsyncLayerGetDisplayQueue(), ^{
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        task.display(context, size, isCancelled);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contents = (__bridge id)(image.CGImage);
        });
    }];
    ...
}

```
此时就很清晰了，在异步线程创建一个图形上下文，调用task的display代码块进行绘制（业务代码），然后生成一个图片，最终进入主队列给YYAsyncLayer的contents赋值CGImage由 GPU 渲染过后提交到显示系统。

## 4、及时的结束无用的绘制

针对同一个YYAsyncLayer，很有可能新的绘制请求到来时，当前的绘制任务还未完成，而当前的绘制任务是无用的，会继续消耗过多的 CPU (GPU) 资源。当然，这种场景主要是出现在列表界面快速滚动时，由于视图的复用机制，导致重新绘制的请求非常频繁。

为了解决这个问题，作者使用了大量的判断来及时的结束无用的绘制，可以看看源码或者是上文贴出的异步绘制核心逻辑代码，会发现一个频繁的操作：

```
if (isCancelled()) {...}
```
看看这个代码块的实现：
```
YYSentinel *sentinel = _sentinel;
int32_t value = sentinel.value;
BOOL (^isCancelled)(void) = ^BOOL() {
  return value != sentinel.value;
};
```

这就是YYSentinel计数类起作用的时候了，这里用一个局部变量value来保持当前绘制逻辑的计数值，保证其他线程改变了全局变量_sentinel的值也不会影响当前的value；若当前value不等于最新的_sentinel .value时，说明当前绘制任务已经被放弃，就需要及时的做返回逻辑。

那么，何时改变这个计数？
```
- (void)setNeedsDisplay {
    [self _cancelAsyncDisplay];
    [super setNeedsDisplay];
}
- (void)_cancelAsyncDisplay {
    [_sentinel increase];
}
```

很明显，在提交重绘请求时，计数器加一。

不得不说，这确实是一个令人兴奋的优化技巧。

5、异步线程的管理

笔者去除了判断 YYDispatchQueuePool 库是否存在的代码，实际上那就是作者提取的队列管理封装，思想和以下代码一样。
```
static dispatch_queue_t YYAsyncLayerGetDisplayQueue() {
//最大队列数量
#define MAX_QUEUE_COUNT 16
//队列数量
    static int queueCount;
//使用栈区的数组存储队列
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
//要点 1 ：串行队列数量和处理器数量相同
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
//要点 2 ：创建串行队列，设置优先级
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.ibireme.yykit.render", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.ibireme.yykit.render", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
//要点 3 ：轮询返回队列
    int32_t cur = OSAtomicIncrement32(&counter);
    if (cur < 0) cur = -cur;
    return queues[(cur) % queueCount];
#undef MAX_QUEUE_COUNT
}

```
##### 要点 1 ：串行队列数量和处理器数量相同

首先要明白，**并发** 和 **并行** 的区别：

并行一定并发，并发不一定并行。在单核设备上，CPU通过频繁的切换上下文来运行不同的线程，速度足够快以至于我们看起来它是‘并行’处理的，然而我们只能说这种情况是并发而非并行。例如：你和两个人一起百米赛跑，你一直在不停的切换跑道，而其他两人就在自己的跑道上，最终，你们三人同时到达了终点。我们把跑道看做任务，那么，其他两人就是并行执行任务的，而你只能的说是并发执行任务。

所以，实际上一个 n 核设备最多能 并行 执行 n 个任务，也就是最多有 n 个线程是相互不竞争 CPU 资源的。

当你开辟的线程过多，超过了处理数量，实际上某些并行的线程之间就可能竞争同一个处理器的资源，频繁的切换上下文也会消耗处理器性能。

**所以，超过处理器数量的线程没有性能上的优势，只是在业务上便于管理而已**

而串行队列中只有一个线程，该框架中，作者使用和处理器相同数量的串行队列，确实在性能上是最优的选择。

##### 要点 2 ：创建串行队列，设置优先级

在 8.0 以上的系统，队列的优先级为 QOS_CLASS_USER_INITIATED，低于用户交互相关的QOS_CLASS_USER_INTERACTIVE。

在 8.0 以下的系统，通过dispatch_set_target_queue()函数设置优先级为DISPATCH_QUEUE_PRIORITY_DEFAULT(第二个参数如果使用串行队列会强行将我们创建的所有线程串行执行任务)。

可以猜测主线程的优先级是大于或等于QOS_CLASS_USER_INTERACTIVE的，让这些串行队列的优先级低于主队列，避免框架创建的线程和主线程竞争资源。

关于两种类型优先级的对应关系是这样的：
```
 *  - DISPATCH_QUEUE_PRIORITY_HIGH:         QOS_CLASS_USER_INITIATED
 *  - DISPATCH_QUEUE_PRIORITY_DEFAULT:      QOS_CLASS_DEFAULT
 *  - DISPATCH_QUEUE_PRIORITY_LOW:          QOS_CLASS_UTILITY
 *  - DISPATCH_QUEUE_PRIORITY_BACKGROUND:   QOS_CLASS_BACKGROUND

```
##### 要点 3 ：轮询返回队列

同样使用原子自增函数OSAtomicIncrement32()对局部静态变量counter进行自增，然后通过取模运算循环返回队列。

注意这里使用了一个判断：if (cur < 0) cur = -cur;，当cur自增越界时就会变为负数最大值（在二进制层面，是用正整数的反码加一来表示其负数的）。

为什么要使用 n 个串行队列实现并发

可能有人会有疑惑，为什么这里需要使用 n 个串行队列来调度，而不用一个并行队列。

主要是因为并行队列无法精确的控制线程数量，很有可能创建过多的线程，导致 CPU 切换上下文过于频繁，影响性能。

可能会想到用信号量 (dispatch_semaphore_t) 来控制并发，然而这样只能控制并发的任务数量，而不能控制线程数量，并且使用起来不是很优雅。

而使用串行队列就很简单了，我们可以很明确的知道自己创建的线程数量，一切皆在掌控之中。

