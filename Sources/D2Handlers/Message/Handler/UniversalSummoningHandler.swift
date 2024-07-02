import D2Commands
import D2MessageIO
import Utils
import Logging

private let theMagicWords = "D2, the chatbots of might, come forth in unison and answer my call."
private let log = Logger(label: "D2Handlers.UniversalSummoningHandler")

public struct UniversalSummoningHandler: MessageHandler {
    private let hostInfo: HostInfo

    public init(hostInfo: HostInfo) {
        self.hostInfo = hostInfo
    }

    public func handle(message: Message, sink: any Sink) async -> Bool {
        if message.content.trimmingCharacters(in: .whitespacesAndNewlines) == theMagicWords,
           let channelId = message.channelId {
            do {
                try await sink.sendMessage(Message(content: "Hey, \(hostInfo.instanceName ?? "unknown D2") here"), to: channelId)
                return true
            } catch {
                log.warning("Could not respond to being summoned: \(error)")
            }
        }
        return false
    }
}
