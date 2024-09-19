import Foundation
import Utils

private let npmArgs = ["run", "--silent", "start", "--"]
private let newlineUtf8 = "\n".data(using: .utf8)!

/// A wrapper around an executable node package that is located in the `Node`
/// folder of this repository.
struct NodePackage {
    private let directoryURL: URL

    init(name: String) {
        directoryURL = URL(fileURLWithPath: "Node/\(name)")
    }

    /// Invokes `npm start` with the given arguments.
    func run(_ args: [String] = []) async throws -> Data {
        try await Shell().output(for: "npm", in: directoryURL, args: npmArgs + args).get()
    }

    /// Invokes `npm start` and return a wrapper for communicating via newline-delimited JSON messages.
    func startJsonSession(_ args: [String] = []) -> JsonSession {
        let (_, process) = Shell().newProcess("npm", in: directoryURL, args: npmArgs + args)
        let stdout = Pipe()
        let stdin = Pipe()
        process.standardOutput = stdout
        process.standardInput = stdin
        return JsonSession(process: process, stdin: stdin, stdout: stdout)
    }

    enum JsonSessionError: Error {
        case couldNotReadLine
    }

    /// A wrapper around a process that facilitates communication via newline-delimited JSON messages.
    class JsonSession {
        private let process: Process

        private let stdinFileHandle: FileHandle
        private var stdoutLines: AsyncLineSequence<FileHandle.AsyncBytes>.AsyncIterator

        private let encoder = JSONEncoder()
        private let decoder = JSONDecoder()

        fileprivate init(process: Process, stdin: Pipe, stdout: Pipe) {
            self.process = process

            stdinFileHandle = stdin.fileHandleForWriting
            stdoutLines = stdout.fileHandleForReading.bytes.lines.makeAsyncIterator()
        }

        /// Writes a single JSON line to the process's stdin.
        func send(_ request: some Encodable) throws {
            let data = try encoder.encode(request) + newlineUtf8
            try stdinFileHandle.write(contentsOf: data)
        }

        /// Reads a single JSON line from the process's stdout.
        func receive<Response>(_ type: Response.Type) async throws -> Response where Response: Decodable {
            guard let line = try await stdoutLines.next(),
                  let data = line.data(using: .utf8) else {
                throw JsonSessionError.couldNotReadLine
            }
            return try decoder.decode(type, from: data)
        }

        deinit {
            process.terminate()
        }
    }
}
