public enum AkinatorError: Error {
    case noServersFound
    case sessionPatternNotFound
    case startGamePatternNotFound(String)
    case invalidStartGameString(String)
}
