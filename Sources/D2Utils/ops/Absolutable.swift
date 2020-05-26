public protocol Absolutable {
    var absolute: Double { get }
}

extension Int: Absolutable {
    public var absolute: Double { Double(magnitude) }
}
extension Double: Absolutable {
    public var absolute: Double { magnitude }
}