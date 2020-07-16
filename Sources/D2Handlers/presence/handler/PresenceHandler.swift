import D2MessageIO

/**
 * Anything that handles presence changes from
 * someone on Discord.
 */
public protocol PresenceHandler {
	mutating func handle(presenceUpdate presence: Presence, client: MessageClient)
}
