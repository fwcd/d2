public enum ReactionTriggerError: Error {
    case notFeelingLucky
    case mismatchingAuthor
    case mismatchingMessageType
    case mismatchingKeywords
    case other(String)
}
