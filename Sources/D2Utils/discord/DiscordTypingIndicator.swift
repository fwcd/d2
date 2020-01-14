import SwiftDiscord
import Dispatch
import Logging

fileprivate let log = Logger(label: "DiscordTypingIndicator")

public class DiscordTypingIndicator {
    private let channel: DiscordTextChannel
    private let queue = DispatchQueue(label: "DiscordTypingIndicator", qos: .background)
    @Synchronized private var running: Bool = false

    public init(on channel: DiscordTextChannel) {
        self.channel = channel
    }
    
    public func startAsync() {
        running = true
        repeatedlyTriggerTypingInBackground()
    }
    
    private func repeatedlyTriggerTypingInBackground() {
        guard running else { return }
        channel.triggerTyping()
        
        let timeout = DispatchTime.now() + .seconds(9)
        queue.asyncAfter(deadline: timeout) {
            self.repeatedlyTriggerTypingInBackground()
        }
    }

    public func stop() {
        running = false
    }
}
