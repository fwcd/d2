import Utils

// The first group matches the BF code
let bfCodePattern = try! LegacyRegex(from: "(?:`(?:``(?:\\w*\n)?)?)?([^`]+)`*")
