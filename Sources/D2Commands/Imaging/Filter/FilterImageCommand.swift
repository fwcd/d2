import Utils
import CairoGraphics

public class FilterImageCommand<F: ImageFilter>: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Applies an image convolution filter",
        requiredPermissionLevel: .basic
    )
    private let maxSize: Int

    public init(maxSize: Int = 30) {
        self.maxSize = maxSize
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let image = input.asImage else {
            await output.append(errorText: "Not an image")
            return
        }

        guard let size = input.asText.map(Int.init) ?? 5 else {
            await output.append(errorText: "Please provide an integer for specifying the filter size!")
            return
        }

        guard size <= maxSize else {
            await output.append(errorText: "Please use a filter size smaller or equal to \(maxSize)!")
            return
        }

        do {
            let width = image.width
            let height = image.height
            var pixels = (0..<height).map { y in (0..<width).map { x in image[y, x] } }

            for filterMatrix in F.init(size: size).matrices {
                pixels = convolve(pixels: pixels, with: filterMatrix)
            }

            let result = try CairoImage(width: width, height: height)

            for (y, row) in pixels.enumerated() {
                for (x, value) in row.enumerated() {
                    result[y, x] = value
                }
            }

            try await output.append(result)
        } catch {
            await output.append(error, errorText: "Error while processing image")
        }
    }
}
