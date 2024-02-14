public enum HangmanError: Error {
    case invalidMove
    case invalidRole(String)
    case playerHasNoRole
    case noTriesLeft
}
