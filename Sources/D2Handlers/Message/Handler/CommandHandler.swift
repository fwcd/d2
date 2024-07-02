import Dispatch
import Foundation
import Logging
import D2MessageIO
import D2Commands
import D2Permissions
import NIO
import Utils

fileprivate let log = Logger(label: "D2Handlers.CommandHandler")

/// A segment of an invocation pipe that transfers outputs from one command to another.
fileprivate class PipeComponent {
    let name: String
    let command: any Command
    let context: CommandContext
    let args: String
    var output: (any CommandOutput)? = nil

    init(name: String, command: any Command, context: CommandContext, args: String) {
        self.name = name
        self.command = command
        self.context = context
        self.args = args
    }
}

fileprivate struct RunnablePipe: AsyncRunnable {
    let pipeSource: PipeComponent
    let input: RichValue

    func run() async {
        await pipeSource.command.invoke(with: input, output: pipeSource.output!, context: pipeSource.context)
    }
}

// The first group matches the command name,
// the second matches the iteration count and
// the third the arguments (the rest of the message content)
fileprivate let commandPattern = #/(?<name>\w+)(?:\^(?<iterations>\d+))?(?:\s+(?<args>[\s\S]*))?/#

/// Handles (possibly piped or chained) command invocations.
public class CommandHandler: MessageHandler {
    private let commandPrefix: String
    private let hostInfo: HostInfo
    private let registry: CommandRegistry
    private let permissionManager: PermissionManager
    private let subscriptionManager: SubscriptionManager
    private let eventLoopGroup: any EventLoopGroup

    private let msgParser = MessageParser()
    private let chainSeparator: Character
    private let pipeSeparator: Character

    private let maxPipeLengthForUsers: Int
    private let maxConcurrentlyRunningCommands: Int
    private let unconditionallyAllowedCommands: Set<String>

    @Synchronized private var currentlyRunningCommands = 0
    @Synchronized @Box private var mostRecentPipeRunner: (any AsyncRunnable, PermissionLevel)?

    public init(
        commandPrefix: String,
        hostInfo: HostInfo,
        registry: CommandRegistry,
        permissionManager: PermissionManager,
        subscriptionManager: SubscriptionManager,
        eventLoopGroup: any EventLoopGroup,
        mostRecentPipeRunner: Synchronized<Box<(any AsyncRunnable, PermissionLevel)?>>,
        maxPipeLengthForUsers: Int = 7,
        maxConcurrentlyRunningCommands: Int = 4,
        unconditionallyAllowedCommands: Set<String> = ["quit"],
        chainSeparator: Character = ";",
        pipeSeparator: Character = "|"
    ) {
        self.commandPrefix = commandPrefix
        self.hostInfo = hostInfo
        self.registry = registry
        self.permissionManager = permissionManager
        self.subscriptionManager = subscriptionManager
        self.eventLoopGroup = eventLoopGroup
        self._mostRecentPipeRunner = mostRecentPipeRunner
        self.maxPipeLengthForUsers = maxPipeLengthForUsers
        self.maxConcurrentlyRunningCommands = maxConcurrentlyRunningCommands
        self.unconditionallyAllowedCommands = unconditionallyAllowedCommands
        self.chainSeparator = chainSeparator
        self.pipeSeparator = pipeSeparator
    }

