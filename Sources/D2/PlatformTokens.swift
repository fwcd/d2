import D2IRCIO

struct PlatformTokens: Sendable, Codable {
    let discord: String?
    let irc: [IRCConfig]?
}
