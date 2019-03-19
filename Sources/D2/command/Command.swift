import Sword

protocol Command {
	func invoke(withMessage message: Message, args: String)
}
