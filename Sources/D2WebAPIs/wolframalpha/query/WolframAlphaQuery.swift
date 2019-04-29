import Foundation
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
		guard let appid = storedWebApiKeys?.wolframAlpha else { throw WebApiError.missingApiKey("No WolframAlpha API key found") }
		
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
		
		guard let url = components.url else { throw WebApiError.urlError(components) }
		self.url = url
	}
	
	/** Starts a query and returns the data. */
	public func start(then: @escaping (Result<Data, Error>) -> Void) {
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				then(.failure(WebApiError.httpError(error!)))
				return
			}
			guard let data = data else {
				then(.failure(WebApiError.missingData))
				return
			}
			then(.success(data))
		}.resume()
	}
	
	public func startAndParse(then: @escaping (Result<WolframAlphaOutput, Error>) -> Void) {
		start {
			if case let .success(data) = $0 {
				let parser = XMLParser(data: data)
				let delegate = WolframAlphaParserDelegate(then: then)
				
				parser.delegate = delegate
				_ = parser.parse()
			}
		}
	}
}
