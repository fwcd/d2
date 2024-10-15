import Foundation
import Utils

nonisolated(unsafe) private let tokenPattern = #/token:\s*"(?<token>[^"]+)"/#

public struct FastQuery {
    private let rounds: Int

    public init(rounds: Int = 2) {
        self.rounds = rounds
    }

    public func perform() async throws -> FastNetworkSpeed {
        let request = try HTTPRequest(scheme: "https", host: "fast.com", path: "/")
        let document = try await request.fetchHTML()
        guard let script = try document.getElementsByTag("script").last() else {
            throw NetApiError.apiError("Could not find script on fast homepage")
        }
        let src = try script.attr("src")
        let raw = try await HTTPRequest(host: "fast.com", path: src).fetchUTF8()
        guard let parsedToken = try? tokenPattern.firstMatch(in: raw) else {
            throw NetApiError.apiError("Could not find fast token")
        }
        let response = try await HTTPRequest(
            host: "api.fast.com",
            path: "/netflix/speedtest/v2",
            query: [
                "https": "true",
                "token": String(parsedToken.token)
            ]
        ).fetchJSON(as: FastApiResponse.self)
        guard let url = response.targets.first?.url else {
            throw NetApiError.apiError("No target found")
        }
        return try await measureSpeed(url: url, remainingRounds: rounds)
    }

    private func measureSpeed(url: URL, remainingRounds: Int) async throws -> FastNetworkSpeed {
        if remainingRounds == 0 {
            return FastNetworkSpeed(megabits: 0, seconds: 0)
        }
        let request = HTTPRequest(url: url)
        let startTime = Date()
        let data = try await request.run()
        let seconds = -startTime.timeIntervalSinceNow
        let megabits = Double(data.count) / 125_000.0
        let speed = FastNetworkSpeed(megabits: megabits, seconds: seconds)
        return try await speed + measureSpeed(url: url, remainingRounds: remainingRounds - 1)
        }
}
