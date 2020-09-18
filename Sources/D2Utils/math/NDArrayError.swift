public enum NDArrayError: Error {
    case shapeMismatch(String)
    case dimensionMismatch(String)
}
