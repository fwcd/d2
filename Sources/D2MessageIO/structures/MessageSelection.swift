public enum MessageSelection {
	case after(MessageID)
	case around(MessageID)
	case before(MessageID)
}
