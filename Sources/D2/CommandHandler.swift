import SwiftDiscord
import Foundation

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

class CommandHandler: DiscordClientDelegate {
	private let chainSeparator: String
	private let pipeSeparator: String
	private let msgPrefix: String
	private let commandPattern: Regex
	private var currentIndex = 0
	
	private(set) var registry = CommandRegistry()
	let permissionManager = PermissionManager()
	
	init(withPrefix msgPrefix: String, chainSeparator: String = ";", pipeSeparator: String = "|") throws {
		self.msgPrefix = msgPrefix
		self.chainSeparator = chainSeparator
		self.pipeSeparator = pipeSeparator
		
		// The first group matches the command name,
		// the second matches the arguments (the rest of the message content)
		commandPattern = try Regex(from: "(\\S+)(?:\\s+([\\s\\S]*))?")
	}
	
	func client(_ client: DiscordClient, didCreateMessage message: DiscordMessage) {
		let msgIndex = currentIndex
		let fromBot = message.author.bot
		
		currentIndex += 1
		
		if !fromBot && message.content.starts(with: msgPrefix) {
			// Precedence: Chain < Pipe
			let slicedMessage = message.content[msgPrefix.index(msgPrefix.startIndex, offsetBy: msgPrefix.count)...]
			
			for rawPipeCommand in slicedMessage.components(separatedBy: chainSeparator) {
				var pipe = [PipeComponent]()
				var pipeConstructionSuccessful = true
				
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
								print("Invoking '\(name)'")
								
								let context = CommandContext(
									guild: client.guildForChannel(message.channelId),
									registry: registry,
									message: message
								)
								
								pipe.append(PipeComponent(command: command, context: context, args: args))
							} else {
								print("Rejected '\(name)' due to insufficient permissions")
								message.channel?.send("Sorry, you are not permitted to execute `\(name)`.")
								pipeConstructionSuccessful = false
								break
							}
						} else {
							print("Did not recognize command '\(name)'")
							message.channel?.send("Sorry, I do not know the command `\(name)`.")
							pipeConstructionSuccessful = false
							break
						}
					}
				}
				
				if pipeConstructionSuccessful {
					// Setup the pipe outputs
					if let pipeSink = pipe.last {
						pipeSink.output = DiscordChannelOutput(channel: message.channel)
					}
					
					for i in stride(from: pipe.count - 2, through: 0, by: -1) {
						let pipeNext = pipe[i + 1]
						pipe[i].output = PipeOutput(withSink: pipeNext.command, context: pipeNext.context, args: pipeNext.args, next: pipeNext.output)
					}
					
					// Execute the pipe
					if let pipeSource = pipe.first {
						pipeSource.command.invoke(withInput: nil, output: pipeSource.output!, context: pipeSource.context, args: pipeSource.args)
					}
				}
			}
		}
	}
	
	subscript(name: String) -> Command? {
		get { return registry[name] }
		set(newValue) { registry[name] = newValue }
	}
}