    public func handle(message: Message, sink: any Sink) async -> Bool {
        guard message.content.starts(with: commandPrefix),
            !message.dm || (message.author.map { permissionManager.user($0, hasPermission: .vip) } ?? false),
            let channelId = message.channelId else { return false }
        guard let author = message.author else {
            log.warning("Command invocation message has no author and is thus not handled by CommandHandler. This is probably a bug.")
            return false
        }
        guard currentlyRunningCommands < maxConcurrentlyRunningCommands || unconditionallyAllowedCommands.contains(where: { message.content.starts(with: "\(commandPrefix)\($0)") }) else {
            sink.sendMessage("Too many concurrent command invocations, please wait for one to finish!", to: channelId)
            log.notice("Command invocation not processed, since max concurrent operation count was reached")
            return false
        }

        let slicedMessage = message.content[commandPrefix.index(commandPrefix.startIndex, offsetBy: commandPrefix.count)...]

        // Precedence: Chain < Pipe
        for rawPipeCommand in slicedMessage.splitPreservingQuotes(by: chainSeparator, omitQuotes: false, omitBackslashes: false) {
            if let pipe = constructPipe(rawPipeCommand: rawPipeCommand, message: message, sink: sink) {
                guard permissionManager.user(author, hasPermission: .admin) || (pipe.count <= maxPipeLengthForUsers) else {
                    sink.sendMessage("Your pipe is too long.", to: channelId)
                    log.notice("Too long pipe")
                    return true
                }

                // Ensure that all commands are available on the current platform
                let platform = sink.name
                for component in pipe {
                    if let availability = component.command.info.platformAvailability {
                        guard availability.contains(platform) else {
                            sink.sendMessage("Sorry, the command `\(component.name)` is unavailable on your platform (`\(platform)`). It is supported on: \(availability.map { "`\($0)`" }.joined(separator: ", "))", to: channelId)
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
                                sink: sink,
                                registry: self.registry,
                                message: sent,
                                commandPrefix: self.commandPrefix,
                                hostInfo: self.hostInfo,
                                subscriptions: pipeSink.context.subscriptions,
                                eventLoopGroup: self.eventLoopGroup
                            ))
                        }
                    }
                }

                for i in stride(from: pipe.count - 2, through: 0, by: -1) {
                    let pipeNext = pipe[i + 1]
                    pipe[i].output = PipeOutput(withSink: pipeNext.command, context: pipeNext.context, args: pipeNext.args, next: pipeNext.output)
                }

                guard let pipeSource = pipe.first else { continue }

                Task {
                    self.currentlyRunningCommands += 1
                    log.debug("Currently running \(self.currentlyRunningCommands) commands")

                    let input = await self.msgParser.parse(pipeSource.args, message: message, clientName: sink.name, guild: pipeSource.context.guild)

                    // Execute the pipe
                    let runner = RunnablePipe(pipeSource: pipeSource, input: input)
                    await runner.run()

                    // Store the pipe for potential re-execution
                    if pipe.allSatisfy({ $0.command.info.shouldOverwriteMostRecentPipeRunner }), let minPermissionLevel = pipe.map(\.command.info.requiredPermissionLevel).max() {
                        self.mostRecentPipeRunner = (runner, minPermissionLevel)
                    }

                    self.currentlyRunningCommands -= 1
                }
            }
        }

        return true
    }

    private func constructPipe(rawPipeCommand: String, message: Message, sink: any Sink) -> [PipeComponent]? {
        guard let channelId = message.channelId, let author = message.author else { return nil }
        let isBot = author.bot
        var pipe = [PipeComponent]()
        var userOnly = false

        // Construct the pipe
        for rawCommand in rawPipeCommand.splitPreservingQuotes(by: pipeSeparator, omitQuotes: false, omitBackslashes: true) {
            let trimmedCommand = rawCommand.trimmingCharacters(in: .whitespacesAndNewlines)

            if let groups = try? commandPattern.firstMatch(in: trimmedCommand) {
                let name = String(groups.name)
                let iterationCount = groups.iterations.flatMap { Int($0) } ?? 1
                let args = String(groups.args ?? "")

                log.info("\(author.displayTag) invoked '\(name)' with '\(args)' (\(iterationCount) \("time".pluralized(with: iterationCount)))")

                if let command = registry[name] {
                    let hasPermission = permissionManager.user(author, hasPermission: command.info.requiredPermissionLevel, usingSimulated: command.info.usesSimulatedPermissionLevel)
                    if hasPermission {
                        log.debug("Appending '\(name)' to pipe")

                        let context = CommandContext(
                            sink: sink,
                            registry: registry,
                            message: message,
                            commandPrefix: commandPrefix,
                            hostInfo: hostInfo,
                            subscriptions: subscriptionManager.createIfNotExistsAndGetSubscriptionSet(for: name),
                            eventLoopGroup: eventLoopGroup
                        )

                        pipe.append(PipeComponent(name: name, command: command, context: context, args: args))

                        for _ in 0..<(iterationCount - 1) {
                            pipe.append(PipeComponent(name: name, command: command, context: context, args: ""))
                        }
                    } else {
                        log.notice("Rejected '\(name)' by \(author.displayTag) due to insufficient permissions")
                        sink.sendMessage("Sorry, you are not permitted to execute `\(name)`.", to: channelId)
                        return nil
                    }

                    userOnly = userOnly || command.info.userOnly
                } else {
                    log.notice("Did not recognize command '\(name)'")
                    if !isBot {
                        let alternative = registry.map { $0.0 }.min(by: ascendingComparator { $0.levenshteinDistance(to: name) })
                        sink.sendMessage("Sorry, I do not know the command `\(name)`.\(alternative.map { " Did you mean `\($0)`?" } ?? "")", to: channelId)
                    }
                    return nil
                }
            }
        }

        guard !(userOnly && isBot) else { return nil }
        return pipe
    }
}
