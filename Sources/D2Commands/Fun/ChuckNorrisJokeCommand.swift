import D2NetAPIs

public class ChuckNorrisJokeCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Outputs a random chuck norris joke",
        helpText: "Syntax: [first name]? [last name]?",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let args = input.split(separator: " ")
        do {
            let result = try await IcndbJokeQuery(firstName: args[safely: 0].map { String($0) }, lastName: args[safely: 1].map { String($0) }).perform()
            guard let value = result.value else {
                await output.append(errorText: "Got invalid response from API")
                return
            }
            await output.append(value.joke)
        } catch {
            await output.append(error, errorText: "Could not fetch joke")
        }
    }
}
