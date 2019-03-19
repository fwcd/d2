import Sword

protocol ClientHandler {
	func on(createMessage message: Message)
}
