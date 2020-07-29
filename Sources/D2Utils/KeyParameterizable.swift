public struct EmptyKey: StringEnum {
    public static var allCases: [EmptyKey] { [] }
    public var rawValue: String { "" }

    public init?(rawValue: String) { nil }
}

/**
 * Anything with an enumerable key.
 */
public protocol KeyParameterizable {
    associatedtype Key: StringEnum = EmptyKey
}
