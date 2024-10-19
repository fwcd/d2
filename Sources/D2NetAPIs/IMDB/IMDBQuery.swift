import Foundation
import Utils

public struct IMDBQuery: Sendable {
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

    public func perform() async throws -> IMDBResults {
        let request =  try HTTPRequest(host: "v2.sg.media-imdb.com", path: "/suggestion/\(formattedQuery.first!)/\(formattedQuery).json")
        return try await request.fetchJSON(as: IMDBResults.self)
    }
}
