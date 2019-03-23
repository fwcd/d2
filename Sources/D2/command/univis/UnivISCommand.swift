import SwiftDiscord

fileprivate let rawKeyPattern = "(?:\\w+)"
fileprivate let rawValuePattern = "(?:\\w+|(?:\"[\\w ]+\"))"
fileprivate let rawCapturingKeyPattern = "(\\w+)"
fileprivate let rawCapturingValuePattern = "(?:(?:\"(.+?)\")|(\\S+))"

// Matches the arguments of the command. The first group captures the
// search parameter, the second group the (raw) key-value parameters.
fileprivate let argsPattern = try! Regex(from: "(\\w+)((?:\\s+\(rawKeyPattern)\\s*=\\s*\(rawValuePattern))+)")

// Matches a single key-value argument. The first group captures the
// key, the second (or third) group captures the value.
fileprivate let kvArgPattern = try! Regex(from: "\(rawCapturingKeyPattern)\\s*=\\s*\(rawCapturingValuePattern)")

class UnivISCommand: Command {
	let description = "Queries the UnivIS of the CAU"
	let requiredPermissionLevel = PermissionLevel.basic
	let maxResponseEntries: Int
	
	init(maxResponseEntries: Int = 15) {
		self.maxResponseEntries = maxResponseEntries
	}
	
	func invoke(withMessage message: DiscordMessage, context: CommandContext, args: String) {
		do {
			guard let parsedArgs = argsPattern.firstGroups(in: args) else {
				message.channel?.send("Syntax error: Your arguments need to match `[searchkey] [searchparameter=value]*`")
				return
			}
			guard let searchKey = UnivISSearchKey(rawValue: parsedArgs[1]) else {
				message.channel?.send("Unrecognized search key `\(parsedArgs[1])`. Try one of:\n```\n\(UnivISSearchKey.allCases.map { $0.rawValue })\n```")
				return
			}
			
			let queryParams = try queryParameterDict(of: kvArgPattern.allGroups(in: args))
			
			try UnivISQuery(search: searchKey, params: queryParams).start { response in
				if case let .ok(result) = response {
					let responseGroups = Dictionary(grouping: result.childs, by: { $0.nodeType })
					var embed = DiscordEmbed()
					
					embed.title = "UnivIS query result"
					embed.fields = Array(responseGroups
						.map { DiscordEmbed.Field(name: $0.key, value: $0.value.map { $0.shortDescription }.joined(separator: "\n")) }
						.prefix(self.maxResponseEntries))
					
					message.channel?.send(embed: embed)
				} else if case let .error(error) = response {
					print(error)
					message.channel?.send("UnivIS query error. Check the log for more information.")
				}
			}
		} catch UnivISCommandError.invalidSearchParameter(let paramName) {
			message.channel?.send("Invalid search parameter `\(paramName)`. Try one of:\n```\n\(UnivISSearchParameter.allCases.map { $0.rawValue })\n```")
		} catch {
			print(error)
			message.channel?.send("An error occurred. Check the log for more information.")
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
