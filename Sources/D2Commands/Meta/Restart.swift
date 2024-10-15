import Foundation

struct Restart: Sendable, Codable {
    var timestamp: Date = Date()
    var instanceName: String? = nil
}
