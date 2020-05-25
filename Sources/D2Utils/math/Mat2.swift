import Foundation

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
    public var asMatrix: Matrix<T> { Matrix(width: 2, height: 2, values: [ix, jx, iy, jy]) }
    public var asNDArray: NDArray<T> { try! NDArray([ix, jx, iy, jy], shape: [2, 2]) }
    public var description: String { ("(\(ix), \(jx))\n(\(iy), \(jy))") }
    
    public init(ix: T, jx: T, iy: T, jy: T) {
        self.ix = ix
        self.jx = jx
        self.iy = iy
        self.jy = jy
    }
    
    public static func zero() -> Mat2<T> {
        Mat2(
            ix: 0, jx: 0,
            iy: 0, jy: 0
        )
    }
    
    public static func identity() -> Mat2<T> {
        Mat2(
            ix: 1, jx: 0,
            iy: 0, jy: 1
        )
    }
    
    public static func rotation(by angle: Double) -> Mat2<Double> {
        Mat2<Double>(
            ix: cos(angle), jx: -sin(angle),
            iy: sin(angle), jy: cos(angle)
        )
    }
    
    public static func diagonal(x: T, y: T) -> Mat2<T> {
        Mat2(
            ix: x, jx: 0,
            iy: 0, jy: y
        )
    }
    
    public static func +(lhs: Mat2<T>, rhs: Mat2<T>) -> Mat2<T> {
        Mat2(
            ix: lhs.ix + rhs.ix, jx: lhs.jx + rhs.jx,
            iy: lhs.iy + rhs.iy, jy: lhs.jy + rhs.jy
        )
    }
    
    public static func -(lhs: Mat2<T>, rhs: Mat2<T>) -> Mat2<T> {
        Mat2(
            ix: lhs.ix - rhs.ix, jx: lhs.jx - rhs.jx,
            iy: lhs.iy - rhs.iy, jy: lhs.jy - rhs.jy
        )
    }
    
    public static func *(lhs: Mat2<T>, rhs: Mat2<T>) -> Mat2<T> {
        Mat2(
            ix: lhs.ix * rhs.ix + lhs.jx * rhs.iy, jx: lhs.ix * rhs.jx + lhs.jx * rhs.jy,
            iy: lhs.iy * rhs.ix + lhs.jy * rhs.iy, jy: lhs.iy * rhs.jx + lhs.jy * rhs.jy
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

extension NDArray {
    public var asMat2: Mat2<T>? {
        shape == [2, 2] ? Mat2(ix: values[0], jx: values[1], iy: values[2], jy: values[3]) : nil
    }
}