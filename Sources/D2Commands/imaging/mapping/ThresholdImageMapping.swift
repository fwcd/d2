import Graphics

public struct ThresholdImageMapping: ImageMapping {
    private let minThreshold: UInt8 = 0
    private let maxThreshold: UInt8 = 255
    private let threshold: UInt8

    private enum ThresholdError: Error {
        case invalidArgs(String)
    }

    public init(args: String?) throws {
        guard
            let rawThreshold = args,
            let threshold = UInt8(rawThreshold),
            threshold >= minThreshold,
            threshold <= maxThreshold else {
            throw ThresholdError.invalidArgs("Please enter a threshold between \(minThreshold) and \(maxThreshold) (inclusive)!")
        }
        self.threshold = threshold
    }

    public func apply(to image: Image) throws -> Image {
        let width = image.width
        let height = image.height
        let thresholded = try Image(width: width, height: height)

        for y in 0..<height {
            for x in 0..<width {
                thresholded[y, x] = image[y, x].luminance > threshold
                    ? .white
                    : .black
            }
        }

        return thresholded
    }
}
