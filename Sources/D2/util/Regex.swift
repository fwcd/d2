import Foundation

/** A wrapper around NSRegularExpression with a more modern API. */
struct Regex {
	let pattern: NSRegularExpression
	
	init(from str: String) throws {
		pattern = try NSRegularExpression(pattern: str)
	}
	
	func matchCount(in str: String) -> Int {
		return pattern.numberOfMatches(in: str, range: NSRange(str.startIndex..., in: str))
	}
	
	func matches(in str: String) -> [String] {
		// Source: https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
		
		return pattern.matches(in: str, range: NSRange(str.startIndex..., in: str))
			.compactMap { Range($0.range, in: str).map { String(str[$0]) } }
	}
	
	func firstGroups(in str: String) -> [String]? {
		let optionalGroups = pattern.matches(in: str, range: NSRange(str.startIndex..., in: str))[safe: 0]
		
		return optionalGroups.map { groups in
			(0..<groups.numberOfRanges)
				.map { Range(groups.range(at: $0), in: str).map { String(str[$0]) } ?? "" }
		}
	}
}
