import Foundation

/** A wrapper around NSRegularExpression with a more modern API. */
public struct Regex: CustomStringConvertible {
    private let pattern: NSRegularExpression

    public var caseSensitive: Bool { !pattern.options.contains(.caseInsensitive) }
    public var rawPattern: String { return pattern.pattern }
    public var description: String { return rawPattern }

    public init(from rawPattern: String, caseSensitive: Bool = true) throws {
        pattern = try NSRegularExpression(pattern: rawPattern, options: caseSensitive ? [] : [.caseInsensitive])
    }

    public func matchCount(in str: String) -> Int {
        return pattern.numberOfMatches(in: str, range: NSRange(str.startIndex..., in: str))
    }

    public func matches(in str: String) -> [String] {
        // Source: https://stackoverflow.com/questions/27880650/swift-extract-regex-matches

        return pattern.matches(in: str, range: NSRange(str.startIndex..., in: str))
            .compactMap { Range($0.range, in: str).map { String(str[$0]) } }
    }

    private func groups(from match: NSTextCheckingResult, in str: String) -> [String] {
        return (0..<match.numberOfRanges)
            .map { Range(match.range(at: $0), in: str).map { String(str[$0]) } ?? "" }
    }

    public func firstGroups(in str: String) -> [String]? {
        return pattern.matches(in: str, range: NSRange(str.startIndex..., in: str)).first
            .map { groups(from: $0, in: str) }
    }

    public func allGroups(in str: String) -> [[String]] {
        return pattern.matches(in: str, range: NSRange(str.startIndex..., in: str))
            .map { groups(from: $0, in: str) }
    }

    public func replace(in str: String, with replacement: String, casePreserving: Bool = false) -> String {
        if !casePreserving {
            return pattern.stringByReplacingMatches(in: str, range: NSRange(str.startIndex..., in: str), withTemplate: replacement)
        } else {
            guard !caseSensitive else { fatalError("Case-preserving replacement requires a case-insensitive regex! (...while trying to replace in '\(str)' with '\(replacement)')") }
            // Note that case-preserving replacement may truncate resulting substitutions if
            // matched strings are shorter than the replacement.
            return replace(in: str) { zip($0[0], replacement).map { $0.0.isLowercase ? $0.1.lowercased() : $0.1.uppercased() }.joined() }
        }
    }

    public func replace(in str: String, using replacer: ([String]) -> String) -> String {
        return replaceImpl(in: str) { replacer(groups(from: $0, in: str)) }
    }

    private func replaceImpl(in str: String, using replacer: (NSTextCheckingResult) -> String) -> String {
        var result = ""
        var i = str.startIndex

        for match in pattern.matches(in: str, range: NSRange(str.startIndex..., in: str)) {
            guard let range = Range(match.range, in: str) else { continue }
            result += str[i..<range.lowerBound]
            result += replacer(match)
            i = range.upperBound
        }

        result += str[i...]

        return result
    }

    public static func escape(_ str: String) -> String {
        return NSRegularExpression.escapedPattern(for: str)
    }
}
