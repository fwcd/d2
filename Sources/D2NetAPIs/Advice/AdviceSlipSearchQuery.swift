import Utils

public struct AdviceSlipSearchQuery {
    private let searchTerm: String

    public init(searchTerm: String) {
        self.searchTerm = searchTerm
    }

    public func perform() -> Promise<AdviceSlipSearchResults, any Error> {
        Promise.catchingThen {
            let request = try HTTPRequest(host: "api.adviceslip.com", path: "/advice/search/\(searchTerm)")
            return request.fetchJSONAsync(as: AdviceSlipSearchResults.self)
        }
    }
}
