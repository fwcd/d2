import D2MessageIO

public struct CronTab: Sendable, Codable, Hashable {
    public var schedules: [String: Schedule] = [:]

    public struct Schedule: Sendable, Codable, Hashable {
        public var cron: String
        public var command: String
        public var channelId: ChannelID
    }
}
