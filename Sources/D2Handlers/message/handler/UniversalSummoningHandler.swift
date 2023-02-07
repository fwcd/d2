import D2Commands
import D2MessageIO
import Utils

private let theMagicWords = "D2, the chatbots of might, come forth in unison and answer my call."

public struct UniversalSummoningHandler: MessageHandler {
    private let hostInfo: HostInfo

    public init(hostInfo: HostInfo) {
        self.hostInfo = hostInfo
    }

    public func handle(message: Message, from client: any MessageClient) -> Bool {
        if message.content.trimmingCharacters(in: .whitespacesAndNewlines) == theMagicWords,
           let channelId = message.channelId {
            client.sendMessage(Message(content: "Hey, \(hostInfo.instanceName ?? "unknown D2") here"), to: channelId)
            return true
        }
        return false
    }
}
