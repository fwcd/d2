fileprivate let hostPortPattern = try! Regex(from: "([^:]+)(?::(\\d+))?")

public func parseHostPort(from raw: String) -> (String, Int32?)? {
    hostPortPattern.firstGroups(in: raw).map {
        ($0[1], Int32($0[2]))
    }
}
