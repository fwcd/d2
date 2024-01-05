import D2NetAPIs

public class ExamCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Fetches details about CS exams at the CAU",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        CAUCSExamsQuery().perform().listen {
            do {
                let exams = try $0.get()
                // TODO: More high-level formatting
                output.append(String(describing: exams))
            } catch {
                output.append(error, errorText: "Could not query CAU CS exams")
            }
        }
    }
}
