import Foundation

public struct HTTPCodes: Sendable {
    public static let shared = Self(values: try! JSONDecoder().decode([String: HTTPCode].self, from: Data(contentsOf: URL(fileURLWithPath: "Resources/Net/httpCodes.json"))))

    public let values: [String: HTTPCode]

    public struct HTTPCode: Codable, Sendable {
        public let code: Int
        public let message: String
        public let description: String
    }
}
