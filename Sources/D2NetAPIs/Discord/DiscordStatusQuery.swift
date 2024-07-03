import Utils

public struct DiscordStatusQuery {
    public init() {}

    public func perform() async throws -> DiscordStatus {
        let request = try HTTPRequest(host: "status.discord.com", path: "/api/v2/summary.json")
        return try await request.fetchJSON(as: DiscordStatus.self)
    }
}
