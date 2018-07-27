## weak 实现原理的概括



**Runtime**维护了一个**weak**表，用于存储指向某个对象的所有**weak**指针。**weak**表其实是一个**hash**（哈希）表，<u>**Key**是所指对象的地址，**Value**是**weak**指针的地址</u>（这个地址的值是所指对象指针的地址）数组。



#### weak 的实现原理可以概括一下三步：

1. 初始化时：**runtime**会调用**objc_initWeak**函数，初始化一个新的**weak**指针指向对象的地址。
2. 添加引用时：**objc_initWeak**函数会调用 **objc_storeWeak()** 函数， **objc_storeWeak()** 的作用是更新指针指向，创建对应的弱引用表。
3. 释放时，调用**clearDeallocating**函数。**clearDeallocating**函数首先根据对象地址获取所有**weak**指针地址的数组，然后遍历这个数组把其中的数据设为**nil**，最后把这个**entry**从**weak**表中删除，最后清理对象的记录。

## 下面将开始详细介绍每一步：

#####  1、初始化时：runtime会调用objc_initWeak函数，objc_initWeak函数会初始化一个新的weak指针指向对象的地址。

 

```objective-c
{
    NSObject *obj = [[NSObject alloc] init];
    id __weak obj1 = obj;
}
```

还是上面那个例子，实际上编译器会进行一些变动：

```objective-c
{
    id __weak weakObj = strongObj;
}
// 会变成
{
    id __weak weakObj;
    objc_initWeak(&weakObj, strongObj);
    
    // 离开变量的范围，进行销毁
    objc_destroyWeak(&weakObj);
}
```

当我们初始化一个**weak**变量时，**runtime**会调用 **NSObject.mm** 中的**objc_initWeak**函数。这个函数在**Clang**中的声明如下：

```objective-c
id objc_initWeak(id *object, id value);
```

 而对于 `objc_initWeak()` 方法的实现

```objective-c
id objc_initWeak(id *location, id newObj) {
// 查看对象实例是否有效
// 无效对象直接导致指针释放
    if (!newObj) {
        *location = nil;
        return nil;
    }
    // 这里传递了三个 bool 数值
    // 使用 template 进行常量参数传递是为了优化性能
    return storeWeak<false/*old*/, true/*new*/, true/*crash*/>
        (location, (objc_object*)newObj);

}

void objc_destroyWeak(id *location)
{
    (void)storeWeak<true/*old*/, false/*new*/, false/*crash*/>
        (location, nil);
}
```

可以看出，这个函数仅仅是一个深层函数的调用入口，而一般的入口函数中，都会做一些简单的判断（例如 **objc_msgSend** 中的缓存判断），这里判断了其指针指向的类对象是否有效，无效直接释放，不再往深层调用函数。否则，**object**将被注册为一个指向**value**的**__weak**对象。而这事应该是**objc_storeWeak**函数干的。



 <u>**注意：*objc_initWeak函数有一个前提条件：就是object必须是一个没有被注册为__weak对象的有效指针。而value则可以是null，或者指向一个有效的对象。***</u>



#####  2、添加引用时：`objc_initWeak`函数会调用 `objc_storeWeak()` 函数， `objc_storeWeak()` 的作用是更新指针指向，创建对应的弱引用表。

##### 赋值

当已有的 `__weak` 变量被重新赋值时会怎么样呢？

```objc
weakObj = anotherStrongObj;

// 会变成下面这样
objc_storeWeak(&weakObj, anotherStrongObj);
```

 它的实现如下：

```objc
id
objc_storeWeak(id *location, id newObj)
{
    return storeWeak<true/*old*/, true/*new*/, true/*crash*/>
        (location, (objc_object *)newObj);
} 
```

但实际上也还是对 `storeWeak` 函数模板的封装。

