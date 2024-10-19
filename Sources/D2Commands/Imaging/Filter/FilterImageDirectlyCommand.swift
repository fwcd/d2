import Utils
@preconcurrency import CairoGraphics

public class FilterImageDirectlyCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Applies the given image convolution kernel",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .compound([.ndArrays, .image])
    public let outputValueType: RichValueType = .image
    private let maxFilterWidth: Int
    private let maxFilterHeight: Int

    public init(
        maxFilterWidth: Int = 5,
        maxFilterHeight: Int = 5
    ) {
        self.maxFilterWidth = maxFilterWidth
        self.maxFilterHeight = maxFilterHeight
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let image = input.asImage else {
            await output.append(errorText: "Please provide an image!")
            return
        }
        guard let matrix = input.asNDArrays?.first?.asMatrix else {
            await output.append(errorText: "Please enter a matrix to be applied to the image!")
            return
        }
        guard matrix.width <= maxFilterWidth && matrix.height <= maxFilterHeight else {
            await output.append(errorText: "Please make sure that your filter is of size <= (\(maxFilterWidth), \(maxFilterHeight))!")
            return
        }

        do {
            let width = image.width
            let height = image.height
            let pixels = (0..<height).map { y in (0..<width).map { x in image[y, x] } }
            let resultPixels = await convolve(pixels: pixels, with: matrix.map(\.asDouble))

            let result = try CairoImage(width: width, height: height)

            for (y, row) in resultPixels.enumerated() {
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
