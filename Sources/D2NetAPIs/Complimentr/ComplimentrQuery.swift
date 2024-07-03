import Utils

public struct ComplimentrQuery {
    public init() {}

    public func perform() async throws -> Compliment {
        let request = try HTTPRequest(host: "complimentr.com", path: "/api")
        return try await request.fetchJSON(as: Compliment.self)
    }
}
