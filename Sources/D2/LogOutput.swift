import Dispatch

/// A simple pub/sub facility for publishing log messages.
actor LogOutput {
    private var isSilenced: Bool = false
    private var consumers: [(String) -> Void] = []

    /// Registers a consumer for log messages.
    func register(_ consumer: @escaping (String) -> Void) {
        consumers.append(consumer)
    }

    /// Publishes a log message.
    func publish(_ message: String) {
        guard !isSilenced else { return }
        isSilenced = true
        for consumer in consumers {
            consumer(message)
        }
        isSilenced = false
    }
}
