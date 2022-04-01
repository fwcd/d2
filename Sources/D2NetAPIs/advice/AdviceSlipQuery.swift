import Utils

public struct AdviceSlipQuery {
    private let searchTerm: String?

    public init(searchTerm: String? = nil) {
        self.searchTerm = searchTerm
    }

    public func perform() -> Promise<AdviceSlipResult, any Error> {
        Promise.catching { try HTTPRequest(host: "api.adviceslip.com", path: "/advice\((searchTerm?.nilIfEmpty).map { "/search/\($0)" } ?? "")") }
            .then { $0.fetchJSONAsync(as: AdviceSlipResult.self) }
    }
}
