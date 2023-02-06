/// A simple pub/sub facility for publishing log messages.
class LogOutput {
    private var consumers: [(String) -> Void] = []

    /// Registers a consumer for log messages.
    func register(_ consumer: @escaping (String) -> Void) {
        consumers.append(consumer)
    }

    /// Publishes a log message.
    func publish(_ message: String) {
        for consumer in consumers {
            consumer(message)
        }
    }
}
