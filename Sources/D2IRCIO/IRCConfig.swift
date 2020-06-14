public struct IRCConfig: Codable {
    public let host: String
    public let port: Int
    public let nickname: String
    public let password: String?
    public let autojoinedChannels: [String]?
}
