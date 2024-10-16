import Utils

public struct ThisForThatQuery: Sendable {
    public init() {}

    public func perform() async throws -> ThisForThat {
        let request = try HTTPRequest(host: "itsthisforthat.com", path: "/api.php", query: ["json": ""])
        return try await request.fetchJSON(as: ThisForThat.self)
    }
}
