import SwiftDiscord
import D2Commands

/**
 * Automatically detects "mention-spammers" and assigns
 * them a spammer role (which can be configured using a command).
 */
struct SpamHandler: MessageHandler {
    private let config: SpamConfiguration
    
    init(config: SpamConfiguration) {
        self.config = config
    }

    func handle(message: DiscordMessage, from client: DiscordClient) -> Bool {
        // TODO
        return false
    }
}
