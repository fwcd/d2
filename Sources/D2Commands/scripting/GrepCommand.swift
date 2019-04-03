import SwiftDiscord
import D2Permissions
import D2Utils

public class GrepCommand: ArgListCommand {
	public let description = "Filters and prints lines that match a regular expression"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
	public let expectedArgCount: Int = 2
	
	public init() {}
	
	public func invoke(withInputArgs inputArgs: [String], output: CommandOutput, context: CommandContext) {
		do {
			let regex = try Regex(from: inputArgs[0])
			var result = ""
			
			for line in inputArgs[1].split(separator: "\n").map({ String($0) }) {
				if regex.matchCount(in: line) > 0 {
					result += line + "\n"
				}
			}
			
			output.append(result)
		} catch {
			output.append("Regex syntax error")
			print(error)
		}
	}
}
