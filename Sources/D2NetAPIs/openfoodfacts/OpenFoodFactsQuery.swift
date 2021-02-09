import Utils

public struct OpenFoodFactsQuery {
    public let code: String

    public init(code: String) {
        self.code = code
    }

    public func perform() -> Promise<OpenFoodFactsResult, Error> {
        Promise.catching { try HTTPRequest(host: "world.openfoodfacts.org", path: "/api/v0/product/\(code).json") }
            .then { $0.fetchJSONAsync(as: OpenFoodFactsResult.self) }
    }
}
