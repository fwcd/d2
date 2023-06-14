import Foundation
import Utils

private let tokenPattern = try! Regex(from: #"token:\\s*"([^"]+)""#)

public struct FastQuery {
    public init() {}

    public func perform() -> Promise<FastResult, any Error> {
        Promise.catching { try HTTPRequest(host: "fast.com", path: "/") }
            .then { $0.fetchHTMLAsync() }
            .thenCatching {
                guard let script = try $0.getElementsByTag("script").last() else {
                    throw NetApiError.apiError("Could not find script on fast homepage")
                }
                let src = try script.attr("src")
                return try HTTPRequest(host: "fast.com", path: src).fetchUTF8Async()
            }
            .thenCatching {
                guard let parsedToken = tokenPattern.firstGroups(in: $0) else {
                    throw NetApiError.apiError("Could not find fast token")
                }
                let startTime = Date()
                return try HTTPRequest(
                    host: "api.fast.com",
                    path: "/netflix/speedtest/v2",
                    query: [
                        "https": "true",
                        "token": parsedToken[1]
                    ]
                ).runAsync().map {
                    let seconds = -startTime.timeIntervalSinceNow
                    let megabits = Double($0.count) * 8_000_000.0
                    return FastResult(megabitsPerSecond: megabits / seconds)
                }
            }
    }
}
