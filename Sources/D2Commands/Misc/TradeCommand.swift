import Utils
import D2MessageIO

nonisolated(unsafe) private let tradePattern = #/(?<authorsItem>\w+)\s+(?<othersItem>\w+)/#

public class TradeCommand: Command {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Trades an item with someone",
        helpText: "Syntax: @otherperson [authors item] [otherperson's item]",
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true
    )
    private let inventoryManager: InventoryManager
    private var trades: [ChannelID: Trade] = [:]

    private struct ItemWithUser {
        public let category: String
        public let item: Inventory.Item
        public let userId: UserID
    }

    private struct Trade {
        public let author: ItemWithUser
        public let other: ItemWithUser

        public func perform(with inventoryManager: InventoryManager) {
            inventoryManager[author.userId].remove(item: author.item, from: author.category)
            inventoryManager[other.userId].append(item: author.item, to: author.category)

            inventoryManager[other.userId].remove(item: other.item, from: other.category)
            inventoryManager[author.userId].append(item: other.item, to: author.category)
        }
    }

    public init(inventoryManager: InventoryManager) {
        self.inventoryManager = inventoryManager
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let author = context.author else {
            await output.append(errorText: "No author available")
            return
        }
        guard let channelId = context.channel?.id else {
            await output.append(errorText: "No channel id available")
            return
        }
        guard let text = input.asText, let parsedTrade = try? tradePattern.firstMatch(in: text), let other = input.asMentions?.first else {
            await output.append(errorText: info.helpText!)
            return
        }

        let authorsRawItem = String(parsedTrade.authorsItem)
        let othersRawItem = String(parsedTrade.othersItem)
        let authorsInventory = inventoryManager[author]
        let othersInventory = inventoryManager[other]

        guard let (authorsCategory, authorsItem) = authorsInventory.first(where: { $0.1.name.lowercased() == authorsRawItem.lowercased() }) else {
            await output.append(errorText: "Could not find `\(authorsRawItem)` in your inventory!")
            return
        }
        guard let (othersCategory, othersItem) = othersInventory.first(where: { $0.1.name.lowercased() == othersRawItem.lowercased() }) else {
            await output.append(errorText: "Could not find `\(othersRawItem)` in \(other.username)'s inventory!")
            return
        }

        let offer = Trade(
            author: ItemWithUser(category: authorsCategory, item: authorsItem, userId: author.id),
            other: ItemWithUser(category: othersCategory, item: othersItem, userId: other.id)
        )
        trades[channelId] = offer

        // TODO: Multi-item trades

        await output.append(Embed(
            title: "\(other.username), \(author.username) offers you the following trade:",
            description: """
                1x \(authorsItem) (\(authorsCategory)) for you
                1x \(othersItem) (\(othersCategory)) for \(author.username)

                Do you accept it? [yes/no]
                """
        ))
        context.subscribeToChannel()
    }

    public func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) async {
        guard let channelId = context.channel?.id,
            let author = context.author,
            let trade = trades[channelId],
            trade.other.userId == author.id else { return }
        if content.lowercased() == "yes" {
            trade.perform(with: inventoryManager)
            await output.append(":white_check_mark: Successfully performed trade")
        } else {
            await output.append(":x: Declined trade")
        }
        context.unsubscribeFromChannel()
    }
}
