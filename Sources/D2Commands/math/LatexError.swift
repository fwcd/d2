import Foundation

enum LatexError: Error {
    case templateFileNotFound(URL)
    case noTemplateFileData(URL)
    case invalidTemplateFileEncoding(URL)
    case pdfError(log: String)
    case processError(executable: String, cause: Error)
}
