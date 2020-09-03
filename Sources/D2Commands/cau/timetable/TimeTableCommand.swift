import D2MessageIO
import D2Permissions

public class TimeTableCommand: StringCommand {
	public let info = CommandInfo(
		category: .cau,
		shortDescription: "Generates a time table from CAU modules",
		longDescription: "Creates a time table from CAU modules by querying the module/lecture databases",
		requiredPermissionLevel: .basic,
		hidden: true
	)

	public init() {}

	public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
		// TODO
	}
}
