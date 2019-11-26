import SwiftDiscord
import D2Permissions

public class CountdownCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "A date/time countdown manager",
        longDescription: "Stores a collection of dates that it counts down to",
        requiredPermissionLevel: .basic
    )
    private var goals: [String: CountdownGoal] = [:]
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
