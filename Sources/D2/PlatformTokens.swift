import D2IRCIO

struct PlatformTokens: Codable {
    let discord: String?
    let irc: [IRCConfig]?
}
