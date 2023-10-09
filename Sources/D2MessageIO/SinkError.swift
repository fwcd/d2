public enum SinkError: Error {
    case couldNotFindClientWithName(String)
    case noMIOCommandSink
}
