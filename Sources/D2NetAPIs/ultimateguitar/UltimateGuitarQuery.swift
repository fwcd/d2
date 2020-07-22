import Foundation
import D2Utils

public struct UltimateGuitarQuery<T> where T: Codable {
    private let path: String
    private let query: [String: String]

    public init(path: String, query: [String: String]) {
        self.path = path
        self.query = query
    }

    public func perform(then: @escaping (Result<UltimateGuitarResponse<T>, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "www.ultimate-guitar.com", path: path, query: query)
            request.fetchHTMLAsync {
                do {
                    let doc = try $0.get()
                    guard let store = try doc.getElementsByClass("js-store").array().first else {
                        throw UltimateGuitarError.noStoreOnPage
                    }
                    guard let data = try store.attr("data-content").data(using: .utf8) else {
                        throw UltimateGuitarError.invalidlyEncodedStore
                    }
                    let decoded = try JSONDecoder().decode(UltimateGuitarResponse<T>.self, from: data)
                    then(.success(decoded))
                } catch {
                    then(.failure(error))
                }
            }
        } catch {
            then(.failure(error))
        }
    }
}
