import D2MessageIO
import D2Commands
import Logging

struct Config: Sendable, Codable {
    var commandPrefix: String?
    var hostInfo: HostInfo?
    var setPresenceInitially: Bool?
    var useMIOCommands: Bool?
    var useMIOCommandsOnlyOnGuild: GuildID?
    var log: Log?

    struct Log: Sendable, Codable {
        var level: Logger.Level?
        var dependencyLevel: Logger.Level?
        var printToStdout: Bool?
        var channel: ChannelID?
    }
}
