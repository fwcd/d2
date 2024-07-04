public class MockifyCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Converts text into letters with rAndOm CaPs",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        await output.append(mockify(input))
    }

    private func mockify(_ input: String) -> String {
        return input.map { Bool.random() ? $0.lowercased() : $0.uppercased() }.joined()
    }
}
