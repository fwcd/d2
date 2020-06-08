import D2MessageIO

public protocol Conversator {
    func answer(input: String, on guildId: GuildID) throws -> String?
}
