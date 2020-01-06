import SwiftDiscord
import Logging
import D2Permissions
import D2Utils
import D2NetAPIs

fileprivate let log = Logger(label: "UnivISCommand")

fileprivate let rawKeyPattern = "(?:\\w+)"
fileprivate let rawValuePattern = "(?:\\w+|(?:\"[\\w ]+\"))"
fileprivate let rawCapturingKeyPattern = "(\\w+)"
fileprivate let rawCapturingValuePattern = "(?:(?:\"(.+?)\")|(\\S+))"

// Matches the arguments of the command. The first group captures the
// search parameter, the second group the (raw) key-value parameters.
fileprivate let inputPattern = try! Regex(from: "(\\w+)((?:\\s+\(rawKeyPattern)\\s*=\\s*\(rawValuePattern))+)")

// Matches a single key-value argument. The first group captures the
// key, the second (or third) group captures the value.
fileprivate let kvArgPattern = try! Regex(from: "\(rawCapturingKeyPattern)\\s*=\\s*\(rawCapturingValuePattern)")

// TODO: Use the new Arg API for this

public class UnivISCommand: StringCommand {
	public let info = CommandInfo(
		category: .cau,
		shortDescription: "Queries the UnivIS",
		longDescription: "Queries the lecture database 'UnivIS' from the CAU",
		requiredPermissionLevel: .basic
	)
	let maxResponseEntries: Int
	
	public init(maxResponseEntries: Int = 15) {
		self.maxResponseEntries = maxResponseEntries
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			guard let parsedArgs = inputPattern.firstGroups(in: input) else {
				output.append(errorText: "Syntax error: Your arguments need to match `[searchkey] [searchparameter=value]*`")
				return
			}
			guard let searchKey = UnivISSearchKey(rawValue: parsedArgs[1]) else {
				output.append(errorText: "Unrecognized search key `\(parsedArgs[1])`. Try one of:\n```\n\(UnivISSearchKey.allCases.map { $0.rawValue })\n```")
				return
			}
			
			let queryParams = try queryParameterDict(of: kvArgPattern.allGroups(in: input))
			
			try UnivISQuery(search: searchKey, params: queryParams).start { response in
				if case let .success(result) = response {
					let responseGroups = Dictionary(grouping: result.childs, by: { $0.nodeType })
					var embed = DiscordEmbed()
					
					embed.title = "UnivIS query result"
					embed.fields = Array(responseGroups
						.map { DiscordEmbed.Field(name: $0.key, value: $0.value.map { $0.shortDescription }.joined(separator: "\n")) }
						.prefix(self.maxResponseEntries))
					
					output.append(embed)
				} else if case let .failure(error) = response {
					output.append(error, errorText: "UnivIS query error.")
				}
			}
		} catch UnivISCommandError.invalidSearchParameter(let paramName) {
			output.append(errorText: "Invalid search parameter `\(paramName)`. Try one of:\n```\n\(UnivISSearchParameter.allCases.map { $0.rawValue })\n```")
		} catch {
			output.append(error)
		}
	}
	
	private func queryParameterDict(of parsedKVArgs: [[String]]) throws -> [UnivISSearchParameter: String] {
		var dict = [UnivISSearchParameter: String]()
		
		for kvArg in parsedKVArgs {
			if let searchParameter = UnivISSearchParameter(rawValue: kvArg[1]) {
				let value = kvArg[2].nilIfEmpty ?? kvArg[3]
				dict[searchParameter] = value
			} else {
				throw UnivISCommandError.invalidSearchParameter(kvArg[1])
			}
		}
		
		return dict
	}
}
