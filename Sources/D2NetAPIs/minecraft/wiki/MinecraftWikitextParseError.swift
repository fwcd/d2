public enum MinecraftWikitextParseError: Error {
    case unexpectedToken(String)
    case noMoreTokens(String)
}
