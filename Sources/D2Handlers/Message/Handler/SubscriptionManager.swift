import D2MessageIO
import D2Commands

@CommandActor
public class SubscriptionManager {
    private let registry: CommandRegistry
    private var subscriptionSets: [String: SubscriptionSet] = [:]
    public var isEmpty: Bool { subscriptionSets.isEmpty }

    public var debugSubscriptionInfos: String { subscriptionSets.keys.joined(separator: ", ") }

    init(registry: CommandRegistry) {
        self.registry = registry
    }

    public func createIfNotExistsAndGetSubscriptionSet(for commandName: String) -> SubscriptionSet {
        var subscriptionSet = subscriptionSets[commandName]
        if subscriptionSet == nil {
            subscriptionSet = SubscriptionSet()
            subscriptionSets[commandName] = subscriptionSet
        }
        return subscriptionSet!
    }

    public func hasSubscription(on channel: ChannelID, by commandName: String) -> Bool {
        subscriptionSets[commandName]?.contains(channel) ?? false
    }

    public func notifySubscriptions(on channel: ChannelID, isBot: Bool, action: @CommandActor (String, SubscriptionSet) async -> Void) async {
        for (commandName, subscriptionSet) in subscriptionSets {
            let allowed = !isBot || !(registry[commandName]?.info.subscriptionsUserOnly ?? true)
            if allowed && subscriptionSet.contains(channel) {
                await action(commandName, subscriptionSet)
            }
        }
    }
}
