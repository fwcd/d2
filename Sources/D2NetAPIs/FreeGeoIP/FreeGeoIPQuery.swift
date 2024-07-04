import Utils
import Foundation

public struct FreeGeoIPQuery {
    public let host: String

    public init(host: String) {
        self.host = host.replacingOccurrences(of: "/", with: "")
    }

    public func perform() async throws -> FreeGeoIP {
        let request = try HTTPRequest(host: "freegeoip.app", path: "/json/\(host)")
        return try await request.fetchJSON(as: FreeGeoIP.self)
    }
}
