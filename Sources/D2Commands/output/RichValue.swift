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
	case files([Message.FileUpload])
	case compound([RichValue])
	
	public var asText: String? {
		if case let .text(txt) = self {
			return txt
		} else if case let .compound(values) = self {
			return values.compactMap { $0.asText }.first
		} else {
			return nil
		}
	}
	public var asCode: String? {
		if case .code(let code, language: _) = self {
			return code
		} else if case let .compound(values) = self {
			return values.compactMap { $0.asCode }.first
		} else {
			return nil
		}
	}
	public var asImage: Image? {
		if case .image(let image) = self {
			return image
		} else if case let .compound(values) = self {
			return values.compactMap { $0.asImage }.first
		} else {
			return nil
		}
	}
	public var values: [RichValue] {
		switch self {
			case .none: return []
			case let .compound(values): return values
			default: return [self]
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
