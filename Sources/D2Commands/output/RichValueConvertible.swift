public protocol RichValueConvertible {
	var asRichValue: RichValue { get }
}

extension Int: RichValueConvertible {
	public var asRichValue: RichValue { return .text(String(self)) }
}

extension Double: RichValueConvertible {
	public var asRichValue: RichValue { return .text(String(self)) }
}

extension String: RichValueConvertible {
	public var asRichValue: RichValue { return .text(self) }
}
