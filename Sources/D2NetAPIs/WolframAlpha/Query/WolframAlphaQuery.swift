import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import Utils

public struct WolframAlphaQuery {
    private let url: URL

    public init(
        input: String,
        endpoint: WolframAlphaQueryEndpoint,
        scheme: String = "https",
        host: String = "api.wolframalpha.com",
        showSteps: Bool = false
    ) throws {
        guard let appid = storedNetApiKeys?.wolframAlpha else { throw NetApiError.missingApiKey("No WolframAlpha API key found") }

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = endpoint.rawValue
        components.percentEncodedQuery = [
            "input": input,
            "appid": appid
        ].urlQueryEncoded

        if showSteps {
            components.queryItems?.append(URLQueryItem(name: "podstate", value: "Result__Step-by-step+solution"))
        }

        guard let url = components.url else { throw NetApiError.urlError(components) }
        self.url = url
    }

    /// Starts a query and returns the data.
    public func performRaw() async throws -> Data {
        try await HTTPRequest(url: url).run()
    }

    public func performParsed() async throws -> WolframAlphaOutput {
        let data = try await performRaw()
        return try await withCheckedThrowingContinuation { continuation in
            let parser = XMLParser(data: data)
            let delegate = WolframAlphaParserDelegate(continuation: continuation)

            parser.delegate = delegate
            _ = parser.parse()
        }
    }
}
