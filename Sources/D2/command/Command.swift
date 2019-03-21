import Sword

protocol Command {
	var description: String { get }
	var requiredPermissionLevel: PermissionLevel { get }
	
	func invoke(withMessage message: Message, args: String)
}
