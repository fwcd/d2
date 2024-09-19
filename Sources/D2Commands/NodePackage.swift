import Foundation
import Utils

/// A wrapper around an executable node package that is located in the `Node`
/// folder of this repository.
struct NodePackage {
    private let directoryURL: URL

    init(name: String) {
        directoryURL = URL(fileURLWithPath: "Node/\(name)")
    }

    /// Invokes `npm start` with the given arguments.
    func run(_ args: [String]) async throws -> Data {
        try await Shell().output(for: "npm", in: directoryURL, args: ["run", "--silent", "start", "--"] + args).get()
    }
}
