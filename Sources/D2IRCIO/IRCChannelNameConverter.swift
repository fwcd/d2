import D2MessageIO
import IRC

// FROM IRC conversions

// TODO: Convert IRCMessageRecipient to/from instead
// TODO: Represent other things, not just messaging endpoints, with IDs

extension IRCChannelName: MessageIOConvertible {
    public var usingMessageIO: ID {
        // TODO: This currently assumes that only a single
        // IRC client is present. It would be better to
        // use a combination of ircClientName and host:port
        // to identify the client uniquely.
        ID(stringValue, clientName: ircClientName)
    }
}

// TO IRC conversions

extension ID: IRCAPIConvertible {
    public var usingIRCAPI: IRCChannelName {
        IRCChannelName(value)!
    }
}
