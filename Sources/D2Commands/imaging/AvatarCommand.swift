import D2MessageIO
import D2Permissions
import D2Graphics
import D2Utils
import Foundation
import Logging

fileprivate let log = Logger(label: "D2Commands.AvatarCommand")

public class AvatarCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Fetches the avatar of a user",
        longDescription: "Fetches the user's profile picture and outputs it in PNG form",
        helpText: "Syntax: [@user]",
        requiredPermissionLevel: .basic,
        platformAvailability: ["Discord"] // Due to Discord-specific CDN URLs
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let user = input.asMentions?.first else {
            output.append(errorText: "Mention someone to begin!")
            return
        }

        Promise.catching { try HTTPRequest(
            scheme: "https",
            host: "cdn.discordapp.com",
            path: "/avatars/\(user.id)/\(user.avatar).png",
            query: ["size": "256"]
        ) }
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