```c++
// HaveOld:  true - 变量有值
//          false - 需要被及时清理，当前值可能为 nil
// HaveNew:  true - 需要被分配的新值，当前值可能为 nil
//          false - 不需要分配新值
// CrashIfDeallocating: true - 说明 newObj 已经释放或者 newObj 不支持弱引用，该过程需要暂停
//          false - 用 nil 替代存储
template <bool HaveOld, bool HaveNew, bool CrashIfDeallocating>
static id storeWeak(id *location, objc_object *newObj) {
    // 该过程用来更新弱引用指针的指向
    // 初始化 previouslyInitializedClass 指针
    Class previouslyInitializedClass = nil;
    id oldObj;
    // 声明两个 SideTable
    // ① 新旧散列创建
    SideTable *oldTable;
    SideTable *newTable;
    // 获得新值和旧值的锁存位置（用地址作为唯一标示）
    // 通过地址来建立索引标志，防止桶重复
    // 下面指向的操作会改变旧值
retry:
    if (HaveOld) {
        // 更改指针，获得以 oldObj 为索引所存储的值地址
        oldObj = *location;
        oldTable = &SideTables()[oldObj];
    } else {
        oldTable = nil;
    }
    if (HaveNew) {
        // 更改新值指针，获得以 newObj 为索引所存储的值地址
        newTable = &SideTables()[newObj];
    } else {
        newTable = nil;
    }
    // 加锁操作，防止多线程中竞争冲突
    SideTable::lockTwo<HaveOld, HaveNew>(oldTable, newTable);
    // 避免线程冲突重处理
    // location 应该与 oldObj 保持一致，如果不同，说明当前的 location 已经处理过 oldObj 可是又被其他线程所修改
    if (HaveOld  &&  *location != oldObj) {
        SideTable::unlockTwoHaveOld, HaveNew>(oldTable, newTable);
        goto retry;
    }
    // 防止弱引用间死锁
    // 并且通过 +initialize 初始化构造器保证所有弱引用的 isa 非空指向
    if (HaveNew  &&  newObj) {
        // 获得新对象的 isa 指针
        Class cls = newObj->getIsa();
        // 判断 isa 非空且已经初始化
        if (cls != previouslyInitializedClass  &&
            !((objc_class *)cls)->isInitialized()) {
            // 解锁
            SideTable::unlockTwoHaveOld, HaveNew>(oldTable, newTable);
            // 对其 isa 指针进行初始化
            _class_initialize(_class_getNonMetaClass(cls, (id)newObj));
            // 如果该类已经完成执行 +initialize 方法是最理想情况
            // 如果该类 +initialize 在线程中
            // 例如 +initialize 正在调用 storeWeak 方法
            // 需要手动对其增加保护策略，并设置 previouslyInitializedClass 指针进行标记
            previouslyInitializedClass = cls;
            // 重新尝试
            goto retry;
        }
    }
    // ② 清除旧值
    if (HaveOld) {
        weak_unregister_no_lock(&oldTable->weak_table, oldObj, location);
    }
    // ③ 分配新值
    if (HaveNew) {
        newObj = (objc_object *)weak_register_no_lock(&newTable->weak_table,
                                                      (id)newObj, location,
                                                      CrashIfDeallocating);
        // 如果弱引用被释放 weak_register_no_lock 方法返回 nil
        // 在引用计数表中设置若引用标记位
        if (newObj  &&  !newObj->isTaggedPointer()) {
            // 弱引用位初始化操作
            // 引用计数那张散列表的weak引用对象的引用计数中标识为weak引用
            newObj->setWeaklyReferenced_nolock();
        }
        // 之前不要设置 location 对象，这里需要更改指针指向
        *location = (id)newObj;
    }
    else {
        // 没有新值，则无需更改
    }
    SideTable::unlockTwoHaveOld, HaveNew>(oldTable, newTable);
    return (id)newObj;
}

```

###  1)、SideTable

 

```c++
struct SideTable {
// 保证原子操作的自旋锁
    spinlock_t slock;
    // 引用计数的 hash 表
    RefcountMap refcnts;
    // weak 引用全局 hash 表
    weak_table_t weak_table;
}
```



回到 `storeWeak` 函数：

 

```c++
// Acquire locks for old and new values.
    // Order by lock address to prevent lock ordering problems. 
    // Retry if the old value changes underneath us.
 retry:
    if (HaveOld) {
        oldObj = *location;
        oldTable = &SideTables()[oldObj];
    } else {
        oldTable = nil;
    }
    if (HaveNew) {
        newTable = &SideTables()[newObj];
    } else {
        newTable = nil;
    }

    SideTable::lockTwo<HaveOld, HaveNew>(oldTable, newTable);

    if (HaveOld  &&  *location != oldObj) {
        SideTable::unlockTwo<HaveOld, HaveNew>(oldTable, newTable);
        goto retry;
    }

```

