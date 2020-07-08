import D2Utils

/**
 * A mask "cutting out" a certain part
 * of the image.
 */
public protocol ImageMask {
    init()

    func contains(pos: Vec2<Int>, imageSize: Vec2<Int>) -> Bool
}
