import D2MessageIO

struct DiscordinderMatch {
    let initiator: MatchUser
    let acceptor: MatchUser
    let state: MatchState

    struct MatchUser {
        let id: UserID
        let name: String
    }

    enum MatchState: String {
        case waitingForAcceptor
        case accepted
        case rejected
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
            let acceptorName = attributes["acceptor.name"],
            let state = attributes["state"].flatMap(DiscordinderMatch.MatchState.init(rawValue:)) else { return nil }
        return DiscordinderMatch(
            initiator: DiscordinderMatch.MatchUser(
                id: initiatorId,
                name: initiatorName
            ),
            acceptor: DiscordinderMatch.MatchUser(
                id: acceptorId,
                name: acceptorName
            ),
            state: state
        )
    }

    init(fromDiscordinderMatch match: DiscordinderMatch) {
        self.init(
            id: "\(match.initiator.id) + \(match.acceptor.id)",
            name: "\(match.initiator.name) + \(match.acceptor.name)",
            hidden: match.state == .accepted,
            attributes: [
                "initiator.id": match.initiator.id.value,
                "initiator.name": match.initiator.name,
                "initiator.clientName": match.initiator.id.clientName,
                "acceptor.id": match.acceptor.id.value,
                "acceptor.name": match.acceptor.name,
                "acceptor.clientName": match.acceptor.id.clientName,
                "acceptor.state": match.state.rawValue
            ]
        )
    }
}
