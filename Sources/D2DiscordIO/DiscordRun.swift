import Foundation
import Dispatch
import Logging
import D2MessageIO
import SwiftDiscord

fileprivate let log = Logger(label: "D2DiscordIO.DiscordRun")

/** Runs the Discord-based backend. */
public func runDiscordIO(with delegate: MessageDelegate, combinedClient: CombinedMessageClient, token: String, disposables: inout [Any]) {
    let delegate = MessageIOClientDelegate(inner: delegate, sinkClient: combinedClient)
    let queue = DispatchQueue(label: "Discord handle queue")
    let discordClient = DiscordClient(token: DiscordToken(stringLiteral: "Bot \(token)"), delegate: delegate, configuration: [.handleQueue(queue)])

    combinedClient.register(client: DiscordMessageClient(client: discordClient))
    
    log.info("Connecting client")
    discordClient.connect()
    
    // Keep delegate alive since DiscordClient only holds a weak reference to it
    disposables.append(delegate)
}
