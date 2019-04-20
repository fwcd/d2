import Foundation
import D2Utils

public struct WolframAlphaSimpleQuery {
	private let url: URL
	
	public init(
		input: String,
		scheme: String = "https",
		host: String = "api.wolframalpha.com",
		path: String = "/v1/simple"
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
}
