import Foundation
import SwiftDiscord

func main() throws {
	let path = Bundle.main.path(forResource: "authtoken", ofType: "txt")
	let token = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
	let client = DiscordClient(token: DiscordToken(stringLiteral: token), delegate: D2ClientDelegate(), configuration: [.log(.info)])
}

main()
