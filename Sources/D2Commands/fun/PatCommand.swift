import D2MessageIO
import D2Graphics
import D2Utils

public class PatCommand: Command {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Creates a pat animation",
        requiredPermissionLevel: .basic,
        platformAvailability: ["Discord"] // Due to Discord-specific CDN URLs
    )
    public let inputValueType: RichValueType = .image
    public let outputValueType: RichValueType = .gif
    private let frameCount: Int
    private let delayTime: Int

    public init(frameCount: Int = 25, delayTime: Int = 2) {
        self.frameCount = frameCount
        self.delayTime = delayTime
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let user = input.asMentions?.first else {
            output.append(errorText: "Please mention someone!")
            return
        }

        // TODO: Add MessageClient API for fetching avatars to reduce
        //       code duplication among this command and e.g. AvatarCommand
        Promise.catching { try HTTPRequest(
            scheme: "https",
            host: "cdn.discordapp.com",
            path: "/avatars/\(user.id)/\(user.avatar).png",
            query: ["size": "128"]
        ) }
            .then { $0.runAsync() }
            .listen {
                do {
                    let data = try $0.get()
                    guard !data.isEmpty else {
                        output.append(errorText: "No avatar available")
                        return
                    }

                    // Generate the animation
                    let patHand = try Image(fromPngFile: "Resources/fun/patHand.png")
                    let avatarImage = try Image(fromPng: data)
                    var gif = AnimatedGif(quantizingImage: avatarImage)

                    for _ in 0..<self.frameCount {
                        let frame = try Image(width: avatarImage.width, height: avatarImage.height)
                        var graphics = CairoGraphics(fromImage: frame)

                        graphics.draw(avatarImage)
                        graphics.draw(patHand)

                        gif.append(frame: .init(image: frame, delayTime: self.delayTime))
                    }

                    output.append(.gif(gif))
                } catch {
                    output.append(errorText: "The avatar could not be fetched \(error)")
                }
            }
    }
}
