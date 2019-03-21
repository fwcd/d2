# D2
General-purpose virtual assistant for Discord.

## Installation

### on Linux
* Install the required system dependencies:
	* Swift 4.1
    * `sudo apt-get install libopus-dev libsodium-dev libssl1.0-dev`
* Create a file named `authkeys.swift` in `Sources/D2` containing the API keys:

```swift
let discordToken = "YOUR_DISCORD_API_TOKEN"
let mapQuestKey = "YOUR_MAP_QUEST_KEY"
```

* Create a file named `userwhitelist.swift` in `Sources/D2` containing a list of Discord usernames that have full permissions:

```swift
let whitelistedDiscordUsers = [
	"YOUR_DISCORD_TAG"
]
```

## Building
* `swift build`

## Running
* `swift run`
