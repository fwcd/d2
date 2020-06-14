struct PlatformTokens: Codable {
	let discord: String?
	let telegram: String?
	let irc: [IRC]?

	struct IRC: Codable {
		let host: String
		let port: Int
		let nickname: String?
		let password: String?
	}
}
