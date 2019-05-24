import SwiftDiscord
import D2Permissions
import D2Script

public class D2ScriptCommand: StringCommand {
	public let description: String
	public let sourceFile: String = #file
	public let requiredPermissionLevel: PermissionLevel
	private let script: D2Script
	
	public init(script: D2Script) {
		self.script = script
		
		let executor = D2ScriptExecutor()
		executor.run(script)
		description = executor.topLevelStorage[string: "description"] ?? "Anonymous D2Script"
		requiredPermissionLevel = executor.topLevelStorage[string: "requiredPermissionLevel"].flatMap { PermissionLevel.of($0) } ?? .vip
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		let executor = D2ScriptExecutor()
		executor.run(script)
		
		let storage = executor.topLevelStorage
		let commandNames = storage.commandNames
		
		// Add Discord commands
		storage[function: "output"] = {
			guard let value = $0.first else {
				output.append("output(...) received no arguments")
				return nil
			}
			switch value {
				case let .string(str)?:
					output.append(str)
				case let .number(num)?:
					output.append(String(num))
				default:
					output.append(String(describing: value))
			}
			return nil
		}
		
		if commandNames.count > 1 {
			output.append("Ambiguous invocation, there is more than one command in the executor's storage: \(commandNames)")
		} else if let commandName = commandNames.first {
			executor.call(command: commandName)
		} else {
			output.append("No invokable command found in the executor's storage")
		}
	}
}
