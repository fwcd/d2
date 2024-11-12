import Foundation

public struct HTTPCodes {
    public static let values = try! JSONDecoder().decode([String: HTTPCode].self, from: Data(contentsOf: URL(fileURLWithPath: "Resources/Net/httpCodes.json")))

    public struct HTTPCode: Codable, Sendable {
        public let code: Int
        public let message: String
        public let description: String
    }
}
