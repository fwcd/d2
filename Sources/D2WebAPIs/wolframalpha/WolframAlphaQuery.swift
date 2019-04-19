import Foundation
import D2Utils

public struct WolframAlphaQuery {
	private let url: URL
	
	public init(
		input: String,
		scheme: String = "https",
		host: String = "api.wolframalpha.com",
		path: String = "/v2/query"
	) throws {
		guard let appid = storedWebApiKeys?.wolframAlpha else { throw WebApiError.missingApiKey("No WolframAlpha API key found") }
		
		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = path
		components.queryItems = [
			URLQueryItem(name: "input", value: input),
			URLQueryItem(name: "appid", value: appid)
		]
		
		guard let url = components.url else { throw WebApiError.urlError(components) }
		self.url = url
	}
	
	public func start(then: @escaping (Result<WolframAlphaOutput, Error>) -> Void) {
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
			
			let parser = XMLParser(data: data)
			let delegate = WolframAlphaParserDelegate(then: then)
			
			parser.delegate = delegate
			_ = parser.parse()
		}.resume()
	}
}
