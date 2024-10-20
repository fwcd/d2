import Logging
import NIO
import NIOCronScheduler

private let log = Logger(label: "D2Commands.CronSchedulerBus")

public class CronSchedulerBus {
    private var schedules: [String: Schedule] = [:]
    private let eventLoopGroup: any EventLoopGroup
    private let eventLoop: EventLoop

    private class Schedule {
        let job: NIOCronJob

        init(name: String, cron: String, on eventLoop: EventLoop, action: @escaping () -> Void) throws {
            job = try NIOCronScheduler.schedule(cron, on: eventLoop) {
                log.info("Invoking cron schedule '\(name)' (scheduled to run at \(cron))")
                action()
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

    public func addSchedule(name: String, cron: String, action: @escaping () -> Void) throws {
        log.info("Adding schedule '\(name)' at \(cron)")
        schedules[name] = try Schedule(name: name, cron: cron, on: eventLoop, action: action)
    }

    public func removeSchedule(name: String) {
        log.info("Removing schedule '\(name)'")
        schedules[name] = nil
    }
}
