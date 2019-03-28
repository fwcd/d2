import Foundation

/** A wrapper around NSRegularExpression with a more modern API. */
public struct Regex: CustomStringConvertible {
	private let pattern: NSRegularExpression
	public var rawPattern: String { return pattern.pattern }
	public var description: String { return rawPattern }
	
	public init(from str: String) throws {
		pattern = try NSRegularExpression(pattern: str)
	}
	
	public func matchCount(in str: String) -> Int {
		return pattern.numberOfMatches(in: str, range: NSRange(str.startIndex..., in: str))
	}
	
	public func matches(in str: String) -> [String] {
		// Source: https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
		
		return pattern.matches(in: str, range: NSRange(str.startIndex..., in: str))
			.compactMap { Range($0.range, in: str).map { String(str[$0]) } }
	}
	
	public func firstGroups(in str: String) -> [String]? {
		let optionalGroups = pattern.matches(in: str, range: NSRange(str.startIndex..., in: str))[safely: 0]
		
		return optionalGroups
			.map { groups in (0..<groups.numberOfRanges)
				.map { Range(groups.range(at: $0), in: str).map { String(str[$0]) } ?? "" }
		}
	}
	
	public func allGroups(in str: String) -> [[String]] {
		return pattern.matches(in: str, range: NSRange(str.startIndex..., in: str))
			.map { groups in (0..<groups.numberOfRanges)
				.map { Range(groups.range(at: $0), in: str).map { String(str[$0]) } ?? "" }
		}
	}
	
	public func replace(in str: String, with replacement: String) -> String {
		return pattern.stringByReplacingMatches(in: str, range: NSRange(str.startIndex..., in: str), withTemplate: replacement)
	}
	
	public static func escape(_ str: String) -> String {
		return NSRegularExpression.escapedPattern(for: str)
	}
}
