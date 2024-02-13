import Foundation
import Utils

private let tokenPattern = try! LegacyRegex(from: #"token:\s*"([^"]+)""#)

public struct FastQuery {
    private let rounds: Int

    public init(rounds: Int = 2) {
        self.rounds = rounds
    }

    public func perform() -> Promise<FastNetworkSpeed, any Error> {
        Promise.catching { try HTTPRequest(scheme: "https", host: "fast.com", path: "/") }
            .then { $0.fetchHTMLAsync() }
            .thenCatching { document in
                guard let script = try document.getElementsByTag("script").last() else {
                    throw NetApiError.apiError("Could not find script on fast homepage")
                }
                let src = try script.attr("src")
                return try HTTPRequest(host: "fast.com", path: src).fetchUTF8Async()
            }
            .thenCatching { raw in
                guard let parsedToken = tokenPattern.firstGroups(in: raw) else {
                    throw NetApiError.apiError("Could not find fast token")
                }
                return try HTTPRequest(
                    host: "api.fast.com",
                    path: "/netflix/speedtest/v2",
                    query: [
                        "https": "true",
                        "token": parsedToken[1]
                    ]
                ).fetchJSONAsync(as: FastApiResponse.self)
            }
            .thenCatching { (response: FastApiResponse) in
                guard let url = response.targets.first?.url else {
                    throw NetApiError.apiError("No target found")
                }
                return measureSpeed(url: url, remainingRounds: rounds)
            }
    }

    private func measureSpeed(url: URL, remainingRounds: Int) -> Promise<FastNetworkSpeed, any Error> {
        if remainingRounds == 0 {
            return Promise(FastNetworkSpeed(megabits: 0, seconds: 0))
        }
        let request = HTTPRequest(url: url)
        let startTime = Date()
        return request.runAsync()
            .then { data in
                let seconds = -startTime.timeIntervalSinceNow
                let megabits = Double(data.count) / 125_000.0
                let speed = FastNetworkSpeed(megabits: megabits, seconds: seconds)
                return measureSpeed(url: url, remainingRounds: remainingRounds - 1)
                    .map { speed + $0 }
            }
        }
}
