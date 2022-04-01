import Dispatch
import Foundation
import Logging
import D2MessageIO
import D2Commands
import D2Permissions
import Utils

fileprivate let log = Logger(label: "D2Handlers.CommandHandler")

/// A segment of an invocation pipe that transfers outputs from one command to another.
fileprivate class PipeComponent {
    let name: String
    let command: Command
    let context: CommandContext
    let args: String
    var output: (any CommandOutput)? = nil

    init(name: String, command: Command, context: CommandContext, args: String) {
        self.name = name
        self.command = command
        self.context = context
        self.args = args
    }
}

fileprivate struct RunnablePipe: Runnable {
    let pipeSource: PipeComponent
    let input: RichValue

    func run() {
        pipeSource.command.invoke(with: input, output: pipeSource.output!, context: pipeSource.context)
    }
}

// The first group matches the command name,
// the second matches the arguments (the rest of the message content)
fileprivate let commandPattern = try! Regex(from: "(\\S+)(?:\\s+([\\s\\S]*))?")

/// Handles (possibly piped or chained) command invocations.
public class CommandHandler: MessageHandler {
    private let commandPrefix: String
    private let registry: CommandRegistry
    private let permissionManager: PermissionManager
    private let subscriptionManager: SubscriptionManager

    private let msgParser = MessageParser()
    private let chainSeparator: Character
    private let pipeSeparator: Character

    private let maxPipeLengthForUsers: Int
    private let maxConcurrentlyRunningCommands: Int
    private let unconditionallyAllowedCommands: Set<String>

    @Synchronized private var currentlyRunningCommands = 0
    @Synchronized @Box private var mostRecentPipeRunner: (Runnable, PermissionLevel)?

    private let commandQueue = DispatchQueue(label: "CommandHandler", attributes: [.concurrent])

    public init(
        commandPrefix: String,
        registry: CommandRegistry,
        permissionManager: PermissionManager,
        subscriptionManager: SubscriptionManager,
        mostRecentPipeRunner: Synchronized<Box<(Runnable, PermissionLevel)?>>,
        maxPipeLengthForUsers: Int = 7,
        maxConcurrentlyRunningCommands: Int = 4,
        unconditionallyAllowedCommands: Set<String> = ["quit"],
        chainSeparator: Character = ";",
        pipeSeparator: Character = "|"
    ) {
        self.commandPrefix = commandPrefix
        self.registry = registry
        self.permissionManager = permissionManager
        self.subscriptionManager = subscriptionManager
        self._mostRecentPipeRunner = mostRecentPipeRunner
        self.maxPipeLengthForUsers = maxPipeLengthForUsers
        self.maxConcurrentlyRunningCommands = maxConcurrentlyRunningCommands
        self.unconditionallyAllowedCommands = unconditionallyAllowedCommands
        self.chainSeparator = chainSeparator
        self.pipeSeparator = pipeSeparator
    }

