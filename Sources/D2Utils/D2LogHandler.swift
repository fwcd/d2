import Foundation
import Logging

/**
 * A handler that logs to the console and stores
 * the last n lines in memory.
 */
public struct D2LogHandler: LogHandler {
    public static let timestampFormatKey = "timestamp"
    
    public var logLevel: Logger.Level = .info
    public var metadata: Logger.Metadata = [
        timestampFormatKey: .string("dd.MM.yyyy HH:mm:ss")
    ]
    
    private let label: String
    @Box private var lastOutputs: CircularArray<String>!
    
    public init(label: String, capacity: Int = 100) {
        self.label = label
        lastOutputs = CircularArray(capacity: capacity)
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        let output = "\(timestamp(using: metadata)) [\(level)] \(label): \(message)"

        lastOutputs.push(output)
        print(output)
    }
    
    private func timestamp(using metadata: Logger.Metadata?) -> String {
        guard case let .string(timestampFormat)? = metadata?[D2LogHandler.timestampFormatKey] else { return "<invalid timestamp format>" }
        let formatter = DateFormatter()
        formatter.dateFormat = timestampFormat
        return formatter.string(from: Date())
    }
    
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get { return metadata[metadataKey] }
        set { metadata[metadataKey] = newValue }
    }
}
