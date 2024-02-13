import Foundation
import Logging
import Utils
import SwiftSoup

fileprivate let log = Logger(label: "D2NetAPIs.IntegralCalculatorQuery")
fileprivate let pageVersionPattern = try! LegacyRegex(from: "\\bpageVersion\\s*=\\s*(\\d+)\\b")

public struct IntegralCalculatorQuery<P: IntegralQueryParams> {
    private let params: P

    public init(params: P) {
        self.params = params
    }

    public func perform() -> Promise<IntegralQueryOutput, any Error> {
        fetchPageVersion()
            .mapCatching { pageVersion -> HTTPRequest in
                let params = String(data: try JSONEncoder().encode(self.params), encoding: .utf8) ?? ""
                log.info("Querying integral calculator v\(pageVersion) with params \(params)...")

                return try HTTPRequest(
                    scheme: "https",
                    host: "www.integral-calculator.com",
                    path: P.endpoint,
                    method: "POST",
                    query: [
                        "q": params,
                        "v": pageVersion
                    ]
                )
            }
            .then { $0.fetchHTMLAsync() }
            .mapCatching { document in
                let steps = try document.getElementsByClass("calc-math").map { try $0.text() }
                guard !steps.isEmpty else {
                    throw NetApiError.apiError(try document.text())
                }
                return IntegralQueryOutput(steps: steps)
            }
    }

    private func fetchPageVersion() -> Promise<String, any Error> {
        Promise.catching { try HTTPRequest(
            scheme: "https",
            host: "www.integral-calculator.com",
            path: "/",
            method: "GET"
        ) }
            .then { $0.fetchUTF8Async() }
            .mapCatching { try Result.from(pageVersionPattern.firstGroups(in: $0)?[1], errorIfNil: NetApiError.apiError("Could not find page version of integral calculator")).get() }
    }
}
