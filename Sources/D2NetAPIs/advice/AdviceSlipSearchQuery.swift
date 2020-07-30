import D2Utils

public struct AdviceSlipSearchQuery {
    private let searchTerm: String

    public init(searchTerm: String) {
        self.searchTerm = searchTerm
    }

    public func perform() -> Promise<AdviceSlipSearchResults, Error> {
        Promise.catchingThen {
            let request = try HTTPRequest(host: "api.adviceslip.com", path: "/advice/search/\(searchTerm)")
            return request.fetchJSONAsync(as: AdviceSlipSearchResults.self)
        }
    }
}
