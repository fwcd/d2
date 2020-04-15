public enum MessageDatabaseError: Error {
    case missingTimestamp
    case missingID(String)
    case invalidID(String)
}
