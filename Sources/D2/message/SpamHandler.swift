import SwiftDiscord
import D2Commands

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
