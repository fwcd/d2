# D2

[![Build](https://github.com/fwcd/d2/actions/workflows/build.yml/badge.svg)](https://github.com/fwcd/d2/actions/workflows/build.yml)

General-purpose assistant for Discord, IRC and Telegram featuring more than 300 commands, including:

* 💬 Various useful chat utilities, e.g. polls or coin flips
* ⚙️ A flexible command system that supports chaining, piping and permissions
* 🎲 Multiplayer board and card games, such as chess or Uno
* 📙 Integration with a wide range of web APIs, including WolframAlpha, MediaWiki, Reddit and OpenWeatherMap
* 🖼 Image processing capabilities, including generation of animated GIFs
* 📊 Tools for mathematics and linear algebra, e.g. a linear system solver
* 🎵 Music theory utilities, including a chord finder
* 🖥 Programming tools, including a Haskell API search and a Prolog interpreter
* 🍬 Humorous commands, e.g. for jokes

## Getting Started

### Locally

To build and run D2 locally, make sure to have the following installed:

* Linux or macOS 10.15+
* Swift 5.6+
    * Swift can be installed conveniently using a version manager such as [`swiftenv`](https://github.com/kylef/swiftenv)
    * Current builds of Swift for Raspberry Pi [can be found here](https://github.com/uraimo/buildSwiftOnARM/releases)
        * Note that you might need to perform a [custom installation](https://swiftenv.fuller.li/en/latest/commands.html#custom-installation) if you use `swiftenv` on Raspberry Pi
* Node.js and npm (for LaTeX rendering)
* `timeout` and `kill` (for `MaximaCommand`)

On Linux the following dependencies are required:

* `sudo apt-get install libssl1.0-dev libfreetype6-dev libcairo2-dev poppler-utils maxima libsqlite3-dev graphviz libgraphviz-dev libtesseract-dev libleptonica-dev`
    * Note that you might need to use `libssl-dev` instead of `libssl1.0-dev` on Ubuntu
    * If Swift cannot find the Freetype headers despite `libfreetype6-dev` being installed, you may need to add symlinks:
        * `mkdir /usr/include/freetype2/freetype`
        * `ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h`
        * `ln -s /usr/include/freetype2/tttables.h /usr/include/freetype2/freetype/tttables.h`
    * Note that you might need to `apt-get install clang` separately on a Raspberry Pi
    * Also make sure that you are installing Tesseract 4. If you are on an older version of Ubuntu, try adding the following repository:
        * `sudo add-apt-repository ppa:alex-p/tesseract-ocr`

On macOS:

* Install `maxima`
* `brew tap vapor/tap`
* `brew install ctls freetype2 cairo poppler gd graphviz`

Create a folder named `local` under the repository and add configuration files as described in [the configuration section](#configuration).

Run `(cd Node && ./install-all)` to install the dependencies for node packages used by D2.

Finally, use `swift build` to build D2 and `swift run` to run it. With `swift test` you can run the test suite.

> To suppress warnings, you can append `-Xswiftc -suppress-warnings` after `swift build` or `swift run`.

### With Docker (Compose)

Make sure to have recent versions of Docker and Docker Compose installed and create a volume named `d2local` using `docker volume create d2local`.

In this volume, add configuration files as described in [the configuration section](#configuration).

> [See here](https://stackoverflow.com/a/55683656) for instructions on how to copy files into a Docker volume

You can then use `docker-compose build` to build the image and `docker-compose up` to run it (add the `-d` flag to run it in daemonized mode).

### With Kubernetes (Helm)

Make sure to have `kubectl` + `helm` installed and connected to a Kubernetes cluster. The cluster should have a persistent volume available.

> In a local cluster (where persistent volumes generally aren't provisioned automatically), you may find the `d2-local-storage` chart useful, which registers a persistent volume. To use it, create a folder such as `./local/k8s` and run `helm upgrade --install --set storage.hostPath=$PWD/local/k8s d2-local-storage Helm/d2-local-storage`.

Create a `values.yaml` in some local location (e.g. in `local` or outside the repository) containing D2 configurations (see [the configuration section](#configuration) for details on the schema):

```yaml
d2:
  adminWhitelist:
    users:
    - value: 'YOUR_DISCORD_USER_ID'
      clientName: Discord
  config:
    commandPrefix: '%'
  platformTokens:
    discord: 'YOUR_DISCORD_API_TOKEN'
```

<!-- TODO: Document that netApiKeys can be set here too -->

You can now upgrade/install D2 to the cluster using `helm upgrade --install -f path/to/local/values.yaml d2 Helm/d2`.

To uninstall it, just run `helm uninstall d2`.

> Note that the persistent volume storage claim by `d2` might still persist after uninstalling, in which case you could do [something like this](https://stackoverflow.com/questions/50667437/what-to-do-with-released-persistent-volume) (or reinstall `d2-local-storage`, if you installed it earlier).

## Configuration

Navigate to your `local` folder or volume (as described in the sections above).

### Required

Create a file named `platformTokens.json` in `local` containing the API tokens (at least one of them should be specified):

```json
{
    "discord": "YOUR_DISCORD_API_TOKEN",
    "telegram": "YOUR_TELEGRAM_API_TOKEN",
    "irc": [
        {
            "host": "YOUR_IRC_HOST",
            "port": 6667,
            "nickname": "YOUR_IRC_USERNAME",
            "password": "YOUR_IRC_PASSWORD"
        }
    ]
}
```

> For more information e.g. on how to connect to the Twitch IRC API, see [this guide](https://dev.twitch.tv/docs/irc/guide/)

### Optional

Create a file named `config.json` in `local` (or the `d2local` volume):

```json
{
    "prefix": "%"
}
```

Create a file named `adminWhitelist.json` in `local` (or the `d2local` volume) containing a list of Discord usernames that have full permissions:

```json
{
  "users": [
    {
      "value": "YOUR_DISCORD_USER_ID",
      "clientName": "Discord"
    }
  ]
}
```

Create a file named `netApiKeys.json` in `local` (or the `d2local` volume) containing various API keys:

```json
{
    "mapQuest": "YOUR_MAP_QUEST_KEY",
    "wolframAlpha": "YOUR_WOLFRAM_ALPHA_KEY",
    "gitlab": "YOUR_GITLAB_PERSONAL_ACCESS_TOKEN"
}
```

Create a folder named `memeTemplates` in `local` containing PNG images. Any fully transparent sections will be filled by a user-defined image, once the corresponding command is invoked.

## Architecture

The program consists of a single executable:

* `D2`, the main Discord frontend

This executable depends on several library targets:
* `D2Handlers`, top-level message/event handling
* `D2Commands`, the command framework and the implementations
* `D2MessageIO`, the messaging framework (abstracting over the Discord library)
    * `D2DiscordIO`, the Discord implementation
    * `D2TelegramIO`, the Telegram implementation
    * `D2IRCIO`, the IRC/Twitch implementation
* `D2Permissions`, permission management
* `D2Script`, an experimental DSL that can be used to script commands
* `D2NetAPIs`, client implementations of various web APIs

### D2

The executable application. Sets up messaging backends (like Discord) and the top-level event handler (`D2Delegate`). Besides other events, the `D2Delegate` handles incoming messages and forwards them to multiple `MessageHandler`s. One of these is `CommandHandler`, which in turn parses the command and invokes the actual command.

### D2Commands

At a basic level, the `Command` protocol consists of a single method named `invoke` that carries information about the user's request:

```swift
protocol Command: AnyObject {
    ...

    func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext)

    ...
}
```

The arguments each represent a part of the invocation context. Given a request such as `%commandname arg1 arg2`, the implementor would receive:

| Parameter | Value |
| --------- | ----- |
| `input` | `.text("arg1 arg2")` |
| `output` | `DiscordOutput` |
| `context` | `CommandContext` containing the message, the client and the command registry |

Since `output: any CommandOutput` represents a polymorphic object, the output of an invocation does not necessarily get sent to the Discord channel where the request originated from. For example, if the user creates a piped request such as `%first | second | third`, only the third command would operate on a `DiscordOutput`. Both the first and the second command call a `PipeOutput` instead that passes any values to the next command:

```swift
class PipeOutput: CommandOutput {
    private let sink: any Command
    private let context: CommandContext
    private let args: String
    private let next: (any CommandOutput)?

    init(withSink sink: any Command, context: CommandContext, args: String, next: (any CommandOutput)? = nil) {
        self.sink = sink
        self.args = args
        self.context = context
        self.next = next
    }

    func append(_ value: RichValue) {
        let nextInput = args.isEmpty ? value : (.text(args) + value)
        sink.invoke(with: nextInput, output: next ?? PrintOutput(), context: context)
    }
}
```

Often the `Command` protocol is too low-level to be adopted directly, since the input can be of any form (including embeds or images). To address this, there are subprotocols that provide a simpler template interface for implementors:

```swift
protocol StringCommand: Command {
    func invoke(with input: String, output: any CommandOutput, context: CommandContext)
}
```

`StringCommand` is useful when the command accepts a single string as an argument or if a custom argument parser is used. Its default implementation of `Command.invoke` passes either `args`, if not empty, or otherwise `input.content` to `StringCommand.invoke`.

```swift
protocol ArgCommand: Command {
    associatedtype Args: Arg

    var argPattern: Args { get }

    func invoke(withInputArgs inputArgs: [String], output: any CommandOutput, context: CommandContext)
}
```

`ArgCommand` should be adopted if the command expects a fixed structure of arguments.