    public func handle(message: Message, from client: MessageClient) -> Bool {
        guard message.content.starts(with: commandPrefix),
            !message.dm || (message.author.map { permissionManager.user($0, hasPermission: .vip) } ?? false),
            let channelId = message.channelId else { return false }
        guard let author = message.author else {
            log.warning("Command invocation message has no author and is thus not handled by CommandHandler. This is probably a bug.")
            return false
        }
        guard currentlyRunningCommands < maxConcurrentlyRunningCommands || unconditionallyAllowedCommands.contains(where: { message.content.starts(with: "\(commandPrefix)\($0)") }) else {
            client.sendMessage("Too many concurrent command invocations, please wait for one to finish!", to: channelId)
            log.notice("Command invocation not processed, since max concurrent operation count was reached")
            return false
        }

        let slicedMessage = message.content[commandPrefix.index(commandPrefix.startIndex, offsetBy: commandPrefix.count)...]

        // Precedence: Chain < Pipe
        for rawPipeCommand in slicedMessage.splitPreservingQuotes(by: chainSeparator, omitQuotes: false, omitBackslashes: false) {
            if let pipe = constructPipe(rawPipeCommand: rawPipeCommand, message: message, client: client) {
                guard permissionManager.user(author, hasPermission: .admin) || (pipe.count <= maxPipeLengthForUsers) else {
                    client.sendMessage("Your pipe is too long.", to: channelId)
                    log.notice("Too long pipe")
                    return true
                }

                // Ensure that all commands are available on the current platform
                let platform = client.name
                for component in pipe {
                    if let availability = component.command.info.platformAvailability {
                        guard availability.contains(platform) else {
                            client.sendMessage("Sorry, the command `\(component.name)` is unavailable on your platform (`\(platform)`). It is supported on: \(availability.map { "`\($0)`" }.joined(separator: ", "))", to: channelId)
                            log.notice("\(component.name) is unavailable on \(platform)")
                            return true
                        }
                    }
                }

                // Setup the pipe outputs
                if let pipeSink = pipe.last {
                    let sinkCommand = pipeSink.command
                    pipeSink.output = MessageIOOutput(context: pipeSink.context) { sentMessages in
                        for sent in sentMessages {
                            sinkCommand.onSuccessfullySent(context: CommandContext(
                                client: client,
                                registry: self.registry,
                                message: sent,
                                commandPrefix: self.commandPrefix,
                                subscriptions: pipeSink.context.subscriptions
                            ))
                        }
                    }
                }

                for i in stride(from: pipe.count - 2, through: 0, by: -1) {
                    let pipeNext = pipe[i + 1]
                    pipe[i].output = PipeOutput(withSink: pipeNext.command, context: pipeNext.context, args: pipeNext.args, next: pipeNext.output)
                }

                guard let pipeSource = pipe.first else { continue }

                commandQueue.async {
                    self.currentlyRunningCommands += 1
                    log.debug("Currently running \(self.currentlyRunningCommands) commands")

                    self.msgParser.parse(pipeSource.args, message: message, clientName: client.name, guild: pipeSource.context.guild).listenOrLogError { input in
                        // Execute the pipe
                        let runner = RunnablePipe(pipeSource: pipeSource, input: input)
                        runner.run()

                        // Store the pipe for potential re-execution
                        if pipe.allSatisfy({ $0.command.info.shouldOverwriteMostRecentPipeRunner }), let minPermissionLevel = pipe.map(\.command.info.requiredPermissionLevel).max() {
                            self.mostRecentPipeRunner = (runner, minPermissionLevel)
                        }

                        self.currentlyRunningCommands -= 1
                    }
                }
            }
        }

        return true
    }

    private func constructPipe(rawPipeCommand: String, message: Message, client: MessageClient) -> [PipeComponent]? {
        guard let channelId = message.channelId, let author = message.author else { return nil }
        let isBot = author.bot
        var pipe = [PipeComponent]()
        var userOnly = false

        // Construct the pipe
        for rawCommand in rawPipeCommand.splitPreservingQuotes(by: pipeSeparator, omitQuotes: false, omitBackslashes: true) {
            let trimmedCommand = rawCommand.trimmingCharacters(in: .whitespacesAndNewlines)

            if let groups = commandPattern.firstGroups(in: trimmedCommand) {
                log.info("\(author.displayTag) invoked '\(groups.dropFirst().joined(separator: " "))'")
                let name = groups[1]
                let args = groups[2]

                if let command = registry[name] {
                    let hasPermission = permissionManager.user(author, hasPermission: command.info.requiredPermissionLevel, usingSimulated: command.info.usesSimulatedPermissionLevel)
                    if hasPermission {
                        log.debug("Appending '\(name)' to pipe")

                        let context = CommandContext(
                            client: client,
                            registry: registry,
                            message: message,
                            commandPrefix: commandPrefix,
                            subscriptions: subscriptionManager.createIfNotExistsAndGetSubscriptionSet(for: name)
                        )

                        pipe.append(PipeComponent(name: name, command: command, context: context, args: args))
                    } else {
                        log.notice("Rejected '\(name)' by \(author.displayTag) due to insufficient permissions")
                        client.sendMessage("Sorry, you are not permitted to execute `\(name)`.", to: channelId)
                        return nil
                    }

                    userOnly = userOnly || command.info.userOnly
                } else {
                    log.notice("Did not recognize command '\(name)'")
                    if !isBot {
                        let alternative = registry.map { $0.0 }.min(by: ascendingComparator { $0.levenshteinDistance(to: name) })
                        client.sendMessage("Sorry, I do not know the command `\(name)`.\(alternative.map { " Did you mean `\($0)`?" } ?? "")", to: channelId)
                    }
                    return nil
                }
            }
        }

        guard !(userOnly && isBot) else { return nil }
        return pipe
    }
}
