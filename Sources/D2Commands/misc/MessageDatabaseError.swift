public enum MessageDatabaseError: Error {
    case missingID(String)
    case invalidID(String)
}
