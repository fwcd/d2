import D2MessageIO

struct AdminWhitelist: Codable {
    var users: [UserID]
}
