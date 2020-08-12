import D2Utils

public struct RandomJokeQuery {
    public init() {}

    public func perform() -> Promise<Joke, Error> {
        Promise.catching { try HTTPRequest(host: "official-joke-api.appspot.com", path: "/random_joke") }
            .then { $0.fetchJSONAsync(as: Joke.self) }
    }
}
