import D2MessageIO
import Discord

// TO Discord conversions

extension MessageSelection: DiscordAPIConvertible {
    public var usingDiscordAPI: DiscordEndpoint.Options.MessageSelection {
        switch self {
            case .before(let id):
                return .before(id.usingDiscordAPI)
            case .around(let id):
                return .around(id.usingDiscordAPI)
            case .after(let id):
                return .after(id.usingDiscordAPI)
        }
    }
}
