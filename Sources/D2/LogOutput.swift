import Dispatch

/// A simple pub/sub facility for publishing log messages.
class LogOutput {
    private static let dispatchQueue = DispatchQueue(label: "D2.LogOutput")

    private var isSilenced: Bool = false
    private var consumers: [(String) -> Void] = []

    /// Registers a consumer for log messages.
    private func register(_ consumer: @escaping (String) -> Void) {
        consumers.append(consumer)
    }

    /// Publishes a log message.
    private func publish(_ message: String) {
        isSilenced = true
        for consumer in consumers {
            consumer(message)
        }
        isSilenced = false
    }

    /// Registers a consumer for log messages asynchronously.
    func registerAsync(_ consumer: @escaping (String) -> Void) {
        Self.dispatchQueue.async {
            self.consumers.append(consumer)
        }
    }

    /// Publishes a log message asynchronously.
    func publishAsync(_ message: String) {
        guard !isSilenced else { return }
        Self.dispatchQueue.async {
            self.publish(message)
        }
    }
}
