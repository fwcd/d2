import Foundation
import Logging
import D2MessageIO
import Utils
import Graphics
import GIF
import Dispatch

fileprivate let log = Logger(label: "D2Commands.MessageParser")

fileprivate let urlPattern = try! Regex(from: "<?(\\w+:[^>\\s]+)>?")

// The first group matches the language, the second group matches the code
fileprivate let codePattern = try! Regex(from: "`(?:``(?:(\\w*)\n)?)?([^`]+)`*")

fileprivate let idPattern = try! Regex(from: "\\d+")

/**
 * Parses Discord messages into rich values.
 */
public struct MessageParser {
    private let ndArrayParser = NDArrayParser()
    private let useExplicitMentions: Bool

    public init(useExplicitMentions: Bool = false) {
        self.useExplicitMentions = useExplicitMentions
    }

    /**
    * Asynchronously parses a string with its
    * parent message and downloads
    * the attachments of a message.
    */
    public func parse(
        _ str: String? = nil,
        message: Message? = nil,
        clientName: String? = nil,
        guild: Guild? = nil
    ) -> Promise<RichValue, Error> {
        Promise { then in
            var values: [RichValue] = []

            // Parse message content
            let content = str ?? message?.content ?? ""

            let textualContent = codePattern.replace(in: content, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !textualContent.isEmpty {
                values.append(.text(textualContent))
            }

            if let codeGroups = codePattern.firstGroups(in: content) {
                let language = codeGroups[1].nilIfEmpty
                let code = codeGroups[2]
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
                mentions += idPattern.allGroups(in: content)
                    .map { UserID($0[0], clientName: clientName ?? "Dummy") }
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
            if let urls = urlPattern.allGroups(in: content).compactMap({ URL(string: $0[1]) }).nilIfEmpty {
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
            var asyncTaskCount = 0
            let semaphore = DispatchSemaphore(value: 0)

            for attachment in message?.attachments ?? [] {
                let fileName = attachment.filename.lowercased()

                if fileName.hasSuffix(".png") {
                    // Download PNG attachment
                    asyncTaskCount += 1
                    attachment.download().listen {
                        do {
                            let data = try $0.get()
                            values.append(.image(try Image(fromPng: data)))
                        } catch {
                            log.error("\(error)")
                        }
                        semaphore.signal()
                    }
                } else if fileName.hasSuffix(".gif") {
                    // Download GIF attachment

                    // TODO: Implement animated GIF parser

                    // asyncTaskCount += 1
                    // attachment.download {
                    // 	do {
                    // 		let data = try $0.get()
                    // 		values.append(.gif(try GIF(from: data)))
                    // 	} catch {
                    // 		log.error("\(error)")
                    // 	}
                    // 	semaphore.signal()
                    // }
                }
            }

            DispatchQueue.global(qos: .userInitiated).async {
                // Return first once all asynchronous
                // tasks have been completed
                for _ in 0..<asyncTaskCount {
                    semaphore.wait()
                }

                log.debug("Parsed input: \(values)")
                then(.success(RichValue.of(values: values)))
            }
        }
    }
}
