public enum UltimateGuitarTabParserError: Error {
    case tagMismatch(String)
    case orphanClosingTag(String)
    case unexpectedEOF
}
