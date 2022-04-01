import Logging
import NIO
import NIOCronScheduler

fileprivate let log = Logger(label: "D2Commands.CronSchedulerBus")

// TODO: Persist cron schedules?

public class CronSchedulerBus {
    private var schedules: [String: Schedule] = [:]
    private let eventLoopGroup: EventLoopGroup
    private let eventLoop: EventLoop

    private class Schedule {
        let job: NIOCronJob

        init(name: String, cron: String, output: any CommandOutput, on eventLoop: EventLoop) throws {
            job = try NIOCronScheduler.schedule(cron, on: eventLoop) {
                log.info("Invoking cron schedule '\(name)' (scheduled to run at \(cron))")
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

    public func addSchedule(name: String, with cron: String, output: any CommandOutput) throws {
        schedules[name] = try Schedule(name: name, cron: cron, output: output, on: eventLoop)
    }

    public func removeSchedule(name: String) {
        schedules[name] = nil
    }
}
