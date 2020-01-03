import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(FoundationXML)
import FoundationXML
#endif
import D2Utils

public struct MDBQuery {
	public let url: URL
	
	public init(
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
		
		guard let url = components.url else { throw NetApiError.urlError(components) }
		self.url = url
	}
	
	public func start(then: @escaping (Result<[MDBModule], Error>) -> Void) {
		print("Querying \(url)")
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				then(.failure(NetApiError.httpError(error!)))
				return
			}
			guard let data = data else {
				then(.failure(NetApiError.missingData))
				return
			}
			
			let delegate = MDBXMLParserDelegate(then: then)
			let parser = XMLParser(data: data)
			
			parser.delegate = delegate
			_ = parser.parse()
		}.resume()
	}
}
