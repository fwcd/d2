public protocol Magnitudable {
    associatedtype Magnitude

    var magnitude: Magnitude { get }
}

extension Int: Magnitudable {}
extension UInt: Magnitudable {}
extension Double: Magnitudable {}
