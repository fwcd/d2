import Dispatch

@discardableResult
public func all<T, E>(promises: [Promise<T, E>]) -> Promise<[T], E> where E: Error {
    Promise { then in
        let queue = DispatchQueue(label: "all(promises:)")
        var values = [T]()
        var remaining = Synchronized(wrappedValue: promises.count)
        var failed = false

        for promise in promises {
            promise.listen { result in
                queue.sync {
                    switch result {
                        case let .success(value):
                            values.append(value)
                            remaining.wrappedValue -= 1
                            if remaining.wrappedValue == 0 && !failed {
                                then(.success(values))
                            }
                        case let .failure(error):
                            if !failed {
                                failed = true
                                then(.failure(error))
                            }
                    }
                }
            }
        }
    }
}

/// Sequentially executes the promises.
@discardableResult
public func sequence<T, C, E>(promises: C) -> Promise<[T], E> where E: Error, C: Collection, C.Element == (() -> Promise<T, E>) {
    if let promise = promises.first {
        return promise().then { value in sequence(promises: promises.dropFirst()).map { [value] + $0 } }
    } else {
        return Promise(.success([]))
    }
}
