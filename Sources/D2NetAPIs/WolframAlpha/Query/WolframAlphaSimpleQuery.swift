import Foundation
import Utils

public struct WolframAlphaSimpleQuery: Sendable {
    private let url: URL

    public init(
        input: String,
        scheme: String = "https",
        host: String = "api.wolframalpha.com",
        path: String = "/v1/simple"
    ) throws {
        guard let appid = storedNetApiKeys?.wolframAlpha else { throw NetApiError.missingApiKey("No WolframAlpha API key found") }

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [
            URLQueryItem(name: "input", value: input),
            URLQueryItem(name: "appid", value: appid)
        ]

        guard let url = components.url else { throw NetApiError.urlError(components) }
        self.url = url
    }

    public func perform() async throws -> Data {
        try await HTTPRequest(url: url).run()
    }
}
