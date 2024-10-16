import Utils

public struct JokeAPIQuery: Sendable {
    private let categories: [JokeCategory]
    private let type: JokeType?

    public init(categories: [JokeCategory] = [], type: JokeType? = nil) {
        self.categories = categories
        self.type = type
    }

    public func perform() async throws -> Joke {
        let categoryEndpoint = categories.nilIfEmpty?.map(\.rawValue).joined(separator: ",") ?? "Any"
        let request = try HTTPRequest(
            host: "v2.jokeapi.dev",
            path: "/joke/\(categoryEndpoint)",
            query: [
                // Exclude inappropriate jokes
                "blacklistFlags": "racist,sexist"
            ]
        )
        return try await request.fetchJSON(as: Joke.self)
    }
}
