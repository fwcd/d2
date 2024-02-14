import D2Commands
import D2MessageIO
import Utils

fileprivate let countToNPattern = #/count\s+to\s+(?<n>\d+)/#

public struct CountToNHandler: MessageHandler {
    public func handle(message: Message, sink: any Sink) -> Bool {
        if let parsed = try? countToNPattern.firstMatch(in: message.content.lowercased()), let n = UInt(parsed.n), n <= 300, let channelId = message.channelId {
            sink.sendMessage(Message(content: "Here you go: \((1...n).map(String.init).joined(separator: ", "))"), to: channelId)
            return true
        }
        return false
    }
}
