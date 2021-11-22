import NIO
import NIOCronScheduler

public class CronSchedulerBus {
    private var schedules: [String: Schedule] = [:]
    private let eventLoopGroup: EventLoopGroup
    private let eventLoop: EventLoop

    private class Schedule {
        let job: NIOCronJob

        init(cron: String, output: CommandOutput, on eventLoop: EventLoop) throws {
            job = try NIOCronScheduler.schedule(cron, on: eventLoop) {
                output.append(.none)
            }
        }

        deinit {
            job.cancel()
        }
    }

    public init() {
        eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        eventLoop = eventLoopGroup.next()
    }

    public func addSchedule(name: String, with cron: String, output: CommandOutput) throws {
        schedules[name] = try Schedule(cron: cron, output: output, on: eventLoop)
    }

    public func removeSchedule(name: String) {
        schedules[name] = nil
    }
}
