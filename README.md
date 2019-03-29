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

* Create a file named `userwhitelist.swift` in `Sources/D2/permission` containing a list of Discord usernames that have full permissions:

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

## Running
* `swift run`

## Architecture
The program consists of three modules:

* `D2`, the executable
* `D2Utils`, a collection of useful utilities
* `D2WebAPIs`, client implementations of various web APIs

### D2
The executable application. The base functionality is provided by `CommandHandler`, which is a `DiscordClientDelegate` that handles raw, incoming messages and dispatches them to custom handlers that conform to the `Command` protocol.

At a basic level, the protocol consists of a single method named `invoke` that carries information about the user's request:

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
