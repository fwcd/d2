import SwiftDiscord

/**
 * Represents anything that receives/handles incoming Discord messages.
 *
 * Handlers are usually arranged in a "chain of responsibility" where
 * the first successful handler stops propagation of the message.
 */
protocol MessageHandler {
    /** Receives the message and returns whether it was handled (successfully). */
    mutating func handle(message: DiscordMessage, from client: DiscordClient) -> Bool
}
