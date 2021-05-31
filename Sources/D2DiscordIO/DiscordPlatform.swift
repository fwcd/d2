import Foundation
import Dispatch
import Logging
import D2MessageIO
import Discord

fileprivate let log = Logger(label: "D2DiscordIO.DiscordPlatform")

public struct DiscordPlatform: MessagePlatform {
    private let discordClient: DiscordClient
    private let delegate: MessageIOClientDelegate // Keep delegate alive since DiscordClient only holds a weak ref to it

    public var name: String { discordClientName }

    public init(with delegate: MessageDelegate, combinedClient: CombinedMessageClient, token: String) {
        log.info("Initializing Discord backend...")

        let queue = DispatchQueue(label: "Discord handle queue")
        self.delegate = MessageIOClientDelegate(inner: delegate, sinkClient: combinedClient)
        discordClient = DiscordClient(token: DiscordToken(stringLiteral: "Bot \(token)"), delegate: self.delegate, configuration: [
            .handleQueue(queue),
            .intents(.allIntents)
        ])

        combinedClient.register(client: DiscordMessageClient(client: discordClient))
    }

    public func start() {
        discordClient.connect()
    }
}
