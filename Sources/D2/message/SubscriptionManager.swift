import D2MessageIO
import D2Commands

class SubscriptionManager {
    private var subscriptions: [Subscription] = []
    var isEmpty: Bool { return subscriptions.isEmpty }

    func add(subscriptions: [Subscription]) {
        self.subscriptions += subscriptions
    }
    
    func hasSubscription(on channel: ChannelID, by command: Command) -> Bool {
        return subscriptions.contains(where: { command.equalTo($0.command) && channel == $0.channel })
    }
    
    func notifySubscriptions(on channel: ChannelID, isBot: Bool, action: (Subscription) -> SubscriptionAction) {
        for (i, sub) in subscriptions.enumerated().reversed() {
            if sub.channel == channel && !(sub.command.info.userOnly && isBot) {
                let response = action(sub)
                if response == .cancelSubscription {
                    subscriptions.remove(at: i)
                }
            }
        }
    }
}
