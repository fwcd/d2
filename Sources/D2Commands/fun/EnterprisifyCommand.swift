public class EnterprisifyCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Enterprisifies your class names!",
        requiredPermissionLevel: .basic
    )
    private let prefixes: [String]
    private let postfixes: [String]
    private let iterations: Int

    public init(prefixes: [String] = [
        "Abstract",
        "Wrapping",
        "Test",
        "Mock",
        "Delegating",
        "I",
        "External",
        "Remote",
        "Local",
        "Dynamic",
        "Global",
        "Default",
        "Simple",
        "Generic",
        "General",
        "Alternative",
        "Configurable"
    ], postfixes: [String] = [
        "Factory",
        "Builder",
        "Consumer",
        "Producer",
        "Controller",
        "Delegate",
        "Router",
        "Mediator",
        "Manager",
        "Worker",
        "Model",
        "Schema",
        "List",
        "Collection",
        "Iterator",
        "Client",
        "Server",
        "Identifier",
        "Broadcaster",
        "Predicate",
        "Supplier",
        "Function",
        "Interpreter",
        "Listener",
        "Bean",
        "Strategy",
        "Visitor",
        "Configuration",
        "Info",
        "Center",
        "Bus",
        "Hub",
        "Wrapper",
        "Advisor",
        "Utils",
        "Resolver",
        "Importer",
        "Facade",
        "Filter",
        "Stub",
        "Definition",
        "Order",
        "Annotation",
        "Publisher",
        "Subscriber",
        "Exception",
        "Getter",
        "Setter",
        "Candidate",
        "Message",
        "Store",
        "Service",
        "Container",
        "Task",
        "State",
        "Impl",
        "Composer",
        "Descriptor",
        "Map",
        "Template",
        "Event",
        "Instance",
        "Queue",
        "Mapper",
        "Loader",
        "Serializer",
        "Deserializer",
        "Exporter",
        "Response",
        "Connection",
        "Target",
        "Provider",
        "Proxy",
        "Class",
        "Type",
        "Holder",
        "Box",
        "Substitutor",
        "Owner",
        "Fragment",
        "Pointer",
        "Logger",
        "Bundle",
        "Aggregator",
        "Key",
        "Value",
        "Thread",
        "Context",
        "Checker",
        "Result",
        "Callback",
        "Object",
        "Group",
        "Item",
        "Command",
        "Extractor",
        "Agent",
        "Prototype"
    ], iterations: Int = 3) {
        assert(!prefixes.isEmpty)
        assert(!postfixes.isEmpty)
        assert(iterations > 0)

        self.prefixes = prefixes
        self.postfixes = postfixes
        self.iterations = iterations
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        var result = input

        for _ in 0..<iterations {
            result = enterprisify(name: result)
        }

        output.append(result)
    }

    private func enterprisify(name: String) -> String {
        if Bool.random() && !name.isEmpty {
            return prefixes.randomElement()! + name
        } else {
            return name + postfixes.randomElement()!
        }
    }
}
