import SwiftDiscord
import D2Permissions
import D2Utils

public class GrepCommand: ArgCommand {
	public let info = CommandInfo(
		category: .scripting,
		shortDescription: "Filters using a regex",
		longDescription: "Filters and outputs lines that match a given regular expression",
		requiredPermissionLevel: .vip
	)
	public let outputValueType: RichValueType = .text
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
