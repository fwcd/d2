import Foundation

/**
 * An executable node package that
 * is located in the `Node` folder
 * of this repository and is meant
 * to be used in conjunction with
 * this project, e.g. by exposing
 * functionality from Node.js
 * libraries.
 */
public struct NodePackage {
    private let directoryURL: URL

    public init(name: String) {
        directoryURL = URL(fileURLWithPath: "Node/\(name)")
    }

    /** Invokes `npm start` with the given arguments. */
    public func start(withArgs args: [String], then: @escaping (Process) -> Void) throws {
        try Shell().run("npm", in: directoryURL, args: ["start"] + args, then: then)
    }
}
