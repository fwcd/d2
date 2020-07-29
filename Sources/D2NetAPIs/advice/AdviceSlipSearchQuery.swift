import D2Utils

public struct AdviceSlipSearchQuery {
    private let searchTerm: String

    public init(searchTerm: String) {
        self.searchTerm = searchTerm
    }

    public func perform() -> Promise<AdviceSlipSearchResults, Error> {
        do {
            let request = try HTTPRequest(host: "api.adviceslip.com", path: "/advice/search/\(searchTerm)")
            request.fetchJSONAsync(as: AdviceSlipSearchResults.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
