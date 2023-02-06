import D2Commands
import Dispatch
import Foundation
import Logging
import Utils

/// A handler that logs to the console and stores
/// the last n lines in a global cyclic queue.
public struct D2LogHandler: LogHandler {
    private static let dispatchQueue = DispatchQueue(label: "D2LogHandler.dispatchQueue")
    public static let timestampFormatKey = "timestamp"

    public var logLevel: Logger.Level
    public var metadata: Logger.Metadata = [
        timestampFormatKey: .string("dd.MM.yyyy HH:mm:ss")
    ]

    private let logBuffer: LogBuffer
    private let label: String
    private let printToStdout: Bool

    public init(
        label: String,
        logBuffer: LogBuffer,
        printToStdout: Bool,
        logLevel: Logger.Level = .info
    ) {
        self.label = label
        self.logBuffer = logBuffer
        self.printToStdout = printToStdout
        self.logLevel = logLevel
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        let mergedMetadata = self.metadata.merging(metadata ?? [:], uniquingKeysWith: { _, newKey in newKey })
        let output = "\(timestamp(using: mergedMetadata)) [\(level)] \(label): \(message)"

        if printToStdout {
            print(output)
        }

        Self.dispatchQueue.async {
            logBuffer.push(output)
        }
    }

    private func timestamp(using metadata: Logger.Metadata?) -> String {
        guard case let .string(timestampFormat)? = metadata?[Self.timestampFormatKey] else { return "<invalid timestamp format>" }
        let formatter = DateFormatter()
        formatter.dateFormat = timestampFormat
        return formatter.string(from: Date())
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get { return metadata[metadataKey] }
        set { metadata[metadataKey] = newValue }
    }
}
