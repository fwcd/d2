import Utils

public class ReduceFractionCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Reduces a fraction",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let fraction = Rational(input) else {
            await output.append(errorText: "Please enter a valid fraction!")
            return
        }

        await output.append("\(fraction)")
    }
}
