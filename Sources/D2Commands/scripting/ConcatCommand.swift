import SwiftDiscord
import D2Permissions

public class ConcatCommand: Command {
	public let info = CommandInfo(
		category: .scripting,
		shortDescription: "Concatenates the input values",
		longDescription: "Concatenates a compound input as text",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .compound([.text])
	public let outputValueType: RichValueType = .text
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let separator = " "
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		output.append(input.values.compactMap { $0.asText }.joined(separator: separator))
	}
}
