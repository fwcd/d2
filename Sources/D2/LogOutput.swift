import Dispatch

/// A simple pub/sub facility for publishing log messages.
actor LogOutput {
    private var isSilenced: Bool = false
    private var consumers: [@Sendable (String) async -> Void] = []

    /// Registers a consumer for log messages.
    func register(_ consumer: @Sendable @escaping (String) async -> Void) {
        consumers.append(consumer)
    }

    /// Publishes a log message.
    func publish(_ message: String) async {
        guard !isSilenced else { return }
        isSilenced = true
        await withDiscardingTaskGroup { group in
            for consumer in consumers {
                group.addTask {
                    await consumer(message)
                }
            }
        }
        isSilenced = false
    }
}
