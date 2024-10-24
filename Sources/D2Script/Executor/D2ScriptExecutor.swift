public struct D2ScriptExecutor {
    public let topLevelStorage = D2ScriptStorage(name: "Top-level scope")

    public init() {}

    public func run(_ node: any D2ScriptASTNode) async {
        await run(node, storage: topLevelStorage)
    }

    public func run(_ node: any D2ScriptASTNode, storage: D2ScriptStorage) async {
        await node.accept(D2ScriptStatementRunner(storage: storage))
    }

    /// Calls a command that has been previously
    /// declared in this environment, i.e. one whose
    /// declaration has been processed by 'run' before.
    public func call(command: String, args: [D2ScriptValue] = []) async {
        if let commandFunction = topLevelStorage[function: command] {
            let _ = await commandFunction(args)
        }
    }
}
