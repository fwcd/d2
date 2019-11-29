/** Wraps a value that is automatically read from/written to a file. */
public class AutoSerializing<T: Codable & DefaultInitializable> {
    private let serializer = DiskJsonSerializer()
    private let filePath: String
    public private(set) var value: T
    
    public init(filePath: String) throws {
        self.filePath = filePath
        if let storedValue = try? serializer.readJson(as: T.self, fromFile: filePath) {
            value = storedValue
        } else {
            value = T.init()
            try writeToDisk()
        }
    }
    
    private func writeToDisk() throws {
        try serializer.write(value, asJsonToFile: filePath)
    }
    
    public func update(action: (inout T) throws -> Void) throws {
        try action(&value)
        try writeToDisk()
    }
}
