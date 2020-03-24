import SwiftDiscord
import Logging

fileprivate let log = Logger(label: "CommandContext")

public struct CommandContext {
	public let guild: DiscordGuild?
	public let registry: CommandRegistry
	public let message: DiscordMessage
	public let commandPrefix: String
	public let subscriptions: SubscriptionSet
	
	public var author: DiscordUser { return message.author }
	public var channel: DiscordTextChannel? { return message.channel }
	public var client: DiscordClient? { return message.client }
	
	public var isSubscribed: Bool { return (channel?.id).map { subscriptions.contains($0) } ?? false }
	
	public init(
		guild: DiscordGuild?,
		registry: CommandRegistry,
		message: DiscordMessage,
		commandPrefix: String,
		subscriptions: SubscriptionSet
	) {
		self.guild = guild
		self.registry = registry
		self.message = message
		self.commandPrefix = commandPrefix
		self.subscriptions = subscriptions
	}
	
	/** Subscribes to the current channel. */
	public func subscribeToChannel() {
		if let id = channel?.id {
			subscriptions.subscribe(to: id)
		} else {
			log.warning("Tried to subscribe to current channel without a channel being present.")
		}
	}
	
	/** Unsubscribes from the current channel. */
	public func unsubscribeFromChannel() {
		if let id = channel?.id {
			subscriptions.unsubscribe(from: id)
		} else {
			log.warning("Tried to unsubscribe from current channel without a channel being present.")
		}
	}
}
