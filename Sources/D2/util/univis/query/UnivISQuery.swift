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
	
	func start(then: @escaping (Result<UnivISOutputNode>) -> Void) {
		do {
			let url = try UnivISQuery(
				scheme: "http", host: "univis.uni-kiel.de", path: "/prg", search: .rooms, params: [
					.name: "Haase"
				]
			).url
			
			var request = URLRequest(url: url)
			request.httpMethod = "GET"
			URLSession.shared.dataTask(with: request) { data, response, error in
				guard error == nil else {
					then(.error(UnivISError.httpError(error!)))
					return
				}
				guard let data = data else {
					then(.error(UnivISError.missingData))
					return
				}
				
				let delegate = UnivISXMLParserDelegate(then: then)
				let parser = XMLParser(data: data)
				
				parser.delegate = delegate
				_ = parser.parse()
			}.resume()
		} catch {
			then(.error(error))
		}
	}
}
