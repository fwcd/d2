import D2Datasets
import D2MessageIO

public class HTTPCodeCommand: StringCommand {
    public let info = CommandInfo(
        category: .net,
        shortDescription: "Looks up an HTTP status code",
        helpText: "Syntax: [status code]",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let code = HTTPCodes.values[input] else {
            await output.append(errorText: "Unknown HTTP code \(input)")
            return
        }

        await output.append(Embed(
            title: "\(code.code) \(code.message)",
            description: code.description
        ))
    }
}
