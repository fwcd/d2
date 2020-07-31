import Dispatch

/// A basic synchronization primitive.
public struct Lock {
    private let semaphore = DispatchSemaphore(value: 1)

    /// Acquires the lock for the duration of the given block.
    /// May block the current thread.
    public func lock(_ action: () throws -> Void) rethrows {
        semaphore.wait()
        try action()
        semaphore.signal()
    }
}
