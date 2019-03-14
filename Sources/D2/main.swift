import SwiftDiscord

fun main() {
	let path = Bundle.main.path(forResource: "authtoken", ofType: "txt")
	let token = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil!)
	let client = DiscordClient(token: token, delegate: D2ClientDelegate(), configuration: [.log(.info)])
}

main()
