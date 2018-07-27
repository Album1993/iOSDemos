# 用于修饰属性的atomic关键字

atomic只能保证属性系统生成的set/get方法读写线程安全，对属性发送其他消息如release等等，还是需要lock等其它的同步机制来确保线程安全。

那OC是如何实现atomic的属性的getter/setter呢？  
在[objc-accessors.mm](https://opensource.apple.com/source/objc4/objc4-709/runtime/objc-accessors.mm.auto.html)中，查看代码可知，property 的 atomic 是采用 spinlock_t 也就是俗称的自旋锁实现的。  

```
// getter
id objc_getProperty(id self, SEL _cmd, ptrdiff_t offset, BOOL atomic) {
    // ...
    if (!atomic) return *slot;

    // Atomic retain release world
    spinlock_t& slotlock = PropertyLocks[slot];
    slotlock.lock();
    id value = objc_retain(*slot);
    slotlock.unlock();
    // ...
}

// setter
static inline void reallySetProperty(id self, SEL _cmd, id newValue, ptrdiff_t offset, bool atomic, bool copy, bool mutableCopy)
{
    // ...
    if (!atomic) {
        oldValue = *slot;
        *slot = newValue;
    } else {
        spinlock_t& slotlock = PropertyLocks[slot];
        slotlock.lock();
        oldValue = *slot;
        *slot = newValue;        
        slotlock.unlock();
    }
    // ...
}
```