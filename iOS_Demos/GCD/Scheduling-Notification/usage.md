
# Scheduling Services

A micro-post about a micro-framework. Schedule (possibly repeating) events for some time in the future, along with restoration support. An NSNotification-based scheduling service in Swift.

## Requirements

* Schedule a request
* Cancel a request
* Restore all requests upon app-launch
* Pause/resume all requests


Essentially I wanted to remove the knowledge/management of a timer. Obviously the implementation would need to handle this, but I wanted to build an abstraction on top of this that would support all of my requirements, while providing a simple/clean API.

## Scheduling Service

The result is a lightweight micro-framework – SchedulingService.
```
// schedule a request
let request = service.schedule(date: Date().addingTimeInterval(5))

// cancel the request
service.cancel(request)

// schedule an NSNotification
service.schedule(date: Date().addingTimeInterval(20), 
         notification: .CountdownDidUpdate)

```

## Codable

I also wanted to be able to save/restore all scheduled events so that I wouldn't need to restore them manually upon launch.


```
// decodes or makes a new Service
let store = SchedulingServiceStore(service: nil)

// encodes the current service
store.service.save()
```

