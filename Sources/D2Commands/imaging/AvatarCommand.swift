import D2MessageIO
import D2Permissions
import CairoGraphics
import GIF
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
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .image
    private let preferredExtension: String?

    public init(preferredExtension: String? = nil) {
        self.preferredExtension = preferredExtension
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let user = input.asMentions?.first else {
            output.append(errorText: "Mention someone to begin!")
            return
        }
        guard let avatarUrl = context.client?.avatarUrlForUser(user.id, with: user.avatar, preferredExtension: preferredExtension) else {
            output.append(errorText: "Could not fetch avatar URL")
            return
        }

        Promise(.success(HTTPRequest(url: avatarUrl)))
            .then { $0.runAsync() }
            .listen {
                do {
                    let data = try $0.get()
                    if data.isEmpty {
                        output.append(errorText: "No avatar available")
                    } else if avatarUrl.path.hasSuffix(".png") {
                        output.append(.image(try CairoImage(pngData: data)))
                    } else if avatarUrl.path.hasSuffix(".gif") {
                        output.append(.gif(try GIF(data: data)))
                    } else {
                        output.append(errorText: "Unsupported image format in avatar URL: \(avatarUrl). Most likely this is a bug, since inferred image formats should be handled exhaustively in AvatarCommand.")
                    }
                } catch {
                    output.append(errorText: "The avatar could not be fetched \(error)")
                }
            }
    }
}
