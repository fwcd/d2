import SwiftDiscord
import D2Graphics

public class AnimateCommand: Command {
    public let info: CommandInfo
    public let inputValueType: RichValueType = .image
    public let outputValueType: RichValueType = .gif
    private let animation: Animation
    private let frames: Int
    private let delayTime: UInt16
    
    public init(description: String, animation: Animation, frames: Int = 30, delayTime: UInt16 = 2) {
        info = CommandInfo(
            category: .imaging,
            shortDescription: description,
            longDescription: description,
            requiredPermissionLevel: .basic
        )
        self.animation = animation
        self.frames = frames
        self.delayTime = delayTime
    }
    
    public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
        if let image = input.asImage {
            let args = input.asText ?? ""
            
            let width = image.width
            let height = image.height
            var gif = AnimatedGif(quantizingImage: image)
            
            do {
                for frameIndex in 0..<frames {
                    var frame = try Image(width: width, height: height)
                    let percent = Double(frameIndex) / Double(frames)
                    
                    try animation.renderFrame(from: image, to: &frame, percent: percent, args: args)
                    try gif.append(frame: frame, delayTime: delayTime)
                }
                
                gif.appendTrailer()
                output.append(.gif(gif))
            } catch {
                output.append(error, errorText: "Error while generating animation")
            }
        } else {
            output.append(errorText: "No image passed to AnimateCommand")
        }
    }
}
