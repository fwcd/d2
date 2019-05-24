import SwiftDiscord
import D2Permissions
import D2Script

public class D2ScriptCommand: StringCommand {
	public let description: String
	public let sourceFile: String = #file
	public let requiredPermissionLevel: PermissionLevel
	public let name: String
	private let script: D2Script
	
	public init(script: D2Script) throws {
		self.script = script
		
		let executor = D2ScriptExecutor()
		executor.run(script)
		
		let commandNames = executor.topLevelStorage.commandNames
		guard let name = commandNames.first else { throw D2ScriptCommandError.noCommandDefined("Script defines no 'command { ... }' blocks") }
		guard commandNames.count == 1 else { throw D2ScriptCommandError.multipleCommandsDefined("Currently only one command declaration per script is supported") }
		
		self.name = name
		description = executor.topLevelStorage[string: "description"] ?? "Anonymous D2Script"
		requiredPermissionLevel = executor.topLevelStorage[string: "requiredPermissionLevel"].flatMap { PermissionLevel.of($0) } ?? .vip
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		let executor = D2ScriptExecutor()
		executor.run(script)
		
		let storage = executor.topLevelStorage
		
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
		
		executor.call(command: name)
	}
}
