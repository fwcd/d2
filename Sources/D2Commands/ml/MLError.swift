public enum MLError: Error {
    case invalidFormat(String)
    case illegalState(String)
    case sizeMismatch(String)
}
