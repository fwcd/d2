public protocol Absolutable {
    var absolute: Double { get }
}

extension Int: Absolutable {
    public var absolute: Double { Double(magnitude) }
}
extension UInt: Absolutable {
    public var absolute: Double { Double(magnitude) }
}
extension UInt32: Absolutable {
    public var absolute: Double { Double(magnitude) }
}
extension UInt64: Absolutable {
    public var absolute: Double { Double(magnitude) }
}
extension Double: Absolutable {
    public var absolute: Double { magnitude }
}
