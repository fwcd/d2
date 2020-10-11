import Graphics

public struct ScaleMapping: ImageMapping {
    private let factor: Double
    private let maxWidth: Int = 800
    private let maxHeight: Int = 800

    private enum ScaleError: Error {
        case outOfBounds(String)
        case invalidArgs(String)
    }

    public init(args: String?) throws {
        guard let factor = args.flatMap(Double.init) else {
            throw ScaleError.invalidArgs("Please input a scale factor!")
        }
        self.factor = factor
    }

    public func apply(to image: Image) throws -> Image {
        let width = Int(Double(image.width) * factor)
        let height = Int(Double(image.height) * factor)
        var scaled = try Image(width: width, height: height)

        guard (0..<maxWidth).contains(width), (0..<maxHeight).contains(height) else {
            throw ScaleError.outOfBounds("Please ensure that your size is within the bounds of \(maxWidth), \(maxHeight)!")
        }

        for y in 0..<height {
            for x in 0..<width {
                scaled[y, x] = image[Int(Double(y) / factor), Int(Double(x) / factor)]
            }
        }

        return scaled
    }
}
