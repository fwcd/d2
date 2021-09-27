import Utils

public struct JokeAPIQuery {
    private let categories: [JokeCategory]
    private let type: JokeType?

    public init(categories: [JokeCategory] = [], type: JokeType? = nil) {
        self.categories = categories
        self.type = type
    }

    public func perform() -> Promise<Joke, Error> {
        let categoryEndpoint = categories.nilIfEmpty?.map(\.rawValue).joined(separator: ",") ?? "Any"
        return Promise
            .catching {
                try HTTPRequest(
                    host: "v2.jokeapi.dev",
                    path: "/joke/\(categoryEndpoint)",
                    query: [
                        // Exclude inappropriate jokes
                        "blacklistFlags": "racist,sexist"
                    ]
                )
            }
            .then { $0.fetchJSONAsync(as: Joke.self) }
    }
}
