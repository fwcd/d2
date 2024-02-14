public enum WikitextParseError: Error {
    case unexpectedToken(String)
    case noMoreTokens(String)
}
