import Utils

public struct NhieIoQuery: Sendable {
    public init() {}

    public func perform() async throws -> NeverHaveIEverStatement {
        let request = try HTTPRequest(host: "api.nhie.io", path: "/v1/statements/random")
        return try await request.fetchJSON(as: NeverHaveIEverStatement.self)
    }
}
