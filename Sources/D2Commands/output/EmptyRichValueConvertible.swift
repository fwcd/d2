public struct EmptyRichValueConvertible: RichValueConvertible {
    public var asRichValue: RichValue { return .none }
}
