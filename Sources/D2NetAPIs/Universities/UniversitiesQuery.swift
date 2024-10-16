import Utils

public struct UniversitiesQuery: Sendable {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    public func perform() async throws -> [University] {
        let request = try HTTPRequest(scheme: "http", host: "universities.hipolabs.com", path: "/search", query: ["name": name])
        return try await request.fetchJSON(as: [University].self)
    }
}
