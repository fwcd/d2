import D2MessageIO
import D2Permissions
import Utils

public class CycleThroughCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Animates a sequence of characters",
        longDescription: "Creates a pseudo-animation by repeatedly editing the sent message",
        requiredPermissionLevel: .vip
    )
    private let loops = 4
    private let timer = RepeatingTimer(interval: .milliseconds(500))

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !timer.isRunning else {
            output.append(errorText: "Animation is already running.")
            return
        }

        let frames = input.split(separator: " ")

        guard frames.count < 4 else {
            output.append(errorText: "Too many frames.")
            return
        }

        guard let firstFrame = frames.first else {
            output.append(errorText: "Cannot create empty animation.")
            return
        }

        let client = context.client!
        let channelId = context.channel!.id

        client.sendMessage(Message(content: String(firstFrame)), to: channelId).listenOrLogError { sentMessage in
            self.timer.schedule(nTimes: self.loops * frames.count) { i, _ in
                let frame = String(frames[i % frames.count])
                client.editMessage(sentMessage!.id!, on: channelId, content: frame)
            }
        }
    }
}
