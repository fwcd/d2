import D2IRCIO

struct PlatformTokens: Codable {
	let discord: String?
	let telegram: String?
	let irc: [IRCConfig]?
}
