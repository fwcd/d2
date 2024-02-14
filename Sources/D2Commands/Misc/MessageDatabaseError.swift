public enum MessageDatabaseError: Error {
    case invalidMarkovState(String)
    case missingMarkovData(String)
    case missingMessageData(String)
    case missingTimestamp
    case missingID(String)
    case invalidID(String)
}
