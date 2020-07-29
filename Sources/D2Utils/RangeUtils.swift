fileprivate let intRangePattern = try! Regex(from: "(\\d+)\\.\\.<(\\d+)")
fileprivate let closedIntRangePattern = try! Regex(from: "(\\d+)\\.\\.\\.(\\d+)")

public func parseIntRange(from str: String) -> Range<Int>? {
    if let rawBounds = intRangePattern.firstGroups(in: str) {
        return Int(rawBounds[1])!..<Int(rawBounds[2])!
    } else {
        return nil
    }
}

public func parseClosedIntRange(from str: String) -> ClosedRange<Int>? {
    if let rawBounds = closedIntRangePattern.firstGroups(in: str) {
        return Int(rawBounds[1])!...Int(rawBounds[2])!
    } else {
        return nil
    }
}

public protocol LowBoundedIntRange {
    var count: Int { get }
    var lowerBound: Int { get }
}

extension Range: LowBoundedIntRange where Bound == Int {}

extension ClosedRange: LowBoundedIntRange where Bound == Int {}
