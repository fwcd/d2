import Utils

/**
 * A (bijective) transformation function
 * that distorts the image.
 */
public protocol ImageTransform: KeyParameterizable {
    init(at pos: Vec2<Int>?, kvArgs: [Key: String])

    /**
    * Inversely applies this function,
    * i.e. fetches the position of the pixel
    * in the source image given a destination
    * position.
    */
    func sourcePos(from destPos: Vec2<Int>, imageSize: Vec2<Int>, percent: Double) -> Vec2<Int>
}
