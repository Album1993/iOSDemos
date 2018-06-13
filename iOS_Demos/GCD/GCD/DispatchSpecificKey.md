```
final class SafeSyncQueue {

    struct QueueIdentity {
        let label: String
    }

    let queue: DispatchQueue

    fileprivate let queueKey: DispatchSpecificKey<QueueIdentity>

    init(label: String) {
        self.queue = DispatchQueue(label: "com.khanlou.\(label).SafeSyncQueue")
        self.queueKey = DispatchSpecificKey<QueueIdentity>()
        self.queue.setSpecific(key: queueKey, value: QueueIdentity(label: queue.label))
    }

    fileprivate var currentQueueIdentity: QueueIdentity? {
        return DispatchQueue.getSpecific(key: queueKey)
    }

    func sync(execute: ()->()) {
        if currentQueueIdentity?.label == queue.label {
            execute()
        } else {
            queue.sync(execute: execute)
        }

    }
}
```