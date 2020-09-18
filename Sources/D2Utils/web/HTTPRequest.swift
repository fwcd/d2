import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(FoundationXML)
import FoundationXML
#endif
import SwiftSoup

public struct HTTPRequest {
    private var request: URLRequest

    public init(url: URL) {
        request = URLRequest(url: url)
    }

    public init(
        scheme: String = "https",
        host: String,
        port: Int? = nil,
        path: String,
        method: String = "GET",
        query: [String: String] = [:],
        headers: [String: String] = [:],
        body customBody: String? = nil
    ) throws {
        let isPost = method == "POST"

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }

        if let p = port {
            components.port = p
        }

        let body: Data

        if isPost && !query.isEmpty {
            body = components.percentEncodedQuery?.data(using: .utf8) ?? .init()
            components.queryItems = []
        } else {
            body = customBody?.data(using: .utf8) ?? .init()
        }

        guard let url = components.url else { throw NetworkError.couldNotCreateURL(components) }

        request = URLRequest(url: url)
        request.httpMethod = method

        if isPost {
            if !query.isEmpty {
                request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            }
            request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = body
        }

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    public func runAsync() -> Promise<Data, Error> {
        Promise { then in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    then(.failure(NetworkError.ioError(error!)))
                    return
                }
                guard let data = data else {
                    then(.failure(NetworkError.missingData))
                    return
                }

                then(.success(data))
            }.resume()
        }
    }

    public func fetchUTF8Async() -> Promise<String, Error> {
        runAsync().then {
            if let utf8 = String(data: $0, encoding: .utf8) {
                return Promise(.success(utf8))
            } else {
                return Promise(.failure(NetworkError.notUTF8($0)))
            }
        }
    }

    public func fetchJSONAsync<T>(as type: T.Type) -> Promise<T, Error> where T: Decodable {
        runAsync().then {
            if let deserialized = try? JSONDecoder().decode(type, from: $0) {
                return Promise(.success(deserialized))
            } else {
                return Promise(.failure(NetworkError.jsonDecodingError(String(data: $0, encoding: .utf8) ?? "<non-UTF-8-encoded data: \($0)>")))
            }
        }
    }

    public func fetchXMLAsync(using delegate: XMLParserDelegate) {
        runAsync().listen {
            switch $0 {
                case .success(let data):
                    let parser = XMLParser(data: data)
                    parser.delegate = delegate
                    _ = parser.parse()
                case .failure(let error):
                    // Work around the issue that the method is marked optional on macOS but not on Linux
                    #if os(macOS)
                    delegate.parser?(XMLParser(data: Data()), parseErrorOccurred: error)
                    #else
                    delegate.parser(XMLParser(data: Data()), parseErrorOccurred: error)
                    #endif
            }
        }
    }

    public func fetchHTMLAsync() -> Promise<Document, Error> {
        fetchUTF8Async().mapCatching { try SwiftSoup.parse($0) }
    }
}
