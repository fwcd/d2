/// Represents an asynchronously computed value.
public class Promise<T, E> where E: Error {
    private var state: State
    private var listeners: [(Result<T, E>) -> Void] = []

    /// Creates a finished, succeeded promise.
    public convenience init(_ value: T) {
        self.init(.success(value))
    }

    /// Creates a finished promise.
    public required init(_ value: Result<T, E>) {
        state = .finished(value)
    }

    /// Creates a promise from the given thenable and
    /// synchronously begins running it.
    public required init(_ thenable: (@escaping (Result<T, E>) -> Void) -> Void) {
        state = .pending
        thenable {
            self.state = .finished($0)
            for listener in self.listeners {
                listener($0)
            }
            self.listeners = []
        }
    }

    private enum State {
        case pending
        case finished(Result<T, E>)
    }

    /// Listens for the result. Only fires once.
    public func listen(_ listener: @escaping (Result<T, E>) -> Void) {
        if case let .finished(result) = state {
            listener(result)
        } else {
            listeners.append(listener)
        }
    }

    /// Listens for the result. Only fires once. Returns the promise.
    public func peekListen(_ listener: @escaping (Result<T, E>) -> Void) -> Self {
        listen(listener)
        return self
    }

    /// Chains another asynchronous computation after this one.
    public func then<U>(_ next: @escaping (T) -> Promise<U, E>) -> Promise<U, E> {
        Promise<U, E> { then in
            self.listen {
                switch $0 {
                    case .success(let value):
                        next(value).listen(then)
                    case .failure(let error):
                        then(.failure(error))
                }
            }
        }
    }

    /// Chains another synchronous computation after this one.
    public func map<U>(_ transform: @escaping (T) -> U) -> Promise<U, E> {
        Promise<U, E> { then in
            self.listen {
                then($0.map(transform))
            }
        }
    }

    /// Ignores the return value of the promise.
    public func void() -> Promise<Void, E> {
        map { _ in }
    }

    /// Convenience method for discarding the promise in a method chain.
    /// Making this explicit helps preventing accidental race conditions.
    public func forget() {}
}

extension Promise where E == Error {
    /// Creates a (finished) promise catching the given block.
    public static func catching(_ block: () throws -> T) -> Self {
        Self(Result(catching: block))
    }

    /// Creates a promise catching the given block returning another promise.
    public static func catchingThen(_ block: () throws -> Promise<T, Error>) -> Promise<T, Error> {
        Promise<Promise<T, Error>, Error>.catching(block).then { $0 }
    }
}
