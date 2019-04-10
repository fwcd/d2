import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let argsPattern = try! Regex(from: "(\\S+)((?:\\s+--\\S+)*)\\s+([\\s\\S]+)")
fileprivate let flagPattern = try! Regex(from: "--(\\S+)")
fileprivate let trimPattern = try! Regex(from: "`(?:``(?:.+)?\n?)?([^`]+)`(?:``)?")

public class ToFileCommand: Command {
	public let description = "Writes text to a file"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext) {
		let combinedArgs = "\(args) \(input?.content ?? "")"
		
		if let parsedArgs = argsPattern.firstGroups(in: combinedArgs) {
			let filename = parsedArgs[1]
			let flags = parsedArgs[2].nilIfEmpty.map { flagPattern.allGroups(in: $0).map { $0[1] } } ?? []
			let rawContent = parsedArgs[3]
			let content = flags.contains("raw") ? rawContent : trim(rawContent: rawContent)
			
			guard let data = content.data(using: .utf8) else {
				output.append("Could not encode file data as UTF-8")
				return
			}
			
			output.append([DiscordFileUpload(data: data, filename: filename, mimeType: "plain/text")])
		} else {
			output.append("Syntax error: Use `[filename] [--raw]? [content...]`")
		}
	}
	
	private func trim(rawContent: String) -> String {
		return trimPattern.firstGroups(in: rawContent)?[safely: 1] ?? rawContent
	}
}
