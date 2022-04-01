import Foundation
import D2MessageIO

public class MicdropCommand: VoidCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Sends a micdrop GIF",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(output: any CommandOutput, context: CommandContext) {
        output.append(Embed(
            image: Embed.Image(url: URL(string: "https://media.giphy.com/media/mVJ5xyiYkC3Vm/giphy.gif")!)
        ))
    }
}
