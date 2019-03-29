# D2
General-purpose virtual assistant for Discord.

In addition to suporting various web APIs, it features basic scripting capabilities (such as piping and and chaining of commands) and a permission system.

## Installation

### on Linux
* Install the required system dependencies:
	* Swift 5
    * `sudo apt-get install libopus-dev libsodium-dev libssl1.0-dev`
* Create a file named `discordtoken.swift` in `Sources/D2` containing the API keys:

```swift
let discordToken = "YOUR_DISCORD_API_TOKEN"
```

* Create a file named `userwhitelist.swift` in `Sources/D2Permissions` containing a list of Discord usernames that have full permissions:

```swift
let whitelistedDiscordUsers: Set<String> = [
	"YOUR_USERNAME#1234"
]
```

* Create a file named `authkeys.swift` in `Sources/D2WebAPIs` containing the API keys:

```swift
let mapQuestKey = "YOUR_MAP_QUEST_KEY"
```

## Building
* `swift build`

## Testing
* `swift test`

## Running
* `swift run`

## Architecture
The program consists of three modules:

* `D2`, the executable
* `D2Commands`, the command framework and the implementations
* `D2Permissions`, the permission manager
* `D2Utils`, a collection of useful utilities
* `D2WebAPIs`, client implementations of various web APIs

### D2
The executable application. The base functionality is provided by `CommandHandler`, which is a `DiscordClientDelegate` that handles raw, incoming messages and dispatches them to custom handlers that conform to the `Command` protocol.

### D2Commands
At a basic level, the `Command` protocol consists of a single method named `invoke` that carries information about the user's request:

```swift
protocol Command: class {
	...
	
	func invoke(withArgs args: String, input: DiscordMessage?, output: CommandOutput, context: CommandContext)
	
	...
}
```

These arguments each represent a part of the invocation context. Given a request such as `%commandname arg1 arg2`, the implementor would receive:

| Parameter | Value |
| --------- | ----- |
| `args` | `"arg1 arg2"` |
| `input` | `nil` |
| `output` | `DiscordChannelOutput` |
| `context` | `CommandContext` containing the message, the client and the command registry |

It should be noted that `input` is `nil` because the user did not attach a pipe to his request. If he would send `%firstcommand | secondcommand arg1`, the `input` field of the second invocation would contain the piped message:

| Parameter | Value |
| --------- | ----- |
| `args` | `"arg1"`
| `input` | `DiscordMessage` representing the output of the first invocation |
| `output` | `DiscordChannelOutput` |
| `context` | `CommandContext` |

Since `output: CommandOutput` represents a polymorphic object, the output of an invocation does not necessarily get sent to the Discord channel where the request originated from. For example, if the user creates a piped request such as `%first | second | third`, only the third command would operate on a `DiscordChannelOutput`. Both the first and the second command call a `PipeOutput` instead that passes any messages to the next command:

```swift
class PipeOutput: CommandOutput {
	private let sink: Command
	private let context: CommandContext
	private let args: String
	private let next: CommandOutput?
	
	init(withSink sink: Command, context: CommandContext, args: String, next: CommandOutput? = nil) {
		self.sink = sink
		self.args = args
		self.context = context
		self.next = next
	}
	
	func append(_ message: DiscordMessage) {
		print("Piping to \(sink)")
		sink.invoke(withArgs: args, input: message, output: next ?? DiscordChannelOutput(channel: message.channel), context: context)
	}
}
```

Often, the `Command` protocol is too low-level to be adopted directly, since direct arguments and pipe inputs have to be handled separately. Instead, there are subprotocols that provide a simpler template interface for implementors:

```swift
protocol StringCommand: Command {
	func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext)
}
```

`StringCommand` is useful when the command accepts a single string as an argument or if a custom argument parser is used. Its default implementation of `Command.invoke` passes either `args`, if not empty, or otherwise `input.content` to `StringCommand.invoke`.

```swift
protocol ArgListCommand: Command {
	var expectedArgCount: Int { get }
	
	func invoke(withInputArgs inputArgs: [String], output: CommandOutput, context: CommandContext)
}
```

`ArgListCommand` should be adopted if the command excepts a fixed number of arguments. It allows the user to partially apply the command's arguments and then pipe the rest.
