import Foundation
import Dispatch

// TODO: Move this to swift-utils?

extension FileHandle {
    func asyncLines(encoding: String.Encoding = .utf8) -> AsyncThrowingStream<String, any Error> {
        AsyncThrowingStream { continuation in
            // Run the reading process on a background queue to avoid blocking the main thread
            DispatchQueue.global(qos: .background).async {
                var buffer = Data()
                let newlineData = Data([UInt8(ascii: "\n")])
                var isEOF = false

                while !isEOF {
                    do {
                        // Read a chunk of data from the file
                        let chunkSize = 4096
                        let chunk = try self.read(upToCount: chunkSize) ?? Data()
                        if chunk.isEmpty {
                            isEOF = true
                            // If there's remaining data in the buffer, yield it as the last line
                            if !buffer.isEmpty {
                                if let line = String(data: buffer, encoding: encoding) {
                                    continuation.yield(line)
                                }
                                buffer.removeAll()
                            }
                            continuation.finish()
                            break
                        }
                        buffer.append(chunk)

                        // Split the buffer into lines
                        while let range = buffer.range(of: newlineData) {
                            let lineData = buffer.subdata(in: 0..<range.lowerBound)
                            buffer.removeSubrange(0...range.lowerBound)
                            if let line = String(data: lineData, encoding: encoding) {
                                continuation.yield(line)
                            }
                        }
                    } catch {
                        continuation.finish(throwing: error)
                        break
                    }
                }
            }
        }
    }
}
