import Foundation
import Logging
import D2MessageIO
import SwiftDiscord

fileprivate let log = Logger(label: "DiscordRun")

/** Runs the Discord-based backend and blocks the thread. */
public func runDiscordIOBackend(with delegate: MessageDelegate, token: String) {
    let delegate = MessageIOClientDelegate(inner: delegate) // Needs to be declared separately since DiscordClient only holds a weak reference to it
    let discordClient = DiscordClient(token: DiscordToken(stringLiteral: "Bot \(token)"), delegate: delegate, configuration: [])
    
    log.info("Connecting client")
    discordClient.connect()
    RunLoop.current.run()
}
