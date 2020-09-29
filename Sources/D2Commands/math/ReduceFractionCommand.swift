import Utils

public class ReduceFractionCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Reduces a fraction",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let fraction = Rational(input) else {
            output.append(errorText: "Please enter a valid fraction!")
            return
        }

        output.append("\(fraction)")
    }
}
