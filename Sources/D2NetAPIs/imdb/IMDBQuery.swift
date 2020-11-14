import Foundation
import Utils

public struct IMDBQuery {
    private let query: String
    private var formattedQuery: String {
        query
            .lowercased()
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: " ", with: "_")
    }

    public init(query: String) {
        assert(!query.isEmpty)
        self.query = query
    }

    public func perform() -> Promise<IMDBResults, Error> {
        Promise.catching { try HTTPRequest(host: "v2.sg.media-imdb.com", path: "/suggestion/\(formattedQuery.first!)/\(formattedQuery).json") }
            .then { $0.fetchJSONAsync(as: IMDBResults.self) }
    }
}
