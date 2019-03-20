import Foundation

struct UnivISQuery {
	let url: URL
	
	init(
		host: String,
		path: String,
		search: UnivISSearchKey,
		params: [UnivISSearchParameter : String],
		scheme: String = "https"
	) throws {
		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = path
		components.queryItems = params.map { URLQueryItem($0.key.rawValue, $0.value) }
		
		guard let url = components.url else { throw UnivISError.urlError(components) }
		self.url = url
	}
}
