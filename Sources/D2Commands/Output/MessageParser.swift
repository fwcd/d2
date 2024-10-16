import Foundation
import Logging
import D2MessageIO
import Utils
@preconcurrency import CairoGraphics
@preconcurrency import GIF
import Dispatch

fileprivate let log = Logger(label: "D2Commands.MessageParser")

nonisolated(unsafe) private let urlPattern = #/<?(\w+:[^>\s]+)>?/#
nonisolated(unsafe) private let codePattern = #/`(?:``(?:(?<language>\w*)\n)?)?(?<code>[^`]+)`*/#
nonisolated(unsafe) private let idPattern = #/\d+/#

/// Parses Discord messages into rich values.
public struct MessageParser {
    private let ndArrayParser = NDArrayParser()
    private let useExplicitMentions: Bool

    public init(useExplicitMentions: Bool = false) {
        self.useExplicitMentions = useExplicitMentions
    }

    /// Asynchronously parses a string with its
    /// parent message and downloads
    /// the attachments of a message.
    public func parse(
        _ str: String? = nil,
        message: Message? = nil,
        clientName: String? = nil,
        guild: Guild? = nil
    ) async -> RichValue {
        var values: [RichValue] = []

        // Parse message content
        let content = str ?? message?.content ?? ""

        let textualContent = content.replacing(codePattern, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !textualContent.isEmpty {
            values.append(.text(textualContent))
        }

        if let codeGroups = try? codePattern.firstMatch(in: content) {
            let language = codeGroups.language.map { String($0) }
            let code = String(codeGroups.code)
            values.append(.code(code, language: language))
        }

        // Append embeds
        values += message?.embeds.map { .embed($0) } ?? []

        // Append (explicit and implicit) mentions
        var mentions = [User]()

        if useExplicitMentions, let explicitMentions = message?.mentions.nilIfEmpty {
            // Note that explicit mentions don't count duplicates
            mentions += explicitMentions
        } else {
            mentions += content.matches(of: idPattern)
                .map { UserID(String($0.0), clientName: clientName ?? "Dummy") }
                .compactMap { guild?.members[$0]?.user }

            if content.contains("#") {
                mentions += guild?.members
                    .map { $0.1.user }
                    .filter { content.contains("\($0.username)#\($0.discriminator)") } ?? []
            }
        }

        if !mentions.isEmpty {
            values.append(.mentions(mentions))
        }

        // Append role mentions
        if let roleMentions = message?.mentionRoles.nilIfEmpty {
            values.append(.roleMentions(roleMentions))
        }

        // Append parsed URLs
        if let urls = content.matches(of: urlPattern).compactMap({ URL(string: String($0.1)) }).nilIfEmpty {
            values.append(.urls(urls))
        }

        // Parse nd-arrays
        if let ndArrays = ndArrayParser.parseMultiple(content).nilIfEmpty {
            values.append(.ndArrays(ndArrays))
        }

        // Fetch attachments
        if let attachments = message?.attachments.nilIfEmpty {
            values.append(.attachments(attachments))
        }

        // Download image attachments
        values += await withTaskGroup(of: RichValue.self) { group in
            for attachment in message?.attachments ?? [] {
                let fileName = attachment.filename.lowercased()

                if fileName.hasSuffix(".png") {
                    // Download PNG attachment
                    group.addTask {
                        do {
                            let data = try await attachment.download()
                            return .lazy(UncheckedSendable(.lazy {
                                do {
                                    return .image(try CairoImage(pngData: data))
                                } catch {
                                    log.error("Could not decode PNG: \(error)")
                                    return .none
                                }
                            }))
                        } catch {
                            log.error("Could not download PNG attachment: \(error)")
                            return .none
                        }
                    }
                } else if fileName.hasSuffix(".gif") {
                    // Download GIF attachment
                    group.addTask {
                        do {
                            let data = try await attachment.download()
                            return .lazy(UncheckedSendable(.lazy {
                                do {
                                    log.info("Decoding GIF...")
                                    return .gif(try GIF(data: data))
                                } catch {
                                    log.error("Could not parse GIF: \(error)")
                                    return .none
                                }
                            }))
                        } catch {
                            log.error("Could not download GIF attachment: \(error)")
                            return .none
                        }
                    }
                }
            }

            // Collect downloaded attachments
            var attachmentValues: [RichValue] = []
            for await value in group {
                attachmentValues.append(value)
            }

            return attachmentValues
        }

        log.debug("Parsed input: \(values)")
        return RichValue.of(values: values)
    }
}
