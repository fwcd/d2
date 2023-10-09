import Foundation
import Dispatch
import Logging
import NIO
import D2MessageIO
import Discord

fileprivate let log = Logger(label: "D2DiscordIO.DiscordPlatform")

public struct DiscordPlatform: MessagePlatform {
    private let manager: DiscordClientManager

    public var name: String { discordClientName }

    public init(
        with delegate: any MessageDelegate,
        combinedClient: CombinedMessageIOSink,
        eventLoopGroup: any EventLoopGroup,
        token: String
    ) {
        log.info("Initializing Discord backend...")
        manager = DiscordClientManager(
            inner: delegate,
            combinedClient: combinedClient,
            eventLoopGroup: eventLoopGroup,
            token: token
        )
    }

    public func start() {
        manager.connect()
    }
}
