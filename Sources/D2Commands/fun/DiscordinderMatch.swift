import D2MessageIO

struct DiscordinderMatch {
    let initiator: MatchUser
    let acceptor: MatchUser
    let halfOpen: Bool

    struct MatchUser {
        let id: UserID
        let name: String
    }
}

extension Inventory.Item {
    var asDiscordinderMatch: DiscordinderMatch? {
        guard
            let initiatorClientName = attributes["initiator.clientName"],
            let initiatorId = attributes["initiator.id"].map({ UserID($0, clientName: initiatorClientName) }),
            let initiatorName = attributes["initiator.name"],
            let acceptorClientName = attributes["acceptor.clientName"],
            let acceptorId = attributes["acceptor.id"].map({ UserID($0, clientName: acceptorClientName) }),
            let acceptorName = attributes["acceptor.name"] else { return nil }
        return DiscordinderMatch(
            initiator: DiscordinderMatch.MatchUser(
                id: initiatorId,
                name: initiatorName
            ),
            acceptor: DiscordinderMatch.MatchUser(
                id: acceptorId,
                name: acceptorName
            ),
            halfOpen: hidden
        )
    }

    init(fromDiscordinderMatch match: DiscordinderMatch) {
        self.init(
            id: "\(match.initiator.id) + \(match.acceptor.id)",
            name: "\(match.initiator.name) + \(match.acceptor.name)",
            hidden: match.halfOpen,
            attributes: [
                "initiator.id": match.initiator.id.value,
                "initiator.name": match.initiator.name,
                "initiator.clientName": match.initiator.id.clientName,
                "acceptor.id": match.acceptor.id.value,
                "acceptor.name": match.acceptor.name,
                "acceptor.clientName": match.acceptor.id.clientName
            ]
        )
    }
}
