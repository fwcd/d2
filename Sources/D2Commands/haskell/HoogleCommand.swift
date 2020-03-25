import Logging
import D2MessageIO
import D2Utils
import D2NetAPIs

fileprivate let log = Logger(label: "D2Commands.HoogleCommand")

public class HoogleCommand: StringCommand {
    public let info = CommandInfo(
        category: .haskell,
        shortDescription: "Hoogles a type signature",
        longDescription: "Searches for a function matching a type signature using the Hoogle search engine",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        HoogleQuery(term: input).perform {
            switch $0 {
                case let .success(results):
                    output.append(Embed(
                        title: ":closed_umbrella: Hoogle Results",
                        description: results
                            .map { """
                                ```haskell
                                \($0.item)
                                ```
                                _from \($0.module?.markdown ?? "?") in \($0.package?.markdown ?? "?")_
                                \($0.docs?.replacingOccurrences(of: "\n\n", with: "\n") ?? "_no docs_")
                                """ }
                            .joined(separator: "\n"),
                        color: 0x8900b3
                    ))
                case let .failure(error):
                    output.append(error, errorText: "An error occurred while hoogling")
            }
        }
    }
}
