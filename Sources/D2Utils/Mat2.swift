/**
 * A linear transformation in 2D euclidean space.
 */
public struct Mat2<T: IntExpressibleAlgebraicField>: Addable, Subtractable, Hashable, CustomStringConvertible {
    public let ix: T
    public let jx: T
    public let iy: T
    public let jy: T
    public var determinant: T { (ix * jy) - (jx * iy) }
    public var inverse: Mat2<T>? {
        let det = determinant
        guard det != 0 else { return nil }
        return Mat2(ix: jy / det, jx: -jx / det, iy: -iy / det, jy: ix / det)
    }
    public var description: String { ("(\(ix), \(jx))\n(\(iy), \(jy))") }
    
    public init(ix: T, jx: T, iy: T, jy: T) {
        self.ix = ix
        self.jx = jx
        self.iy = iy
        self.jy = jy
    }
    
    public static func +(lhs: Mat2<T>, rhs: Mat2<T>) -> Mat2<T> {
        Mat2(
            ix: lhs.ix + rhs.ix,
            jx: lhs.jx + rhs.jx,
            iy: lhs.iy + rhs.iy,
            jy: lhs.jy + rhs.jy
        )
    }
    
    public static func -(lhs: Mat2<T>, rhs: Mat2<T>) -> Mat2<T> {
        Mat2(
            ix: lhs.ix - rhs.ix,
            jx: lhs.jx - rhs.jx,
            iy: lhs.iy - rhs.iy,
            jy: lhs.jy - rhs.jy
        )
    }
    
    public static func *(lhs: Mat2<T>, rhs: Mat2<T>) -> Mat2<T> {
        Mat2(
            ix: lhs.ix * rhs.ix + lhs.jx * rhs.iy,
            jx: lhs.ix * rhs.jx + lhs.jx * rhs.jy,
            iy: lhs.iy * rhs.ix + lhs.jy * rhs.iy,
            jy: lhs.iy * rhs.jx + rhs.jy * rhs.jy
        )
    }
    
    public static func *(lhs: Mat2<T>, rhs: Vec2<T>) -> Vec2<T> {
        Vec2(
            x: lhs.ix * rhs.x + lhs.jx * rhs.y,
            y: lhs.iy * rhs.x + lhs.jy * rhs.y
        )
    }
    
    public static func /(lhs: Mat2<T>, rhs: Mat2<T>) -> Mat2<T>? {
        rhs.inverse.map { lhs * $0 }
    }
}
