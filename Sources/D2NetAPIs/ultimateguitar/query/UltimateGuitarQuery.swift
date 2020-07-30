import Foundation
import D2Utils

public struct UltimateGuitarQuery<T> where T: Codable {
    private let host: String
    private let path: String
    private let query: [String: String]

    public init(host: String = "www.ultimate-guitar.com", path: String, query: [String: String]) {
        self.host = host
        self.path = path
        self.query = query
    }

    public func perform() -> Promise<UltimateGuitarResponse<T>, Error> {
        Promise.catching { try HTTPRequest(host: host, path: path, query: query) }
            .then { $0.fetchHTMLAsync() }
            .mapCatching { doc in
                guard let store = try doc.getElementsByClass("js-store").array().first else {
                    throw UltimateGuitarError.noStoreOnPage
                }
                guard let data = try store.attr("data-content").data(using: .utf8) else {
                    throw UltimateGuitarError.invalidlyEncodedStore
                }
                let decoded = try JSONDecoder().decode(UltimateGuitarResponse<T>.self, from: data)
                return decoded
            }
    }
}
