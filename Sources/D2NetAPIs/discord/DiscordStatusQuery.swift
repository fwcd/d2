import D2Utils

public struct DiscordStatusQuery {
    public init() {}

    public func perform() -> Promise<DiscordStatus, Error> {
        Promise.catchingThen {
            let request = try HTTPRequest(host: "status.discord.com", path: "/api/v2/summary.json")
            return request.fetchJSONAsync(as: DiscordStatus.self)
        }
    }
}
