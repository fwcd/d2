import Dispatch
import Foundation
import Logging
import D2MessageIO
import D2Commands
import D2Permissions
import D2Utils

fileprivate let log = Logger(label: "CommandHandler")

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
    private let msgParser = MessageParser()
	
	private let operationQueue: OperationQueue
    
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
		
		operationQueue = OperationQueue()
		operationQueue.name = "CommandHandler queue"
		operationQueue.maxConcurrentOperationCount = 4
    }

    func handle(message: Message, from client: MessageClient) -> Bool {
        guard message.content.starts(with: commandPrefix) && !(message.channel is DiscordDMChannel) else { return false }
		guard operationQueue.operationCount < operationQueue.maxConcurrentOperationCount else {
			message.channel?.send("Too many concurrent command invocations, please wait for one to finish!")
			log.notice("Command invocation not processed, since max concurrent operation count was reached")
			return false
		}

        currentIndex += 1

  
		let slicedMessage = message.content[commandPrefix.index(commandPrefix.startIndex, offsetBy: commandPrefix.count)...]
		
		// Precedence: Chain < Pipe
		for rawPipeCommand in slicedMessage.splitPreservingQuotes(by: chainSeparator, omitQuotes: false, omitBackslashes: false) {
			if let pipe = constructPipe(rawPipeCommand: rawPipeCommand, message: message, client: client) {
				guard (permissionManager[message.author].rawValue >= PermissionLevel.admin.rawValue) || (pipe.count <= maxPipeLengthForUsers) else {
					message.channel?.send("Your pipe is too long.")
					log.notice("Too long pipe")
					return true
				}
				
				// Setup the pipe outputs
				if let pipeSink = pipe.last {
					let sinkCommand = pipeSink.command
					pipeSink.output = MessageIOOutput(client: client, defaultTextChannelId: channelId) { sentMessage, _ in
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
				
				operationQueue.addOperation {
					self.msgParser.parse(pipeSource.args, message: message) { input in
						// Execute the pipe
						pipeSource.command.invoke(input: input, output: pipeSource.output!, context: pipeSource.context)
					}
				}
			}
		}
        
        return true
    }
	
	private func constructPipe(rawPipeCommand: String, message: DiscordMessage, client: DiscordClient) -> [PipeComponent]? {
		let isBot = message.author.bot
		var pipe = [PipeComponent]()
		var userOnly = false
		
		// Construct the pipe
		for rawCommand in rawPipeCommand.splitPreservingQuotes(by: pipeSeparator, omitQuotes: true, omitBackslashes: true) {
			let trimmedCommand = rawCommand.trimmingCharacters(in: .whitespacesAndNewlines)
			
			if let groups = commandPattern.firstGroups(in: trimmedCommand) {
				log.info("Got command #\(currentIndex): \(groups)")
				let name = groups[1]
				let args = groups[2]

				if let command = registry[name] {
					let hasPermission = permissionManager.user(message.author, hasPermission: command.info.requiredPermissionLevel)
					if hasPermission {
						log.debug("Appending '\(name)' to pipe")

						let context = CommandContext(
							guild: client.guildForChannel(message.channelId),
							registry: registry,
							message: message,
							commandPrefix: commandPrefix,
							subscriptions: subscriptionManager.createIfNotExistsAndGetSubscriptionSet(for: name)
						)				

						pipe.append(PipeComponent(command: command, context: context, args: args))
					} else {
						log.notice("Rejected '\(name)' due to insufficient permissions")
						message.channel?.send("Sorry, you are not permitted to execute `\(name)`.")
						return nil
					}
					
					userOnly = userOnly || command.info.userOnly
				} else {
					log.notice("Did not recognize command '\(name)'")
					if !isBot {
						message.channel?.send("Sorry, I do not know the command `\(name)`.")
					}
					return nil
				}
			}
		}
		
		guard !(userOnly && isBot) else { return nil }
		return pipe
	}
}
