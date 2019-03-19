import Sword

protocol Command {
	var description: String { get }
	
	func invoke(withMessage message: Message, args: String)
}
