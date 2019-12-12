import D2MessageIO
import D2Commands

struct Subscription {
	let channel: ChannelID
	let command: Command
}
