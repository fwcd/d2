import Foundation
import Logging
import D2Utils
import SwiftSoup

fileprivate let log = Logger(label: "IntegralCalculatorQuery")
fileprivate let pageVersionPattern = try! Regex(from: "\\bpageVersion\\s*=\\s*(\\d+)\\b")

public struct IntegralCalculatorQuery {
	private let params: IntegralQueryParams
	private let manual: Bool
	
	public init(params: IntegralQueryParams, manual: Bool = true) {
		self.params = params
		self.manual = manual
	}
	
	public func perform(then: @escaping (Result<IntegralQueryOutput, Error>) -> Void) {
		log.info("Querying integral calculator...")
		fetchPageVersion {
			switch $0 {
				case let .success(pageVersion):
					do {
						try HTTPRequest(
							scheme: "https",
							host: "www.integral-calculator.com",
							path: self.manual ? "/manualint.php" : "/int.php",
							method: "POST",
							query: [
								"q": String(data: try JSONEncoder().encode(self.params), encoding: .utf8) ?? "",
								"v": pageVersion
							]
						).fetchUTF8Async {
							switch $0 {
								case let .success(rawHTML):
									do {
										let document = try SwiftSoup.parse(rawHTML)
										let steps = try document.getElementsByClass("calc-math").map { try $0.text() }
										if steps.isEmpty {
											then(.failure(NetApiError.apiError(try document.text())))
										} else {
											then(.success(IntegralQueryOutput(steps: steps)))
										}
									} catch {
										then(.failure(error))
									}
								case let .failure(error):
									then(.failure(error))
							}
						}
					} catch {
						then(.failure(error))
					}
				case let .failure(error):
					then(.failure(error))
			}
		}
	}
	
	private func fetchPageVersion(then: @escaping (Result<String, Error>) -> Void) {
		do {
			try HTTPRequest(
				scheme: "https",
				host: "www.integral-calculator.com",
				path: "/",
				method: "GET"
			).fetchUTF8Async {
				switch $0 {
					case let .success(rawHTML):
						if let parsedPageVersion = pageVersionPattern.firstGroups(in: rawHTML) {
							then(.success(parsedPageVersion[1]))
						} else {
							then(.failure(NetApiError.apiError("Could not find page version of integral calculator")))
						}
					case let .failure(error):
						then(.failure(error))
				}
			}
		} catch {
			then(.failure(error))
		}
	}
}
