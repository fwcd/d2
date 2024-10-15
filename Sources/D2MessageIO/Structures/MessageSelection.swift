public enum MessageSelection: Sendable {
    case after(MessageID)
    case around(MessageID)
    case before(MessageID)
}
