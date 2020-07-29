/** Provides a fluent interface for building strings. */
public final class StringBuilder {
    public private(set) var value: String
    public var trimmedValue: String { return value.trimmingCharacters(in: .whitespacesAndNewlines) }
	
    public init(value: String = "") {
        self.value = value
    }
	
    public func append<T: LosslessStringConvertible>(_ appended: T?, or defaultValue: String = "", withSeparator separator: String = "") -> StringBuilder {
        value += (appended.map { String($0) + separator } ?? defaultValue)
        return self
    }
}
