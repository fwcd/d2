import D2MessageIO
import Utils
import Logging
import NIO

private let log = Logger(label: "D2Commands.CronManager")

@CommandActor
public class CronManager {
    @AutoSerializing(filePath: "local/cronTab.json") private var cronTab: CronTab = .init()
    private var liveCronTab: CronTab = .init()
    private let scheduler: CronSchedulerBus = .init()
    private let msgParser: MessageParser = .init()

    private let registry: CommandRegistry
    private let sink: any Sink
    private let commandPrefix: String
    private let hostInfo: HostInfo
    private let eventLoopGroup: any EventLoopGroup

    public init(
        registry: CommandRegistry,
        sink: any Sink,
        commandPrefix: String,
        hostInfo: HostInfo,
        eventLoopGroup: any EventLoopGroup
    ) {
        self.registry = registry
        self.sink = sink
        self.commandPrefix = commandPrefix
        self.hostInfo = hostInfo
        self.eventLoopGroup = eventLoopGroup
        sync()
    }

    public subscript(name: String) -> CronTab.Schedule? {
        get { cronTab.schedules[name] }
        set {
            cronTab.schedules[name] = newValue
            sync()
        }
    }

    private func run(schedule: CronTab.Schedule) async {
        let parsedCommand = schedule.command
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ", maxSplits: 2, omittingEmptySubsequences: false)
            .map(String.init)

        let commandName = parsedCommand[0]
        let commandArgs = parsedCommand[1]

        guard let command = registry[commandName] else {
            log.warning("Scheduled command '\(commandName)' was not found!")
            return
        }

        let input = await msgParser.parse(commandArgs)
        let context = CommandContext(
            sink: sink,
            registry: registry,
            message: Message(content: "", channelId: schedule.channelId),
            commandPrefix: commandPrefix,
            hostInfo: hostInfo,
            subscriptions: SubscriptionSet(), // TODO: Support subscriptions?
            eventLoopGroup: eventLoopGroup
        )
        let output = MessageIOOutput(context: context)
        await command.invoke(with: input, output: output, context: context)
    }

    private func sync() {
        let current = liveCronTab.schedules
        let new = cronTab.schedules
        let removed = Set(current.keys).subtracting(new.keys)
        let added = Set(new.keys).subtracting(current.keys)

        for name in removed {
            scheduler.removeSchedule(name: name)
            liveCronTab.schedules[name] = nil
        }

        for name in added {
            let schedule = new[name]!
            do {
                try scheduler.addSchedule(name: name, cron: schedule.cron) {
                    Task {
                        await self.run(schedule: schedule)
                    }
                }
                liveCronTab.schedules[name] = schedule
            } catch {
                log.error("Adding schedule \(name) failed, removing it...")
                cronTab.schedules[name] = nil
            }
        }
    }
}
