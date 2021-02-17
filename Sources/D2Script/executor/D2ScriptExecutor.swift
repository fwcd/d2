public struct D2ScriptExecutor {
    public let topLevelStorage = D2ScriptStorage(name: "Top-level scope")

    public init() {}

    public func run(_ node: D2ScriptASTNode) {
        run(node, storage: topLevelStorage)
    }

    public func run(_ node: D2ScriptASTNode, storage: D2ScriptStorage) {
        node.accept(D2ScriptStatementRunner(storage: storage))
    }

    /// Calls a command that has been previously
    /// declared in this environment, i.e. one whose
    /// declaration has been processed by 'run' before.
    public func call(command: String, args: [D2ScriptValue] = []) {
        if let commandFunction = topLevelStorage[function: command] {
            let _ = commandFunction(args)
        }
    }
}
