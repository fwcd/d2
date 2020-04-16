# D2
General-purpose virtual assistant for Discord and Telegram.

[![Linux](https://github.com/fwcd/d2/workflows/Linux/badge.svg)](https://github.com/fwcd/d2/actions)
[![macOS](https://github.com/fwcd/d2/workflows/macOS/badge.svg)](https://github.com/fwcd/d2/actions)

In addition to supporting various web APIs, it features basic scripting capabilities (such as piping and and chaining of commands) and a permission system.

## Installation

### using Docker (for production environments)
* Make sure to have recent versions of Docker and Docker Compose installed
* Create a volume named `d2local` using `docker volume create d2local`

### Manually (for local development)

#### System Dependencies
* Swift 5.1
    * Swift can be installed conveniently using a version manager such as [`swiftenv`](https://github.com/kylef/swiftenv)
    * Current builds of Swift for Raspberry Pi [can be found here](https://github.com/uraimo/buildSwiftOnARM/releases)
        * Note that you might need to perform a [custom installation](https://swiftenv.fuller.li/en/latest/commands.html#custom-installation) if you use `swiftenv` on Raspberry Pi
* Haskell + Cabal Install or Stack (for Hoogle, Pointfree, ...)
* Node.js and npm (for LaTeX rendering)
* `timeout` and `kill` (for `MaximaCommand`)

#### Linux
* `sudo apt-get install libopus-dev libsodium-dev libssl1.0-dev libcairo2-dev poppler-utils maxima sqlite3`
    * Note that you might need to use `libssl-dev` instead of `libssl1.0-dev` on Ubuntu
    * If Swift cannot find the Freetype headers despite `libfreetype6-dev` being installed, you may need to add symlinks:
        * `mkdir /usr/include/freetype2/freetype`
        * `ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h`
        * `ln -s /usr/include/freetype2/tttables.h /usr/include/freetype2/freetype/tttables.h`
    * Note that you might need to `apt-get install clang` separately on a Raspberry Pi

#### macOS
* Install `maxima`
* `brew tap vapor/tap`
* `brew install opus libsodium ctls cairo poppler gd`

#### General
* `stack install happy show mueval pointfree pointful` (or `cabal-install ...`)
* `cd Node && ./install-all`

## Configuration

### Required
* Create a folder named `local` in the repository
    * If you use Docker, the `local` folder is represented by the `d2local` volume
    * [See here](https://stackoverflow.com/a/55683656) for instructions on how to copy files into it
* Create a file named `platformTokens.json` in `local` containing the API tokens (at least one of them should be specified):

```json
{
    "discord": "YOUR_DISCORD_API_TOKEN",
    "telegram": "YOUR_TELEGRAM_API_TOKEN"
}
```

### Optional
* Create a file named `config.json` in `local` (or the `d2local` volume):

```json
{
    "prefix": "%"
}
```

* Create a file named `adminWhitelist.json` in `local` (or the `d2local` volume) containing a list of Discord usernames that have full permissions:

```json
{
    "users": [
        "YOUR_USERNAME#1234"
    ]
}
```

* Create a file named `netApiKeys.json` in `local` (or the `d2local` volume) containing various API keys:

```json
{
    "mapQuest": "YOUR_MAP_QUEST_KEY",
    "wolframAlpha": "YOUR_WOLFRAM_ALPHA_KEY",
    "gitlab": "YOUR_GITLAB_PERSONAL_ACCESS_TOKEN"
}
```

## Building
* Using Docker: `docker-compose build`
* On Linux: `swift build`
* On macOS: `swift build -Xlinker -L/usr/local/lib -Xlinker -lopus -Xcc -I/usr/local/include`

For Xcode support, see [the README of SwiftDiscord](https://github.com/nuclearace/SwiftDiscord/blob/master/README.md).

## Testing
* `swift test`

## Running
* Using Docker: `docker-compose up -d`
* On Linux: `swift run D2`
* On macOS: `swift run -Xlinker -L/usr/local/lib -Xlinker -lopus -Xcc -I/usr/local/include D2`

## Additional Build Flags
To suppress warnings, you can use `-Xswiftc -suppress-warnings` after `swift build` or `swift run`.

## Architecture
The program consists of a single executable:

* `D2`, the main Discord frontend

Each executable uses its own implementation of message IO, e.g. `D2` uses `SwiftDiscord` to conform to `D2MessageIO`'s API.

These depend on several library targets:
* `D2Commands`, the command framework and the implementations
* `D2Graphics`, 2D graphics and drawing
* `D2MessageIO`, the messaging framework used by D2 (abstracts over the Discord library)
* `D2Permissions`, the permission manager
* `D2Script`, an experimental DSL that can be used to script commands
* `D2Graphics`, 2D graphics and drawing
* `D2NetAPIs`, client implementations of various web APIs
* `D2Utils`, a collection of useful utilities

### D2
The executable application. The base functionality is provided by `D2ClientHandler`, which is a `DiscordClientDelegate` that handles raw, incoming messages and dispatches them to custom handlers that conform to the `Command` protocol.

### D2Commands
At a basic level, the `Command` protocol consists of a single method named `invoke` that carries information about the user's request:

```swift
protocol Command: class {
    ...
    
    func invoke(input: RichValue, output: CommandOutput, context: CommandContext)
    
    ...
}
```

The arguments each represent a part of the invocation context. Given a request such as `%commandname arg1 arg2`, the implementor would receive:

| Parameter | Value |
| --------- | ----- |
| `input` | `.text("arg1 arg2")` |
| `output` | `DiscordOutput` |
| `context` | `CommandContext` containing the message, the client and the command registry |

Since `output: CommandOutput` represents a polymorphic object, the output of an invocation does not necessarily get sent to the Discord channel where the request originated from. For example, if the user creates a piped request such as `%first | second | third`, only the third command would operate on a `DiscordOutput`. Both the first and the second command call a `PipeOutput` instead that passes any values to the next command:

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
    
    func append(_ value: RichValue) {
        let nextInput = args.isEmpty ? value : (.text(args) + value)
        sink.invoke(input: nextInput, output: next ?? PrintOutput(), context: context)
    }
}
```

Often the `Command` protocol is too low-level to be adopted directly, since the input can be of any form (including embeds or images). To address this, there are subprotocols that provide a simpler template interface for implementors:

```swift
protocol StringCommand: Command {
    func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext)
}
```

`StringCommand` is useful when the command accepts a single string as an argument or if a custom argument parser is used. Its default implementation of `Command.invoke` passes either `args`, if not empty, or otherwise `input.content` to `StringCommand.invoke`.

```swift
protocol ArgCommand: Command {
    associatedtype Args: Arg

    var argPattern: Args { get }
    
    func invoke(withInputArgs inputArgs: [String], output: CommandOutput, context: CommandContext)
}
```

`ArgCommand` should be adopted if the command expects a fixed structure of arguments.
