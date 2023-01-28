import D2MessageIO
import D2Commands

struct Config: Codable {
    var commandPrefix: String?
    var hostInfo: HostInfo?
    var setPresenceInitially: Bool?
    var useMIOCommands: Bool?
    var useMIOCommandsOnlyOnGuild: GuildID?
}
