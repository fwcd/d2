import Utils
@preconcurrency import CairoGraphics

nonisolated(unsafe) private let argsPattern = #/(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/#

public struct CropImageMapping: ImageMapping {
    private let topLeftX: Int
    private let topLeftY: Int
    private let bottomRightX: Int
    private let bottomRightY: Int

    private enum CropError: Error {
        case invalidArgs(String)
        case invalidDimensions(String)
        case outOfBounds(String)
    }

    public init(args: String?) throws {
        guard
            let rawBounds = args,
            let parsedBounds = try? argsPattern.firstMatch(in: rawBounds) else {
            throw CropError.invalidArgs("Syntax: [top left x] [top left y] [bottom right x] [bottom right y]")
        }

        (topLeftX, topLeftY, bottomRightX, bottomRightY) = (Int(parsedBounds.0)!, Int(parsedBounds.1)!, Int(parsedBounds.2)!, Int(parsedBounds.3)!)
    }

    public func apply(to image: CairoImage) throws -> CairoImage {
        let inputWidth = image.width
        let inputHeight = image.height

        guard (0..<inputHeight).contains(topLeftY), (0..<inputWidth).contains(topLeftX), (0..<inputHeight).contains(bottomRightY), (0..<inputWidth).contains(bottomRightX) else {
            throw CropError.outOfBounds("Make sure that all cropped bounds are in the image's bounds!")
        }

        let width = bottomRightX - topLeftX
        let height = bottomRightY - topLeftY

        guard width > 0, height > 0 else {
            throw CropError.invalidDimensions("Make sure that the width/height of the cropped dimensions are positive!")
        }

        let cropped = try CairoImage(width: width, height: height)

        for y in 0..<height {
            for x in 0..<width {
                cropped[y, x] = image[y + topLeftY, x + topLeftX]
            }
        }

        return cropped
    }
}
