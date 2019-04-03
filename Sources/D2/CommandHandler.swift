import SwiftDiscord
import Foundation
import D2Utils
import D2Commands
import D2Permissions

/** A segment of an invocation pipe that transfers outputs from one command to another. */
fileprivate class PipeComponent {
	let command: Command
	let context: CommandContext
	let args: String
	var output: CommandOutput? = nil
	
	init(command: Command, context: CommandContext, args: String) {
		self.command = command
		self.context = context
		self.args = args
	}
}

/** A client delegate that dispatches commands. */
class CommandHandler: DiscordClientDelegate {
	private let chainSeparator: String
	private let pipeSeparator: String
	private let msgPrefix: String
	private let commandPattern: Regex
	private var currentIndex = 0
	private var maxPipeLengthForUsers: Int = 3
	
	private(set) var registry = CommandRegistry()
	private var subscribedCommands = [CommandSubscription]()
	let permissionManager = PermissionManager()
	
	init(withPrefix msgPrefix: String, chainSeparator: String = ";", pipeSeparator: String = "|") throws {
		self.msgPrefix = msgPrefix
		self.chainSeparator = chainSeparator
		self.pipeSeparator = pipeSeparator
		
		// The first group matches the command name,
		// the second matches the arguments (the rest of the message content)
		commandPattern = try Regex(from: "(\\S+)(?:\\s+([\\s\\S]*))?")
	}
	
	func client(_ client: DiscordClient, didConnect connected: Bool) {
		client.setPresence(DiscordPresenceUpdate(game: DiscordActivity(name: "%help", type: .listening)))
	}
	
	func client(_ client: DiscordClient, didCreateMessage message: DiscordMessage) {
		let msgIndex = currentIndex
		currentIndex += 1
		
		if message.content.starts(with: msgPrefix) {
			handleInvocationMessage(client: client, message: message, msgIndex: msgIndex)
		} else if !subscribedCommands.isEmpty {
			handleSubscriptionMessage(client: client, message: message)
		}
	}
	
	private func handleInvocationMessage(client: DiscordClient, message: DiscordMessage, msgIndex: Int) {
		let context = CommandContext(
			guild: client.guildForChannel(message.channelId),
			registry: registry,
			message: message
		)
		let isBot = message.author.bot
		
		// Precedence: Chain < Pipe
		let slicedMessage = message.content[msgPrefix.index(msgPrefix.startIndex, offsetBy: msgPrefix.count)...]
		
		for rawPipeCommand in slicedMessage.components(separatedBy: chainSeparator) {
			var pipe = [PipeComponent]()
			var pipeConstructionSuccessful = true
			var userOnly = false
			
			// Construct the pipe
			for rawCommand in rawPipeCommand.components(separatedBy: pipeSeparator) {
				let trimmedCommand = rawCommand.trimmingCharacters(in: .whitespacesAndNewlines)
				
				if let groups = commandPattern.firstGroups(in: trimmedCommand) {
					print("Got command #\(msgIndex): \(groups)")
					let name = groups[1]
					let args = groups[2]
					
					if let command = registry[name] {
						let hasPermission = permissionManager.user(message.author, hasPermission: command.requiredPermissionLevel)
						if hasPermission {
							print("Appending '\(name)' to pipe")
							pipe.append(PipeComponent(command: command, context: context, args: args))
						} else {
							print("Rejected '\(name)' due to insufficient permissions")
							message.channel?.send("Sorry, you are not permitted to execute `\(name)`.")
							pipeConstructionSuccessful = false
							break
						}
						
						userOnly = userOnly || command.userOnly
					} else {
						print("Did not recognize command '\(name)'")
						if !isBot {
							message.channel?.send("Sorry, I do not know the command `\(name)`.")
						}
						pipeConstructionSuccessful = false
						break
					}
				}
			}
			
			if pipeConstructionSuccessful && !(userOnly && isBot) {
				guard (permissionManager[message.author].rawValue >= PermissionLevel.admin.rawValue) || (pipe.count <= maxPipeLengthForUsers) else {
					message.channel?.send("Your pipe is too long.")
					return
				}
				
				// Setup the pipe outputs
				if let pipeSink = pipe.last {
					pipeSink.output = DiscordOutput(client: client, defaultTextChannel: message.channel)
				}
				
				for i in stride(from: pipe.count - 2, through: 0, by: -1) {
					let pipeNext = pipe[i + 1]
					pipe[i].output = PipeOutput(withSink: pipeNext.command, context: pipeNext.context, args: pipeNext.args, next: pipeNext.output)
				}
				
				// Execute the pipe
				if let pipeSource = pipe.first {
					pipeSource.command.invoke(withArgs: pipeSource.args, input: nil, output: pipeSource.output!, context: pipeSource.context)
				}
				
				// Add subscriptions
				let added = pipe
					.map { $0.command }
					.filter { cmd in cmd.subscribesToNextMessages && !subscribedCommands.contains { cmd === $0.command } }
					.map { CommandSubscription(channel: message.channelId, command: $0) }
				subscribedCommands += added
			}
		}
	}
	
	private func handleSubscriptionMessage(client: DiscordClient, message: DiscordMessage) {
		let output = DiscordOutput(client: client, defaultTextChannel: message.channel)
		let context = CommandContext(
			guild: client.guildForChannel(message.channelId),
			registry: registry,
			message: message
		)
		let isBot = message.author.bot
		
		for (i, subscription) in subscribedCommands.enumerated().reversed() {
			if (subscription.channel == message.channelId) && !(subscription.command.userOnly && isBot) {
				let response = subscription.command.onSubscriptionMessage(withContent: message.content, output: output, context: context)
				if response == .cancelSubscription {
					subscribedCommands.remove(at: i)
				}
			}
		}
	}
	
	subscript(name: String) -> Command? {
		get { return registry[name] }
		set(newValue) { registry[name] = newValue }
	}
}
