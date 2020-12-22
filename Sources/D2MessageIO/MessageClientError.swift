public enum MessageClientError: Error {
    case couldNotFindClientWithName(String)
    case noMIOCommandClient
}
