import Foundation
import Sword

func main() throws {
	// 'discordToken' should be declared in 'authtoken.swift'
	let client = Sword(token: discordToken)
	let handler: ClientHandler = CommandHandler()
	
	client.on(.messageCreate) { handler.on(createMessage: $0 as! Message) }
	
	print("Connecting client")
	client.connect()
}

try main()
