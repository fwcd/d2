import Foundation

public struct Ports {
    public static let values = try! JSONDecoder().decode([Int: [Service]].self, from: Data(contentsOf: URL(fileURLWithPath: "Resources/Net/ports.json")))

    public struct Service: Codable, Sendable {
        public let description: String
        public let udp: Bool
        public let status: String
        public let port: String
        public let tcp: Bool
    }
}
