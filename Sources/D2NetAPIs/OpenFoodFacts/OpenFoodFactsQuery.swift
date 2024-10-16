import Utils

public struct OpenFoodFactsQuery: Sendable {
    public let code: String

    public init(code: String) {
        self.code = code
    }

    public func perform() async throws -> OpenFoodFactsResult {
        let request = try HTTPRequest(host: "world.openfoodfacts.org", path: "/api/v0/product/\(code).json")
        return try await request.fetchJSON(as: OpenFoodFactsResult.self)
    }
}
