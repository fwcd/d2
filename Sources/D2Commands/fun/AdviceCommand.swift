import D2NetAPIs
import D2MessageIO

public class AdviceCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Gives advice",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        if input.isEmpty {
            AdviceSlipQuery().perform {
                do {
                    output.append(self.embedFrom(slip: try $0.get().slip))
                } catch {
                    output.append(error, errorText: "Could not fetch advice")
                }
            }
        } else {
            AdviceSlipSearchQuery(searchTerm: input).perform {
                do {
                    let results = try $0.get()
                    guard let slip = results.slips.first else {
                        output.append(errorText: "No search results found")
                        return
                    }
                    output.append(self.embedFrom(slip: slip))
                } catch {
                    output.append(error, errorText: "Could not perform search")
                }
            }
        }
    }
    
    private func embedFrom(slip: AdviceSlip) -> Embed {
        Embed(
            description: "**\(slip.advice)**"
        )
    }
}
