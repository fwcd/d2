import D2MessageIO

public protocol Conversator: Sendable {
    func answer(input: String, on guildId: GuildID) async throws -> String?
}
