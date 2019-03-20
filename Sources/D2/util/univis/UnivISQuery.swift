import Foundation

struct UnivISQuery {
	let url: URL
	
	init(
		scheme: String,
		host: String,
		path: String,
		search: UnivISSearchKey,
		params: [UnivISSearchParameter : String]
	) throws {
		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = path
		components.queryItems = [
			URLQueryItem(name: "search", value: search.rawValue),
			URLQueryItem(name: "show", value: "xml")
		] + params.map { URLQueryItem(name: $0.key.rawValue, value: $0.value) }
		
		guard let url = components.url else { throw UnivISError.urlError(components) }
		self.url = url
	}
}
