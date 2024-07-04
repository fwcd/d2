import Utils

public struct IcndbJokeQuery {
    private var params: [String: String] = [:]

    public init(
        firstName: String? = nil,
        lastName: String? = nil
    ) {
        params["firstName"] = firstName
        params["lastName"] = lastName
    }

    public func perform() async throws -> IcndbResult {
        let request = try HTTPRequest(host: "api.icndb.com", path: "/jokes/random", query: params)
        return try await request.fetchJSON(as: IcndbResult.self)
    }
}
