public enum AkinatorError: Error {
    case noServersFound
    case sessionPatternNotFound
    case startGamePatternNotFound
    case invalidStartGameString(String)
}
