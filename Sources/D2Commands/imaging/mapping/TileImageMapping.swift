import Utils
import Graphics

fileprivate let argsPattern = try! Regex(from: "(x|y)?\\s*(\\d+)?")

public struct TileImageMapping: ImageMapping {
    private let maxWidth: Int = 2000
    private let maxHeight: Int = 2000
    private let axis: Axis
    private let replicas: Int

    private enum TileError: Error {
        case invalidArgs(String)
        case tooLarge(String)
    }

    public init(args: String?) throws {
        guard
            let text = args,
            let parsed = argsPattern.firstGroups(in: text),
            let axis = parsed[1].isEmpty ? .x : Axis(rawValue: parsed[1]),
            let replicas = parsed[2].isEmpty ? 2 : Int(parsed[2]) else {
            throw TileError.invalidArgs("Syntax: [x|y]? [number of replicas]?")
        }
        self.axis = axis
        self.replicas = replicas
    }

    public func apply(to image: Image) throws -> Image {
        let width = image.width
        let height = image.height
        let newWidth: Int
        let newHeight: Int

        switch axis {
            case .x: (newWidth, newHeight) = (width * replicas, height)
            case .y: (newWidth, newHeight) = (width, height * replicas)
        }

        guard newWidth <= maxWidth && newHeight <= maxHeight else {
            throw TileError.tooLarge("Output image dimensions should not exceed \(maxWidth) x \(maxHeight)")
        }

        let pixels = (0..<height).map { y in (0..<width).map { x in image[y, x] } }
        let tiled = try Image(width: newWidth, height: newHeight)

        for y in 0..<height {
            for x in 0..<width {
                for i in 0..<replicas {
                    switch axis {
                        case .x: tiled[y, x + (i * width)] = pixels[y][x]
                        case .y: tiled[y + (i * height), x] = pixels[y][x]
                    }
                }
            }
        }

        return tiled
    }
}
