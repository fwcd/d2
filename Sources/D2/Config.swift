import D2MessageIO

struct Config: Codable {
    var commandPrefix: String
    var setPresenceInitially: Bool
    var useMIOCommands: Bool?
    var useMIOCommandsOnlyOnGuild: GuildID
}
