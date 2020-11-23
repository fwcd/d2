import Utils
import Graphics

public class HugCommand: Command {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Hugs someone",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let user = input.asMentions?.first else {
            output.append(errorText: "Please mention someone!")
            return
        }
        guard let avatarUrl = context.client?.avatarUrlForUser(user.id, with: user.avatar, size: 128, preferredExtension: "png") else {
            output.append(errorText: "Could not fetch avatar URL")
            return
        }

        Promise(.success(HTTPRequest(url: avatarUrl)))
            .then { $0.runAsync() }
            .listen {
                do {
                    let image = try Image(fromPng: $0.get())
                    let rawTemplate = try Image(fromPngFile: "Resources/fun/hugTemplate.png")
                    let green = Color(rgb: 0x00FF03)
                    let (topLeft, bottomRight) = findBoundingBox(in: rawTemplate) { $0.squaredEuclideanDistance(to: green) < 0.01 }
                    let template = try colorToAlpha(in: rawTemplate, color: green, squaredThreshold: 0.4)
                    let composition = try composeImage(from: template, with: image, between: topLeft, and: bottomRight)
                    try output.append(composition)
                } catch {
                    output.append(error, errorText: "Could not create hug image. :(")
                }
            }
    }
}
