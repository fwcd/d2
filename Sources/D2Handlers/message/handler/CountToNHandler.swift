import D2Commands
import D2MessageIO
import Utils

fileprivate let countToNPattern = try! Regex(from: "count\\s+to\\s+(\\d+)")

public struct CountToNHandler: MessageHandler {
    public func handle(message: Message, sink: any Sink) -> Bool {
        if let parsed = countToNPattern.firstGroups(in: message.content.lowercased()), let n = UInt(parsed[1]), n <= 300, let channelId = message.channelId {
            sink.sendMessage(Message(content: "Here you go: \((1...n).map(String.init).joined(separator: ", "))"), to: channelId)
            return true
        }
        return false
    }
}
