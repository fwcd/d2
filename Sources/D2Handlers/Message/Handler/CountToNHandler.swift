import D2Commands
import D2MessageIO
import Logging
import Utils

nonisolated(unsafe) private let countToNPattern = #/count\s+to\s+(?<n>\d+)/#
fileprivate let log = Logger(label: "D2Handlers.CountToNHandler")

public struct CountToNHandler: MessageHandler {
    public func handle(message: Message, sink: any Sink) async -> Bool {
        if let parsed = try? countToNPattern.firstMatch(in: message.content.lowercased()), let n = UInt(parsed.n), n <= 300, let channelId = message.channelId {
            do {
                try await sink.sendMessage(Message(content: "Here you go: \((1...n).map(String.init).joined(separator: ", "))"), to: channelId)
                return true
            } catch {
                log.warning("Could not send count-to-\(n) message: \(error)")
            }
        }
        return false
    }
}
