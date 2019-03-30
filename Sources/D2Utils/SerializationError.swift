enum SerializationError: Error {
	case fileNotFound(String)
	case noData(String)
}
