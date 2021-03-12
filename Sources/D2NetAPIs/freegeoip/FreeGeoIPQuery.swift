import Utils
import Foundation

public struct FreeGeoIPQuery {
    public let host: String

    public init(host: String) {
        self.host = host.replacingOccurrences(of: "/", with: "")
    }

    public func perform() -> Promise<FreeGeoIP, Error> {
        Promise.catching { try HTTPRequest(host: "freegeoip.app", path: "/json/\(host)") }
            .then { $0.fetchJSONAsync(as: FreeGeoIP.self) }
    }
}
