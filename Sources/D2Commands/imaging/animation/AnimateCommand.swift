import D2MessageIO
import D2Graphics
import D2Utils
import Logging

fileprivate let log = Logger(label: "AnimateCommand")

public class AnimateCommand<A: Animation>: Command {
    public let info: CommandInfo
    public let inputValueType: RichValueType = .image
    public let outputValueType: RichValueType = .gif
    private let defaultFrameCount: Int
    private let delayTime: Int
    
    public init(description: String, defaultFrameCount: Int = 30, delayTime: Int = 2) {
        info = CommandInfo(
            category: .imaging,
            shortDescription: description,
            longDescription: description,
            requiredPermissionLevel: .basic
        )
        self.defaultFrameCount = defaultFrameCount
        self.delayTime = delayTime
    }
    
    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        let args = input.asText ?? ""
        let typingIndicator = context.channel.map { TypingIndicator(on: $0) }
        typingIndicator?.startAsync()

        do {
            log.trace("Creating animation")
            let animation = try A.init(args: args)

            if let image = input.asImage {
                log.trace("Fetching image size")
                let width = image.width
                let height = image.height

                log.debug("Creating gif")
                var gif = AnimatedGif(quantizingImage: image)
                
                for i in 0..<defaultFrameCount {
                    log.debug("Creating frame \(i)")
                    var frame = try Image(width: width, height: height)
                    let percent = Double(i) / Double(defaultFrameCount)
                    
                    log.debug("Rendering frame \(i)")
                    try animation.renderFrame(from: image, to: &frame, percent: percent)
                    gif.append(frame: .init(image: frame, delayTime: delayTime))
                }
                
                output.append(.gif(gif))
            } else if let sourceGif = input.asGif {
                var gif = sourceGif
                let frameCount = sourceGif.frames.count

                gif.frames = try sourceGif.frames.enumerated().map { (i, f) in
                    var frame = try Image(width: f.image.width, height: f.image.height)
                    let percent = Double(i) / Double(frameCount)

                    try animation.renderFrame(from: f.image, to: &frame, percent: percent)
                    return .init(image: frame, delayTime: f.delayTime)
                }
                
                output.append(.gif(gif))
            } else {
                output.append(errorText: "No image passed to AnimateCommand")
            }
        } catch {
            output.append(error, errorText: "Error while generating animation")
        }

        typingIndicator?.stop()
    }
}
