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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !timer.isRunning else {
            await output.append(errorText: "Animation is already running.")
            return
        }

        let frames = input.split(separator: " ")

        guard frames.count < 4 else {
            await output.append(errorText: "Too many frames.")
            return
        }

        guard let firstFrame = frames.first else {
            await output.append(errorText: "Cannot create empty animation.")
            return
        }

        let sink = context.sink!
        let channelId = context.channel!.id

        do {
            let sentMessage = try await sink.sendMessage(Message(content: String(firstFrame)), to: channelId)
            for i in 0..<(self.loops * frames.count) {
                let frame = String(frames[i % frames.count])
                try await sink.editMessage(sentMessage!.id!, on: channelId, content: frame)
            }
        } catch {
            await output.append(error, errorText: "Could not send/edit message")
        }
    }
}
