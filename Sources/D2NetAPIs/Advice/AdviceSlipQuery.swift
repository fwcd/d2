import Utils

public struct AdviceSlipQuery {
    private let searchTerm: String?

    public init(searchTerm: String? = nil) {
        self.searchTerm = searchTerm
    }

    public func perform() async throws -> AdviceSlipResult {
        let request = try HTTPRequest(host: "api.adviceslip.com", path: "/advice\((searchTerm?.nilIfEmpty).map { "/search/\($0)" } ?? "")")
        return try await request.fetchJSON(as: AdviceSlipResult.self)
    }
}
