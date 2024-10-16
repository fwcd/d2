import D2MessageIO
import D2Permissions
import CairoGraphics
import GIF
import Utils
import Foundation
import Logging

fileprivate let log = Logger(label: "D2Commands.AvatarCommand")

public class AvatarUrlCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Fetches the URL of a user's avatar",
        longDescription: "Fetches the user's profile picture and outputs a URL pointing to it",
        helpText: "Syntax: [@user]",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .urls

    public init() {}

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let user = input.asMentions?.first else {
            await output.append(errorText: "Mention someone to begin!")
            return
        }
        guard let avatarUrl = await context.sink?.avatarUrlForUser(user.id, with: user.avatar) else {
            await output.append(errorText: "Could not fetch avatar URL")
            return
        }

        await output.append(.urls([avatarUrl]))
    }
}
