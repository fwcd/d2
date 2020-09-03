public class FizzBuzzCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Counts to 100, replacing 3s with 'fizz' and 5s with 'buzz",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        output.append((1...100).map {
            var s = [String]()
            if $0 % 3 == 0 {
                s.append("fizz")
            }
            if $0 % 5 == 0 {
                s.append("buzz")
            }
            return s.isEmpty ? String($0) : s.joined(separator: " ")
        }.joined(separator: ", "))
    }
}
