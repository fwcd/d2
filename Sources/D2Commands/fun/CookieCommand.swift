fileprivate let inventoryCategory = "Cookies"

public class CookieCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Gives someone a cookie",
        requiredPermissionLevel: .basic
    )
    private let inventoryManager: InventoryManager
    private let cookieTypes: [String]
    private let templates: [String]

    public init(inventoryManager: InventoryManager, cookieTypes: [String] = [
        "Snickerdoodle",
        "Chocolate Chip Cookie",
        "Oatmeal Raisin Cookie",
        "Gingersnap",
        "Shortbread Cookie",
        "Peanut Butter Cookie",
        "Whoopie Pie",
        "Sugar Cookie",
        "Molasses Cookie",
        "Kiss Cookie",
        "Butter Cookie",
        "Spritz Cookie",
        "Snowball Cookie",
        "Drop Cookie",
        "Thumbprint Cookie",
        "Pinwheel Cookie",
        "Wafer",
        "Macaron",
        "Fortune Cookie",
        "Crinkle Cookie",
        "Icebox Cookie",
        "Gingerbread Cookie",
        "Tassle",
        "Lebkuchen",
        "Black and White Cookie",
        "White Chocolate Macadamia Nut Cookie"
    ], templates: [String] = [
        "Here, %, have a %!",
        "%, you have received a %!",
        "%, you have been given a %!",
        "%, enjoy your %!"
    ]) {
        self.inventoryManager = inventoryManager
        self.cookieTypes = cookieTypes
        self.templates = templates
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let author = context.author else {
            output.append(errorText: "No author available!")
            return
        }
        guard let mention = context.message.mentions.first else {
            output.append(errorText: "Mention someone to get started!")
            return
        }
        guard let template = templates.randomElement(), let cookieType = cookieTypes.randomElement() else {
            output.append(errorText: "No template/cookie type available!")
            return
        }

        var inventory = inventoryManager[author.id]
        inventory.append(item: Inventory.Item(id: cookieType, name: cookieType), to: inventoryCategory)
        inventoryManager[author.id] = inventory

        output.append(":cookie: \(template.applyAsTemplate(to: [mention.username, cookieType]))")
    }
}
