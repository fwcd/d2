public enum MessageIOSinkError: Error {
    case couldNotFindClientWithName(String)
    case noMIOCommandClient
}
