import D2MessageIO
import D2NetAPIs

public class JokeCommand: VoidCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Tells a joke!",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) async {
        do {
            let joke = try await JokeAPIQuery().perform()
            switch joke.type {
                case .single:
                    guard let line = joke.joke else {
                        await output.append(errorText: "The joke did not contain a joke.")
                        return
                    }
                    await output.append(Embed(
                        description: "**\(line)**"
                    ))
                case .twopart:
                    guard let setup = joke.setup, let delivery = joke.delivery else {
                        await output.append(errorText: "The joke either did not contain a setup or a delivery.")
                        return
                    }
                    await output.append(Embed(
                        title: setup,
                        description: delivery
                    ))
            }
        } catch {
            await output.append(error, errorText: "Could not fetch joke")
        }
    }
}
