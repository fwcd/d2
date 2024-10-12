import D2MessageIO
import Logging

fileprivate let pattern = #/(?<prefix>.*\b\w+)-(?<subject>ass) (?<suffix>\w+\b.*)/#
fileprivate let log = Logger(label: "D2Handlers.Xkcd37Handler")

public struct Xkcd37Handler: MessageHandler {
    public func handle(message: Message, sink: any Sink) async -> Bool {
        if let parsed = try? pattern.firstMatch(in: message.content), let channelId = message.channelId {
            do {
                let response = [
                    "> \(parsed.prefix) \(parsed.subject)-\(parsed.suffix)",
                    "[FTFY](<https://xkcd.com/37>)",
                ].joined(separator: "\n")
                try await sink.sendMessage(Message(content: response), to: channelId)
                return true
            } catch {
                log.warning("Could not send xkcd 37 message: \(error)")
            }
        }
        return false
    }
}
