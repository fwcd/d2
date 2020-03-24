import D2MessageIO
import D2Graphics
import D2Utils

/**
 * A value of a common format that
 * can be sent to an output.
 */
public enum RichValue: Addable {
	case none
	case text(String)
	case image(Image)
	case gif(AnimatedGif)
	case code(String, language: String?)
	case embed(Embed?)
	case error(Error?, errorText: String)
	case files([Message.FileUpload])
	case compound([RichValue])
	
	public var asText: String? {
		extract { if case let .text(text) = $0 { return text } else { return nil } }
	}
	public var asCode: String? {
		extract { if case let .code(code, language: _) = $0 { return code } else { return nil } }
	}
	public var asImage: Image? {
		extract { if case let .image(image) = $0 { return image } else { return nil } }
	}
	public var asGif: AnimatedGif? {
		extract { if case let .gif(gif) = $0 { return gif } else { return nil } }
	}
	public var values: [RichValue] {
		switch self {
			case .none: return []
			case let .compound(values): return values
			default: return [self]
		}
	}
	
	private func extract<T>(using extractor: (RichValue) -> T?) -> T? {
		if let extracted = extractor(self) {
			return extracted
		} else if case let .compound(values) = self {
			return values.compactMap { $0.extract(using: extractor) }.first
		} else {
			return nil
		}
	}
	
	public static func of(values: [RichValue]) -> RichValue {
		switch values.count {
			case 0: return .none
			case 1: return values.first!
			default: return .compound(values)
		}
	}
	
	public static func +(lhs: RichValue, rhs: RichValue) -> RichValue {
		return .of(values: lhs.values + rhs.values)
	}
}
