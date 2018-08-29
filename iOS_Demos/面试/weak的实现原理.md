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

###  SideTable

 

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

- `slock` 是一个自旋锁，用来对 `SideTable` 实例进行操作时的加锁。

- `refcnts` 则是存放引用计数的地方。

- `weak_table` 则是存放弱引用的地方

  

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

这一段即获取 `oldObj`、`oldTable`和 `newTable`，并将获取的两个表上锁。注意到获取 `oldTable`和 `newTable`时，其实是用对象的地址当作 key 从 `SideTables`获取的，`SideTables`返回的就是一个哈希表，存储着若干个 `SideTable`，一般是 **64** 个。



```c++
// Prevent a deadlock between the weak reference machinery
// and the +initialize machinery by ensuring that no 
// weakly-referenced object has an un-+initialized isa.
if (HaveNew  &&  newObj) {
    Class cls = newObj->getIsa();
    if (cls != previouslyInitializedClass  &&  
        !((objc_class *)cls)->isInitialized()) 
    {
        SideTable::unlockTwo<HaveOld, HaveNew>(oldTable, newTable);
        _class_initialize(_class_getNonMetaClass(cls, (id)newObj));

        // If this class is finished with +initialize then we're good.
        // If this class is still running +initialize on this thread 
        // (i.e. +initialize called storeWeak on an instance of itself)
        // then we may proceed but it will appear initializing and 
        // not yet initialized to the check above.
        // Instead set previouslyInitializedClass to recognize it on retry.
        previouslyInitializedClass = cls;

        goto retry;
    }
}
```

 

上面这一段代码也有着很好的注释，就是要确保对象的类已经走过 `+initialize` 流程了。



```c++
// Clean up old value, if any.
    if (HaveOld) {
        weak_unregister_no_lock(&oldTable->weak_table, oldObj, location);
    }

    // Assign new value, if any.
    if (HaveNew) {
        newObj = (objc_object *)weak_register_no_lock(&newTable->weak_table, 
                                                      (id)newObj, location, 
                                                      CrashIfDeallocating);
        // weak_register_no_lock returns nil if weak store should be rejected

        // Set is-weakly-referenced bit in refcount table.
        if (newObj  &&  !newObj->isTaggedPointer()) {
            newObj->setWeaklyReferenced_nolock();
        }

        // Do not set *location anywhere else. That would introduce a race.
        *location = (id)newObj;
    }
    else {
        // No new value. The storage is not changed.
    }
    
    SideTable::unlockTwo<HaveOld, HaveNew>(oldTable, newTable);

    return (id)newObj;
}

```

 

最后一段的逻辑也是很清晰的。首先，如果有旧的值（`HaveOld`），则使用 `weak_unregister_no_lock`函数将其从 `oldTable`的 `weak_table`中移除。其次，如果有新的值（`HaveNew`），则使用 `weak_register_no_lock`函数将其注册到 `newTable`的 `weak_table`中，并使用 `setWeaklyReferenced_nolock`函数将对象标记为被弱引用过。

`storeWeak`的实现就告一段落了，其重点就在 `weak_register_no_lock`和 `weak_unregister_no_lock`函数上。

