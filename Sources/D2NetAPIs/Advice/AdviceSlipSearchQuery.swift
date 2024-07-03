import Utils

public struct AdviceSlipSearchQuery {
    private let searchTerm: String

    public init(searchTerm: String) {
        self.searchTerm = searchTerm
    }

    public func perform() async throws -> AdviceSlipSearchResults {
        let request = try HTTPRequest(host: "api.adviceslip.com", path: "/advice/search/\(searchTerm)")
        return try await request.fetchJSON(as: AdviceSlipSearchResults.self)
    }
}
