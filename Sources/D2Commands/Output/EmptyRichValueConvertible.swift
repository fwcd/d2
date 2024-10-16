public struct EmptyRichValueConvertible: RichValueConvertible, Sendable {
    public var asRichValue: RichValue { return .none }
}
