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

    public func invoke(output: CommandOutput, context: CommandContext) {
        JokeAPIQuery().perform().listen {
            do {
                let joke = try $0.get()
                if joke.type == .single {
                    guard let line = joke.joke else {
                        output.append(errorText: "The joke did not contain a joke.")
                        return
                    }
                    output.append(Embed(
                        title: line
                    ))
                } else if joke.type == .twopart {
                    guard let setup = joke.setup, let delivery = joke.delivery else {
                        output.append(errorText: "The joke either did not contain a setup or a delivery.")
                        return
                    }
                    output.append(Embed(
                        title: setup,
                        description: delivery
                    ))
                }
            } catch {
                output.append(error, errorText: "Could not fetch joke")
            }
        }
    }
}
