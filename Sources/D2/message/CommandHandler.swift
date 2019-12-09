import SwiftDiscord
import D2Commands
import D2Permissions
import D2Utils

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

// The first group matches the command name,
// the second matches the arguments (the rest of the message content)
fileprivate let commandPattern = try! Regex(from: "(\\S+)(?:\\s+([\\s\\S]*))?")

/** Handles (possibly piped or chained) command invocations. */
class CommandHandler: MessageHandler {
	private let commandPrefix: String
    private let registry: CommandRegistry
    private let permissionManager: PermissionManager
	private let subscriptionManager: SubscriptionManager

	private let chainSeparator: Character
	private let pipeSeparator: Character
    
    private var currentIndex = 0
	private var maxPipeLengthForUsers: Int = 3
    private let msgParser = DiscordMessageParser()
    
    init(
        commandPrefix: String,
        registry: CommandRegistry,
        permissionManager: PermissionManager,
		subscriptionManager: SubscriptionManager,
        chainSeparator: Character = ";",
        pipeSeparator: Character = "|"
    ) {
		self.commandPrefix = commandPrefix
        self.registry = registry
        self.permissionManager = permissionManager
		self.subscriptionManager = subscriptionManager
		self.chainSeparator = chainSeparator
		self.pipeSeparator = pipeSeparator
    }

    func handle(message: DiscordMessage, from client: DiscordClient) -> Bool {
        guard message.content.starts(with: commandPrefix) && !(message.channel is DiscordDMChannel) else { return false }
        currentIndex += 1

        let context = CommandContext(
			guild: client.guildForChannel(message.channelId),
			registry: registry,
			message: message
		)
		let isBot = message.author.bot
		let slicedMessage = message.content[commandPrefix.index(commandPrefix.startIndex, offsetBy: commandPrefix.count)...]
		
		// Precedence: Chain < Pipe
		for rawPipeCommand in slicedMessage.splitPreservingQuotes(by: chainSeparator, omitQuotes: false, omitBackslashes: false) {
			var pipe = [PipeComponent]()
			var pipeConstructionSuccessful = true
			var userOnly = false
			
			// Construct the pipe
			for rawCommand in rawPipeCommand.splitPreservingQuotes(by: pipeSeparator, omitQuotes: true, omitBackslashes: true) {
				let trimmedCommand = rawCommand.trimmingCharacters(in: .whitespacesAndNewlines)
				
				if let groups = commandPattern.firstGroups(in: trimmedCommand) {
					print("Got command #\(currentIndex): \(groups)")
					let name = groups[1]
					let args = groups[2]
					
					if let command = registry[name] {
						let hasPermission = permissionManager.user(message.author, hasPermission: command.info.requiredPermissionLevel)
						if hasPermission {
							print("Appending '\(name)' to pipe")
							pipe.append(PipeComponent(command: command, context: context, args: args))
						} else {
							print("Rejected '\(name)' due to insufficient permissions")
							message.channel?.send("Sorry, you are not permitted to execute `\(name)`.")
							pipeConstructionSuccessful = false
							break
						}
						
						userOnly = userOnly || command.info.userOnly
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
					return true
				}
				
				// Setup the pipe outputs
				if let pipeSink = pipe.last {
					let sinkCommand = pipeSink.command
					pipeSink.output = DiscordOutput(client: client, defaultTextChannel: message.channel) { sentMessage, _ in
						if let sent = sentMessage {
							sinkCommand.onSuccessfullySent(message: sent)
						}
					}
				}
				
				for i in stride(from: pipe.count - 2, through: 0, by: -1) {
					let pipeNext = pipe[i + 1]
					pipe[i].output = PipeOutput(withSink: pipeNext.command, context: pipeNext.context, args: pipeNext.args, next: pipeNext.output)
				}
				
				guard let pipeSource = pipe.first else { continue }
				
				msgParser.parse(pipeSource.args, message: message) { input in
					// Execute the pipe (asynchronously)
					pipeSource.command.invoke(input: input, output: pipeSource.output!, context: pipeSource.context)
					
					// Add subscriptions
					let added = pipe
						.map { (it: PipeComponent) -> Command in it.command }
						.filter { cmd in cmd.info.subscribesToNextMessages && !self.subscriptionManager.hasSubscription(on: message.channelId, by: cmd) }
						.map { Subscription(channel: message.channelId, command: $0) }
					
					self.subscriptionManager.add(subscriptions: added)
				}
			}
		}
        
        return true
    }
}
