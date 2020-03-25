import Foundation
import Dispatch
import Logging
import D2MessageIO
import SwiftDiscord

fileprivate let log = Logger(label: "DiscordRun")

/** Runs the Discord-based backend. */
public func runDiscordIOBackend(with delegate: MessageDelegate, token: String, disposables: inout [Any]) {
    let delegate = MessageIOClientDelegate(inner: delegate) // Needs to be declared separately since DiscordClient only holds a weak reference to it
    let queue = DispatchQueue(label: "Discord handle queue")
    let discordClient = DiscordClient(token: DiscordToken(stringLiteral: "Bot \(token)"), delegate: delegate, configuration: [.handleQueue(queue)])
    
    log.info("Connecting client")
    discordClient.connect()

    // Ensure that the client is kept alive for the entire application's lifetime
    disposables.append(discordClient)
}
