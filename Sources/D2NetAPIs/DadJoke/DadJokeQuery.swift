import Utils

public struct DadJokeQuery: Sendable {
    public init() {}

    public func perform() async throws -> DadJoke {
        try await HTTPRequest(
            host: "icanhazdadjoke.com",
            path: "/",
            headers: [
                "Accept": "application/json",
                "User-Agent": "D2 (https://github.com/fwcd/d2)"
            ]
        ).fetchJSON(as: DadJoke.self)
    }
}
