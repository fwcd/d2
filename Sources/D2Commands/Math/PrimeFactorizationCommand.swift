import Utils

public class PrimeFactorizationCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Finds the prime factorization of a number",
        requiredPermissionLevel: .basic
    )
    private let upperLimit: UInt64

    public init(upperLimit: UInt64 = 2 << 20) {
        self.upperLimit = upperLimit
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let input = UInt64(input), input >= 1 else {
            await output.append(errorText: "Only positive integers >= 1 can be prime-factorized!")
            return
        }
        guard input <= upperLimit else {
            await output.append(errorText: "Your number should be <= \(upperLimit)!")
            return
        }
        await output.append(primeFactorization(input).sorted().map { "\($0)" }.joined(separator: " * "))
    }
}
