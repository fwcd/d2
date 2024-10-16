import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(FoundationXML)
import FoundationXML
#endif
import Logging
import Utils

fileprivate let log = Logger(label: "D2NetAPIs.UnivISQuery")

public struct UnivISQuery: Sendable {
    private let url: URL

    public init(
        search: UnivISSearchKey,
        params: [UnivISSearchParameter: String],
        scheme: String = "http",
        host: String = "univis.uni-kiel.de",
        path: String = "/prg"
    ) throws {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [
            URLQueryItem(name: "search", value: search.rawValue),
            URLQueryItem(name: "show", value: "xml")
        ] + params.map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }

        guard let url = components.url else { throw NetApiError.urlError(components) }
        self.url = url
    }

    public func perform() async throws -> UnivISOutputNode {
        try await withCheckedThrowingContinuation { continuation in
            log.info("Querying \(url)")

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    continuation.resume(throwing: NetApiError.httpError(error!))
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: NetApiError.missingData)
                    return
                }

                log.debug("Got \(String(data: data, encoding: .utf8) ?? "nil")")

                let delegate = UnivISXMLParserDelegate(continuation: continuation)
                let parser = XMLParser(data: data)

                parser.delegate = delegate
                _ = parser.parse()
            }.resume()
        }
    }
}
