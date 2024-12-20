import Foundation
import Utils

public struct UltimateGuitarQuery<T> where T: Sendable & Codable {
    private let host: String
    private let path: String
    private let query: [String: String]

    public init(host: String = "www.ultimate-guitar.com", path: String, query: [String: String]) {
        self.host = host
        self.path = path
        self.query = query
    }

    public func perform() async throws -> UltimateGuitarResponse<T> {
        let request = try HTTPRequest(host: host, path: path, query: query)
        let document = try await request.fetchHTML()
        guard let store = try document.getElementsByClass("js-store").array().first else {
            throw UltimateGuitarError.noStoreOnPage
        }
        guard let data = try store.attr("data-content").data(using: .utf8) else {
            throw UltimateGuitarError.invalidlyEncodedStore
        }
        let decoded = try JSONDecoder().decode(UltimateGuitarResponse<T>.self, from: data)
        return decoded
    }
}
