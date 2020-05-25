/// Represents an asynchronously computed value.
public class Promise<T, E> where E: Error {
    private var state: State
    private var listeners: [(Result<T, E>) -> Void] = []

    /// Creates a finished, succeeded promise.
    public convenience init(_ value: T) {
        self.init(.success(value))
    }

    /// Creates a finished promise.
    public init(_ value: Result<T, E>) {
        state = .finished(value)
    }

    /// Creates a promise from the given thenable and
    /// synchronously begins running it.
    public init(_ thenable: (@escaping (Result<T, E>) -> Void) -> Void) {
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
                switch $0 {
                    case .success(let value):
                        then(.success(transform(value)))
                    case .failure(let error):
                        then(.failure(error))
                }
            }
        }
    }
}