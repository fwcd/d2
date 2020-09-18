import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif
import D2Utils

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

    /** Starts a query and returns the data. */
    public func start() -> Promise<Data, Error> {
        HTTPRequest(url: url).runAsync()
    }

    public func startAndParse() -> Promise<WolframAlphaOutput, Error> {
        start().then { data in
            Promise { then in
                let parser = XMLParser(data: data)
                let delegate = WolframAlphaParserDelegate(then: then)

                parser.delegate = delegate
                _ = parser.parse()
            }
        }
    }
}
