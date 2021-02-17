public enum AkinatorError: Error {
    case noServersFound
    case sessionPatternNotFound
    case invalidStep(String)
    case invalidProgression(String)
    case invalidProbability(String)
    case startGamePatternNotFound(String)
    case invalidStartGameString(String)
    case noGuesses
}
