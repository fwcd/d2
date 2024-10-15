import D2MessageIO

struct AdminWhitelist: Sendable, Codable {
    var users: [UserID]
}
