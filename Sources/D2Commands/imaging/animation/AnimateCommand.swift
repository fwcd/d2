import D2MessageIO
import D2Graphics
import D2Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.AnimateCommand")

/**
 * Matches a single integer vector.
 *
 * The first capture describes the x-coordinate
 * and the second capture the y-coordinate of the
 * position where the transform is applied.
 */
fileprivate let posPattern = try! Regex(from: "(-?\\d+)\\s+(-?\\d+)")

/**
 * Matches a single key-value argument.
 */
fileprivate let kvPattern = try! Regex(from: "(\\w+)\\s*=\\s*(\\S+)")

fileprivate let virtualEdgesParameter = "virtualedges"
fileprivate let framesParameter = "frames"

public class AnimateCommand<A>: Command where A: Animation {
    public let info: CommandInfo
    public let inputValueType: RichValueType = .image
    public let outputValueType: RichValueType = .gif

    private let kvParameters: [String]
    private let defaultFrameCount: Int
    private let maxFrameCount: Int
    private let delayTime: Int

    public init(description: String, defaultFrameCount: Int = 30, maxFrameCount: Int = 300, delayTime: Int = 2) {
        let kvParameters = [framesParameter] + A.Key.allCases.map { $0.rawValue }
        info = CommandInfo(
            category: .imaging,
            shortDescription: description,
            longDescription: description,
            helpText: """
                Syntax: `[x?] [y?] [key=value...]`
                Available Keys: \(kvParameters.map { "`\($0)`" }.joined(separator: ", "))

                Example: `80 20\(kvParameters.first.map { " \($0)=2" } ?? "")`
                """,
            requiredPermissionLevel: .basic
        )

        self.kvParameters = kvParameters
        self.defaultFrameCount = defaultFrameCount
        self.maxFrameCount = maxFrameCount
        self.delayTime = delayTime
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        let args = input.asText ?? ""
        let typingIndicator = context.channel.map { TypingIndicator(on: $0) }
        typingIndicator?.startAsync()

        // Parse user-specified args
        let pos: Vec2<Int>? = posPattern.firstGroups(in: args).map { Vec2<Int>(x: Int($0[1])!, y: Int($0[2])!) }
        let kvArgs: [String: String] = Dictionary(uniqueKeysWithValues: kvPattern.allGroups(in: args).map { ($0[1], $0[2]) })

        let frameCount = kvArgs[framesParameter].flatMap(Int.init) ?? defaultFrameCount

        guard frameCount <= maxFrameCount else {
            output.append(errorText: "Please specify less than \(maxFrameCount) frames!")
            return
        }

        // Render the animation
        do {
            guard let animationKvArgs = kvArgs
                .filter({ (k, _) in k != framesParameter })
                .sequenceMap({ (k, v) in A.Key(rawValue: k).map { ($0, v) } })
                .map(Dictionary.init(uniqueKeysWithValues:)) else {
                output.append(errorText: "Invalid keys. Try using only these: \(kvParameters.map { "`\($0)`" }.joined(separator: ", "))")
                return
            }

            log.trace("Creating animation")
            let animation = try A.init(pos: pos, kvArgs: animationKvArgs)

            if let image = input.asImage {
                log.trace("Fetching image size")
                let width = image.width
                let height = image.height

                log.debug("Creating gif")
                var gif = AnimatedGif(quantizingImage: image)

                for i in 0..<frameCount {
                    log.debug("Creating frame \(i)")
                    var frame = try Image(width: width, height: height)
                    let percent = Double(i) / Double(frameCount)

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
