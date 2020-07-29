import D2Utils

public struct HoogleQuery {
    private let term: String
    private let count: Int

    public init(term: String, count: Int = 4) {
        self.term = term
        self.count = count
    }

    public func perform() -> Promise<[HoogleResult], Error> {
        do {
            let request = try HTTPRequest(host: "hoogle.haskell.org", path: "/", query: [
                "mode": "json",
                "hoogle": term,
                "start": "1",
                "count": "\(count)"
            ])
            request.fetchJSONAsync(as: [HoogleResult].self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
