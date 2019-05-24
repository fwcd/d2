import SwiftDiscord
import D2Permissions
import D2Script

public class D2ScriptCommand: StringCommand {
	public let description: String
	public let sourceFile: String = #file
	public let requiredPermissionLevel: PermissionLevel
	private let executor: D2ScriptExecutor
	
	public init(executor: D2ScriptExecutor) {
		self.executor = executor
		description = executor.topLevelStorage[string: "description"] ?? "Anonymous D2Script"
		requiredPermissionLevel = executor.topLevelStorage[string: "requiredPermissionLevel"].flatMap { PermissionLevel.of($0) } ?? .vip
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		let commandNames = executor.topLevelStorage.commandNames
		if commandNames.count > 1 {
			output.append("Ambiguous invocation, there is more than one command in the executor's storage: \(commandNames)")
		} else if let commandName = commandNames.first {
			executor.call(command: commandName)
		} else {
			output.append("No invokable command found in the executor's storage")
		}
	}
}
