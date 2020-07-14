public protocol Magnitudable {
    associatedtype Magnitude

    var magnitude: Magnitude { get }
}

extension Int: Magnitudable {}
extension UInt: Magnitudable {}
extension UInt32: Magnitudable {}
extension UInt64: Magnitudable {}
extension Double: Magnitudable {}
