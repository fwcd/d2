import Foundation

enum LatexError: Error {
	case templateFileNotFound(URL)
	case noTemplateFileData(URL)
	case invalidTemplateFileEncoding(URL)
	case noPDFGenerated(log: String)
}
