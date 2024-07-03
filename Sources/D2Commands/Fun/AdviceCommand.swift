import D2NetAPIs
import D2MessageIO

public class AdviceCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Gives advice",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if input.isEmpty {
            do {
                let result = try await AdviceSlipQuery().perform()
                await output.append(embedFrom(slip: result.slip))
            } catch {
                await output.append(error, errorText: "Could not fetch advice")
            }
        } else {
            do {
                let results = try await AdviceSlipSearchQuery(searchTerm: input).perform()
                guard let slip = results.slips.first else {
                    await output.append(errorText: "No search results found")
                    return
                }
                await output.append(embedFrom(slip: slip))
            } catch {
                await output.append(error, errorText: "Could not perform search")
            }
        }
    }

    private func embedFrom(slip: AdviceSlip) -> Embed {
        Embed(
            description: ":scroll: **\(slip.advice)**"
        )
    }
}
