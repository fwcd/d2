import D2Utils

public class PrimeFactorizationCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Finds the prime factorization of a number",
        requiredPermissionLevel: .basic
    )
    private let upperLimit: UInt

    public init(upperLimit: UInt = 2 << 16) {
        self.upperLimit = upperLimit
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let input = UInt(input), input >= 1 else {
            output.append(errorText: "Only positive integers >= 1 can be prime-factorized!")
            return
        }
        guard input <= upperLimit else {
            output.append(errorText: "Your number should be <= \(upperLimit)!")
            return
        }
        output.append(primeFactorization(input).map { "\($0)" }.joined(separator: " * "))
    }
}
