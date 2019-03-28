import Foundation
import D2Utils

struct MDBQuery {
	let url: URL
	
	init(
		moduleCode: String? = nil,
		scheme: String = "https",
		host: String = "mdb.ps.informatik.uni-kiel.de",
		path: String = "/show.cgi"
	) throws {
		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = path
		components.query = "xml\(moduleCode.map { "=\($0)" } ?? "")"
		
		guard let url = components.url else { throw MDBError.urlError(components) }
		self.url = url
	}
	
	func start(then: @escaping (Result<[MDBModule]>) -> Void) {
		print("Querying \(url)")
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				then(.error(MDBError.httpError(error!)))
				return
			}
			guard let data = data else {
				then(.error(MDBError.missingData))
				return
			}
			
			let delegate = MDBXMLParserDelegate(then: then)
			let parser = XMLParser(data: data)
			
			parser.delegate = delegate
			_ = parser.parse()
		}.resume()
	}
}
