import D2Graphics
import D2Utils

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

/**
 * An animation that applies a progress-dependent
 * pixel transformation function.
 */
public struct TransformAnimation<T: ImageTransform>: Animation {
    private let transform: T
    
    public init(args: String) {
        let pos: Vec2<Int>? = posPattern.firstGroups(in: args).map { Vec2<Int>(x: Int($0[1])!, y: Int($0[2])!) }
        let kvArgs: [String: String] = Dictionary(uniqueKeysWithValues: kvPattern.allGroups(in: args).map { ($0[1], $0[2]) })

        transform = T.init(at: pos, kvArgs: kvArgs)
    }

    public func renderFrame(from image: Image, to frame: inout Image, percent: Double) {
        let width = image.width
        let height = image.height
        let size = Vec2<Int>(x: width, y: height)

        for y in 0..<height {
            for x in 0..<width {
                let src = transform.sourcePos(from: Vec2(x: x, y: y), imageSize: size, percent: percent)
                if src.x >= 0 && src.x < width && src.y >= 0 && src.y < height {
                    frame[y, x] = image[src.y, src.x]
                }
            }
        }
    }
}
