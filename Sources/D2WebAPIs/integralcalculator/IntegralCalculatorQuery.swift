import Foundation
import D2Utils
import SwiftSoup

public struct IntegralCalculatorQuery {
	public let url: URL
	private let queryString: String
	
	public init<P: Encodable>(
		params: P,
		moduleCode: String? = nil,
		scheme: String = "https",
		host: String = "www.integral-calculator.com",
		path: String = "/int.php"
	) throws {
		var components = URLComponents()
		components.scheme = scheme
		components.host = host
		components.path = path
		
		queryString = [
			"q": String(data: try JSONEncoder().encode(params), encoding: .utf8) ?? "",
			"v": "1554468795"
		].urlQueryEncoded
		
		guard let url = components.url else { throw WebApiError.urlError(components) }
		self.url = url
	}
	
	public func start(then: @escaping (Result<IntegralQueryOutput, Error>) -> Void) {
		print("Querying \(url)")
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.httpBody = queryString.data(using: .utf8)
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard error == nil else {
				then(.failure(WebApiError.httpError(error!)))
				return
			}
			guard let rawHTML = data.flatMap({ String(data: $0, encoding: .utf8) }) else {
				then(.failure(WebApiError.encodingError("Could not parse data as UTF-8")))
				return
			}
			
			do {
				let document = try SwiftSoup.parse(rawHTML)
				let steps = try document.getElementsByClass("calc-math").map { try $0.text() }
				if steps.isEmpty {
					then(.failure(WebApiError.apiError(try document.text())))
				} else {
					then(.success(IntegralQueryOutput(steps: steps)))
				}
			} catch {
				then(.failure(error))
				return
			}
		}.resume()
	}
}
