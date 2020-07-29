import Foundation

public struct DiskJsonSerializer {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init() {}

    public func write<T: Encodable>(_ value: T, asJsonToFile filePath: String) throws {
        let url = URL(fileURLWithPath: filePath)
        let fileManager = FileManager.default
        let data = try encoder.encode(value)

        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }

        fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
    }

    public func readJson<T: Decodable>(as type: T.Type, fromFile filePath: String) throws -> T {
        let url = URL(fileURLWithPath: filePath)
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { throw DiskFileError.fileNotFound(url) }

        if let data = fileManager.contents(atPath: url.path) {
            do {
                return try decoder.decode(type, from: data)
            } catch {
                throw DiskFileError.decodingError(filePath, String(data: data, encoding: .utf8) ?? "<Binary data>", error)
            }
        } else {
            throw DiskFileError.noData("Could not read any data from '\(filePath)'")
        }
    }
}
