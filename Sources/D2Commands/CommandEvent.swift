import SwiftDiscord

/** A "non-invocation" event on a command. */
public enum CommandEvent {
    case successfullySent(message: DiscordMessage)
    case subscriptionMessage(content: String, output: CommandOutput, context: CommandContext)
}
