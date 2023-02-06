import Dispatch

/// A simple pub/sub facility for publishing log messages.
class LogOutput {
    private static let dispatchQueue = DispatchQueue(label: "D2.LogOutput")

    private var consumers: [(String) -> Void] = []

    /// Registers a consumer for log messages.
    private func register(_ consumer: @escaping (String) -> Void) {
        consumers.append(consumer)
    }

    /// Publishes a log message.
    private func publish(_ message: String) {
        for consumer in consumers {
            consumer(message)
        }
    }

    /// Registers a consumer for log messages asynchronously.
    func registerAsync(_ consumer: @escaping (String) -> Void) {
        Self.dispatchQueue.async {
            self.consumers.append(consumer)
        }
    }

    /// Publishes a log message asynchronously.
    func publishAsync(_ message: String) {
        Self.dispatchQueue.async {
            self.publish(message)
        }
    }
}
