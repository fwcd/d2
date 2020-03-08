import D2Utils

public struct HoogleQuery {
    private let term: String
    
    public init(term: String) {
        self.term = term
    }
    
    public func perform(then: @escaping (Result<[HoogleResult], Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "hoogle.haskell.org", path: "/", query: [
                "mode": "json",
                "format": "text",
                "hoogle": term,
                "start": "1",
                "count": "5"
            ])
            request.fetchJSONAsync(as: [HoogleResult].self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
