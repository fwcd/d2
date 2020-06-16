import D2Utils

public struct DiscordStatusQuery {
    public init() {}

    public func perform(then: @escaping (Result<DiscordStatus, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "status.discord.com", path: "/api/v2/summary.json")
            request.fetchJSONAsync(as: DiscordStatus.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
