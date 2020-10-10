import D2MessageIO
import D2Permissions
import Graphics
import Utils
import Foundation
import Logging

fileprivate let log = Logger(label: "D2Commands.AvatarCommand")

public class AvatarCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Fetches the avatar of a user",
        longDescription: "Fetches the user's profile picture and outputs it in PNG form",
        helpText: "Syntax: [@user]",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let user = input.asMentions?.first else {
            output.append(errorText: "Mention someone to begin!")
            return
        }
        guard let url = context.client?.avatarUrlForUser(user.id, with: user.avatar) else {
            output.append(errorText: "Could not fetch avatar URL")
            return
        }

        Promise.catching { HTTPRequest(url: url) }
            .then { $0.runAsync() }
            .listen {
                do {
                    let data = try $0.get()
                    if data.isEmpty {
                        output.append(errorText: "No avatar available")
                    } else {
                        output.append(.image(try Image(fromPng: data)))
                    }
                } catch {
                    output.append(errorText: "The avatar could not be fetched \(error)")
                }
            }
    }
}
