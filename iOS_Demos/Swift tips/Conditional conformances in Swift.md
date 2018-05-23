### The basics


Let’s start with the basics — how to declare conditional conformance to a protocol. Let’s say we are building a game that has multiple types that can be converted into a score (it can be levels, collectibles, enemies, etc). To handle all of these types in a uniform way, we define a **ScoreConvertible** protocol:


```
protocol ScoreConvertible {
    func computeScore() -> Int
}

```

One thing that is very common when working with protocols like the above is to want to deal with arrays of values. In this case, we’d like to easily be able to sum up the total score of all elements of arrays containing **ScoreConvertiblevalues**. One way of enabling that is to add an extension on **Array** for when its **Element** type conforms to **ScoreConvertible**, like this:


```
extension Array where Element: ScoreConvertible {
    func computeScore() -> Int {
        return reduce(0) { result, level in
            result + level.computeScore()
        }
    }
}
```

The above works great for single dimensional arrays, such as when summarizing the total score of an array of **Level** objects:


```
let levels = [Level(id: "water-0"), Level(id: "water-1")]
let score = levels.computeScore()

```

However, as soon as we start dealing with more complex arrays (like if we use nested arrays to group our levels into worlds), we start running into problems. 

Since **Array** itself doesn't actually conform to **ScoreConvertible** we wouldn't be able to compute an array of arrays into a total score. We also wouldn't want all arrays to conform to **ScoreConvertible**, since that wouldn't make sense for variants like **[String]** or **[UIView]**.

This is the core problem that the conditional conformances feature aims to solve. Now, in Swift 4.1, we can make **Array** conform to **ScoreConvertibleonly** if it contains **ScoreConvertible** elements, like this:



```
extension Array: ScoreConvertible where Element: ScoreConvertible {
    func computeScore() -> Int {
        return reduce(0) { result, level in
            result + level.computeScore()
        }
    }
}
```

Which in turn lets us compute the total score of any number of nested arrays containing **ScoreConvertible** types:


```
let worlds = [
    [Level(id: "water-0"), Level(id: "water-1")],
    [Level(id: "sand-0"), Level(id: "sand-1")],
    [Level(id: "lava-0"), Level(id: "lava-1")]
]
let totalScore = worlds.computeScore()

```

As we iterate on our code base, having this level of flexibility can be really sweet! 🍭

### Recursive design

The big benefit of conditional conformances is that they allow us to design our code and systems in a more recursive fashion. By being able to nest types and collections, like in the example above, we are free to structure our objects and values in much more flexible ways.

One of the most clear benefits of such recursive design in the Swift standard library, is that collections containing **Equatable** types are now also equatable themselves. Similar to our **ScoreConvertible** example above, we are now free to check nested collections for equality without having to write any extra code:


```
func didLoadArticles(_ articles: [String : [Article]]) {
    // We can now compare nested collections containing Equatable
    // types simply by using the == or != operators.
    guard articles != currentArticles else {
        return
    }
    currentArticles = articles
    notifyObservers()
    render()
}

```

While being able to do the above is pretty neat, it’s also important to remember that such an equality check can hide complexity — since checking if two collections are equal is an **O(N)** operation.


### Multipart requests


Now let’s take a look at a bit more advanced example, in which we’ll use a conditional conformance to create a nice API for handling multiple network requests. We’ll start by defining a protocol for a **Request**, that can return a **Result** type containing any **Response**, like this:


```
protocol Request {
    associatedtype Response
    typealias Handler = (Result<Response>) -> Void
    func perform(then handler: @escaping Handler)
}
```

Let’s say we’re building an app for a magazine that lets our users read articles within different categories. To be able to load an array of articles for a given category, we define an **ArticleRequest** type that conforms to the above **Request** protocol:


```
struct ArticleRequest: Request {
    typealias Response = [Article]
    let dataLoader: DataLoader
    let category: Category
    func perform(then handler: @escaping Handler) {
        let endpoint = Endpoint.articles(category)
        dataLoader.load(from: endpoint) { result in
            // Here we decode a Result<Data> value to either
            // produce an error or an array of models.
            handler(result.decode())
        }
    }
}

```

Just like we wanted to be able to sum up the total score for multiple **ScoreConvertible** values in the earlier example, let's say we want to have an easy way to perform multiple request in a synchronized fashion. For example, we might want to load the articles for multiple categories at once, and get a dictionary containing all of the combined results back.

You might be able to guess where this is going 😉. By making **Dictionary** conditionally conform to **Request** when it contains values that themselves conform to **Request**, we can again solve this problem in a very nice, recursive way.

Like we took a look at in “A deep dive into Grand Central Dispatch in Swift”, we’ll use GCD’s **DispatchGroup** to synchronize our group of requests and produce an aggregated result, like this:



```
extension Dictionary: Request where Value: Request {
    typealias Response = [Key : Value.Response]
    func perform(then handler: @escaping Handler) {
        var responses = [Key : Value.Response]()
        let group = DispatchGroup()
        for (key, request) in self {
            group.enter()
            request.perform { response in
                switch response {
                case .success(let value):
                    responses[key] = value
                    group.leave()
                case .error(let error):
                    handler(.error(error))
                }
            }
        }
        group.notify(queue: .main) {
            handler(.success(responses))
        }
    }
}

```

With the above extension in place, we can now easily create groups of requests simply by using a dictionary literal:


```
extension TopArticlesViewController {
    func loadArticles() {
        let requests: [Category : ArticleRequest] = [
            .news: ArticleRequest(dataLoader: dataLoader, category: .news),
            .sports: ArticleRequest(dataLoader: dataLoader, category: .sports)
        ]
        requests.perform { [weak self] result in
            switch result {
            case .success(let articles):
                for (category, articles) in articles {
                    self?.render(articles, in: category)
                }
            case .error(let error):
                self?.handle(error)
            }
        }
    }
}

```

We can now use a single, unified implementation for combining multiple requests, rather than having to write separate implementations for various combinations of requests and collections 👍.

