import Foundation
import Logging
import Utils
import SwiftSoup

fileprivate let log = Logger(label: "D2NetAPIs.IntegralCalculatorQuery")
nonisolated(unsafe) private let pageVersionPattern = #/\bpageVersion\s*=\s*(?<pageVersion>\d+)\b/#

public struct IntegralCalculatorQuery<P: IntegralQueryParams> {
    private let params: P

    public init(params: P) {
        self.params = params
    }

    public func perform() async throws -> IntegralQueryOutput {
        let pageVersion = try await fetchPageVersion()
        let params = String(data: try JSONEncoder().encode(self.params), encoding: .utf8) ?? ""
        log.info("Querying integral calculator v\(pageVersion) with params \(params)...")

        let request = try HTTPRequest(
            scheme: "https",
            host: "www.integral-calculator.com",
            path: P.endpoint,
            method: "POST",
            query: [
                "q": params,
                "v": pageVersion
            ]
        )
        let document = try await request.fetchHTML()
        let steps = try document.getElementsByClass("calc-math").map { try $0.text() }
        guard !steps.isEmpty else {
            throw NetApiError.apiError(try document.text())
        }
        return IntegralQueryOutput(steps: steps)
    }

    private func fetchPageVersion() async throws -> String {
        let request = try HTTPRequest(
            scheme: "https",
            host: "www.integral-calculator.com",
            path: "/",
            method: "GET"
        )
        let raw = try await request.fetchUTF8()
        guard let pageVersion = (try? pageVersionPattern.firstMatch(in: raw)).map({ String($0.pageVersion) }) else {
            throw NetApiError.apiError("Could not find page version of integral calculator")
        }
        return pageVersion
    }
}
