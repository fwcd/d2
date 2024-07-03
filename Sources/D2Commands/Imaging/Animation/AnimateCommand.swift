import D2MessageIO
import CairoGraphics
import GIF
import Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.AnimateCommand")

/// Matches a single integer vector.
///
/// The first capture describes the x-coordinate
/// and the second capture the y-coordinate of the
/// position where the transform is applied.
fileprivate let posPattern = #/(-?\d+)\s+(-?\d+)/#

/// Matches a single key-value argument.
fileprivate let kvPattern = #/(\w+)\s*=\s*(\S+)/#

fileprivate let virtualEdgesParameter = "virtualedges"
fileprivate let framesParameter = "frames"

public class AnimateCommand<A>: Command where A: Animation {
    public let info: CommandInfo
    public let inputValueType: RichValueType = .either([.gif, .image])
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

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        let args = input.asText ?? ""
        let typingIndicator = context.channel.map { TypingIndicator(on: $0) }
        await typingIndicator?.start()

        // Parse user-specified args
        let pos: Vec2<Int>? = (try? posPattern.firstMatch(in: args)).map { Vec2<Int>(x: Int($0.1)!, y: Int($0.2)!) }
        let kvArgs: [String: String] = Dictionary(uniqueKeysWithValues: args.matches(of: kvPattern).map { (String($0.1), String($0.2)) })

        let frameCount = kvArgs[framesParameter].flatMap(Int.init) ?? defaultFrameCount

        guard frameCount <= maxFrameCount else {
            await output.append(errorText: "Please specify less than \(maxFrameCount) frames!")
            return
        }

        // Render the animation
        do {
            guard let animationKvArgs = kvArgs
                .filter({ (k, _) in k != framesParameter })
                .sequenceMap({ (k, v) in A.Key(rawValue: k).map { ($0, v) } })
                .map(Dictionary.init(uniqueKeysWithValues:)) else {
                await output.append(errorText: "Invalid keys. Try using only these: \(kvParameters.map { "`\($0)`" }.joined(separator: ", "))")
                return
            }

            log.trace("Creating animation")
            let animation = try A.init(pos: pos, kvArgs: animationKvArgs)

            if let image = input.asImage {
                log.trace("Fetching image size")
                let width = image.width
                let height = image.height

                log.debug("Creating gif")
                var gif = GIF(quantizingImage: image)

                for i in 0..<frameCount {
                    log.debug("Creating frame \(i)")
                    let frame = try CairoImage(width: width, height: height)
                    let percent = Double(i) / Double(frameCount)

                    log.debug("Rendering frame \(i)")
                    try animation.renderFrame(from: image, to: frame, percent: percent)
                    gif.frames.append(.init(image: frame, delayTime: delayTime))

                    await Task.yield()
                }

                await output.append(.gif(gif))
            } else if let sourceGif = input.asGif {
                var gif = sourceGif
                let frameCount = sourceGif.frames.count

                gif.frames = []
                for (i, f) in sourceGif.frames.enumerated() {
                    let frame = try CairoImage(width: f.image.width, height: f.image.height)
                    let percent = Double(i) / Double(frameCount)

                    try animation.renderFrame(from: f.image, to: frame, percent: percent)
                    gif.frames.append(.init(image: frame, delayTime: f.delayTime))

                    await Task.yield()
                }

                await output.append(.gif(gif))
            } else {
                await output.append(errorText: "No image passed to AnimateCommand")
            }
        } catch {
            await output.append(error, errorText: "Error while generating animation")
        }

        await typingIndicator?.stop()
    }
}
