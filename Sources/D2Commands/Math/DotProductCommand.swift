import Utils

public class DotProductCommand: Command {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Computes the dot product",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays
    public let outputValueType: RichValueType = .ndArrays

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let factors = input.asNDArrays else {
            await output.append(errorText: "Please specify the input in the form of vectors, e.g. `(1, 2, 3, 4) (1, 1, (1, 1)`")
            return
        }
        guard factors.count == 2 else {
            await output.append(errorText: "Please input exactly two vectors.")
            return
        }

        do {
            await output.append(.ndArrays([NDArray(try factors[0].dot(factors[1]))]))
        } catch {
            await output.append(error, errorText: "Could not compute dot product: \(error)")
        }
    }
}
