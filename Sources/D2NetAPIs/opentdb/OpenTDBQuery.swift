import D2Utils

public struct OpenTDBQuery {
    private let amount: Int

    public init(amount: Int = 1) {
        self.amount = amount
    }

    public func perform(then: @escaping (Result<OpenTDBResponse, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "opentdb.com", path: "/api.php", query: ["amount": String(amount)])
            request.fetchJSONAsync(as: OpenTDBResponse.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
