import Dispatch
import Logging
import Utils

fileprivate let log = Logger(label: "D2MessageIO.TypingIndicator")

public class TypingIndicator {
    private let channel: InteractiveTextChannel
    private let queue = DispatchQueue(label: "TypingIndicator", qos: .background)
    @Synchronized private var running: Bool = false

    public init(on channel: InteractiveTextChannel) {
        self.channel = channel
    }

    public func startAsync() {
        running = true
        repeatedlyTriggerTypingInBackground()
    }

    private func repeatedlyTriggerTypingInBackground() {
        guard running else { return }
        Task {
            _ = try? await channel.triggerTyping()
        }

        let timeout = DispatchTime.now() + .seconds(9)
        queue.asyncAfter(deadline: timeout) {
            self.repeatedlyTriggerTypingInBackground()
        }
    }

    public func stop() {
        running = false
    }
}
