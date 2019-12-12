import D2MessageIO
import D2Permissions
import D2WebAPIs

/** Fetches the CAU canteen's daily menu. */
public class MensaCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Fetches the CAU canteen's daily menu",
        longDescription: "Looks up the current menu for a CAU canteen",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let canteen = Canteen.parse(from: input) else {
            output.append("Could not parse mensa from \(input), try `i` or `ii`")
            return
        }
        
        do {
            try DailyFoodMenu(canteen: canteen).fetchMealsAsync {
                guard case let .success(meals) = $0 else {
                    guard case let .failure(error) = $0 else { fatalError("Result should either be successful or not") }
                    print(error)
                    output.append("An error occurred while performing the request")
                    return
                }
                
                output.append(.embed(Embed(
                    title: ":fork_knife_plate: Today's menu for \(canteen)",
                    fields: meals.map { Embed.Field(name: "\($0.title) \($0.properties)", value: $0.price) }
                )))
            }
        } catch {
            print(error)
            output.append("An error occurred while constructing the request")
        }
    }
}
