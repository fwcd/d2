import D2NetAPIs

public class ChuckNorrisJokeCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Outputs a random chuck norris joke",
        helpText: "Syntax: [first name]? [last name]?",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let args = input.split(separator: " ")
        IcndbJokeQuery(firstName: args[safely: 0].map { String($0) }, lastName: args[safely: 1].map { String($0) }).perform {
            switch $0 {
                case .success(let result):
                    guard let value = result.value else {
                        output.append(errorText: "Got invalid response from API")
                        return
                    }
                    output.append(value.joke)
                case .failure(let error):
                    output.append(error, errorText: "Could not fetch joke")
            }
        }
    }
}
