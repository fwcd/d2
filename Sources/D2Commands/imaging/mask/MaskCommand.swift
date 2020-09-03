import D2Graphics
import D2Utils

public class MaskCommand<M>: Command where M: ImageMask {
    public private(set) var info = CommandInfo(
        category: .imaging,
        requiredPermissionLevel: .basic
    )

    public init(description: String) {
        info.shortDescription = description
        info.longDescription = description
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let image = input.asImage else {
            output.append(errorText: "Please attach an image!")
            return
        }

        do {
            let width = image.width
            let height = image.height
            let mask = M.init()
            var masked = try Image(width: width, height: height)

            for y in 0..<height {
                for x in 0..<width {
                    masked[y, x] = mask.contains(pos: Vec2(x: x, y: y), imageSize: Vec2(x: width, y: height))
                        ? image[y, x]
                        : Colors.transparent
                }
            }

            try output.append(masked)
        } catch {
            output.append(error, errorText: "Could not create masked image")
        }
    }
}
