enum DiskFileError: Error {
	case fileNotFound(String)
	case noData(String)
}
