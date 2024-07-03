import Dispatch
import Logging
import Utils

fileprivate let log = Logger(label: "D2MessageIO.TypingIndicator")

public actor TypingIndicator {
    private let channel: InteractiveTextChannel
    private var typingTask: Task<Void, any Error>? = nil

    public init(on channel: InteractiveTextChannel) {
        self.channel = channel
    }

    public func start() async {
        await stop()
        typingTask = Task {
            while !Task.isCancelled {
                do {
                    try await channel.triggerTyping()
                    try await Task.sleep(for: .seconds(9))
                } catch _ as CancellationError {
                    break
                } catch {
                    log.warning("Could not trigger typing indicator: \(error)")
                    break
                }
            }
        }
    }

    public func stop() async {
        typingTask?.cancel()
        _ = try? await typingTask?.value
        typingTask = nil
    }
}
