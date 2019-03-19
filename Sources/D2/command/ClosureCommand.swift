import Sword

class ClosureCommand: Command {
	private let closure: (Message, String) -> Void
	let description: String
	
	init(description: String, closure: @escaping (Message, String) -> Void) {
		self.description = description
		self.closure = closure
	}
	
	func invoke(withMessage message: Message, args: String) {
		self.closure(message, args)
	}
}
