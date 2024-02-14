import Utils

fileprivate let inventoryCategory = "Cookies"

public class CookieCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Gives someone a cookie",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .mentions
    public let outputValueType: RichValueType = .text
    private let inventoryManager: InventoryManager
    private let cookies: [Cookie]
    private let templates: [String]

    public init(inventoryManager: InventoryManager, cookies: [Cookie] = [
        Cookie(name: "Snickerdoodle"),
        Cookie(name: "Chocolate Chip Cookie"),
        Cookie(name: "Oatmeal Raisin Cookie"),
        Cookie(name: "Gingersnap"),
        Cookie(name: "Shortbread Cookie"),
        Cookie(name: "Peanut Butter Cookie"),
        Cookie(name: "Whoopie Pie"),
        Cookie(name: "Sugar Cookie"),
        Cookie(name: "Molasses Cookie"),
        Cookie(name: "Kiss Cookie"),
        Cookie(name: "Butter Cookie"),
        Cookie(name: "Spritz Cookie"),
        Cookie(name: "Snowball Cookie"),
        Cookie(name: "Drop Cookie"),
        Cookie(name: "Thumbprint Cookie"),
        Cookie(name: "Pinwheel Cookie"),
        Cookie(name: "Wafer"),
        Cookie(name: "Macaron"),
        Cookie(name: "Fortune Cookie", emoji: "fortune_cookie"),
        Cookie(name: "Crinkle Cookie"),
        Cookie(name: "Icebox Cookie"),
        Cookie(name: "Gingerbread Cookie"),
        Cookie(name: "Tassle"),
        Cookie(name: "Lebkuchen"),
        Cookie(name: "Black and White Cookie"),
        Cookie(name: "White Chocolate Macadamia Nut Cookie")
    ], templates: [String] = [
        "Here, %, have a %!",
        "%, you have received a %!",
        "%, you have been given a %!",
        "%, enjoy your %!"
    ]) {
        self.inventoryManager = inventoryManager
        self.cookies = cookies
        self.templates = templates
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let author = context.author else {
            output.append(errorText: "No author available!")
            return
        }
        guard let mention = input.asMentions?.first else {
            output.append(errorText: "Mention someone to get started!")
            return
        }
        guard let template = templates.randomElement(), let cookie = cookies.randomElement() else {
            output.append(errorText: "No template/cookie available!")
            return
        }

        var inventory = inventoryManager[author.id]
        inventory.append(item: Inventory.Item(fromCookie: cookie), to: inventoryCategory)
        inventoryManager[author.id] = inventory

        output.append(":\(cookie.emoji): \(template.applyAsTemplate(to: [mention.username, cookie.name]))")
    }
}
