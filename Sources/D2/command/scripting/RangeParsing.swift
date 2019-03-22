fileprivate let intRangePattern = try! Regex(from: "(\\d+)\\.\\.<(\\d+)")
fileprivate let closedIntRangePattern = try! Regex(from: "(\\d+)\\.\\.\\.(\\d+)")

func parseIntRange(from str: String) -> Range<Int>? {
	if let rawBounds = intRangePattern.firstGroups(in: str) {
		return Int(rawBounds[1])!..<Int(rawBounds[2])!
	} else {
		return nil
	}
}

func parseClosedIntRange(from str: String) -> ClosedRange<Int>? {
	if let rawBounds = closedIntRangePattern.firstGroups(in: str) {
		return Int(rawBounds[1])!...Int(rawBounds[2])!
	} else {
		return nil
	}
}
