import Utils

public struct AgifyQuery: Sendable {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    public func perform() async throws -> AgeEstimate {
        let request = try HTTPRequest(host: "api.agify.io", path: "/", query: ["name": name])
        return try await request.fetchJSON(as: AgeEstimate.self)
    }
}
