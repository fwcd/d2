import D2Utils

public struct AdviceSlipQuery {
    private let searchTerm: String?

    public init(searchTerm: String? = nil) {
        self.searchTerm = searchTerm
    }

    public func perform() -> Promise<AdviceSlipResult, Error> {
        do {
            let request = try HTTPRequest(host: "api.adviceslip.com", path: "/advice\((searchTerm?.nilIfEmpty).map { "/search/\($0)" } ?? "")")
            request.fetchJSONAsync(as: AdviceSlipResult.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
