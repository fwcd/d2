import D2Graphics
import D2Utils

/**
 * An animation that applies a progress-dependent
 * pixel transformation function.
 */
public struct TransformAnimation<T>: Animation where T: ImageTransform {
    public typealias Key = UnionStringEnum<T.Key, TransformKey>

    public enum TransformKey: String, StringEnum {
        case virtualedges
    }

    private let transform: T
    private let useVirtualEdges: Bool
    
    public init(pos: Vec2<Int>?, kvArgs: [Key: String]) {
        let transformKvArgs = Dictionary(uniqueKeysWithValues: kvArgs.compactMap { (k, v) in T.Key(rawValue: k.rawValue).map { ($0, v) } })
        transform = T.init(at: pos, kvArgs: transformKvArgs)
        useVirtualEdges = kvArgs[Key.virtualedges].flatMap(Bool.init) ?? false
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
                } else if useVirtualEdges {
                    frame[y, x] = image[
                        max(0, min(height - 1, src.y)),
                        max(0, min(width - 1, src.x))
                    ]
                }
            }
        }
    }
}
