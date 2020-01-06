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
