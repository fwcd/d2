import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(FoundationXML)
import FoundationXML
#endif

public struct HTTPRequest {
	private var request: URLRequest
	
	public init(
		scheme: String = "https",
		host: String,
        port: Int? = nil,
		path: String,
		method: String = "GET",
		query: [String: String] = [:],
		headers: [String: String] = [:],
        body customBody: String? = nil
	) throws {
		let isPost = method == "POST"

		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = path
		components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }

        if let p = port {
            components.port = p
        }
		
		let body: Data
		
		if isPost && !query.isEmpty {
			body = components.percentEncodedQuery?.data(using: .utf8) ?? .init()
			components.queryItems = []
		} else {
			body = customBody?.data(using: .utf8) ?? .init()
		}
		
		guard let url = components.url else { throw NetworkError.couldNotCreateURL(components) }
		
		request = URLRequest(url: url)
		request.httpMethod = method
		
		if isPost {
            if !query.isEmpty {
                request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            }
			request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
			request.httpBody = body
		}
		
		for (key, value) in headers {
			request.setValue(value, forHTTPHeaderField: key)
		}
	}
	
	public func runAsync(then: @escaping (Result<Data, Error>) -> Void) {
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				then(.failure(NetworkError.ioError(error!)))
				return
			}
			guard let data = data else {
				then(.failure(NetworkError.missingData))
				return
			}
			
			then(.success(data))
		}.resume()
	}
	
	public func fetchUTF8Async(then: @escaping (Result<String, Error>) -> Void) {
		runAsync {
			guard case let .success(data) = $0 else {
				guard case let .failure(error) = $0 else { fatalError("'Result' should always be either successful or insuccessful") }
				then(.failure(error))
				return
			}
			guard let utf8 = String(data: data, encoding: .utf8) else {
				then(.failure(NetworkError.notUTF8(data)))
				return
			}
			then(.success(utf8))
		}
	}
	
	public func fetchJSONAsync<T>(as type: T.Type, then: @escaping (Result<T, Error>) -> Void) where T: Decodable {
		runAsync {
			guard case let .success(data) = $0 else {
				guard case let .failure(error) = $0 else { fatalError("'Result' should always be either successful or insuccessful") }
				then(.failure(error))
				return
			}
			guard let deserialized = try? JSONDecoder().decode(type, from: data) else {
				then(.failure(NetworkError.jsonDecodingError(String(data: data, encoding: .utf8) ?? "<non-UTF-8-encoded data: \(data)>")))
				return
			}
			then(.success(deserialized))
		}
	}
	
	public func fetchXMLAsync<T>(using delegate: XMLParserDelegate, then: @escaping (Result<T, Error>) -> Void) {
		runAsync {
			switch $0 {
				case .success(let data):
					let parser = XMLParser(data: data)
					parser.delegate = delegate
					_ = parser.parse()
				case .failure(let error):
					then(.failure(error))
			}
		}
	}
}
