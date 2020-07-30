import Dispatch

/**
 * Turns a list of thenables into a thenable of lists.
 */
public func collect<T>(prepending previous: [T] = [], thenables: [(@escaping (Result<T, Error>) -> Void) -> Void], then: @escaping (Result<[T], Error>) -> Void) {
    guard let nextThenable = thenables.first else {
        then(.success(previous))
        return
    }

    nextThenable {
        switch $0 {
            case .success(let value): collect(prepending: previous + [value], thenables: Array(thenables.dropFirst()), then: then)
            case .failure(let error): then(.failure(error))
        }
    }
}

/// Aggregates the result of multiple promises asynchronously.
@discardableResult
public func all<T, E>(promises: [Promise<T, E>]) -> Promise<[T], E> where E: Error {
    Promise { then in
        let queue = DispatchQueue(label: "all(promises:)")
        var values = [T]()
        var remaining = promises.count
        var failed = false

        for promise in promises {
            promise.listen { result in
                queue.sync {
                    switch result {
                        case let .success(value):
                            values.append(value)
                            remaining -= 1
                            if remaining == 0 && !failed {
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
