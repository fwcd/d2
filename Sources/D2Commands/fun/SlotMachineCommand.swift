import D2MessageIO

public class SlotMachineCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Simulates a 'slot machine'",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .embed
    private let slotCount: Int
    private let values: [String]

    public init(slotCount: Int = 3, values: [String] = [":lemon:", ":pear:", ":grapes:", ":apple:", ":peach:"]) {
        assert(!values.isEmpty, "No values available")
        self.slotCount = slotCount
        self.values = values
    }

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        let outcome = (0..<slotCount).map { _ in values.randomElement()! }
        let isWin = Set(outcome).count == 1
        output.append(Embed(
            title: ":slot_machine: Slot Machine",
            description: [
                outcome.joined(separator: "|"),
                isWin ? ":partying_face: Hooray, you won!" : nil
            ].compactMap { $0 }.joined(separator: "\n")
        ))
    }
}
