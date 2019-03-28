import D2Utils

// The first group matches the BF code
let bfCodePattern = try! Regex(from: "(?:`(?:``(?:\\w*\n)?)?)?([^`]+)`*")