###  weak_table_t

 weak表是一个弱引用表，实现为一个weak_table_t结构体，存储了某个对象相关的的所有的弱引用信息。其定义如下(具体定义在[objc-weak.h](https://link.jianshu.com/?t=https://opensource.apple.com/source/objc4/objc4-646/runtime/objc-weak.h)中)：

```c++
/**
 * The global weak references table. Stores object ids as keys,
 * and weak_entry_t structs as their values.
 */
struct weak_table_t {
    // 保存了所有指向指定对象的 weak 指针
    weak_entry_t *weak_entries;
    // 存储空间
    size_t    num_entries;
    // 参与判断引用计数辅助量
    uintptr_t mask;
    // hash key 最大偏移值
    uintptr_t max_hash_displacement;
};

```

 

- `weak_entries`便是存放弱引用的数组；
- `num_entries`是存放的 `weak_entry_t`条目的数量；
- `mask`则是动态申请的弱引用数组 `weak_entries`长度减 1 的值，用来对哈希后的值取余和记录数组大小；
- `max_hash_displacement`则是哈希碰撞后最大的位移值。

 其实 `weak_table_t` 就是一个动态增长的哈希表。

 继续看看其相关的操作，首先是对整个表的扩大：

 

其中**weak_entry_t**是存储在弱引用表中的一个内部结构体，它负责维护和存储指向一个对象的所有弱引用hash表。其定义如下：

```c++
typedef objc_object ** weak_referrer_t;
struct weak_entry_t {
    DisguisedPtr<objc_object> referent;
    union {
        struct {
            weak_referrer_t *referrers;
            uintptr_t        out_of_line : 1;
            uintptr_t        num_refs : PTR_MINUS_1;
            uintptr_t        mask;
            uintptr_t        max_hash_displacement;
        };
        struct {
            // out_of_line=0 is LSB of one of these (don't care which)
            weak_referrer_t  inline_referrers[WEAK_INLINE_COUNT];
        };
    }
}


```

 

 在 **weak_entry_t** 的结构中，`DisguisedPtr referent` 是对泛型对象的指针做了一个封装，通过这个泛型类来解决内存泄漏的问题。从注释中写 `out_of_line` 成员为最低有效位，当其为**0**的时候， `weak_referrer_t` 成员将扩展为多行静态 `hash table`。其实其中的 `weak_referrer_t` 是二维 `objc_object` 的别名，通过一个二维指针地址偏移，用下标作为 **hash** 的 **key**，做成了一个弱引用散列。

- **out_of_line**：最低有效位，也是标志位。当标志位 0 时，增加引用表指针纬度。
- **num_refs**：引用数值。这里记录弱引用表中引用有效数字，因为弱引用表使用的是静态 hash 结构，所以需要使用变量来记3g5录数目。
- **mask**：计数辅助量。
- **max_hash_displacement**：**hash** 元素上限阀值。

其实 `weak_table_t` 就是一个动态增长的哈希表。

继续看看其相关的操作，首先是对整个表的扩大：

```c++
#define TABLE_SIZE(entry) (entry->mask ? entry->mask + 1 : 0)

// Grow the given zone's table of weak references if it is full.
static void weak_grow_maybe(weak_table_t *weak_table)
{
    size_t old_size = TABLE_SIZE(weak_table);

    // Grow if at least 3/4 full.
    if (weak_table->num_entries >= old_size * 3 / 4) {
        weak_resize(weak_table, old_size ? old_size*2 : 64);
    }
}

```

 

 

可以看到，当 `weak_table` 里的弱引用条目达到它容量的四分之三时，便会将容量拓展为两倍。值得注意的是第一次拓展也就是是 `mask` 为 0 的情况，初始值是 64。实际对弱引用表大小的操作则交给了 `weak_resize` 函数。

除了扩大，当然也还有缩小：



```c++
// Shrink the table if it is mostly empty.
static void weak_compact_maybe(weak_table_t *weak_table)
{
    size_t old_size = TABLE_SIZE(weak_table);

    // Shrink if larger than 1024 buckets and at most 1/16 full.
    if (old_size >= 1024  && old_size / 16 >= weak_table->num_entries) {
        weak_resize(weak_table, old_size / 8);
        // leaves new table no more than 1/2 full
    }
}

```

 

 缩小的话则是需要表本身大于等于 1024 并且存放了不足十六分之一的条目时，直接缩小 8 倍。实际工作也是交给了 `weak_resize` 函数：



```c++
static void weak_resize(weak_table_t *weak_table, size_t new_size)
{
    size_t old_size = TABLE_SIZE(weak_table);

    weak_entry_t *old_entries = weak_table->weak_entries;
    weak_entry_t *new_entries = (weak_entry_t *)
        calloc(new_size, sizeof(weak_entry_t));

    weak_table->mask = new_size - 1;
    weak_table->weak_entries = new_entries;
    weak_table->max_hash_displacement = 0;
    weak_table->num_entries = 0;  // restored by weak_entry_insert below
    
    if (old_entries) {
        weak_entry_t *entry;
        weak_entry_t *end = old_entries + old_size;
        for (entry = old_entries; entry < end; entry++) {
            if (entry->referent) {
                weak_entry_insert(weak_table, entry);
            }
        }
        free(old_entries);
    }
}

```

 

 `weak_resize`函数的过程就是新建一个数组，将老数组里的值使用 `weak_entry_insert`函数添加进去，注意到代码中间 `mask`在这里被赋值为新数组的大小减去 1，`max_hash_displacement`和 `num_entries`也都清零了，因为 `weak_entry_insert`函数会对这两个值进行操作。接着对 `weak_entry_insert`函数进行分析：

 

```c++
/** 
 * Add new_entry to the object's table of weak references.
 * Does not check whether the referent is already in the table.
 */
static void weak_entry_insert(weak_table_t *weak_table, weak_entry_t *new_entry)
{
    weak_entry_t *weak_entries = weak_table->weak_entries;
    assert(weak_entries != nil);

    size_t begin = hash_pointer(new_entry->referent) & (weak_table->mask);
    size_t index = begin;
    size_t hash_displacement = 0;
    while (weak_entries[index].referent != nil) {
        index = (index+1) & weak_table->mask;
        if (index == begin) bad_weak_table(weak_entries);
        hash_displacement++;
    }

    weak_entries[index] = *new_entry;
    weak_table->num_entries++;

    if (hash_displacement > weak_table->max_hash_displacement) {
        weak_table->max_hash_displacement = hash_displacement;
    }
}

```

 这个函数就是个很正常的哈希表插入的过程，`hash_pointer`函数是对指针地址进行哈希，哈希后的值之所以要和 `mask`进行 `&`操作，是因为弱引用表的大小永远是 2 的幂（一开始是 64，之后不断乘以 2），`mask`则是大小减去 1 即为一个 `0b111...11`这么一个数，和它进行 `&`运算相当于取余。`hash_displacement`则是记录了哈希相撞后偏移的大小。

既然有插入，也就有删除：

 

 

```c++
/**
 * Remove entry from the zone's table of weak references.
 */
static void weak_entry_remove(weak_table_t *weak_table, weak_entry_t *entry)
{
    // remove entry
    if (entry->out_of_line()) free(entry->referrers);
    bzero(entry, sizeof(*entry));

    weak_table->num_entries--;

    weak_compact_maybe(weak_table);
}

```

 

 很直接的清零 `entry`，并给 `weak_table` 的 `num_entries` 减 1，最后检查看是否需要缩小。

最后还有一个根据指定对象查找存在条目的函数： 

 

```c++
/** 
 * Return the weak reference table entry for the given referent. 
 * If there is no entry for referent, return NULL. 
 * Performs a lookup.
 *
 * @param weak_table 
 * @param referent The object. Must not be nil.
 * 
 * @return The table of weak referrers to this object. 
 */
static weak_entry_t *
weak_entry_for_referent(weak_table_t *weak_table, objc_object *referent)
{
    assert(referent);

    weak_entry_t *weak_entries = weak_table->weak_entries;

    if (!weak_entries) return nil;

    size_t begin = hash_pointer(referent) & weak_table->mask;
    size_t index = begin;
    size_t hash_displacement = 0;
    while (weak_table->weak_entries[index].referent != referent) {
        index = (index+1) & weak_table->mask;
        if (index == begin) bad_weak_table(weak_table->weak_entries);
        hash_displacement++;
        if (hash_displacement > weak_table->max_hash_displacement) {
            return nil;
        }
    }
    
    return &weak_table->weak_entries[index];
}

```

 

 也是很正常的哈希表套路。

### weak_entry_t

那弱引用是怎么存储的呢，继续分析 `weak_entry_t`：

 

```c++
#define WEAK_INLINE_COUNT 4

#define REFERRERS_OUT_OF_LINE 2

struct weak_entry_t {
    DisguisedPtr<objc_object> referent;
    union {
        struct {
            weak_referrer_t *referrers;
            uintptr_t        out_of_line_ness : 2;
            uintptr_t        num_refs : PTR_MINUS_2;
            uintptr_t        mask;
            uintptr_t        max_hash_displacement;
        };
        struct {
            // out_of_line_ness field is low bits of inline_referrers[1]
            weak_referrer_t  inline_referrers[WEAK_INLINE_COUNT];
        };
    };

    bool out_of_line() {
        return (out_of_line_ness == REFERRERS_OUT_OF_LINE);
    }

    weak_entry_t& operator=(const weak_entry_t& other) {
        memcpy(this, &other, sizeof(other));
        return *this;
    }

    weak_entry_t(objc_object *newReferent, objc_object **newReferrer)
        : referent(newReferent)
    {
        inline_referrers[0] = newReferrer;
        for (int i = 1; i < WEAK_INLINE_COUNT; i++) {
            inline_referrers[i] = nil;
        }
    }
};


```

 

首先 `DisguisedPtr<T>`类型和 `T*`的行为是一模一样的，这个类型存在的目的是为了躲过内存泄漏工具的检查（注释原文：「`DisguisedPtr<T>`acts like pointer type `T*`, except the stored value is disguised to hide it from tools like `leaks`.」）。所以 `DisguisedPtr<objc_object> referent`可以看作是 `objc_object *referent`。

`referent`这个指针记录的便是被弱引用的对象。接下来的联合里有两种结构体，先分析第一种：

- `referrers`：`referrers`是一个 `weak_referrer_t`类型的数组，用来存放弱引用变量的地址，`weak_referrer_t`的定义是这样的：`typedef DisguisedPtr<objc_object *> weak_referrer_t;`；
- `out_of_line_ness`：2 bit 标记位，用来确定联合里的内存是第一个结构体还是第二个结构体；
- `num_refs`：`PTR_MINUS_2`便是字长减去 2 位，和 `out_of_line_ness`一起组成一个字长，用来存储 `referrers`的大小；
- `mask`和 `max_hash_displacement`：和前面分析的一样，做哈希表用到的东西。

可以发现第一种结构体也是一个哈希表，第二种结构体则是一个和第一种结构体一样大的数组，所谓的 inline 存储。存放思路则是首先 inline 存储，当超过 `WEAK_INLINE_COUNT`也就是 4 时，再变成第一种的动态哈希表存储。代码下方的构造函数便体现了这个思路。

可以注意到 `weak_entry_t`重载了赋值操作符，将赋值变成了一个拷贝内存的操作。

相关操作也是和上面 `weak_table_t`的类似，只不过加上了 inline 存储情况的变化，就不详细分析了。

 

###  weak_register_no_lock

 开始分析 `weak_register_no_lock` 函数：

```c++
/** 
 * Registers a new (object, weak pointer) pair. Creates a new weak
 * object entry if it does not exist.
 * 
 * @param weak_table The global weak table.
 * @param referent The object pointed to by the weak reference.
 * @param referrer The weak pointer address.
 */
id 
weak_register_no_lock(weak_table_t *weak_table, id referent_id, 
                      id *referrer_id, bool crashIfDeallocating)
{
    objc_object *referent = (objc_object *)referent_id;
    objc_object **referrer = (objc_object **)referrer_id;

    if (!referent  ||  referent->isTaggedPointer()) return referent_id;

```

 第一段，约等于什么都没干。`referent` 是被弱引用的对象，`referrer` 则是弱引用变量的地址。

 

```c++
// ensure that the referenced object is viable
    bool deallocating;
    if (!referent->ISA()->hasCustomRR()) {
        deallocating = referent->rootIsDeallocating();
    }
    else {
        BOOL (*allowsWeakReference)(objc_object *, SEL) = 
            (BOOL(*)(objc_object *, SEL))
            object_getMethodImplementation((id)referent, 
                                           SEL_allowsWeakReference);
        if ((IMP)allowsWeakReference == _objc_msgForward) {
            return nil;
        }
        deallocating =
            ! (*allowsWeakReference)(referent, SEL_allowsWeakReference);
    }

```

 

 这一段很有意思，如果对象没有自定义的内存管理方法（`hasCustomRR`），则将 `deallocating`变量赋值为 `rootIsDeallocating`也就是是否正在销毁。但是如果有自定义的内存管理方法的话，发送的是
`allowsWeakReference`这个消息，即是否允许弱引用。不管怎么样，我们得到了一个 `deallocating`变量。

 

```c++
if (deallocating) {
        if (crashIfDeallocating) {
            _objc_fatal("Cannot form weak reference to instance (%p) of "
                        "class %s. It is possible that this object was "
                        "over-released, or is in the process of deallocation.",
                        (void*)referent, object_getClassName((id)referent));
        } else {
            return nil;
        }
    }

```

 

从上面一段可以知道，`deallocating` 为 `true` 的话肯定是有问题的，所以这一段处理一下。

 

```c++
// now remember it and where it is being stored
    weak_entry_t *entry;
    if ((entry = weak_entry_for_referent(weak_table, referent))) {
        append_referrer(entry, referrer);
    } 
    else {
        weak_entry_t new_entry(referent, referrer);
        weak_grow_maybe(weak_table);
        weak_entry_insert(weak_table, &new_entry);
    }

    // Do not set *referrer. objc_storeWeak() requires that the 
    // value not change.

    return referent_id;
}

```

最后一段终于做了正事了！首先先用 `weak_entry_for_referent`函数搜索对象是否已经有了 `weak_entry_t`类型的条目，有的话则使用 `append_referrer`添加一个变量位置进去，没有的话则新建一个 `weak_entry_t`条目，使用 `weak_grow_maybe`函数扩大（如果需要的话）弱引用表的大小，并使用 `weak_entry_insert`将弱引用插入表中。

 ### weak_unregister_no_lock

接下来是 `weak_unregister_no_lock` 函数：

 

```c++
void
weak_unregister_no_lock(weak_table_t *weak_table, id referent_id, 
                        id *referrer_id)
{
    objc_object *referent = (objc_object *)referent_id;
    objc_object **referrer = (objc_object **)referrer_id;

    weak_entry_t *entry;

    if (!referent) return;

    if ((entry = weak_entry_for_referent(weak_table, referent))) {
        remove_referrer(entry, referrer);
        bool empty = true;
        if (entry->out_of_line()  &&  entry->num_refs != 0) {
            empty = false;
        }
        else {
            for (size_t i = 0; i < WEAK_INLINE_COUNT; i++) {
                if (entry->inline_referrers[i]) {
                    empty = false; 
                    break;
                }
            }
        }

        if (empty) {
            weak_entry_remove(weak_table, entry);
        }
    }

    // Do not set *referrer = nil. objc_storeWeak() requires that the 
    // value not change.
}

```

 

主要功能实现思路很简单，使用 `weak_entry_for_referent` 函数找到对应的弱引用条目，并用 `remove_referrer` 将对应的弱引用变量位置从中移除。最后判断条目是否为空，为空则使用 `weak_entry_remove` 将其从弱引用表中移除。

### 自动置为 nil

对象销毁后，弱引用变量被置为 `nil` 是因为在对象 `dealloc` 的过程中调用了 `weak_clear_no_lock` 函数：

 

```c++
/** 
 * Called by dealloc; nils out all weak pointers that point to the 
 * provided object so that they can no longer be used.
 * 
 * @param weak_table 
 * @param referent The object being deallocated. 
 */
void 
weak_clear_no_lock(weak_table_t *weak_table, id referent_id) 
{
    objc_object *referent = (objc_object *)referent_id;

    weak_entry_t *entry = weak_entry_for_referent(weak_table, referent);
    if (entry == nil) {
        /// XXX shouldn't happen, but does with mismatched CF/objc
        //printf("XXX no entry for clear deallocating %p\n", referent);
        return;
    }

```

首先初始化一下，获取到弱引用条目，顺便处理没有弱引用的情况。

 

```c++
// zero out references
    weak_referrer_t *referrers;
    size_t count;
    
    if (entry->out_of_line()) {
        referrers = entry->referrers;
        count = TABLE_SIZE(entry);
    } 
    else {
        referrers = entry->inline_referrers;
        count = WEAK_INLINE_COUNT;
    }

```

获取弱引用变量位置数组和个数。

```c++
for (size_t i = 0; i < count; ++i) {
        objc_object **referrer = referrers[i];
        if (referrer) {
            if (*referrer == referent) {
                *referrer = nil;
            }
            else if (*referrer) {
                _objc_inform("__weak variable at %p holds %p instead of %p. "
                             "This is probably incorrect use of "
                             "objc_storeWeak() and objc_loadWeak(). "
                             "Break on objc_weak_error to debug.\n", 
                             referrer, (void*)*referrer, (void*)referent);
                objc_weak_error();
            }
        }
    }
    
    weak_entry_remove(weak_table, entry);
}

```

循环将它们置为 `nil`，最后移除整个弱引用条目。

## 访问弱引用

在访问一个弱引用时，ARC 会对其进行一些操作：

```c++
obj = weakObj;

// 会变成
objc_loadWeakRetained(&weakObj);
obj = weakObj;
objc_release(weakObj);
```

`objc_loadWeakRetained` 函数的主要作用就是调用了 `rootTryRetain` 函数：

 

```c++
ALWAYS_INLINE bool 
objc_object::rootTryRetain()
{
    return rootRetain(true, false) ? true : false;
}
```

实际上就是尝试对引用计数加 1，让弱引用对象在使用时不会被释放掉。
