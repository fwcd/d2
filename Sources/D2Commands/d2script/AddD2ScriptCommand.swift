import D2MessageIO
import D2Permissions
import D2Utils
import D2Script

fileprivate let codePattern = try! Regex(from: "(?:`(?:``(?:\\w*\n)?)?)?([^`]+)`*")

// TODO: Use code command instead of StringCommand

public class AddD2ScriptCommand: StringCommand {
	public let info = CommandInfo(
		category: .d2script,
		shortDescription: "Adds a D2 command written in D2Script",
		longDescription: "Dynamically adds a D2Script-based command to the command registry at runtime",
		requiredPermissionLevel: .admin
	)
	private let parser = D2ScriptParser()
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		if let code = codePattern.firstGroups(in: input)?[1] {
			do {
				let command = try D2ScriptCommand(script: try parser.parse(code))
				let name = command.name
				guard !name.contains(" ") else {
					output.append("Command name '\(name)' may not contain spaces")
					return
				}
				
				let registry = context.registry
				registry[name] = command
				output.append(":ballot_box_with_check: Added/updated command `\(name)`")
			} catch D2ScriptCommandError.noCommandDefined(let msg) {
				output.append("No command defined: \(msg)")
			} catch D2ScriptCommandError.multipleCommandsDefined(let msg) {
				output.append("Multiple commands defined: \(msg)")
			} catch {
				print(error)
				output.append("Could not parse code.")
			}
		} else {
			output.append("Did not recognize code. \(info.helpText!)")
		}
	}
}
